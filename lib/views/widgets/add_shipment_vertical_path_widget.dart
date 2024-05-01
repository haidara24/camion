import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AddShipmentPathVerticalWidget extends StatelessWidget {
  final List<TextEditingController> stations;
  final TextEditingController pickup;
  final TextEditingController delivery;
  const AddShipmentPathVerticalWidget({
    Key? key,
    required this.stations,
    required this.pickup,
    required this.delivery,
  }) : super(key: key);

  List<Widget> stoppoints(BuildContext context) {
    List<TextEditingController> pathpoints = [];

    pathpoints.addAll(stations);
    List<Widget> list = [];

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
            width: 30,
            color: AppColor.deepYellow,
            iconStyle: IconStyle(
                iconData: Icons.done, color: Colors.white, fontSize: 20),
          ),
          alignment: TimelineAlign.manual,
          lineXY: .3,
          startChild: Text(
            AppLocalizations.of(context)!.translate('pickup_address'),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          endChild: Text(
            "  ${pickup.text}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );

    for (var i = 0; i < stations.length; i++) {
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
              width: 30,
              color: AppColor.deepYellow,
              iconStyle: IconStyle(
                  iconData: Icons.done, color: Colors.white, fontSize: 20),
            ),
            alignment: TimelineAlign.manual,
            lineXY: .3,
            startChild: Text(
              "${AppLocalizations.of(context)!.translate('station_no')} ${i + 1}",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            endChild: Text(
              "  ${stations[i].text}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
    }

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
            width: 30,
            color: AppColor.deepYellow,
            iconStyle: IconStyle(
                iconData: Icons.done, color: Colors.white, fontSize: 20),
          ),
          alignment: TimelineAlign.manual,
          lineXY: .3,
          startChild: Text(
            AppLocalizations.of(context)!.translate('delivery_address'),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          endChild: Text(
            "  ${delivery.text}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stoppoints(context),
    );
  }
}
