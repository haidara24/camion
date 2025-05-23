import 'dart:io';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/instructions/payment_create_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/read_payment_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_task_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/text_constants.dart';
import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/providers/task_num_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/screens/merchant/ecash_payment_checkout_screen.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:camion/views/widgets/snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart' as intel;
import 'package:shimmer/shimmer.dart';

// import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

class ShipmentPaymentScreen extends StatefulWidget {
  final SubShipment shipment;
  final int subshipmentIndex;
  const ShipmentPaymentScreen({
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

  var f = intel.NumberFormat("#,###", "en_US");

  final ImagePicker _picker = ImagePicker();

  Future<void> _checkAndRequestPermissions() async {
    if (await Permission.photos.isGranted) {
      print('Permission already granted');
    } else {
      PermissionStatus status = await Permission.photos.request();
      if (status.isGranted) {
        print('Permission granted');
      } else if (status.isDenied) {
        print('Permission denied by user');
      } else if (status.isPermanentlyDenied) {
        print('Permission permanently denied by user');
        openAppSettings();
      }
    }
  }

  getPaymentMethodName(String character, String lang) {
    switch (character) {
      case "E":
        return "Ecash";
      case "H":
        return lang == "en" ? "Al Haram" : "الهرم";
      case "B":
        return lang == "en" ? "Al Barakah" : "البركة";
      default:
    }
  }

  int calculatePrice(
    double distance,
    double weight,
  ) {
    double result = 0.0;
    result = distance * (weight / 1000) * 550;
    return result.toInt();
  }

  String setLoadDate(DateTime date, String lang) {
    var mon = date.month;
    var month = lang == "en"
        ? TextConstants.monthsEn[mon - 1]
        : TextConstants.monthsAr[mon - 1];

    // Determine AM/PM
    String period = date.hour >= 12
        ? (lang == "en" ? 'PM' : 'م')
        : (lang == "en" ? 'AM' : 'ص');

    // Convert hour to 12-hour format
    int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;

    return '${date.day}-$month-${date.year}, $hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Card(
                    //   elevation: 1,
                    //   clipBehavior: Clip.antiAlias,
                    //   shape: const RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.all(
                    //       Radius.circular(10),
                    //     ),
                    //   ),
                    //   color: Colors.white,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Column(
                    //       children: [
                    //         Row(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           children: [
                    //             Text(
                    //               AppLocalizations.of(context)!
                    //                   .translate('shipment_path_info'),
                    //               style: TextStyle(
                    //                 fontSize: 17,
                    //                 fontWeight: FontWeight.bold,
                    //                 color: AppColor.darkGrey,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //         const SizedBox(
                    //           height: 10,
                    //         ),
                    //         ShipmentPathVerticalWidget(
                    //           pathpoints: widget.shipment.pathpoints!,
                    //           pickupDate: widget.shipment.pickupDate!,
                    //           deliveryDate: widget.shipment.deliveryDate!,
                    //           langCode: localeState.value.languageCode,
                    //           mini: false,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
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
                        padding: const EdgeInsets.all(16.0),
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
                            SectionTitle(
                              size: 20,
                              text:
                                  '${AppLocalizations.of(context)!.translate('price')}: ${f.format(calculatePrice(widget.shipment.distance!, widget.shipment.totalWeight!.toDouble()))}.00  ${localeState.value.languageCode == 'en' ? 'S.P' : 'ل.س'}',
                            ),
                            // Divider(
                            //   height: 7.h,
                            // ),
                            widget.shipment.shipmentpaymentv2 != null
                                ? BlocBuilder<ReadPaymentInstructionBloc,
                                    ReadPaymentInstructionState>(
                                    builder: (context, state) {
                                      if (state
                                          is ReadPaymentInstructionLoadedSuccess) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 7.h,
                                            ),
                                            SectionTitle(
                                              size: 20,
                                              text:
                                                  '${AppLocalizations.of(context)!.translate('payment_method')}: ${getPaymentMethodName(state.instruction.paymentMethod!, localeState.value.languageCode)}',
                                            ),
                                            SizedBox(
                                              height: 7.h,
                                            ),
                                            SectionBody(
                                              text:
                                                  '${AppLocalizations.of(context)!.translate('date')}: ${setLoadDate(state.instruction.created_date!, localeState.value.languageCode)}',
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15,
                                                      vertical: 5),
                                                  height: 150.h,
                                                  width: double.infinity,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            itemCount: 1,
                                          ),
                                        );
                                      }
                                    },
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
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: double.infinity,
                                    ),
                                    SectionTitle(
                                      text: AppLocalizations.of(context)!
                                          .translate("choose_payment_method"),
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
                                                .25,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                    selectedPaymentType == "B"
                                                        ? AppColor.deepYellow
                                                        : Colors.grey[400]!,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/Albaraka.jpg"),
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
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/Alharam.jpg"),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            height: 65,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .25,
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
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/e_Cash.jpg"),
                                              ),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            height: 65,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .25,
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
              ),
              Consumer<TaskNumProvider>(
                  builder: (context, taskProvider, child) {
                return BlocConsumer<PaymentCreateBloc, PaymentCreateState>(
                  listener: (context, state) {
                    if (state is PaymentCreateSuccessState) {
                      showCustomSnackBar(
                        context: context,
                        backgroundColor: AppColor.deepGreen,
                        message: localeState.value.languageCode == 'en'
                            ? 'Payment Settled.'
                            : 'تم الدفع',
                      );
                      taskProvider.decreaseTaskNum();

                      Navigator.pop(context);
                      BlocProvider.of<ShipmentTaskListBloc>(context)
                          .add(ShipmentTaskListLoadEvent());
                    }
                  },
                  builder: (context, state) {
                    if (state is PaymentLoadingProgressState) {
                      return Container(
                        height: MediaQuery.of(context).size.height,
                        color: Colors.white70,
                        child: Center(child: LoadingIndicator()),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  paymentCard() {
    switch (selectedPaymentType) {
      case "B":
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionTitle(
                      text: AppLocalizations.of(context)!.translate("barakah")),
                  Image.asset(
                    "assets/images/Albaraka.jpg",
                    height: 30,
                  ),
                ],
              ),
              const Divider(),
              SectionBody(
                  text:
                      "${AppLocalizations.of(context)!.translate("account_no")}:1117556556."),
              SectionBody(
                  text:
                      "${AppLocalizations.of(context)!.translate("account_name")} : AcrossMena"),
              SectionBody(
                  text: AppLocalizations.of(context)!
                      .translate("send_attachment")),
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
                      payment.amount = calculatePrice(widget.shipment.distance!,
                          widget.shipment.totalWeight!.toDouble());
                      payment.paymentMethod = "B";
                      payment.fees = 0;
                      payment.extraFees = 0;

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
                  SectionTitle(
                      text: AppLocalizations.of(context)!.translate("haram")),
                  Image.asset(
                    "assets/images/Alharam.jpg",
                    height: 30,
                  ),
                ],
              ),
              const Divider(),
              SectionBody(
                  text:
                      "${AppLocalizations.of(context)!.translate("account_no")}:1117556556."),
              SectionBody(
                  text:
                      "${AppLocalizations.of(context)!.translate("account_name")} : AcrossMena"),
              SectionBody(
                  text: AppLocalizations.of(context)!
                      .translate("send_attachment")),
              const SizedBox(height: 8),
              CustomButton(
                title: const Icon(
                  Icons.cloud_upload_outlined,
                  size: 35,
                ),
                onTap: () async {
                  _checkAndRequestPermissions();
                  var pickedImage = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );

                  haram_image = File(pickedImage!.path);
                  ShipmentPayment payment = ShipmentPayment();
                  payment.shipment = widget.shipment.id!;
                  payment.amount = calculatePrice(widget.shipment.distance!,
                      widget.shipment.totalWeight!.toDouble());
                  payment.paymentMethod = "H";
                  payment.fees = 0;
                  payment.extraFees = 0;

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
                  SectionTitle(
                      text: AppLocalizations.of(context)!.translate("ecash")),
                  Image.asset(
                    "assets/images/e_Cash.jpg",
                    height: 30,
                  ),
                ],
              ),
              const Divider(),
              const SectionBody(text: "under development."),
              widget.shipment.shipmentpaymentv2 == null
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * .9,
                      child: CustomButton(
                        title: _loading
                            ? LoadingIndicator()
                            : Text(AppLocalizations.of(context)!
                                .translate('pay_now')),
                        onTap: () async {
                          setState(() {
                            _loading = true;
                          });
                          String merchantId = "XWZXL9";
                          String terminalKey = "M5NW61";
                          String merchantSecret =
                              "MO7YFXNPDNFOEIK0ZCUIBMY90DDTF46IUM5NDS23AQZGZEVYSMCACOAPE2LLKD53";
                          String amount = calculatePrice(
                                  widget.shipment.distance!,
                                  widget.shipment.totalWeight!.toDouble())
                              .toString();
                          String orderRef = widget.shipment.id.toString();

                          // Concatenate the values
                          String concatenatedString =
                              "$merchantId$merchantSecret$amount$orderRef";

                          // Compute MD5 hash
                          String md5Hash = md5
                              .convert(utf8.encode(concatenatedString))
                              .toString();
                          String callbackUrl =
                              "${DOMAIN}camion/callback/"; // Your callback URL
                          String encodedCallbackUrl =
                              Uri.encodeComponent(callbackUrl);

                          String redirectUrl = "https://your-redirect-url.com";
                          String encodedRedirectUrl =
                              Uri.encodeComponent(redirectUrl);

                          var paymentUrl =
                              "https://checkout.ecash-pay.co/Checkout/Card/$terminalKey/$merchantId/${md5Hash.toUpperCase()}/SYP/$amount/AR/$orderRef/$encodedRedirectUrl";
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ECashPaymentCheckoutScreen(
                                  url: paymentUrl,
                                  shipment: widget.shipment,
                                  amount: amount,
                                ),
                              ));
                          print(paymentUrl);
                          setState(() {
                            _loading = false;
                          });
                        },
                      ),
                    )
                  : const SizedBox.shrink()
            ],
          ),
        );
      default:
    }
  }
}
