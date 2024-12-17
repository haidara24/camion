import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:flutter/material.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubShipmentCardWidget extends StatelessWidget {
  final SubShipment shipment;
  final String languageCode;
  final Function() onTap;

  const SubShipmentCardWidget({
    Key? key,
    required this.shipment,
    required this.languageCode,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AbsorbPointer(
        absorbing: false,
        child: Card(
          color: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          margin: const EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 48.h,
                color: AppColor.deepYellow,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${shipment.id}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ShipmentPathVerticalWidget(
                pathpoints: shipment.pathpoints!,
                pickupDate: shipment.pickupDate!,
                deliveryDate: shipment.pickupDate!,
                langCode: languageCode,
                mini: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
