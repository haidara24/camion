import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/driver_shipments/inprogress_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/requests/owner_incoming_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/owner_shipments/owner_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/requests/driver_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/truck/owner_trucks_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/providers/truck_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/driver/incoming_shipment_details_screen.dart';
import 'package:camion/views/screens/driver/inprogress_shipment_details_screen.dart';
import 'package:camion/views/widgets/no_reaults_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart' as intel;

class AllIncomingShippmentLogScreen extends StatefulWidget {
  const AllIncomingShippmentLogScreen({Key? key}) : super(key: key);

  @override
  State<AllIncomingShippmentLogScreen> createState() =>
      _AllIncomingShippmentLogScreenState();
}

class _AllIncomingShippmentLogScreenState
    extends State<AllIncomingShippmentLogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int tabIndex = 0;
  int truckId = 0;
  int driverId = 0;
  int selectedTruck = 0;
  final TextEditingController _driverController = TextEditingController();

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

  Widget driversList(List<KTruck> trucks) {
    // Add a truck with id = 0 to the beginning of the list
    List<KTruck> updatedTrucks = [
      KTruck(id: 0, driver_firstname: "All", driver_lastname: ""),
      ...trucks
    ];

    return SizedBox(
      height: 55.h,
      child: ListView.builder(
        itemCount: updatedTrucks.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                print(updatedTrucks[index].truckuser);
                truckId = updatedTrucks[index].id!;
                driverId = updatedTrucks[index].truckuser ?? 0;
                selectedTruck = index;
              });
              if (truckId != 0) {
                BlocProvider.of<DriverRequestsListBloc>(context)
                    .add(DriverRequestsListLoadEvent(driverId));
              } else {
                BlocProvider.of<OwnerIncomingShipmentsBloc>(context)
                    .add(OwnerIncomingShipmentsLoadEvent());
              }
            },
            child: Container(
              width: index == 0 ? 100.w : 130.w,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: selectedTruck == index
                      ? AppColor.deepYellow
                      : Colors.grey[400]!,
                ),
              ),
              child: Center(
                child: SectionTitle(
                  text: index == 0
                      ? "All"
                      : "${updatedTrucks[index].driver_firstname!} ${updatedTrucks[index].driver_lastname!}",
                ),
              ),
            ),
          );
        },
      ),
    );
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
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            body: RefreshIndicator(
              onRefresh: onRefresh,
              child: SingleChildScrollView(
                // physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Consumer<TruckProvider>(
                          builder: (context, truckProvider, child) {
                        return BlocConsumer<OwnerTrucksBloc, OwnerTrucksState>(
                          listener: (context, state) {
                            if (state is OwnerTrucksLoadedSuccess) {
                              truckProvider.setTrucks(state.trucks);
                            }
                          },
                          builder: (context, state) {
                            if (state is OwnerTrucksLoadedSuccess) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  driversList(state.trucks),
                                ],
                              );
                            } else if (state is OwnerTrucksLoadedFailed) {
                              return Center(
                                child: InkWell(
                                  onTap: () {
                                    BlocProvider.of<OwnerTrucksBloc>(context)
                                        .add(OwnerTrucksLoadEvent());
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .translate('list_error'),
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                      const Icon(
                                        Icons.refresh,
                                        color: Colors.grey,
                                      )
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return const Center(
                                child: LinearProgressIndicator(),
                              );
                            }
                          },
                        );
                      }),
                    ),
                    truckId == 0
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: BlocBuilder<OwnerIncomingShipmentsBloc,
                                OwnerIncomingShipmentsState>(
                              builder: (context, state) {
                                if (state
                                    is OwnerIncomingShipmentsLoadedSuccess) {
                                  return state.requests.isEmpty
                                      ? NoResultsWidget(
                                          text: AppLocalizations.of(context)!
                                              .translate('no_in_orders'))
                                      : ListView.builder(
                                          itemCount: state.requests.length,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return state.requests[index]
                                                        .responseTurn ==
                                                    "D"
                                                ? InkWell(
                                                    onTap: () {
                                                      // BlocProvider.of<
                                                      //             SubShipmentDetailsBloc>(
                                                      //         context)
                                                      //     .add(SubShipmentDetailsLoadEvent(
                                                      //         state
                                                      //             .requests[
                                                      //                 index]
                                                      //             .subshipment!
                                                      //             .id!));
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              IncomingShipmentDetailsScreen(
                                                            objectId: state
                                                                .requests[index]
                                                                .subshipment!
                                                                .id!,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: AbsorbPointer(
                                                      absorbing: false,
                                                      child: Card(
                                                        color: Colors.white,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(10),
                                                          ),
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 80.h,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                  width: 1,
                                                                ),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "${AppLocalizations.of(context)!.translate("merchant_name")}: ${state.requests[index].subshipment!.firstname!} ${state.requests[index].subshipment!.lastname!}",
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              TextStyle(
                                                                            // color: AppColor.lightBlue,
                                                                            fontSize:
                                                                                17.sp,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "${AppLocalizations.of(context)!.translate("driver_name")}: ${state.requests[index].driver_firstname!} ${state.requests[index].driver_lastname!}",
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              TextStyle(
                                                                            // color: AppColor.lightBlue,
                                                                            fontSize:
                                                                                17.sp,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            11),
                                                                    child: Text(
                                                                      '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.requests[index].subshipment!.id!}',
                                                                      style: TextStyle(
                                                                          // color: AppColor.lightBlue,
                                                                          fontSize: 18.sp,
                                                                          fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            ShipmentPathVerticalWidget(
                                                              pathpoints: state
                                                                  .requests[
                                                                      index]
                                                                  .subshipment!
                                                                  .pathpoints!,
                                                              pickupDate: state
                                                                  .requests[
                                                                      index]
                                                                  .subshipment!
                                                                  .pickupDate!,
                                                              deliveryDate: state
                                                                  .requests[
                                                                      index]
                                                                  .subshipment!
                                                                  .pickupDate!,
                                                              langCode: localeState
                                                                  .value
                                                                  .languageCode,
                                                              mini: true,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink();
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
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: BlocConsumer<DriverRequestsListBloc,
                                DriverRequestsListState>(
                              listener: (context, state) {
                                print(state);
                              },
                              builder: (context, state) {
                                if (state is DriverRequestsListLoadedSuccess) {
                                  return state.requests.isEmpty
                                      ? NoResultsWidget(
                                          text: AppLocalizations.of(context)!
                                              .translate('no_in_orders'))
                                      : ListView.builder(
                                          itemCount: state.requests.length,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return state.requests[index]
                                                        .responseTurn ==
                                                    "D"
                                                ? InkWell(
                                                    onTap: () {
                                                      // BlocProvider.of<
                                                      //             SubShipmentDetailsBloc>(
                                                      //         context)
                                                      //     .add(SubShipmentDetailsLoadEvent(
                                                      //         state
                                                      //             .requests[
                                                      //                 index]
                                                      //             .subshipment!
                                                      //             .id!));
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              IncomingShipmentDetailsScreen(
                                                            objectId: state
                                                                .requests[index]
                                                                .subshipment!
                                                                .id!,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: AbsorbPointer(
                                                      absorbing: false,
                                                      child: Card(
                                                        color: Colors.white,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(10),
                                                          ),
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 48.h,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                  width: 1,
                                                                ),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "${AppLocalizations.of(context)!.translate("merchant_name")}: ${state.requests[index].subshipment!.firstname!} ${state.requests[index].subshipment!.lastname!}",
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        TextStyle(
                                                                      // color: AppColor.lightBlue,
                                                                      fontSize:
                                                                          17.sp,
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            11),
                                                                    child: Text(
                                                                      '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.requests[index].subshipment!.id!}',
                                                                      style: TextStyle(
                                                                          // color: AppColor.lightBlue,
                                                                          fontSize: 18.sp,
                                                                          fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            ShipmentPathVerticalWidget(
                                                              pathpoints: state
                                                                  .requests[
                                                                      index]
                                                                  .subshipment!
                                                                  .pathpoints!,
                                                              pickupDate: state
                                                                  .requests[
                                                                      index]
                                                                  .subshipment!
                                                                  .pickupDate!,
                                                              deliveryDate: state
                                                                  .requests[
                                                                      index]
                                                                  .subshipment!
                                                                  .pickupDate!,
                                                              langCode: localeState
                                                                  .value
                                                                  .languageCode,
                                                              mini: true,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink();
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
          ),
        );
      },
    );
  }
}
