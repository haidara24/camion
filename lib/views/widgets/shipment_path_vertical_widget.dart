import 'package:camion/constants/text_constants.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
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
    var mon = date.month;
    var month = lang == "en"
        ? TextConstants.monthsEn[mon - 1]
        : TextConstants.monthsAr[mon - 1];

    // Determine AM/PM
    String period = date.hour >= 12
        ? (lang == "en" ? 'PM' : 'م')
        : (lang == "en" ? 'AM' : 'ص');

    // Convert hour to 12-hour format
    int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;

    return '${date.day}-$month-${date.year}, $hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  List<Widget> stoppoints(BuildContext context) {
    List<Widget> list = [];

    for (var element in pathpoints) {
      if (element.pointType == "P") {
        list.add(
          SizedBox(
            height: 70,
            child: TimelineTile(
              isLast: false,
              isFirst: true,
              // alignment: TimelineAlign.center,
              beforeLineStyle: LineStyle(
                color: AppColor.deepYellow,
              ),
              indicatorStyle: IndicatorStyle(
                width: 30.h, // Match the size of your custom container
                height: 30.h, // Ensure height matches as well
                indicator: Container(
                  height: 30.h,
                  width: 30.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.deepYellow,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(45),
                    color: AppColor.deepBlack,
                  ),
                  padding: EdgeInsets.all(4.h),
                  child: Center(
                    child: Text(
                      "A",
                      style: TextStyle(
                        fontSize: 16.sp, // Adjust font size as needed
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // afterLineStyle: LineStyle(),
              alignment: TimelineAlign.start,
              endChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SectionBody(
                    text: "  ${element.name!}",
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SectionBody(
                        text: setLoadDate(deliveryDate, langCode),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    for (var i = 0; i < pathpoints.length; i++) {
      if (i == 0 || i == pathpoints.length - 1) continue;
      if (pathpoints[i].pointType == "S" && !mini) {
        list.add(
          SizedBox(
            height: 70,
            child: TimelineTile(
              isLast: false,
              isFirst: false,
              beforeLineStyle: LineStyle(
                color: AppColor.deepYellow,
              ),
              indicatorStyle: IndicatorStyle(
                width: 30.h, // Match the size of your custom container
                height: 30.h, // Ensure height matches as well
                indicator: Container(
                  height: 30.h,
                  width: 30.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.deepYellow,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(45),
                    color: AppColor.deepBlack,
                  ),
                  padding: EdgeInsets.all(4.h),
                  child: Center(
                    child: Text(
                      "$i",
                      style: TextStyle(
                        fontSize: 16.sp, // Adjust font size as needed
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              alignment: TimelineAlign.start,
              // lineXY: .3,
              endChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SectionBody(
                        text: "  ${pathpoints[i].name!}",
                      ),
                    ),
                  ),
                ],
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
            height: 70,
            child: TimelineTile(
              isLast: true,
              isFirst: false,
              // alignment: TimelineAlign.center,
              beforeLineStyle: LineStyle(
                color: AppColor.deepYellow,
              ),
              indicatorStyle: IndicatorStyle(
                width: 30.h, // Match the size of your custom container
                height: 30.h, // Ensure height matches as well
                indicator: Container(
                  // height: 30.h,
                  // width: 30.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.deepYellow,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(45),
                    color: AppColor.deepBlack,
                  ),
                  padding: EdgeInsets.all(4.h),
                  child: Center(
                    child: Text(
                      "B",
                      style: TextStyle(
                        fontSize: 16.sp, // Adjust font size as needed
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              alignment: TimelineAlign.start,
              // lineXY: .3,
              // startChild: FittedBox(
              //   fit: BoxFit.scaleDown,
              //   child: SectionBody(
              //     text:
              //         '${AppLocalizations.of(context)!.translate('delivery_address')} ',
              //   ),
              // ),
              endChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // FittedBox(
                  //   fit: BoxFit.scaleDown,
                  //   child: SectionBody(
                  //     text:
                  //         '${AppLocalizations.of(context)!.translate('delivery_address')} ',
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SectionBody(
                        text: "  ${element.name!}",
                      ),
                    ),
                  ),
                ],
              ),
              // startChild:  SectionBody(
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: stoppoints(context),
      ),
    );
  }
}
