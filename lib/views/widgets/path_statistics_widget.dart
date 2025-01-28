import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PathStatisticsWidget extends StatelessWidget {
  final double distance;
  final String period;
  const PathStatisticsWidget(
      {Key? key, required this.distance, required this.period})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            // height: 50.h,
            width: MediaQuery.of(context).size.width * .25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SectionBody(
                      text:
                          '   ${AppLocalizations.of(context)!.translate('total_co2')}',
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20.h,
                      width: 28.h,
                      child: SvgPicture.asset(
                        "assets/icons/orange/co2.svg",
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    BlocBuilder<LocaleCubit, LocaleState>(
                      builder: (context, localeState) {
                        return SectionBody(
                          text:
                              " ${((distance * 1700) / 1000000).toStringAsFixed(2)} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}",
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // SizedBox(
          //   height: 50.h,
          //   width: 3,
          //   child: const VerticalDivider(
          //     color: Colors.grey,
          //     thickness: 1,
          //     width: 1,
          //   ),
          // ),
          SizedBox(
            // height: 50.h,
            width: MediaQuery.of(context).size.width * .25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SectionBody(
                      text:
                          '   ${AppLocalizations.of(context)!.translate('distance')}',
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20.h,
                      width: 25.h,
                      child: SvgPicture.asset(
                          "assets/icons/orange/shipment_path.svg"),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    BlocBuilder<LocaleCubit, LocaleState>(
                      builder: (context, localeState) {
                        return SectionBody(
                          text:
                              "${distance.toStringAsFixed(2)} ${localeState.value.languageCode == 'en' ? "km" : "كم"}",
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // SizedBox(
          //   height: 50.h,
          //   width: 3,
          //   child: const VerticalDivider(
          //     color: Colors.grey,
          //     thickness: 1,
          //     width: 1,
          //   ),
          // ),
          SizedBox(
            // height: 50.h,
            width: MediaQuery.of(context).size.width * .36,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SectionBody(
                      text:
                          '   ${AppLocalizations.of(context)!.translate('period')}',
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20.h,
                      width: 25.h,
                      child: SvgPicture.asset("assets/icons/orange/time.svg"),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    BlocBuilder<LocaleCubit, LocaleState>(
                      builder: (context, localeState) {
                        return SizedBox(
                          // width: MediaQuery.of(context).size.width * .28,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SectionBody(
                              text:
                                  " ${localeState.value.languageCode == "en" ? period.replaceAll("hours", "h").replaceAll("hour", "h") : period.replaceAll("hours", "ساعة").replaceAll("hour", "ساعة").replaceAll("minutes", "دقيقة").replaceAll("minute", "دقيقة").replaceAll("mins", "دقيقة").replaceAll("min", "دقيقة")} ",
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
