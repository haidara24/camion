import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ShipmentPathVerticalWidget extends StatelessWidget {
  final List<PathPoint> pathpoints;
  final DateTime pickupDate;
  final DateTime deliveryDate;
  final String langCode;
  final bool mini;
  const ShipmentPathVerticalWidget({
    Key? key,
    required this.pathpoints,
    required this.pickupDate,
    required this.deliveryDate,
    required this.langCode,
    required this.mini,
  }) : super(key: key);

  String setLoadDate(DateTime date, String lang) {
    List months = [
      'jan',
      'feb',
      'mar',
      'april',
      'may',
      'jun',
      'july',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec'
    ];

    List monthsAr = [
      'كانون الثاني',
      'شباط',
      'أذار',
      'نيسان',
      'أيار',
      'حزيران',
      'تموز',
      'آب',
      'أيلول',
      'تشرين الأول',
      'تشرين الثاني',
      'كانون الأول'
    ];
    var mon = date.month;
    var month = lang == "en" ? months[mon - 1] : monthsAr[mon - 1];
    return '${date.day}-$month-${date.year}';
  }

  List<Widget> stoppoints(BuildContext context) {
    List<Widget> list = [];

    for (var element in pathpoints) {
      if (element.pointType == "P") {
        list.add(
          SizedBox(
            height: 65,
            child: TimelineTile(
              isLast: false,
              isFirst: true,
              // alignment: TimelineAlign.center,
              beforeLineStyle: LineStyle(
                color: AppColor.deepYellow,
              ),
              indicatorStyle: IndicatorStyle(
                width: 17,
                color: AppColor.deepYellow,
                iconStyle: IconStyle(
                  iconData: Icons.circle_sharp,
                  color: AppColor.deepYellow,
                  fontSize: 15,
                ),
              ),
              // afterLineStyle: LineStyle(),
              alignment: TimelineAlign.manual,
              lineXY: .3,
              startChild: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${AppLocalizations.of(context)!.translate('pickup_address')} \n${setLoadDate(deliveryDate, langCode)}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              endChild: Text(
                "  ${element.name!}",
                style: const TextStyle(
                  fontSize: 18,
                  // fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              // startChild: Text(
              //   setLoadDate(pickupDate),
              //   style: const TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.black,
              //   ),
              // ),
            ),
          ),
        );
      }
    }

    for (var element in pathpoints) {
      if (element.pointType == "S" && !mini) {
        list.add(
          SizedBox(
            height: 65,
            child: TimelineTile(
              isLast: false,
              isFirst: false,
              beforeLineStyle: LineStyle(
                color: AppColor.deepYellow,
              ),
              indicatorStyle: IndicatorStyle(
                width: 17,
                color: AppColor.deepYellow,
                iconStyle: IconStyle(
                  iconData: Icons.circle_sharp,
                  color: AppColor.deepYellow,
                  fontSize: 15,
                ),
              ),
              alignment: TimelineAlign.manual,
              lineXY: .3,
              endChild: Text(
                "  ${element.name!}",
                style: const TextStyle(
                  fontSize: 18,
                  // fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      }
    }

    for (var element in pathpoints) {
      if (element.pointType == "D") {
        list.add(
          SizedBox(
            height: 65,
            child: TimelineTile(
              isLast: true,
              isFirst: false,
              // alignment: TimelineAlign.center,
              beforeLineStyle: LineStyle(
                color: AppColor.deepYellow,
              ),
              indicatorStyle: IndicatorStyle(
                width: 17,
                color: AppColor.deepYellow,
                iconStyle: IconStyle(
                  iconData: Icons.circle_sharp,
                  color: AppColor.deepYellow,
                  fontSize: 15,
                ),
              ),
              alignment: TimelineAlign.manual,
              lineXY: .3,
              startChild: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${AppLocalizations.of(context)!.translate('delivery_address')} ',
                  style: TextStyle(
                    fontSize: 15.sp,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              endChild: Text(
                "  ${element.name!}",
                style: const TextStyle(
                  fontSize: 18,
                  // fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              // startChild: Text(
              //   setLoadDate(deliveryDate),
              //   style: const TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.black,
              //   ),
              // ),
            ),
          ),
        );
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stoppoints(context),
    );
  }
}
