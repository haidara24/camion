import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intel;

class Commodity_info_widget extends StatelessWidget {
  final List<ShipmentItems>? shipmentItems;
  Commodity_info_widget({Key? key, this.shipmentItems}) : super(key: key);
  var f = intel.NumberFormat("#,###", "en_US");

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Table(
          border: TableBorder.all(
            color: Colors.grey[400]!,
            width: 1,
          ),
          children: [
            TableRow(children: [
              TableCell(
                child: Container(
                  color: AppColor.lightYellow,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SectionBody(
                        text: AppLocalizations.of(context)!
                            .translate('commodity_name')),
                  ),
                ),
              ),
              TableCell(
                child: Container(
                  color: AppColor.lightYellow,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SectionBody(
                        text: AppLocalizations.of(context)!
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
                    child:
                        SectionBody(text: shipmentItems![index].commodityName!),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SectionBody(
                        text:
                            '${f.format(shipmentItems![index].commodityWeight!)} ${localeState.value.languageCode == "en" ? 'kg' : 'كغ'}'),
                  ),
                ),
              ]),
            ),
          ],
        );
      },
    );
  }
}
