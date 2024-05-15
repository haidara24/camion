import 'dart:convert';
import 'dart:io';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/instructions/payment_create_bloc.dart';
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
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String selectedPaymentType = "B";
  File? barakah_image;
  File? haram_image;

  final ImagePicker _picker = ImagePicker();

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
                                  '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${widget.shipment.shipment!}',
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
                                        '${AppLocalizations.of(context)!.translate('total_amount')}: ${(widget.shipment.shipmentpaymentv2! + widget.shipment.shipmentpaymentv2! + widget.shipment.shipmentpaymentv2!)}',
                                        style: TextStyle(
                                          // color: AppColor.lightBlue,
                                          fontSize: 17.sp,
                                        ),
                                      ),
                                      Divider(
                                        height: 7.h,
                                      ),
                                      Text(
                                        '${AppLocalizations.of(context)!.translate('payment_date')}: }',
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
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    widget.shipment.shipmentpaymentv2 == null
                        ? Card(
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
                                      "اختر وسيلة الدفع",
                                      style: TextStyle(
                                          // color: AppColor.lightBlue,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 8.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedPaymentType = "B";
                                            });
                                          },
                                          child: Container(
                                            height: 65,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .28,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                    selectedPaymentType == "B"
                                                        ? AppColor.deepYellow
                                                        : Colors.grey[400]!,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                "assets/images/albaraka.png",
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .25,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedPaymentType = "H";
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                    selectedPaymentType == "H"
                                                        ? AppColor.deepYellow
                                                        : Colors.grey[400]!,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            height: 65,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .28,
                                            child: Center(
                                              child: Image.asset(
                                                "assets/images/alharam.png",
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .25,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedPaymentType = "E";
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                    selectedPaymentType == "E"
                                                        ? AppColor.deepYellow
                                                        : Colors.grey[400]!,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            height: 65,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .28,
                                            child: Center(
                                              child: Image.asset(
                                                "assets/images/fatora.png",
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .25,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8.h,
                                    ),
                                  ]),
                            ),
                          )
                        : const SizedBox.shrink(),
                    SizedBox(
                      height: 5.h,
                    ),
                    widget.shipment.shipmentpaymentv2 == null
                        ? Card(
                            elevation: 1,
                            clipBehavior: Clip.antiAlias,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            color: Colors.white,
                            child: paymentCard())
                        : const SizedBox.shrink(),
                    SizedBox(
                      height: 5.h,
                    ),
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

  paymentCard() {
    switch (selectedPaymentType) {
      case "B":
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle(text: "بنك البركة"),
                  Image.asset(
                    "assets/images/albaraka.png",
                    height: 30,
                  ),
                ],
              ),
              const Divider(),
              const SectionBody(text: "رقم الحساب:1117556556."),
              const SectionBody(text: "اسم الحساب : أكروس مينا"),
              const SectionBody(text: "أرفق الاشعار لمراجعته"),
              const SizedBox(height: 8),
              BlocConsumer<PaymentCreateBloc, PaymentCreateState>(
                listener: (context, state) {
                  if (state is PaymentCreateSuccessState) {}
                },
                builder: (context, state) {
                  return CustomButton(
                    title: const Icon(
                      Icons.cloud_upload_outlined,
                      size: 35,
                    ),
                    onTap: () async {
                      var pickedImage = await _picker.pickImage(
                        source: ImageSource.gallery,
                      );

                      barakah_image = File(pickedImage!.path);
                      ShipmentPayment payment = ShipmentPayment();
                      payment.shipment = widget.shipment.id!;
                      payment.amount = widget.shipment.truck!.fees;
                      payment.paymentMethod = "B";
                      payment.fees = widget.shipment.truck!.fees;
                      payment.extraFees = widget.shipment.truck!.extra_fees;

                      BlocProvider.of<PaymentCreateBloc>(context).add(
                          PaymentCreateButtonPressed(payment, barakah_image));
                    },
                  );
                },
              ),
            ],
          ),
        );
      case "H":
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle(text: "الهرم"),
                  Image.asset(
                    "assets/images/alharam.png",
                    height: 30,
                  ),
                ],
              ),
              const Divider(),
              const SectionBody(text: "رقم الحساب:1117556556."),
              const SectionBody(text: "اسم الحساب : أكروس مينا"),
              const SectionBody(text: "أرفق الاشعار لمراجعته"),
              const SizedBox(height: 8),
              CustomButton(
                title: const Icon(
                  Icons.cloud_upload_outlined,
                  size: 35,
                ),
                onTap: () async {
                  var pickedImage = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );

                  haram_image = File(pickedImage!.path);
                  ShipmentPayment payment = ShipmentPayment();
                  payment.shipment = widget.shipment.id!;
                  payment.amount = widget.shipment.truck!.fees;
                  payment.paymentMethod = "H";
                  payment.fees = widget.shipment.truck!.fees;
                  payment.extraFees = widget.shipment.truck!.extra_fees;

                  BlocProvider.of<PaymentCreateBloc>(context)
                      .add(PaymentCreateButtonPressed(payment, haram_image));
                },
              ),
            ],
          ),
        );
      case "E":
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle(text: "فاتورة"),
                  Image.asset(
                    "assets/images/fatora.png",
                    height: 30,
                  ),
                ],
              ),
              const Divider(),
              const SectionBody(text: "under development."),
              // const SectionBody(text: "اسم الحساب : أكروس مينا"),
              // widget.shipment.shipmentpaymentv2 == null
              //     ? SizedBox(
              //         width: MediaQuery.of(context).size.width * .9,
              //         child: CustomButton(
              //           title: _loading
              //               ? const LoadingIndicator()
              //               : Text(AppLocalizations.of(context)!
              //                   .translate('pay_now')),
              //           onTap: () async {
              //             setState(() {
              //               _loading = true;
              //             });
              //             var prefs = await SharedPreferences.getInstance();
              //             var jwt = prefs.getString("token");
              //             var amount = (widget.shipment.truck!.fees! +
              //                     widget.shipment.truck!.extra_fees!) *
              //                 100;

              //             final response = await HttpHelper.get(
              //                 "https://matjari.app/make_payment/?amount=100",
              //                 apiToken: jwt);
              //             print(response.body);
              //             print(response.statusCode);
              //             var jsonBody = jsonDecode(response.body);

              //             StripeModel stripeModel =
              //                 StripeModel.fromJson(jsonBody);
              //             if (stripeModel.paymentIntent! != "" &&
              //                 stripeModel.paymentIntent != null) {
              //               String _intent = stripeModel.paymentIntent!;
              //               await stripe.Stripe.instance.initPaymentSheet(
              //                 paymentSheetParameters:
              //                     stripe.SetupPaymentSheetParameters(
              //                   customFlow: false,
              //                   merchantDisplayName: 'Camion',
              //                   paymentIntentClientSecret:
              //                       stripeModel.paymentIntent,
              //                   customerEphemeralKeySecret:
              //                       stripeModel.ephemeralKey,
              //                   customerId: stripeModel.customer,
              //                   applePay: const stripe.PaymentSheetApplePay(
              //                     merchantCountryCode: 'US',
              //                   ),
              //                   googlePay: const stripe.PaymentSheetGooglePay(
              //                     merchantCountryCode: 'US',
              //                     testEnv: true,
              //                   ),
              //                   style: ThemeMode.light,
              //                 ),
              //               );
              //               setState(() {
              //                 _loading = false;
              //               });
              //               stripe.Stripe.instance
              //                   .presentPaymentSheet()
              //                   .onError((error, stackTrace) {
              //                 print(error);
              //               });
              //               stripe.Stripe.instance
              //                   .confirmPaymentSheetPayment()
              //                   .then((value) {
              //                 var amount = (widget.shipment.truck!.fees! +
              //                     widget.shipment.truck!.extra_fees!);
              //                 ShipmentPayment payment = ShipmentPayment();
              //                 payment.shipment = widget.shipment.id!;
              //                 payment.amount = widget.shipment.truck!.fees;
              //                 payment.paymentMethod = "S";
              //                 payment.fees = widget.shipment.truck!.fees;
              //                 payment.extraFees =
              //                     widget.shipment.truck!.extra_fees;

              //                 // BlocProvider.of<PaymentCreateBloc>(context)
              //                 //     .add(PaymentCreateButtonPressed(payment,));
              //               });
              //             }
              //           },
              //         ),
              //       )
              //     : const SizedBox.shrink()
            ],
          ),
        );
      default:
    }
  }
}
