import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart' as ics;
import 'package:provider/provider.dart';
import 'package:radio_skonto/custom_library/custom_app_slider.dart';
import 'package:radio_skonto/helpers/api_helper.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/models/main_screen_data.dart';
import 'package:radio_skonto/providers/main_screen_provider.dart';
import 'package:radio_skonto/providers/player_provider.dart';
import 'package:radio_skonto/screens/home_screen/ad/popup_banner_widget.dart';
import 'package:radio_skonto/screens/home_screen/app_bar/app_bar_main_screen.dart';
import 'package:radio_skonto/screens/home_screen/home_screen_main_view.dart';
import 'package:radio_skonto/widgets/no_internet_widget.dart';
import 'package:radio_skonto/widgets/progress_indicator_widget.dart';
import 'package:infinity_page_view_astro/infinity_page_view_astro.dart' as infPage;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool internetIsAvailable = true;
  bool appBarIsExpanded = true;
  late MainData mainData;
  bool firstStart = false;
  bool _internetOnFirstStart = false;
  bool _internetOffFirstStart = false;
  final ics.InfiniteScrollController tabBarPageController = ics.InfiniteScrollController();
  final infPage.InfinityPageController mainCellPageController = infPage.InfinityPageController();

  @override
  void initState() {
    super.initState();

    final listener = InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          if (_internetOnFirstStart == true) {
            Provider.of<PlayerProvider>(context, listen: false).setInternetIsAvailableItems(context);
            internetIsAvailable = true;
            setState(() {});
          } else {
            _internetOnFirstStart = true;
          }
          break;
        case InternetStatus.disconnected:
          if (_internetOffFirstStart == true) {
            Provider.of<PlayerProvider>(context, listen: false).setNoInternetItems();
            internetIsAvailable = false;
            setState(() {});
          } else {
            _internetOffFirstStart = true;
          }
          break;
      }
    });

    // subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
    //   if (result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi)) {
    //     Provider.of<PlayerProvider>(context, listen: false).setInternetIsAvailableItems();
    //     internetIsAvailable = true;
    //   } else {
    //     Provider.of<PlayerProvider>(context, listen: false).setNoInternetItems();
    //     internetIsAvailable = false;
    //   }
    //   setState(() {
    //   });
    // });
  }

  _openAppBar() {
    if (appBarIsExpanded == false) {
      setState(() {
        appBarIsExpanded = true;
      });
    }
  }

  _closeAppBar() {
    if (appBarIsExpanded == true) {
      setState(() {
        appBarIsExpanded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        //print(scrollNotification);
        if (scrollNotification.depth == 1) {
          if (scrollNotification is ScrollStartNotification) {
            if (scrollNotification.metrics.extentBefore > 20) {
              _closeAppBar();
            } else {
              _openAppBar();
            }
          } else if (scrollNotification is ScrollUpdateNotification) {
            if (scrollNotification.metrics.extentBefore > 20) {
              _closeAppBar();
            } else {
              _openAppBar();
            }
          } else if (scrollNotification is ScrollEndNotification) {
            if (scrollNotification.metrics.extentBefore > 20) {
              _closeAppBar();
            } else {
              _openAppBar();
            }
          }
        }
        return true;
      },
      child: ChangeNotifierProvider.value(
          value: Provider.of<MainScreenProvider>(context),
          child: Consumer<MainScreenProvider>(builder: (context, mainScreenProvider, _) {
            if (Singleton.instance.needToPlayFirstRadioStationOnStartApp == true && mainScreenProvider.mainScreenData.data.isNotEmpty) {
              Singleton.instance.needToPlayFirstRadioStationOnStartApp = false;
              Provider.of<PlayerProvider>(context, listen: false).playAllTypeMedia(mainScreenProvider.mainScreenData.data, 0, '', '');
            }
            if (mainScreenProvider.mainScreenData.data.isNotEmpty) {
              mainData = mainScreenProvider.mainScreenData.data[mainScreenProvider.currentSelectedDataIndex];
              _showPopupBanner(context, mainScreenProvider.mainScreenData);
            }

            List<HomeScreenMainViewWidget> pageViewListWidgets = [];
            for (MainData mData in mainScreenProvider.mainScreenData.data) {
              pageViewListWidgets.add(HomeScreenMainViewWidget(
                  scrollController: mainScreenProvider.scrollControllerHomeScreen,
                  mainData: mData,
                  mainScreenProvider: mainScreenProvider));
            }

            return mainScreenProvider.getMainScreenDataResponseState == ResponseState.stateLoading || mainScreenProvider.mainScreenData.data.isEmpty ?
            AppProgressIndicatorWidget(
              responseState: mainScreenProvider.getMainScreenDataResponseState,
              onRefresh: () {
                mainScreenProvider.getMainScreenData(false, context);
              },
            ) :
            Stack(
              children: [
                CustomCarouselSlider(
                  key: const ValueKey<int>(8978665),
                  disableGesture: false,
                  carouselController: context.read<PlayerProvider>().carouselSliderControllerMainCell,
                  options: CarouselOptions(
                    scrollPhysics: appBarIsExpanded ? null : const NeverScrollableScrollPhysics(),
                      height: 5000,
                      viewportFraction: 1,
                      disableCenter: false,
                      initialPage: 0,
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      onScrolled: (scrollDouble) {

                      },
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        if (appBarIsExpanded == true) {
                          context.read<PlayerProvider>().carouselSliderControllerAppBar.animateToPage(index, duration: const Duration(milliseconds: 300));
                        }
                      }
                  ),
                  items: List.generate(mainScreenProvider.mainScreenData.data.length, ((index) {
                    return pageViewListWidgets[index];
                  })),
                ),

                // infPage.InfinityPageView(
                //     physics: appBarIsExpanded ? null : const NeverScrollableScrollPhysics(),
                //     controller: mainCellPageController,
                //     itemCount: mainScreenProvider.mainScreenData.data.length,
                //     onPageChanged: (int index) {
                //       print(index);
                //       context.read<PlayerProvider>().carouselSliderController.animateToPage(index, duration: const Duration(milliseconds: 300));
                //     },
                //     itemBuilder: (BuildContext context, int index){
                //       return pageViewListWidgets[index];
                //     }
                // ),
                SafeArea(bottom: false, child: Column(
                  children: [
                    AppBarMainScreenWidget(
                      data: mainScreenProvider.mainScreenData.data.first,
                      onRadioIconTap: (index) {
                        //_closeAppBar();
                        if (index != null) {
                          mainScreenProvider.setCurrentDataIndex(index);
                          context.read<PlayerProvider>().carouselSliderControllerAppBar.animateToPage(index, duration: const Duration(milliseconds: 300));
                          //mainCellPageController.pageController.nextPage(duration:  const Duration(milliseconds: 300), curve: Curves.easeIn);
                          //mainCellPageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                        }
                      },
                      mainDataList: mainScreenProvider.mainScreenData.data,
                      appBarIsExpanded: appBarIsExpanded,
                      onItemFocus: (index) {
                        context.read<PlayerProvider>().carouselSliderControllerMainCell.animateToPage(index, duration: const Duration(milliseconds: 300));
                        //appBarIsExpanded = false;
                       // mainCellPageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                        //_pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                        mainScreenProvider.setCurrentDataIndex(index);
                        context.read<PlayerProvider>().playAllTypeMedia(mainScreenProvider.mainScreenData.data, index, '', '');
                      },
                      currentSelectedDataIndex: mainScreenProvider.currentSelectedDataIndex,
                      controller: tabBarPageController,
                      carouselSliderController: context.read<PlayerProvider>().carouselSliderControllerAppBar,),
                    Expanded(
                        child: Stack(
                          children: [
                            // CustomCarouselSlider(
                            //   key: const ValueKey<int>(8767665),
                            //   disableGesture: false,
                            //   carouselController: context.read<PlayerProvider>().carouselSliderController,
                            //   options: CarouselOptions(
                            //       viewportFraction: 1.2,
                            //       disableCenter: false,
                            //       initialPage: 0,
                            //       enlargeStrategy: CenterPageEnlargeStrategy.height,
                            //       enlargeCenterPage: true,
                            //       onPageChanged: (index, reason) {
                            //         Future.delayed(const Duration(milliseconds: 250), () {
                            //           //onItemFocus(index);
                            //         });
                            //       }
                            //   ),
                            //   items: List.generate(mainScreenProvider.mainScreenData.data.length, ((index) {
                            //     return GestureDetector(
                            //       onTap: () {
                            //         //onRadioIconTap(index);
                            //       },
                            //       child: Expanded(child: pageViewListWidgets[index],) ,
                            //     );
                            //   })),
                            // ),


                            // infPage.InfinityPageView(
                            //     physics: appBarIsExpanded ? null : const NeverScrollableScrollPhysics(),
                            //     controller: mainCellPageController,
                            //     itemCount: mainScreenProvider.mainScreenData.data.length,
                            //     onPageChanged: (int index) {
                            //       print(index);
                            //       context.read<PlayerProvider>().carouselSliderController.animateToPage(index, duration: const Duration(milliseconds: 300));
                            //     },
                            //     itemBuilder: (BuildContext context, int index){
                            //       return pageViewListWidgets[index];
                            //     }
                            // ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 1000),
                              child: internetIsAvailable ? const SizedBox.shrink() : const NoInternetWidget(),
                            ),
                          ],
                        )
                    )
                  ],
                ))
              ],
            );
          })),
    );
  }

  void _showPopupBanner(BuildContext cont, MainScreenData mainScreenData) {
    bool needToShowByTime = true;
    if (mainScreenData.banners.isNotEmpty) {
      final lastBannerShowTimeString = Singleton.instance.getTimeWhenBannerIsShowFromSharedPreferences();
      if (lastBannerShowTimeString != '') {
        DateTime lastBannerShowTime = DateTime.parse(lastBannerShowTimeString);
        DateTime nowDay = DateTime.now();
        if (lastBannerShowTime.day == nowDay.day && lastBannerShowTime.month == nowDay.month) {
          needToShowByTime = false;
        }
      }
      bool needShowBanner = false;
      late AdBanner bannerToShow;
      for (var banner in mainScreenData.banners) {
        if (banner.type == 'banner_popup_mobile') {
          needShowBanner = true;
          bannerToShow = banner;
          break;
        }
      }
      if (needShowBanner == true && needToShowByTime == true) {
        Singleton.instance.writePopupBannerIdToSharedPreferences(bannerToShow.id.toString());
        Singleton.instance.writeTimeWhenBannerIsShowToSharedPreferences();
        Future.delayed(const Duration(seconds: 7), () {
          showDialog(context: cont, builder: (BuildContext context) {
            return PopupBannerWidget(banner: bannerToShow);
          });
        });
      }
    }
  }
}
