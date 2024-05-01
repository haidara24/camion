import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/instructions/payment_create_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_details_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/models/stripe_model.dart';
import 'package:camion/data/providers/task_num_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:camion/views/widgets/shipment_path_widget.dart';

class ShipmentPaymentScreen extends StatefulWidget {
  final SubShipment shipment;
  final int subshipmentIndex;
  ShipmentPaymentScreen({
    Key? key,
    required this.shipment,
    required this.subshipmentIndex,
  }) : super(key: key);

  @override
  State<ShipmentPaymentScreen> createState() => _ShipmentPaymentScreenState();
}

class _ShipmentPaymentScreenState extends State<ShipmentPaymentScreen> {
  bool _loading = false;
  int selectedTruck = 0;

  String getTruckType(int type) {
    switch (type) {
      case 1:
        return "سطحة";
      case 2:
        return "براد";
      case 3:
        return "حاوية";
      case 4:
        return "شحن";
      case 5:
        return "قاطرة ومقطورة";
      case 6:
        return "tier";
      default:
        return "سطحة";
    }
  }

  String getEnTruckType(int type) {
    switch (type) {
      case 1:
        return "Flatbed";
      case 2:
        return "Refrigerated";
      case 3:
        return "Container";
      case 4:
        return "Semi Trailer";
      case 5:
        return "Jumbo Trailer";
      case 6:
        return "tier";
      default:
        return "FlatBed";
    }
  }

  String setLoadDate(DateTime date) {
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
    var mon = date.month;
    var month = months[mon - 1];
    var paymentDate = "";
    paymentDate = '${date.year}-$month-${date.day}';
    return paymentDate;
  }

