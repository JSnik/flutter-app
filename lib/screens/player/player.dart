import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radio_skonto/core/extensions.dart';
import 'package:radio_skonto/custom_library/custom_scroll_snap_list.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/app_text_style.dart';
import 'package:radio_skonto/helpers/constant.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/providers/player_provider.dart';
import 'package:radio_skonto/screens/player/page_view.dart';
import 'package:radio_skonto/screens/player/player_bar.dart';
import 'package:radio_skonto/screens/player/scroll_physics.dart';
import 'package:radio_skonto/screens/player_helpers/audio_player_handler_impl.dart';
import 'package:radio_skonto/screens/player_helpers/queue_state.dart';
import 'package:styled_text/styled_text.dart';

bool isScroll = true;

class AppPlayer extends StatefulWidget {
  final heightTop = 36.0;
  final AnimationController animationController;
  final int? index;
  final List<dynamic>? playlist;

  const AppPlayer({
    super.key,
    required this.animationController,
    required this.index,
    required this.playlist,
  });

  @override
  State<StatefulWidget> createState() => _AppPlayerState();
}

class _AppPlayerState extends State<AppPlayer> {
  PageController _pageController = PageController();
  late AudioPlayer _audioPlayer;
  StreamSubscription? connectivitySubscription;
  final AudioPlayerHandler audioHandler = Singleton.instance.audioHandler;
  int _focusedIndex = 0;
  ScrollController listController = ScrollController();

  @override
  void initState() {
    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
          if (result.last == ConnectivityResult.none) {
            context.read<PlayerProvider>().playerStop();
          }
        });

    widget.animationController.addListener(() {
      setPhysics(widget.animationController.value);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(20);
    return PopScope(
      onPopInvoked: (status) {
        context.read<PlayerProvider>().checkMiniPlayerStatus();
      },
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = MediaQuery.of(context).size.width;
            return SingleChildScrollView(
              physics: const ClampScrollPhysics(),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.darkBlack,
                  borderRadius:
                  BorderRadius.only(topRight: radius, topLeft: radius),
                ),
                child: StreamBuilder<MediaItem?>(
                  stream: audioHandler.mediaItem,
                  builder: (context, snapshot) {
                    final mediaItem = snapshot.data;
                    if (mediaItem == null) return const SizedBox();
                    return StreamBuilder<QueueState>(
                      stream: audioHandler.queueState,
                      builder: (context2, snapshot2) {
                        final queueState = snapshot2.data ?? QueueState.empty;
                        final queue = queueState.queue;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: children(width, 200, mediaItem, queue, audioHandler),
                        );
                      }
                      );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  children(double width, double height, MediaItem mediaItem, List<MediaItem> mediaList, AudioPlayerHandler audioHandler) {
    final title = mediaItem.displaySubtitle?? '';
    var subtitle = mediaItem.title?? '';
    final body = mediaItem.displayDescription?? '';

    if (title == subtitle) {
      subtitle = '';
    }

    //TODO
    mediaList = mediaList + mediaList + mediaList;

     var screenH = MediaQuery.of(context).size.height;

    final style =
    AppTextStyles.main14regular.copyWith(color: AppColors.white);
    return [
      PlayerMainImage(imageUrl: mediaItem.artUri.toString() == '' ?
      'https://farm4.staticflickr.com/3224/3081748027_0ee3d59fea_z_d.jpg' :
      mediaItem.artUri.toString()),
      Container(
        //height: window.screen!.height!.toDouble(),
        color: AppColors.darkBlack,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: AppTextStyles.main18bold.copyWith(
                  color: AppColors.white, overflow: TextOverflow.ellipsis),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTextStyles.main16regular.copyWith(
                  color: AppColors.white, overflow: TextOverflow.ellipsis),
            ),
            10.hs,
            AppPlayerBar(audioHandler: audioHandler, author: subtitle, title: title),
            mediaList.isEmpty ? const SizedBox() :
            30.hs,
            Container(
              height: 50,
              //width: double.infinity,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        listController.animateTo(listController.position.pixels - 80.0, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                      },
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.white,),
                  ),
                  Expanded(child: CustomScrollSnapList(
                    //curve: Curves.easeInCirc,
                    listController: listController,
                    onItemFocus: _onItemFocus,
                    itemSize: 80,
                    itemBuilder: (context, index, size) {
                      return _buildListItem(context, index, mediaList);
                    },
                    itemCount: mediaList.length,
                    dynamicItemSize: true,
                    // dynamicSizeEquation: customEquation, //optional
                  ),
                  ),
                  IconButton(
                    onPressed: () {
                      listController.animateTo(listController.position.pixels + 80.0, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                    },
                    icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.white,),
                  ),
                ],
              ),
            ),
            50.hs
          ],
        ),
      ),
      Padding(
        padding: App.edgeInsets,
        child: StyledText(text: body, style: AppTextStyles.main16regular.copyWith(color: AppColors.white)),
        // MarkdownBody(
        //   data: body,
        //   styleSheet: MarkdownStyleSheet(
        //     a: const TextStyle(
        //         decoration: TextDecoration.underline, color: Colors.white),
        //     p: style,
        //     code: style,
        //   ),
        //   onTapLink: (text, url, title) async {
        //     if (url != null) {
        //       Singleton.instance.openUrl(url, context);
        //     }
        //   },
        // ),
      ),
      32.hs,
    ];
  }

  void _onItemFocus(int index) {
    setState(() {
      _focusedIndex = index;
    });
  }

  Widget _buildListItem(BuildContext context, int index, List<MediaItem> mediaList) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            height: 50,
            width: 80,
            child: Center(
              child: Image.asset(
                'assets/image/skonto_logo_for_radio_list.png',
                color: _focusedIndex == index ? null :  Colors.white70,
              ),
            ),
          )
        ],
      ),
    );
  }

  setPhysics(double value) {
    if (value == 1.0) {
      if (isScroll == true) {
        isScroll = false;
      }
    } else if (value != 1.0) {
      if (isScroll == false) {
        isScroll = true;
      }
    }
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    //_audioPlayer.playerStateStream.drain();
    //_audioPlayer.sequenceStateStream.drain();
    widget.animationController.dispose();
    _pageController.dispose();

    super.dispose();
  }

}
