import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/kshipment_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intel;

class CheckPointShipmentDetailsScreen extends StatefulWidget {
  final ManagmentShipment shipment;
  CheckPointShipmentDetailsScreen({Key? key, required this.shipment})
      : super(key: key);

  @override
  State<CheckPointShipmentDetailsScreen> createState() =>
      _CheckPointShipmentDetailsScreenState();
}

class _CheckPointShipmentDetailsScreenState
    extends State<CheckPointShipmentDetailsScreen> {
  var f = intel.NumberFormat("#,###", "en_US");

  String setLoadDate(DateTime date) {
    if (date == null) {
      return "";
    }
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

    var result = '${date.day}-$month-${date.year}';
    return result;
  }

  String getOfferStatus(String offer) {
    switch (offer) {
      case "P":
        return "معلقة";
      case "R":
        return "جارية";
      case "C":
        return "مكتملة";
      case "F":
        return "مرفوضة";
      default:
        return "خطأ";
    }
  }

  String diffText(Duration diff) {
    if (diff.inSeconds < 60) {
      return "منذ ${diff.inSeconds.toString()} ثانية";
    } else if (diff.inMinutes < 60) {
      return "منذ ${diff.inMinutes.toString()} دقيقة";
    } else if (diff.inHours < 24) {
      return "منذ ${diff.inHours.toString()} ساعة";
    } else {
      return "منذ ${diff.inDays.toString()} يوم";
    }
  }

  String diffEnText(Duration diff) {
    if (diff.inSeconds < 60) {
      return "since ${diff.inSeconds.toString()} seconds";
    } else if (diff.inMinutes < 60) {
      return "since ${diff.inMinutes.toString()} minutes";
    } else if (diff.inHours < 24) {
      return "since ${diff.inHours.toString()} hours";
    } else {
      return "since ${diff.inDays.toString()} days";
    }
  }

  Future<void> onRefresh() async {}
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
              resizeToAvoidBottomInset: false,
              backgroundColor: AppColor.lightGrey200,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.translate('search_result'),
              ),
              body: SingleChildScrollView(
                // physics: const NeverScrollableScrollPhysics(),
                child: Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 1,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: SvgPicture.asset(
                                  "assets/icons/Merchant_information.svg"),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(
                              AppLocalizations.of(context)!
                                  .translate('merchant'),
                              style: TextStyle(
                                // color: AppColor.lightBlue,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'اسم التاجر: ${widget.shipment.merchant!.user!.firstName!} ${widget.shipment.merchant!.user!.lastName!}',
                          style: TextStyle(
                              // color: AppColor.lightBlue,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'رقم الهاتف: ${widget.shipment.merchant!.user!.phone!}',
                          style: TextStyle(
                              // color: AppColor.lightBlue,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        Divider(color: Colors.grey[200]),
                        Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: SvgPicture.asset(
                                  "assets/icons/truck_black.svg"),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(
                              AppLocalizations.of(context)!.translate('driver'),
                              style: TextStyle(
                                // color: AppColor.lightBlue,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'اسم السائق: ${widget.shipment.merchant!.user!.firstName!} ${widget.shipment.merchant!.user!.lastName!}',
                          style: TextStyle(
                              // color: AppColor.lightBlue,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'رقم الهاتف: ${widget.shipment.merchant!.user!.phone!}',
                          style: TextStyle(
                              // color: AppColor.lightBlue,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'رقم الشاحنة: ${widget.shipment.truck!.truckuser!.usertruck!.phone!}',
                          style: TextStyle(
                              // color: AppColor.lightBlue,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        Divider(color: Colors.grey[200]),
                        Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: SvgPicture.asset("assets/icons/goods.svg"),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(
                              AppLocalizations.of(context)!
                                  .translate('commodity_name'),
                              style: TextStyle(
                                // color: AppColor.lightBlue,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'البضاعة',
                          style: TextStyle(
                              // color: AppColor.lightBlue,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.shipment.shipmentItems!.length,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 11),
                                  child: Text(
                                    'نوع البضاعة: ${widget.shipment.shipmentItems![index].commodityCategory!.name_ar!} ',
                                    style: TextStyle(
                                        // color: AppColor.lightBlue,
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 11),
                                  child: Text(
                                    'وزن البضاعة: ${widget.shipment.shipmentItems![index].commodityWeight!} طن',
                                    style: TextStyle(
                                        // color: AppColor.lightBlue,
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                index !=
                                        (widget.shipment.shipmentItems!.length -
                                            1)
                                    ? Divider(
                                        color: Colors.grey[200],
                                      )
                                    : const SizedBox.shrink()
                              ],
                            );
                          },
                        ),
                        Divider(color: Colors.grey[200]),
                        Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: SvgPicture.asset(
                                  "assets/icons/location_black.svg"),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(
                              AppLocalizations.of(context)!.translate('path'),
                              style: TextStyle(
                                // color: AppColor.lightBlue,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'المسار',
                          style: TextStyle(
                              // color: AppColor.lightBlue,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.shipment.pathPoints!
                              .singleWhere(
                                  (element) => element.pointType == "P")
                              .name!,
                          style: TextStyle(
                            // color: AppColor.lightBlue,
                            fontSize: 18.sp,
                          ),
                        ),
                        Text(
                          widget.shipment.pathPoints!
                              .singleWhere(
                                  (element) => element.pointType == "D")
                              .name!,
                          style: TextStyle(
                            // color: AppColor.lightBlue,
                            fontSize: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
