import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:radio_skonto/core/extensions.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/constant.dart';
import 'package:radio_skonto/models/podcasts_model.dart';
import 'package:radio_skonto/providers/download_provider.dart';
import 'package:radio_skonto/widgets/download_routed_button.dart';
import 'package:radio_skonto/widgets/like_widget.dart';
import 'package:radio_skonto/widgets/round_button_with_icon.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../helpers/app_text_style.dart';

class VideoPodcastDetailScreen extends StatefulWidget {
  const VideoPodcastDetailScreen({super.key, required this.episode});

  final Episode episode;

  @override
  State<VideoPodcastDetailScreen> createState() => _VideoPodcastDetailScreenState();
}

class _VideoPodcastDetailScreenState extends State<VideoPodcastDetailScreen> {

  late VideoPlayerController _controller;
  late ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        apiBaseUrl + widget.episode.contentData.cards.first.videoUrl))
      ..initialize().then((_) {
        chewieController = ChewieController(
          videoPlayerController: _controller,
          autoPlay: false,
          looping: false,
        );
        setState(() {});
      });

  }

  @override
  void dispose() {
    _controller.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
        ),
        backgroundColor: AppColors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.hs,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Expanded(child: Text(widget.episode.title, style: AppTextStyles.main18bold, maxLines: 2),),
                  LikeWidget(onTap: () {}, color: AppColors.red.withAlpha(64))
                  ],
                ),
                25.hs,
                _controller.value.isInitialized ?
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Chewie(
                    controller: chewieController,
                  )

                  //VideoPlayer(_controller),
                ) : Container(
                  height: 200,
                  width: double.infinity,
                  color: AppColors.gray,
                  child: const Center(
                    child: Icon(Icons.video_camera_back_outlined, size: 50, color: AppColors.black,),
                  ),
                ),
                20.hs,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.episode.contentData.cards.isEmpty || widget.episode.contentData.cards.first.allowDownloading == false ?
                    const SizedBox() :
                    DownloadRoutedButtonWidget(size: 50, task: TaskInfo(name: widget.episode.contentData.cards.first.video, link: apiBaseUrl +  widget.episode.contentData.cards.first.video)),
                    10.ws,
                    RoutedButtonWithIconWidget(iconName: 'assets/icons/shared_video.svg',
                      iconColor: AppColors.darkBlack,
                      size: 50,
                      onTap: () {
                        Share.share(apiBaseUrl + widget.episode.contentData.cards.first.video);
                      },
                      color: AppColors.gray, iconSize: 20,
                    ),
                  ],
                ),
                20.hs,
                Text(widget.episode.description, style: AppTextStyles.main14regular),
                120.hs
              ],
            ),
          ),
        )
    );
  }
}



