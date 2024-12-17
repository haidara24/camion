import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:flutter/material.dart';
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
            width: 20,
            color: AppColor.deepYellow,
            // iconStyle: IconStyle(
            //     iconData: Icons.done, color: Colors.white, fontSize: 20),
          ),
          alignment: TimelineAlign.manual,
          lineXY: .3,
          startChild: SectionBody(
            text: AppLocalizations.of(context)!.translate('pickup_address'),
          ),
          endChild: SectionBody(
            text: "  ${pickup.text}",
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
              width: 20,
              color: AppColor.deepYellow,
              iconStyle: IconStyle(
                iconData: Icons.circle,
                color: Colors.white,
                fontSize: 17,
              ),
            ),
            alignment: TimelineAlign.manual,
            lineXY: .3,
            startChild: SectionBody(
              text:
                  "${AppLocalizations.of(context)!.translate('station_no')} ${i + 1}",
            ),
            endChild: SectionBody(
              text: "  ${stations[i].text}",
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
            width: 20,
            color: AppColor.deepYellow,
            indicator: Center(
              child: Icon(
                Icons.square,
                color: AppColor.deepYellow,
                size: 20,
              ),
            ),
          ),
          alignment: TimelineAlign.manual,
          lineXY: .3,
          startChild: SectionBody(
            text: AppLocalizations.of(context)!.translate('delivery_address'),
          ),
          endChild: SectionBody(
            text: "  ${delivery.text}",
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
