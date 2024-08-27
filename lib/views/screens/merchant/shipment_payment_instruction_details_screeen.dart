import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/instructions/read_payment_instruction_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart' as intel;

class PaymentInstructionDetailsScreen extends StatelessWidget {
  final SubShipment shipment;

  PaymentInstructionDetailsScreen({
    Key? key,
    required this.shipment,
  }) : super(key: key);
  var f = intel.NumberFormat("#,###", "en_US");
  int calculatePrice(
    double distance,
    double weight,
  ) {
    double result = 0.0;
    result = distance * (weight / 1000) * 550;
    return result.toInt();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: SafeArea(
            child: Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!
                    .translate("payment_instruction"),
              ),
              backgroundColor: Colors.grey[100],
              body: BlocBuilder<ReadPaymentInstructionBloc,
                  ReadPaymentInstructionState>(
                builder: (context, state) {
                  if (state is ReadPaymentInstructionLoadedSuccess) {
                    return Column(
                      children: [
                        Card(
                          elevation: 2,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .translate('shipment_path_info'),
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.darkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ShipmentPathVerticalWidget(
                                  pathpoints: shipment.pathpoints!,
                                  pickupDate: shipment.pickupDate!,
                                  deliveryDate: shipment.deliveryDate!,
                                  langCode: localeState.value.languageCode,
                                  mini: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Card(
                          elevation: 1,
                          clipBehavior: Clip.antiAlias,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: double.infinity,
                                ),
                                SectionTitle(
                                  text: AppLocalizations.of(context)!
                                      .translate('operation_cost'),
                                ),
                                SizedBox(
                                  height: 7.h,
                                ),
                                SectionBody(
                                  text:
                                      '${AppLocalizations.of(context)!.translate('price')}: ${f.format(calculatePrice(shipment.distance!, shipment.totalWeight!.toDouble()))}.00  ${localeState.value.languageCode == 'en' ? 'S.P' : 'ل.س'}',
                                ),
                                SizedBox(
                                  height: 7.h,
                                ),
                                SectionBody(
                                  text:
                                      '${AppLocalizations.of(context)!.translate('payment_method')}: ${state.instruction.paymentMethod!}',
                                ),
                                SizedBox(
                                  height: 7.h,
                                ),
                                SectionBody(
                                  text:
                                      '${AppLocalizations.of(context)!.translate('date')}: ${state.instruction.created_date!}',
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                      ],
                    );
                  } else {
                    return Shimmer.fromColors(
                      baseColor: (Colors.grey[300])!,
                      highlightColor: (Colors.grey[100])!,
                      enabled: true,
                      direction: ShimmerDirection.ttb,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (_, __) => Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              height: 150.h,
                              width: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                        itemCount: 3,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
