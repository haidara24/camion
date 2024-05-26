import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:flutter/material.dart';

class Commodity_info_widget extends StatelessWidget {
  final List<ShipmentItems>? shipmentItems;
  Commodity_info_widget({Key? key, this.shipmentItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: AppColor.deepYellow, width: 1),
      children: [
        TableRow(children: [
          TableCell(
            child: Container(
              color: AppColor.lightYellow,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    AppLocalizations.of(context)!.translate('commodity_name')),
              ),
            ),
          ),
          TableCell(
            child: Container(
              color: AppColor.lightYellow,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(AppLocalizations.of(context)!
                    .translate('commodity_weight')),
              ),
            ),
          ),
        ]),
        ...List.generate(
          shipmentItems!.length,
          (index) => TableRow(children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(shipmentItems![index].commodityName!),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(shipmentItems![index].commodityWeight!.toString()),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
