import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/managment/complete_managment_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/managment_shipment_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/managment/complete_shipmenet_details.dart';
import 'package:camion/views/screens/managment/log_shipment_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timelines/timelines.dart';
import 'package:intl/intl.dart' as intel;

class ManagmentLogScreen extends StatefulWidget {
  ManagmentLogScreen({Key? key}) : super(key: key);

  @override
  State<ManagmentLogScreen> createState() => _ManagmentLogScreenState();
}

class _ManagmentLogScreenState extends State<ManagmentLogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int tabIndex = 0;

  var f = intel.NumberFormat("#,###", "en_US");

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

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
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                    child: TabBar(
                      controller: _tabController,
                      onTap: (value) {
                        switch (value) {
                          case 0:
                            print("asd");
                            BlocProvider.of<ManagmentShipmentListBloc>(context)
                                .add(ManagmentShipmentListLoadEvent("P"));
                            break;
                          case 1:
                            BlocProvider.of<CompleteManagmentShipmentListBloc>(
                                    context)
                                .add(CompleteManagmentShipmentListLoadEvent(
                                    "C"));
                            break;
                          default:
                        }
                        setState(() {
                          tabIndex = value;
                        });
                      },
                      tabs: [
                        // first tab [you can add an icon using the icon property]
                        Tab(
                          child: Center(
                              child: Text(AppLocalizations.of(context)!
                                  .translate('pending'))),
                        ),

                        Tab(
                          child: Center(
                              child: Text(AppLocalizations.of(context)!
                                  .translate('running'))),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: tabIndex == 0
                        ? BlocConsumer<ManagmentShipmentListBloc,
                            ManagmentShipmentListState>(
                            listener: (context, state) {
                              if (state is ManagmentShipmentListLoadedFailed) {
                                print(state.error);
                              }
                            },
                            builder: (context, state) {
                              if (state is ManagmentShipmentListLoadedSuccess) {
                                return state.shipments.isEmpty
                                    ? Center(
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .translate('no_shipments')),
                                      )
                                    : ListView.builder(
                                        itemCount: state.shipments.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          // DateTime now = DateTime.now();
                                          // Duration diff = now
                                          //     .difference(state.offers[index].createdDate!);
                                          return InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ManagmentShipmentDetailsScreen(
                                                            shipment:
                                                                state.shipments[
                                                                    index]),
                                                  ));
                                            },
                                            child: Card(
                                              shape:
                                                  const RoundedRectangleBorder(
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
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'اسم التاجر: ${state.shipments[index].merchant!.user!.firstName!} ${state.shipments[index].merchant!.user!.lastName!}',
                                                            style: TextStyle(
                                                                // color: AppColor.lightBlue,
                                                                fontSize: 18.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.shipments[index].id!}',
                                                            style: TextStyle(
                                                                // color: AppColor.lightBlue,
                                                                fontSize: 18.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 7,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 11),
                                                      child: Text(
                                                        'نوع البضاعة: ${state.shipments[index].shipmentItems![0].commodityCategory!.name_ar!} ',
                                                        style: TextStyle(
                                                            // color: AppColor.lightBlue,
                                                            fontSize: 17.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 7,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 11),
                                                      child: Text(
                                                        'وزن البضاعة: ${state.shipments[index].totalWeight!} طن',
                                                        style: TextStyle(
                                                            // color: AppColor.lightBlue,
                                                            fontSize: 17.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 7,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 11),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'المسار: ',
                                                            style: TextStyle(
                                                                // color: AppColor.lightBlue,
                                                                fontSize: 17.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Spacer(),
                                                          // ShipmentPathWidget(
                                                          //   pickupName: state
                                                          //       .shipments[
                                                          //           index]
                                                          //       .pathPoints!
                                                          //       .singleWhere(
                                                          //           (element) =>
                                                          //               element
                                                          //                   .pointType ==
                                                          //               "P")
                                                          //       .name!,
                                                          //   deliveryName: state
                                                          //       .shipments[
                                                          //           index]
                                                          //       .pathPoints!
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
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 7,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          height: 250.h,
                                          width: double.infinity,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ],
                                    ),
                                    itemCount: 6,
                                  ),
                                );
                              }
                            },
                          )
                        : BlocConsumer<CompleteManagmentShipmentListBloc,
                            CompleteManagmentShipmentListState>(
                            listener: (context, state) {
                              if (state
                                  is CompleteManagmentShipmentListLoadedFailed) {
                                print(state.error);
                              }
                            },
                            builder: (context, state) {
                              if (state
                                  is CompleteManagmentShipmentListLoadedSuccess) {
                                return state.shipments.isEmpty
                                    ? Center(
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .translate('no_shipments')),
                                      )
                                    : ListView.builder(
                                        itemCount: state.shipments.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          // DateTime now = DateTime.now();
                                          // Duration diff = now
                                          //     .difference(state.offers[index].createdDate!);
                                          return InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CompleteManagmentShipmentDetailsScreen(
                                                            shipment:
                                                                state.shipments[
                                                                    index]),
                                                  ));
                                            },
                                            child: Card(
                                              shape:
                                                  const RoundedRectangleBorder(
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
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'اسم التاجر: ${state.shipments[index].merchant!.user!.firstName!} ${state.shipments[index].merchant!.user!.lastName!}',
                                                            style: TextStyle(
                                                                // color: AppColor.lightBlue,
                                                                fontSize: 18.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.shipments[index].id!}',
                                                            style: TextStyle(
                                                                // color: AppColor.lightBlue,
                                                                fontSize: 18.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 7,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 11),
                                                      child: Text(
                                                        'نوع البضاعة: ${state.shipments[index].shipmentItems![0].commodityCategory!.name_ar!} ',
                                                        style: TextStyle(
                                                            // color: AppColor.lightBlue,
                                                            fontSize: 17.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 7,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 11),
                                                      child: Text(
                                                        'وزن البضاعة: ${state.shipments[index].totalWeight!} طن',
                                                        style: TextStyle(
                                                            // color: AppColor.lightBlue,
                                                            fontSize: 17.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 7,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          height: 250.h,
                                          width: double.infinity,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
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
