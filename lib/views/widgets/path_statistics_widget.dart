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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          // height: 50.h,
          width: MediaQuery.of(context).size.width * .3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SectionBody(
                        text: AppLocalizations.of(context)!
                            .translate('total_co2'),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
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
                            " ${(distance * 1700) / 1000000} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}",
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50.h,
          child: const VerticalDivider(
            color: Colors.grey,
            thickness: 1,
            width: 1,
          ),
        ),
        SizedBox(
          // height: 50.h,
          width: MediaQuery.of(context).size.width * .25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SectionBody(
                    text: AppLocalizations.of(context)!.translate('distance'),
                  ),
                ],
              ),
              Row(
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
                            " $distance ${localeState.value.languageCode == 'en' ? "km" : "كم"}",
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50.h,
          child: const VerticalDivider(
            color: Colors.grey,
            thickness: 1,
            width: 1,
          ),
        ),
        SizedBox(
          // height: 50.h,
          width: MediaQuery.of(context).size.width * .35,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SectionBody(
                    text: AppLocalizations.of(context)!.translate('period'),
                  ),
                ],
              ),
              Row(
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
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SectionBody(
                          text:
                              " ${localeState.value.languageCode == "en" ? period : period.replaceAll("hours", "ساعة").replaceAll("hour", "ساعة").replaceAll("mins", "دقيقة").replaceAll("min", "دقيقة")} ",
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
    );
  }
}
