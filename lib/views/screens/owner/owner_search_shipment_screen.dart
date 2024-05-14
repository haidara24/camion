import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/driver_shipments/unassigned_shipment_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/driver/search_shipment_details_screen.dart';
import 'package:camion/views/widgets/shipment_path_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart' as intel;

class OwnerSearchShippmentScreen extends StatelessWidget {
  OwnerSearchShippmentScreen({Key? key}) : super(key: key);

  var f = intel.NumberFormat("#,###", "en_US");

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

  @override
  Widget build(BuildContext context) {
    final playDuration = 600.ms;
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColor.lightGrey200,
            body: SingleChildScrollView(
              // physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 5.h,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BlocBuilder<UnassignedShipmentListBloc,
                        UnassignedShipmentListState>(
                      builder: (context, state) {
                        if (state is UnassignedShipmentListLoadedSuccess) {
                          return state.shipments.isEmpty
                              ? Center(
                                  child: Text(AppLocalizations.of(context)!
                                      .translate('no_shipments')),
                                )
                              : ListView.builder(
                                  itemCount: state.shipments.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    // DateTime now = DateTime.now();
                                    // Duration diff = now
                                    //     .difference(state.offers[index].createdDate!);
                                    return InkWell(
                                      onTap: () {
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //       builder: (context) =>
                                        //           SearchShipmentDetailsScreen(
                                        //               shipment: state
                                        //                   .shipments[index],
                                        //               isOwner: true),
                                        //     ));
                                      },
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
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                contentPadding: EdgeInsets.zero,
                                                enabled: false,
                                                leading: Container(
                                                  height: 75.h,
                                                  width: 75.w,
                                                  decoration: BoxDecoration(
                                                      // color: AppColor.lightGoldenYellow,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: localeState.value
                                                                  .languageCode ==
                                                              'en'
                                                          ? SvgPicture.asset(
                                                              "assets/icons/truck_en.svg",
                                                              height: 55.h,
                                                              width: 55.w,
                                                              fit: BoxFit.fill,
                                                            )
                                                              .animate(
                                                                  delay: 600.ms)
                                                              .shimmer(
                                                                  duration:
                                                                      playDuration -
                                                                          200
                                                                              .ms)
                                                              .flip()
                                                          : SvgPicture.asset(
                                                              "assets/icons/truck_ar.svg",
                                                              height: 55.h,
                                                              width: 55.w,
                                                              fit: BoxFit.fill,
                                                            )
                                                              .animate(
                                                                  delay: 600.ms)
                                                              .shimmer(
                                                                  duration:
                                                                      playDuration -
                                                                          200.ms)
                                                              .flip(),
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
                                                        SizedBox(
                                                          height: 7.h,
                                                        ),
                                                        Text(
                                                          '${AppLocalizations.of(context)!.translate('commodity_type')}: ${state.shipments[index].shipmentItems![0].commodityName!}',
                                                          style: TextStyle(
                                                            // color: AppColor.lightBlue,
                                                            fontSize: 17.sp,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 7.h,
                                                        ),
                                                        Text(
                                                          '${AppLocalizations.of(context)!.translate('commodity_weight')}: ${f.format(state.shipments[index].shipmentItems![0].commodityWeight!)} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}',
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
                                      ).animate().slideX(
                                          duration: 350.ms,
                                          delay: 0.ms,
                                          begin: 1,
                                          end: 0,
                                          curve: Curves.easeInOutSine),
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
        );
      },
    );
  }
}
