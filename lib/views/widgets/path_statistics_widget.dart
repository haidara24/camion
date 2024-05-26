import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
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
                    height: 25.h,
                    width: 25.h,
                    child: SvgPicture.asset("assets/icons/co2fingerprint.svg"),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppLocalizations.of(context)!.translate('total_co2'),
                        style: TextStyle(
                          // color: Colors.grey,
                          fontSize: 17.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  BlocBuilder<LocaleCubit, LocaleState>(
                    builder: (context, localeState) {
                      return SizedBox(
                        child: Text(
                          " ${(distance * 1700) / 1000000} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}",
                          style: TextStyle(
                            // color: Colors.white,
                            fontSize: 17.sp,
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
        SizedBox(
          height: 50.h,
          child: VerticalDivider(
            color: Colors.grey,
            thickness: 1,
            width: 1,
          ),
        ),
        SizedBox(
          // height: 50.h,
          width: MediaQuery.of(context).size.width * .3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 25.h,
                    width: 25.h,
                    child: SvgPicture.asset("assets/icons/distance.svg"),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate('distance'),
                    style: TextStyle(
                      // color: Colors.grey,
                      fontSize: 17.sp,
                    ),
                  ),
                ],
              ),
              BlocBuilder<LocaleCubit, LocaleState>(
                builder: (context, localeState) {
                  return SizedBox(
                    child: Text(
                      " $distance ${localeState.value.languageCode == 'en' ? "km" : "كم"}",
                      style: TextStyle(
                        // color: Colors.white,
                        fontSize: 17.sp,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50.h,
          child: VerticalDivider(
            color: Colors.grey,
            thickness: 1,
            width: 1,
          ),
        ),
        SizedBox(
          // height: 50.h,
          width: MediaQuery.of(context).size.width * .3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 25.h,
                    width: 25.h,
                    child: SvgPicture.asset("assets/icons/time.svg"),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate('period'),
                    style: TextStyle(
                      // color: Colors.grey,
                      fontSize: 17.sp,
                    ),
                  ),
                ],
              ),
              BlocBuilder<LocaleCubit, LocaleState>(
                builder: (context, localeState) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      " ${localeState.value.languageCode == "en" ? period : period.replaceAll("hours", "ساعة").replaceAll("hour", "ساعة").replaceAll("mins", "دقيقة").replaceAll("min", "دقيقة")} ",
                      style: TextStyle(
                        // color: Colors.white,
                        fontSize: 17.sp,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
