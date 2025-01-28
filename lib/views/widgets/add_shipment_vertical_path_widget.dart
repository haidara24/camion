import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AddShipmentPathVerticalWidget extends StatelessWidget {
  final List<TextEditingController> stations;
  const AddShipmentPathVerticalWidget({
    Key? key,
    required this.stations,
  }) : super(key: key);

  List<Widget> stoppoints(BuildContext context) {
    List<TextEditingController> pathpoints = [];

    pathpoints.addAll(stations);
    List<Widget> list = [];

    for (var i = 0; i < stations.length; i++) {
      if (i == 0) {
        list.add(
          SizedBox(
            height: 64,
            child: TimelineTile(
              isLast: false,
              isFirst: true,
              // alignment: TimelineAlign.center,
              beforeLineStyle: LineStyle(
                color: AppColor.deepYellow,
              ),
              indicatorStyle: IndicatorStyle(
                width: 28.h, // Match the size of your custom container
                height: 28.h, // Ensure height matches as well
                indicator: Container(
                  height: 28.h,
                  width: 28.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.deepYellow,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(45),
                    color: AppColor.deepBlack,
                  ),
                  child: const Center(
                    child: Text(
                      "A",
                      style: TextStyle(
                        fontSize: 16, // Adjust font size as needed
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              alignment: TimelineAlign.manual,
              lineXY: .3,
              startChild: SectionBody(
                text: AppLocalizations.of(context)!.translate('pickup_address'),
              ),
              endChild: SectionBody(
                text: "  ${stations[i].text}",
              ),
            ),
          ),
        );
      } else if (i == stations.length - 1) {
        list.add(
          SizedBox(
            height: 64,
            child: TimelineTile(
              isLast: true,
              isFirst: false,
              // alignment: TimelineAlign.center,
              beforeLineStyle: LineStyle(
                color: AppColor.deepYellow,
              ),
              indicatorStyle: IndicatorStyle(
                width: 28.h, // Match the size of your custom container
                height: 28.h, // Ensure height matches as well
                indicator: Container(
                  height: 28.h,
                  width: 28.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.deepYellow,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(45),
                    color: AppColor.deepBlack,
                  ),
                  child: const Center(
                    child: Text(
                      "B",
                      style: TextStyle(
                        fontSize: 16, // Adjust font size as needed
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              alignment: TimelineAlign.manual,
              lineXY: .3,
              startChild: SectionBody(
                text:
                    AppLocalizations.of(context)!.translate('delivery_address'),
              ),
              endChild: SectionBody(
                text: "  ${stations[i].text}",
              ),
            ),
          ),
        );
      } else {
        list.add(
          SizedBox(
            height: 64,
            child: TimelineTile(
              isLast: false,
              isFirst: false,
              beforeLineStyle: LineStyle(
                color: AppColor.deepYellow,
              ),
              indicatorStyle: IndicatorStyle(
                width: 28.h, // Match the size of your custom container
                height: 28.h, // Ensure height matches as well
                indicator: Container(
                  height: 28.h,
                  width: 28.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.deepYellow,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(45),
                    color: AppColor.deepBlack,
                  ),
                  child: Center(
                    child: Text(
                      "$i",
                      style: const TextStyle(
                        fontSize: 16, // Adjust font size as needed
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              alignment: TimelineAlign.manual,
              lineXY: .3,
              startChild: SectionBody(
                text:
                    "${AppLocalizations.of(context)!.translate('station_no')} $i",
              ),
              endChild: SectionBody(
                text: "  ${stations[i].text}",
              ),
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