  // Widget truckList() {
  //   return SizedBox(
  //     height: 115.h,
  //     child: ListView.builder(
  //       itemCount: widget.shipment.trucks!.length,
  //       shrinkWrap: true,
  //       scrollDirection: Axis.horizontal,
  //       itemBuilder: (context, index) {
  //         return InkWell(
  //           onTap: () async {
  //             setState(() {
  //               selectedTruck = index;
  //             });
  //           },
  //           child: Container(
  //             width: 180.w,
  //             margin: const EdgeInsets.all(5),
  //             padding: const EdgeInsets.all(5),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(11),
  //               border: Border.all(
  //                 color: selectedTruck == index
  //                     ? AppColor.deepYellow
  //                     : Colors.grey[400]!,
  //               ),
  //             ),
  //             child: Column(
  //               children: [
  //                 SizedBox(
  //                   height: 50.h,
  //                   width: 175.w,
  //                   child: CachedNetworkImage(
  //                     imageUrl:
  //                         widget.shipment.trucks![index].truck_type!.image!,
  //                     progressIndicatorBuilder:
  //                         (context, url, downloadProgress) =>
  //                             Shimmer.fromColors(
  //                       baseColor: (Colors.grey[300])!,
  //                       highlightColor: (Colors.grey[100])!,
  //                       enabled: true,
  //                       child: Container(
  //                         height: 50.h,
  //                         width: 175.w,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                     errorWidget: (context, url, error) => Container(
  //                       height: 50.h,
  //                       width: 175.w,
  //                       color: Colors.grey[300],
  //                       child: Center(
  //                         child: Text(AppLocalizations.of(context)!
  //                             .translate('image_load_error')),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   height: 7.h,
  //                 ),
  //                 Text(
  //                   "${widget.shipment.trucks![index].truckuser!.user!.firstName!} ${widget.shipment.trucks![index].truckuser!.user!.lastName!}",
  //                   style: TextStyle(
  //                     fontSize: 17.sp,
  //                     color: AppColor.deepBlack,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${widget.shipment.id!}',
                                  style: TextStyle(
                                      // color: AppColor.lightBlue,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 7.h,
                                ),
                                ShipmentPathWidget(
                                  loadDate:
                                      setLoadDate(widget.shipment.pickupDate!),
                                  pickupName: widget.shipment.pathpoints!
                                      .singleWhere(
                                          (element) => element.pointType == "P")
                                      .name!,
                                  deliveryName: widget.shipment.pathpoints!
                                      .singleWhere(
                                          (element) => element.pointType == "D")
                                      .name!,
                                  width: MediaQuery.of(context).size.width * .8,
                                  pathwidth:
                                      MediaQuery.of(context).size.width * .7,
                                ).animate().slideX(
                                    duration: 300.ms,
                                    delay: 0.ms,
                                    begin: 1,
                                    end: 0,
                                    curve: Curves.easeInOutSine),
                                SizedBox(
                                  height: 7.h,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    // truckList(),
                    // SizedBox(
                    //   height: 5.h,
                    // ),
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
                            Text(
                              AppLocalizations.of(context)!
                                  .translate('operation_cost'),
                              style: TextStyle(
                                  // color: AppColor.lightBlue,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 7.h,
                            ),
                            Text(
                              '${AppLocalizations.of(context)!.translate('price')}: ${widget.shipment.truck!.fees!}',
                              style: TextStyle(
                                // color: AppColor.lightBlue,
                                fontSize: 17.sp,
                              ),
                            ),
                            Divider(
                              height: 7.h,
                            ),
                            Text(
                              '${AppLocalizations.of(context)!.translate('extra_fees')}: ${widget.shipment.truck!.extra_fees!}',
                              style: TextStyle(
                                // color: AppColor.lightBlue,
                                fontSize: 17.sp,
                              ),
                            ),
                            SizedBox(
                              height: 7.h,
                            ),
                            widget.shipment.shipmentpaymentv2 != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: double.infinity,
                                      ),
                                      Divider(
                                        height: 7.h,
                                      ),
                                      Text(
                                        '${AppLocalizations.of(context)!.translate('total_amount')}: ${(widget.shipment.shipmentpaymentv2!.amount! + widget.shipment.shipmentpaymentv2!.fees! + widget.shipment.shipmentpaymentv2!.extraFees!)}',
                                        style: TextStyle(
                                          // color: AppColor.lightBlue,
                                          fontSize: 17.sp,
                                        ),
                                      ),
                                      Divider(
                                        height: 7.h,
                                      ),
                                      Text(
                                        '${AppLocalizations.of(context)!.translate('payment_date')}: ${setLoadDate(widget.shipment.shipmentpaymentv2!.created_date!)}',
                                        style: TextStyle(
                                          // color: AppColor.lightBlue,
                                          fontSize: 17.sp,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 7.h,
                                      ),
                                      Divider(
                                        height: 7.h,
                                      ),
                                      Text(
                                        '${AppLocalizations.of(context)!.translate('payment_method')}: VISA Card',
                                        style: TextStyle(
                                          // color: AppColor.lightBlue,
                                          fontSize: 17.sp,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 7.h,
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    widget.shipment.shipmentpaymentv2 == null
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width * .9,
                            child: CustomButton(
                              title: _loading
                                  ? const LoadingIndicator()
                                  : Text(AppLocalizations.of(context)!
                                      .translate('pay_now')),
                              onTap: () async {
                                setState(() {
                                  _loading = true;
                                });
                                var prefs =
                                    await SharedPreferences.getInstance();
                                var jwt = prefs.getString("token");
                                var amount = (widget.shipment.truck!.fees! +
                                        widget.shipment.truck!.extra_fees!) *
                                    100;

                                final response = await HttpHelper.get(
                                    "https://matjari.app/make_payment/?amount=$amount",
                                    apiToken: jwt);
                                print(response.body);
                                print(response.statusCode);
                                var jsonBody = jsonDecode(response.body);

                                StripeModel stripeModel =
                                    StripeModel.fromJson(jsonBody);
                                if (stripeModel.paymentIntent! != "" &&
                                    stripeModel.paymentIntent != null) {
                                  String _intent = stripeModel.paymentIntent!;
                                  await stripe.Stripe.instance.initPaymentSheet(
                                    paymentSheetParameters:
                                        stripe.SetupPaymentSheetParameters(
                                      customFlow: false,
                                      merchantDisplayName: 'Camion',
                                      paymentIntentClientSecret:
                                          stripeModel.paymentIntent,
                                      customerEphemeralKeySecret:
                                          stripeModel.ephemeralKey,
                                      customerId: stripeModel.customer,
                                      applePay:
                                          const stripe.PaymentSheetApplePay(
                                        merchantCountryCode: 'US',
                                      ),
                                      googlePay:
                                          const stripe.PaymentSheetGooglePay(
                                        merchantCountryCode: 'US',
                                        testEnv: true,
                                      ),
                                      style: ThemeMode.light,
                                    ),
                                  );
                                  setState(() {
                                    _loading = false;
                                  });
                                  stripe.Stripe.instance
                                      .presentPaymentSheet()
                                      .onError((error, stackTrace) {
                                    print(error);
                                  });
                                  stripe.Stripe.instance
                                      .confirmPaymentSheetPayment()
                                      .then((value) {
                                    var amount = (widget.shipment.truck!.fees! +
                                        widget.shipment.truck!.extra_fees!);
                                    ShipmentPayment payment = ShipmentPayment();
                                    payment.shipment = widget.shipment.id!;
                                    payment.amount =
                                        widget.shipment.truck!.fees;
                                    payment.paymentMethod = "S";
                                    payment.fees = widget.shipment.truck!.fees;
                                    payment.extraFees =
                                        widget.shipment.truck!.extra_fees;

                                    BlocProvider.of<PaymentCreateBloc>(context)
                                        .add(PaymentCreateButtonPressed(
                                            payment));
                                  });
                                }
                              },
                            ),
                          )
                        : const SizedBox.shrink()
                  ],
                ),
                Consumer<TaskNumProvider>(
                    builder: (context, taskProvider, child) {
                  return BlocConsumer<PaymentCreateBloc, PaymentCreateState>(
                    listener: (context, state) {
                      if (state is PaymentCreateSuccessState) {
                        taskProvider.decreaseTaskNum();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: AppColor.deepGreen,
                          dismissDirection: DismissDirection.up,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height - 150,
                              left: 10,
                              right: 10),
                          content: localeState.value.languageCode == 'en'
                              ? const Text(
                                  'Payment has been created successfully.',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                )
                              : const Text(
                                  'تم الدفع بنجاح',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                          duration: const Duration(seconds: 3),
                        ));

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ControlView(),
                            ),
                            (route) => false);
                      }
                    },
                    builder: (context, state) {
                      if (state is PaymentLoadingProgressState) {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          color: Colors.white70,
                          child: const Center(child: LoadingIndicator()),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
