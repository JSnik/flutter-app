import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/app_text_style.dart';
import 'package:radio_skonto/helpers/constant.dart';
import 'package:radio_skonto/models/interview_model.dart';
import 'package:radio_skonto/providers/download_provider.dart';
import 'package:radio_skonto/widgets/download_routed_button.dart';
import 'package:radio_skonto/widgets/errorImageWidget.dart';
import 'package:radio_skonto/widgets/placeholderImageWidget.dart';
import 'package:radio_skonto/widgets/round_button_with_icon.dart';

class InterviewListCell extends StatelessWidget {
  const InterviewListCell({super.key, required this.interviewData, required this.onTap,});

  final InterviewData interviewData;
  final Function(InterviewData interviewData) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          onTap(interviewData);
        },
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: SizedBox(
              height: 70,
              child: Row(
                children: [
                  SizedBox(width: 70, height: 70,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: apiBaseUrl+interviewData.image,
                          placeholder: (context, url) => const PlaceholderImageWidget(),
                          errorWidget: (context, url, error) => const ErrorImageWidget(),
                        )
                    ),
                  ),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(interviewData.title, style: AppTextStyles.main12bold),
                      ],
                    ),
                  )
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RoutedButtonWithIconWidget(iconName: 'assets/icons/heart_for_button_icon.svg',
                        iconColor: AppColors.darkBlack,
                        size: 32,
                        onTap: () {

                        },
                        color: AppColors.gray, iconSize: 15,
                      ),
                      interviewData.contentData.cards.isEmpty ||  interviewData.contentData.cards.first.allowDownloading == false ?
                      const SizedBox() :
                      DownloadRoutedButtonWidget(task: TaskInfo(name: interviewData.contentData.cards.first.audioFile, link: apiBaseUrl + interviewData.contentData.cards.first.audioFile!),)
                    ],
                  )

                ],
              ),
            ),
          ),
        )
    );
  }
}