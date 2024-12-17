import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/instructions/read_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/read_payment_instruction_bloc.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/merchant/shipment_instruction_details_screen.dart';
import 'package:camion/views/screens/merchant/shipment_payment_instruction_details_screeen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';

class ShipmentInstructionCardsWidget extends StatelessWidget {
  final SubShipment subshipment;
  const ShipmentInstructionCardsWidget({
    super.key,
    required this.subshipment,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  if (subshipment.shipmentinstructionv2 != null) {
                    BlocProvider.of<ReadInstructionBloc>(context).add(
                      ReadInstructionLoadEvent(
                          subshipment.shipmentinstructionv2!),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShipmentInstructionDetailsScreen(
                            shipment: subshipment),
                      ),
                    );
                  }
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * .4,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        color: Colors.white,
                        border: Border.all(
                          color: subshipment.shipmentinstructionv2 != null
                              ? AppColor.deepYellow
                              : AppColor.lightGrey,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // SizedBox(
                                //     height: 25.h,
                                //     width: 25.w,
                                //     child: SvgPicture.asset(
                                //         "assets/icons/instruction.svg")),
                                const SizedBox(
                                  width: 5,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .35,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('shipment_instruction'),
                                      style: TextStyle(
                                          // color: AppColor.lightBlue,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 7.h,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .4,
                              child: subshipment.shipmentinstructionv2 == null
                                  ? Text(
                                      AppLocalizations.of(context)!.translate(
                                          'instruction_not_complete'),
                                      maxLines: 2,
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!
                                          .translate('instruction_complete'),
                                      maxLines: 2,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -5,
                      right: localeState.value.languageCode == "en" ? -5 : null,
                      left: localeState.value.languageCode == "en" ? null : -5,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(45)),
                        child: subshipment.shipmentinstructionv2 == null
                            ? Icon(
                                Icons.warning_amber_rounded,
                                color: AppColor.deepYellow,
                              )
                            : Icon(
                                Icons.check_circle,
                                color: AppColor.deepYellow,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  if (subshipment.shipmentpaymentv2 != null) {
                    BlocProvider.of<ReadPaymentInstructionBloc>(context).add(
                      ReadPaymentInstructionLoadEvent(
                          subshipment.shipmentpaymentv2!),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentInstructionDetailsScreen(
                            shipment: subshipment),
                      ),
                    );
                  }
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * .4,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        color: Colors.white,
                        border: Border.all(
                          color: subshipment.shipmentpaymentv2 != null
                              ? AppColor.deepYellow
                              : AppColor.lightGrey,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // SizedBox(
                                //     height: 25.h,
                                //     width: 25.w,
                                //     child: SvgPicture.asset(
                                //         "assets/icons/payment.svg")),
                                const SizedBox(
                                  width: 5,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .35,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('payment_instruction'),
                                      style: TextStyle(
                                          // color: AppColor.lightBlue,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 7.h,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .4,
                              child: subshipment.shipmentpaymentv2 == null
                                  ? Text(
                                      AppLocalizations.of(context)!
                                          .translate('payment_not_complete'),
                                      maxLines: 2,
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!
                                          .translate('payment_complete'),
                                      maxLines: 2,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -5,
                      right: localeState.value.languageCode == "en" ? -5 : null,
                      left: localeState.value.languageCode == "en" ? null : -5,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(45)),
                        child: subshipment.shipmentpaymentv2 == null
                            ? Icon(
                                Icons.warning_amber_rounded,
                                color: AppColor.deepYellow,
                              )
                            : Icon(
                                Icons.check_circle,
                                color: AppColor.deepYellow,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
