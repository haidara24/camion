import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/managment/managment_shipment_update_status_bloc.dart';
import 'package:camion/business_logic/bloc/managment/shipment_update_status_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/kshipment_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intel;

class ManagmentShipmentDetailsScreen extends StatefulWidget {
  final ManagmentShipment shipment;
  ManagmentShipmentDetailsScreen({Key? key, required this.shipment})
      : super(key: key);

  @override
  State<ManagmentShipmentDetailsScreen> createState() =>
      _ManagmentShipmentDetailsScreenState();
}

class _ManagmentShipmentDetailsScreenState
    extends State<ManagmentShipmentDetailsScreen> {
  var f = intel.NumberFormat("#,###", "en_US");

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
                title:
                    AppLocalizations.of(context)!.translate('shipment_details'),
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
                          ),
                        ),
                        Text(
                          'رقم الهاتف: ${widget.shipment.merchant!.user!.phone!}',
                          style: TextStyle(
                            // color: AppColor.lightBlue,
                            fontSize: 18.sp,
                          ),
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
                          ),
                        ),
                        Text(
                          'رقم الهاتف: ${widget.shipment.merchant!.user!.phone!}',
                          style: TextStyle(
                            // color: AppColor.lightBlue,
                            fontSize: 18.sp,
                          ),
                        ),
                        Text(
                          'رقم الشاحنة: ${widget.shipment.truck!.truckuser!.usertruck!.phone!}',
                          style: TextStyle(
                            // color: AppColor.lightBlue,
                            fontSize: 18.sp,
                          ),
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
                          "التحميل: ${widget.shipment.pathPoints!.singleWhere((element) => element.pointType == "P").name!}",
                          style: TextStyle(
                            // color: AppColor.lightBlue,
                            fontSize: 18.sp,
                          ),
                        ),
                        Text(
                          "التفريغ: ${widget.shipment.pathPoints!.singleWhere((element) => element.pointType == "D").name!}",
                          style: TextStyle(
                            // color: AppColor.lightBlue,
                            fontSize: 18.sp,
                          ),
                        ),
                        Divider(color: Colors.grey[200]),
                        Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: SvgPicture.asset("assets/icons/costs.svg"),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(
                              AppLocalizations.of(context)!.translate('costs'),
                              style: TextStyle(
                                // color: AppColor.lightBlue,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'رسم عبور البضاعة: 3,500,000 ل.س',
                          style: TextStyle(
                            // color: AppColor.lightBlue,
                            fontSize: 18.sp,
                          ),
                        ),
                        Text(
                          'رسم تفتيش الساحة: 1,000,000 ل.س',
                          style: TextStyle(
                            // color: AppColor.lightBlue,
                            fontSize: 18.sp,
                          ),
                        ),
                        Text(
                          'الإجمالي: 4,500,000 ل.س',
                          style: TextStyle(
                            // color: AppColor.lightBlue,
                            fontSize: 18.sp,
                          ),
                        ),
                        Divider(color: Colors.grey[200]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            BlocConsumer<ShipmentUpdateStatusBloc,
                                ShipmentUpdateStatusState>(
                              listener: (context, state) {
                                if (state
                                    is ShipmentUpdateStatusLoadedSuccess) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ControlView(),
                                      ));
                                }
                              },
                              builder: (context, state) {
                                if (state
                                    is ShipmentUpdateStatusLoadingProgress) {
                                  return CustomButton(
                                    title: SizedBox(
                                        width: 90.w, child: LoadingIndicator()),
                                    onTap: () {},
                                  );
                                } else {
                                  return CustomButton(
                                    title: SizedBox(
                                        width: 90.w,
                                        child: const Center(
                                            child: Text("موافقة"))),
                                    onTap: () {
                                      BlocProvider.of<ShipmentUpdateStatusBloc>(
                                              context)
                                          .add(ShipmentStatusUpdateEvent(
                                              widget.shipment.id!, "C"));
                                    },
                                  );
                                }
                              },
                            ),
                            BlocConsumer<ManagmentShipmentUpdateStatusBloc,
                                ManagmentShipmentUpdateStatusState>(
                              listener: (context, state) {
                                if (state
                                    is ManagmentShipmentUpdateStatusLoadedSuccess) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ControlView(),
                                      ));
                                }
                              },
                              builder: (context, state) {
                                if (state
                                    is ManagmentShipmentUpdateStatusLoadingProgress) {
                                  return CustomButton(
                                    title: SizedBox(
                                        width: 90.w, child: LoadingIndicator()),
                                    onTap: () {},
                                  );
                                } else {
                                  return CustomButton(
                                    title: SizedBox(
                                        width: 90.w,
                                        child:
                                            const Center(child: Text("رفض"))),
                                    onTap: () {
                                      BlocProvider.of<
                                                  ManagmentShipmentUpdateStatusBloc>(
                                              context)
                                          .add(
                                              UpdateStatusManagmentShipmentEvent(
                                                  widget.shipment.id!, "F"));
                                    },
                                  );
                                }
                              },
                            ),
                          ],
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
