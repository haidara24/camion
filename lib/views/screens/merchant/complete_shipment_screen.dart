import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_complete_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intel;
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class CompleteShipmentScreen extends StatelessWidget {
  CompleteShipmentScreen({Key? key}) : super(key: key);
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
              backgroundColor: Colors.grey[100],
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.translate('shippment_log'),
              ),
              body: SingleChildScrollView(
                // physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BlocBuilder<ShipmentCompleteListBloc,
                          ShipmentCompleteListState>(
                        builder: (context, state) {
                          if (state is ShipmentCompleteListLoadedSuccess) {
                            return state.shipments.isEmpty
                                ? Center(
                                    child: Text(AppLocalizations.of(context)!
                                        .translate('no_shipments')),
                                  )
                                : ListView.builder(
                                    itemCount: state.shipments.length,
                                    // physics:
                                    //     const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      // DateTime now = DateTime.now();
                                      // Duration diff = now
                                      //     .difference(state.offers[index].createdDate!);
                                      return InkWell(
                                        onTap: () {},
                                        child: Card(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5.h),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 11),
                                                  child: Text(
                                                    '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.shipments[index].id!}',
                                                    style: TextStyle(
                                                        // color: AppColor.lightBlue,
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  enabled: false,
                                                  leading: Container(
                                                    height: 75.h,
                                                    width: 75.w,
                                                    decoration: BoxDecoration(
                                                        // color: AppColor.lightGoldenYellow,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Center(
                                                      child: SvgPicture.asset(
                                                        "assets/icons/commodity_icon.svg",
                                                        height: 55.h,
                                                        width: 55.w,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // ShipmentPathWidget(
                                                          //   pickupName: state
                                                          //       .shipments[
                                                          //           index]
                                                          //       .subshipments![
                                                          //           0]
                                                          //       .pathpoints!
                                                          //       .singleWhere(
                                                          //           (element) =>
                                                          //               element
                                                          //                   .pointType ==
                                                          //               "P")
                                                          //       .name!,
                                                          //   deliveryName: state
                                                          //       .shipments[
                                                          //           index]
                                                          //       .subshipments![
                                                          //           0]
                                                          //       .pathpoints!
                                                          //       .singleWhere(
                                                          //           (element) =>
                                                          //               element
                                                          //                   .pointType ==
                                                          //               "D")
                                                          //       .name!,
                                                          //   width: MediaQuery.of(
                                                          //               context)
                                                          //           .size
                                                          //           .width *
                                                          //       .66,
                                                          //   pathwidth:
                                                          //       MediaQuery.of(
                                                          //                   context)
                                                          //               .size
                                                          //               .width *
                                                          //           .56,
                                                          // ).animate().slideX(
                                                          //     duration: 300.ms,
                                                          //     delay: 0.ms,
                                                          //     begin: 1,
                                                          //     end: 0,
                                                          //     curve: Curves
                                                          //         .easeInOutSine),
                                                          SizedBox(
                                                            height: 7.h,
                                                          ),
                                                          Text(
                                                            '${AppLocalizations.of(context)!.translate('commodity_type')}: ${state.shipments[index].subshipments![0].shipmentItems![0].commodityName!}',
                                                            style: TextStyle(
                                                              // color: AppColor.lightBlue,
                                                              fontSize: 17.sp,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 7.h,
                                                          ),
                                                          Text(
                                                            '${AppLocalizations.of(context)!.translate('commodity_weight')}: ${f.format(state.shipments[index].subshipments![0].shipmentItems![0].commodityWeight!)} kg',
                                                            style: TextStyle(
                                                              // color: AppColor.lightBlue,
                                                              fontSize: 17.sp,
                                                            ),
                                                          ),

                                                          // // Text(
                                                          //     'نوع البضاعة: ${state.offers[index].product!.label!}'),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  dense: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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
                                      height: 250.h,
                                      width: double.infinity,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                                itemCount: 6,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
