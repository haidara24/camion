import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/data/models/post_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String diffText;
  final bool isVisible;
  final VoidCallback onVisibilityToggle;
  final Duration playDuration;
  final String languageCode;

  const PostCard({
    Key? key,
    required this.post,
    required this.diffText,
    required this.isVisible,
    required this.onVisibilityToggle,
    required this.playDuration,
    required this.languageCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.network(
            post.image!,
            height: 225.h,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 225.h,
                width: double.infinity,
                color: Colors.grey[300],
                child: Center(
                  child: Text(AppLocalizations.of(context)!
                      .translate('image_load_error')),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                enabled: true,
                child: Container(
                  height: 225.h,
                  width: double.infinity,
                  color: Colors.white,
                ),
              );
            },
          )
              .animate(delay: 400.ms)
              .shimmer(duration: playDuration - 200.ms)
              .flip(),
          SizedBox(height: 7.h),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diffText,
                  style: const TextStyle(color: Colors.grey),
                )
                    .animate()
                    .fadeIn(
                        duration: 300.ms,
                        delay: playDuration,
                        curve: Curves.decelerate)
                    .slideX(begin: 0.2, end: 0),
                Text(
                  languageCode == 'en' ? post.title! : post.titleAr!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                )
                    .animate()
                    .fadeIn(
                        duration: 300.ms,
                        delay: playDuration,
                        curve: Curves.decelerate)
                    .slideX(begin: 0.2, end: 0),
                Text("${AppLocalizations.of(context)!.translate('source')}: ${post.source!}")
                    .animate()
                    .scaleXY(
                        begin: 0,
                        end: 1,
                        delay: 300.ms,
                        duration: playDuration - 100.ms,
                        curve: Curves.decelerate),
                Visibility(
                  visible: isVisible,
                  child: Column(
                    children: [
                      const Divider(),
                      Text(
                        languageCode == 'en' ? post.content! : post.contentAr!,
                        maxLines: 1000,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: onVisibilityToggle,
                      child: Text(
                        AppLocalizations.of(context)!
                            .translate(isVisible ? 'read_less' : 'read_more'),
                        style: TextStyle(
                          color: AppColor.deepYellow,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    ).animate().slideX(
        duration: 200.ms,
        delay: 0.ms,
        begin: 1,
        end: 0,
        curve: Curves.easeInOutSine);
  }
}
