import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/constant.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/models/interview_model.dart';
import 'package:radio_skonto/models/main_screen_data.dart';
import 'package:radio_skonto/providers/detail_provider.dart';
import 'package:radio_skonto/providers/main_screen_provider.dart';
import 'package:radio_skonto/providers/player_provider.dart';
import 'package:radio_skonto/screens/home_screen/ad/ad_horisontal_list_widget.dart';
import 'package:radio_skonto/screens/home_screen/ad/contests_horisontal_list_widget.dart';
import 'package:radio_skonto/screens/home_screen/ad/one_image_banner_widget.dart';
import 'package:radio_skonto/screens/home_screen/cell_first_main_big.dart';
import 'package:radio_skonto/screens/home_screen/cells/connection_cell.dart';
import 'package:radio_skonto/screens/home_screen/cells/social_media_cell.dart';
import 'package:radio_skonto/screens/home_screen/horisontal_list_widget.dart';
import 'package:radio_skonto/screens/podcasts_screen/podcasts_detail.dart';
import 'package:radio_skonto/screens/podcasts_screen/podcasts_screen.dart';

class HomeScreenMainViewWidget extends StatelessWidget {
  const HomeScreenMainViewWidget({super.key, required this.scrollController, required this.mainData, required this.mainScreenProvider});

  final ScrollController scrollController;
  final MainData mainData;
  final MainScreenProvider mainScreenProvider;

  static const _backgroundLoungeFm = 'assets/image/LOUNGE_FM.png';
  static const _backgroundSconto = 'assets/image/RADIO_SKONTO.png';
  static const _backgroundScontoPlus= 'assets/image/RADIO_SKONTO_PLUS.png';
  static const _backgroundTev = 'assets/image/RADIO_TEV.png';
  static const _backgroundTevLv = 'assets/image/TEV_LV.png';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        controller: scrollController,
        child: Stack(
          children: [
            Positioned(
                top: 0,
                child: Container(
                  color: AppColors.red,
                  child: Image.asset(
                    mainData.name == 'RADIO SKONTO' ? _backgroundSconto :
                    mainData.name == 'SKONTO PLUS' ? _backgroundScontoPlus :
                    mainData.name == 'RADIO TEV' ? _backgroundTev :
                    mainData.name == 'LOUNGE FM' ? _backgroundLoungeFm :
                    mainData.name == 'TEV LV' ? _backgroundTevLv : _backgroundSconto,
                    fit: BoxFit.fill,
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height,
                  ),
                )
            ),
            ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 15,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const SizedBox(height: 200,);
                  }
                  if (index == 1) {
                    return CellFirstMainBig(isExpanded: true, data: mainData);
                  }
                  if (index == 2) {
                    return ConnectionCellWidget(mainData: mainData);
                  }
                  if (index == 3) {
                    return HorizontalListWidget(type: MainScreenCellType.news, mainData: mainData,
                      onItemTap: (int index) {
                        String url = apiBaseUrl + mainData.news![index].url;
                        Singleton.instance.openUrl(url, context);
                      },
                      onSeeMoreTap: () {
                        String langCode = Singleton.instance.getCurrentLanguageName();
                        Singleton.instance.openUrl(
                            langCode == 'en' ?
                            '$apiBaseUrl/en/news':
                            langCode == 'ru' ?
                            '$apiBaseUrl/ru/news' :
                            '$apiBaseUrl/lv/jaunumi',
                            context);
                      },);
                  }
                  if (index == 4) {
                    return AdHorizontalListWidget(
                      banners: mainScreenProvider.mainScreenData.banners,
                    );
                  }
                  if (index == 5) {
                    return HorizontalListWidget(type: MainScreenCellType.playlist, mainData: mainData,
                      onItemTap: (int index) {
                        mainScreenProvider.switchToDataByPlaylistId(mainData.playlists![index].id);
                      },
                      onSeeMoreTap: () {
                        context.read<PlayerProvider>().switchToTabBarItem(2);
                      },);
                  }
                  if (index == 6) {
                    return OneImageBannerWidget(banners: mainScreenProvider.mainScreenData.banners, padding: 24);
                  }
                  if (index == 7) {
                    return HorizontalListWidget(type: MainScreenCellType.audio, mainData: mainData,
                      onItemTap: (int index) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PodcastDetailScreen(podcast: mainData.audioPodcasts![index]),
                            fullscreenDialog: true
                        ));
                      },
                      onSeeMoreTap: () {
                        context.read<PlayerProvider>().switchToTabBarItem(1);
                        podcastsBarKey.currentState?.animateTo(0);
                      },);
                  }
                  if (index == 8 && mainData.contests != null && mainData.contests!.isNotEmpty) {
                    return ContestListWidget(contest: mainData.contests!);
                  }
                  if (index == 9) {
                    return HorizontalListWidget(type: MainScreenCellType.video, mainData: mainData,
                      onItemTap: (int index) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PodcastDetailScreen(podcast: mainData.videoPodcasts![index]),
                            fullscreenDialog: true
                        ));
                      },
                      onSeeMoreTap: () {
                        context.read<PlayerProvider>().switchToTabBarItem(1);
                        podcastsBarKey.currentState?.animateTo(1);
                      },);
                  }
                  if (index == 10) {
                    return HorizontalListWidget(type: MainScreenCellType.interview, mainData: mainData,
                      onItemTap: (int index) {
                        InterviewData interview = mainData.interviews![index];
                        context.read<DetailProvider>().openMediaDetail(interview, context);
                      },
                      onSeeMoreTap: () {
                        context.read<PlayerProvider>().switchToTabBarItem(1);
                        podcastsBarKey.currentState?.animateTo(2);
                      },);
                  }
                  if (index == 11) {
                    return SocialMediaCellWidget(mainData: mainData);
                  }
                  if (index == 12) {
                    return Container(height: 130, width: 600, color: AppColors.white,);
                  }
                  return const SizedBox();
                }
            ),
            // Container(
            //   margin: const EdgeInsets.only(top: 600),
            //   width: double.infinity,
            //   height: 2200,
            //   color: AppColors.white,
            // ),
          ],
        )
    );
  }
}