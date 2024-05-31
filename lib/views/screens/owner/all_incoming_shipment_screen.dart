import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/driver_shipments/incoming_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/inprogress_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/owner_shipments/owner_incoming_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/owner_shipments/owner_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/truck/owner_trucks_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/providers/truck_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/driver/incoming_shipment_details_screen.dart';
import 'package:camion/views/widgets/shipment_path_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart' as intel;

class AllIncomingShippmentLogScreen extends StatefulWidget {
  AllIncomingShippmentLogScreen({Key? key}) : super(key: key);

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
                            if (truckId == 0) {
                              BlocProvider.of<OwnerShipmentListBloc>(context)
                                  .add(OwnerShipmentListLoadEvent("P"));
                            } else {
                              BlocProvider.of<OwnerIncomingShipmentsBloc>(
                                      context)
                                  .add(OwnerIncomingShipmentsLoadEvent(
                                      "P", truckId));
                            }
                            break;
                          case 1:
                            if (truckId == 0) {
                              BlocProvider.of<OwnerShipmentListBloc>(context)
                                  .add(OwnerShipmentListLoadEvent("R"));
                            } else {
                              BlocProvider.of<OwnerIncomingShipmentsBloc>(
                                      context)
                                  .add(OwnerIncomingShipmentsLoadEvent(
                                      "R", truckId));
                            }
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
                                  .translate('inprogress'))),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
                            print("state.trucks.length");
                            print(state.trucks.length);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonHideUnderline(
                                  child: DropdownButton2<KTruck?>(
                                    isExpanded: true,
                                    barrierLabel: AppLocalizations.of(context)!
                                        .translate('select_driver'),
                                    hint: Text(
                                      AppLocalizations.of(context)!
                                          .translate('select_driver'),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    items: state.trucks
                                        .map((KTruck item) =>
                                            DropdownMenuItem<KTruck>(
                                              value: item,
                                              child: Text(
                                                "${item.truckuser!.usertruck!.firstName!} ${item.truckuser!.usertruck!.lastName!}",
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    value: truckProvider.selectedTruck,
                                    onChanged: (KTruck? value) {
                                      truckProvider.setSelectedTruck(value!);
                                      setState(() {
                                        truckId = value.truckuser!.id!;
                                      });
                                      if (truckId != 0) {
                                        BlocProvider.of<
                                                    OwnerIncomingShipmentsBloc>(
                                                context)
                                            .add(
                                                OwnerIncomingShipmentsLoadEvent(
                                                    tabIndex == 0 ? "P" : "R",
                                                    value.truckuser!.id!));
                                      } else {
                                        if (tabIndex == 0) {
                                          BlocProvider.of<
                                                      OwnerShipmentListBloc>(
                                                  context)
                                              .add(OwnerShipmentListLoadEvent(
                                                  "P"));
                                        } else {
                                          BlocProvider.of<
                                                      OwnerShipmentListBloc>(
                                                  context)
                                              .add(OwnerShipmentListLoadEvent(
                                                  "R"));
                                        }
                                      }
                                    },
                                    buttonStyleData: ButtonStyleData(
                                      height: 50,
                                      width: double.infinity,

                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9.0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.black26,
                                        ),
                                        color: Colors.white,
                                      ),
                                      // elevation: 2,
                                    ),
                                    iconStyleData: IconStyleData(
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_sharp,
                                      ),
                                      iconSize: 20,
                                      iconEnabledColor: AppColor.lightYellow,
                                      iconDisabledColor: Colors.grey,
                                    ),
                                    dropdownSearchData: DropdownSearchData(
                                      searchController: _driverController,
                                      searchInnerWidgetHeight: 60,
                                      searchInnerWidget: Container(
                                        height: 60,
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 4,
                                          right: 8,
                                          left: 8,
                                        ),
                                        child: TextFormField(
                                          expands: true,
                                          maxLines: null,
                                          controller: _driverController,
                                          onTapOutside: (event) {
                                            BlocProvider.of<BottomNavBarCubit>(
                                                    context)
                                                .emitShow();
                                          },
                                          onTap: () {
                                            BlocProvider.of<BottomNavBarCubit>(
                                                    context)
                                                .emitHide();
                                            _driverController.selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        _driverController
                                                            .value.text.length);
                                          },
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            hintText:
                                                AppLocalizations.of(context)!
                                                    .translate('select_driver'),
                                            hintStyle:
                                                const TextStyle(fontSize: 17),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onFieldSubmitted: (value) {
                                            BlocProvider.of<BottomNavBarCubit>(
                                                    context)
                                                .emitShow();
                                          },
                                        ),
                                      ),
                                      searchMatchFn: (item, searchValue) {
                                        print(searchValue);
                                        print(item.value!.truckuser!.usertruck!
                                            .firstName!);
                                        return item.value!.truckuser!.usertruck!
                                            .firstName!
                                            .contains(searchValue);
                                      },
                                    ),
                                    onMenuStateChange: (isOpen) {
                                      if (!isOpen) {
                                        _driverController.clear();
                                      }
                                    },
                                    dropdownStyleData: DropdownStyleData(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: Colors.white,
                                      ),
                                      scrollbarTheme: ScrollbarThemeData(
                                        radius: const Radius.circular(40),
                                        thickness: MaterialStateProperty.all(6),
                                        thumbVisibility:
                                            MaterialStateProperty.all(true),
                                      ),
                                    ),
                                    menuItemStyleData: MenuItemStyleData(
                                      height: 40.h,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else if (state is OwnerTrucksLoadedFailed) {
                            return Center(
                              child: InkWell(
                                onTap: () {
                                  // BlocProvider.of<
                                  //             OwnerTrucksBloc>(
                                  //         context)
                                  //     .add(
                                  //         OwnerTrucksLoadEvent());
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .translate('list_error'),
                                      style: const TextStyle(color: Colors.red),
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
                          child: tabIndex == 0
                              ? BlocBuilder<OwnerShipmentListBloc,
                                  OwnerShipmentListState>(
                                  builder: (context, state) {
                                    if (state
                                        is OwnerShipmentListLoadedSuccess) {
                                      return state.shipments.isEmpty
                                          ? Center(
                                              child: Text(AppLocalizations.of(
                                                      context)!
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
                                                    Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    100))
                                                        .then(
                                                      (value) => Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              IncomingShipmentDetailsScreen(
                                                                  requestId: 0),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Card(
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(10),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5.h),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        11),
                                                            child: Text(
                                                              '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.shipments[index].id!}',
                                                              style: TextStyle(
                                                                  // color: AppColor.lightBlue,
                                                                  fontSize:
                                                                      18.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          ListTile(
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            enabled: false,
                                                            leading: Column(
                                                              children: [
                                                                Container(
                                                                  height: 55.h,
                                                                  width: 75.w,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                  child: Center(
                                                                    child: localeState.value.languageCode ==
                                                                            'en'
                                                                        ? SvgPicture
                                                                                .asset(
                                                                            "assets/icons/truck_en.svg",
                                                                            height:
                                                                                45.h,
                                                                            width:
                                                                                55.w,
                                                                            fit:
                                                                                BoxFit.fill,
                                                                          )
                                                                            .animate(delay: 600.ms)
                                                                            .shimmer(duration: playDuration - 200.ms)
                                                                            .flip()
                                                                        : SvgPicture.asset(
                                                                            "assets/icons/truck_ar.svg",
                                                                            height:
                                                                                45.h,
                                                                            width:
                                                                                55.w,
                                                                            fit:
                                                                                BoxFit.fill,
                                                                          ).animate(delay: 600.ms).shimmer(duration: playDuration - 200.ms).flip(),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          3.0),
                                                                  child:
                                                                      SizedBox(
                                                                    width: 75.w,
                                                                    child:
                                                                        FittedBox(
                                                                      fit: BoxFit
                                                                          .scaleDown,
                                                                      child:
                                                                          Text(
                                                                        "${state.shipments[index].driver!.user!.firstName!} ${state.shipments[index].driver!.user!.lastName!}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.black),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
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
                                                                    ShipmentPathWidget(
                                                                      loadDate: setLoadDate(state
                                                                          .shipments[
                                                                              index]
                                                                          .pickupDate!),
                                                                      pickupName: state
                                                                          .shipments[
                                                                              index]
                                                                          .pickupCityLocation!,
                                                                      deliveryName: state
                                                                          .shipments[
                                                                              index]
                                                                          .deliveryCityLocation!,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .66,
                                                                      pathwidth:
                                                                          MediaQuery.of(context).size.width *
                                                                              .56,
                                                                    ).animate().slideX(
                                                                        duration: 300
                                                                            .ms,
                                                                        delay: 0
                                                                            .ms,
                                                                        begin:
                                                                            1,
                                                                        end: 0,
                                                                        curve: Curves
                                                                            .easeInOutSine),
                                                                    SizedBox(
                                                                      height:
                                                                          7.h,
                                                                    ),
                                                                    Text(
                                                                      '${AppLocalizations.of(context)!.translate('commodity_type')}: ${state.shipments[index].shipmentItems![0].commodityName!}',
                                                                      style:
                                                                          TextStyle(
                                                                        // color: AppColor.lightBlue,
                                                                        fontSize:
                                                                            17.sp,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          7.h,
                                                                    ),
                                                                    Text(
                                                                      '${AppLocalizations.of(context)!.translate('commodity_weight')}: ${f.format(state.shipments[index].shipmentItems![0].commodityWeight!)} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}',
                                                                      style:
                                                                          TextStyle(
                                                                        // color: AppColor.lightBlue,
                                                                        fontSize:
                                                                            17.sp,
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
                                                      curve:
                                                          Curves.easeInOutSine),
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
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 5),
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
                              : BlocBuilder<OwnerShipmentListBloc,
                                  OwnerShipmentListState>(
                                  builder: (context, state) {
                                    if (state
                                        is OwnerShipmentListLoadedSuccess) {
                                      return state.shipments.isEmpty
                                          ? Center(
                                              child: Text(AppLocalizations.of(
                                                      context)!
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
                                                    // Navigator.push(
                                                    //     context,
                                                    //     MaterialPageRoute(
                                                    //       builder: (context) =>
                                                    //           IncomingShipmentDetailsScreen(
                                                    //               shipment:
                                                    //                   state.shipments[
                                                    //                       index]),
                                                    //     ));
                                                  },
                                                  child: Card(
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(10),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5.h),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        11),
                                                            child: Text(
                                                              '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.shipments[index].id!}',
                                                              style: TextStyle(
                                                                  // color: AppColor.lightBlue,
                                                                  fontSize:
                                                                      18.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          ListTile(
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            enabled: false,
                                                            leading: Column(
                                                              children: [
                                                                Container(
                                                                  height: 55.h,
                                                                  width: 75.w,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          // color: AppColor.lightGoldenYellow,
                                                                          borderRadius:
                                                                              BorderRadius.circular(5)),
                                                                  child: Center(
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: localeState.value.languageCode ==
                                                                              'en'
                                                                          ? SvgPicture
                                                                              .asset(
                                                                              "assets/icons/truck_en.svg",
                                                                              height: 45.h,
                                                                              width: 55.w,
                                                                              fit: BoxFit.fill,
                                                                            ).animate(delay: 600.ms).shimmer(duration: playDuration - 200.ms).flip()
                                                                          : SvgPicture.asset(
                                                                              "assets/icons/truck_ar.svg",
                                                                              height: 45.h,
                                                                              width: 55.w,
                                                                              fit: BoxFit.fill,
                                                                            ).animate(delay: 600.ms).shimmer(duration: playDuration - 200.ms).flip(),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          3.0),
                                                                  child:
                                                                      SizedBox(
                                                                    width: 75.w,
                                                                    child:
                                                                        FittedBox(
                                                                      fit: BoxFit
                                                                          .scaleDown,
                                                                      child:
                                                                          Text(
                                                                        "${state.shipments[index].driver!.user!.firstName!} ${state.shipments[index].driver!.user!.lastName!}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.black),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
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
                                                                    ShipmentPathWidget(
                                                                      loadDate: setLoadDate(state
                                                                          .shipments[
                                                                              index]
                                                                          .pickupDate!),
                                                                      pickupName: state
                                                                          .shipments[
                                                                              index]
                                                                          .pickupCityLocation!,
                                                                      deliveryName: state
                                                                          .shipments[
                                                                              index]
                                                                          .deliveryCityLocation!,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .66,
                                                                      pathwidth:
                                                                          MediaQuery.of(context).size.width *
                                                                              .56,
                                                                    ).animate().slideX(
                                                                        duration: 300
                                                                            .ms,
                                                                        delay: 0
                                                                            .ms,
                                                                        begin:
                                                                            1,
                                                                        end: 0,
                                                                        curve: Curves
                                                                            .easeInOutSine),
                                                                    SizedBox(
                                                                      height:
                                                                          7.h,
                                                                    ),
                                                                    Text(
                                                                      '${AppLocalizations.of(context)!.translate('commodity_type')}: ${state.shipments[index].shipmentItems![0].commodityName!}',
                                                                      style:
                                                                          TextStyle(
                                                                        // color: AppColor.lightBlue,
                                                                        fontSize:
                                                                            17.sp,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          7.h,
                                                                    ),
                                                                    Text(
                                                                      '${AppLocalizations.of(context)!.translate('commodity_weight')}: ${f.format(state.shipments[index].shipmentItems![0].commodityWeight!)} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}',
                                                                      style:
                                                                          TextStyle(
                                                                        // color: AppColor.lightBlue,
                                                                        fontSize:
                                                                            17.sp,
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
                                                      curve:
                                                          Curves.easeInOutSine),
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
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 5),
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
                          child: tabIndex == 0
                              ? BlocBuilder<OwnerIncomingShipmentsBloc,
                                  OwnerIncomingShipmentsState>(
                                  builder: (context, state) {
                                    if (state
                                        is OwnerIncomingShipmentsLoadedSuccess) {
                                      return state.shipments.isEmpty
                                          ? Center(
                                              child: Text(AppLocalizations.of(
                                                      context)!
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
                                                    Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    100))
                                                        .then(
                                                      (value) => Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              IncomingShipmentDetailsScreen(
                                                                  requestId: 0),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Card(
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(10),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5.h),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        11),
                                                            child: Text(
                                                              '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.shipments[index].id!}',
                                                              style: TextStyle(
                                                                  // color: AppColor.lightBlue,
                                                                  fontSize:
                                                                      18.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          ListTile(
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            enabled: false,
                                                            leading: Container(
                                                              height: 75.h,
                                                              width: 75.w,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      // color: AppColor.lightGoldenYellow,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                              child: Center(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: localeState
                                                                              .value
                                                                              .languageCode ==
                                                                          'en'
                                                                      ? SvgPicture
                                                                              .asset(
                                                                          "assets/icons/truck_en.svg",
                                                                          height:
                                                                              55.h,
                                                                          width:
                                                                              55.w,
                                                                          fit: BoxFit
                                                                              .fill,
                                                                        )
                                                                          .animate(
                                                                              delay: 600
                                                                                  .ms)
                                                                          .shimmer(
                                                                              duration: playDuration -
                                                                                  200
                                                                                      .ms)
                                                                          .flip()
                                                                      : SvgPicture
                                                                              .asset(
                                                                          "assets/icons/truck_ar.svg",
                                                                          height:
                                                                              55.h,
                                                                          width:
                                                                              55.w,
                                                                          fit: BoxFit
                                                                              .fill,
                                                                        )
                                                                          .animate(
                                                                              delay: 600.ms)
                                                                          .shimmer(duration: playDuration - 200.ms)
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
                                                                    ShipmentPathWidget(
                                                                      loadDate: setLoadDate(state
                                                                          .shipments[
                                                                              index]
                                                                          .pickupDate!),
                                                                      pickupName: state
                                                                          .shipments[
                                                                              index]
                                                                          .pickupCityLocation!,
                                                                      deliveryName: state
                                                                          .shipments[
                                                                              index]
                                                                          .deliveryCityLocation!,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .66,
                                                                      pathwidth:
                                                                          MediaQuery.of(context).size.width *
                                                                              .56,
                                                                    ).animate().slideX(
                                                                        duration: 300
                                                                            .ms,
                                                                        delay: 0
                                                                            .ms,
                                                                        begin:
                                                                            1,
                                                                        end: 0,
                                                                        curve: Curves
                                                                            .easeInOutSine),
                                                                    SizedBox(
                                                                      height:
                                                                          7.h,
                                                                    ),
                                                                    Text(
                                                                      '${AppLocalizations.of(context)!.translate('commodity_type')}: ${state.shipments[index].shipmentItems![0].commodityName!}',
                                                                      style:
                                                                          TextStyle(
                                                                        // color: AppColor.lightBlue,
                                                                        fontSize:
                                                                            17.sp,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          7.h,
                                                                    ),
                                                                    Text(
                                                                      '${AppLocalizations.of(context)!.translate('commodity_weight')}: ${f.format(state.shipments[index].shipmentItems![0].commodityWeight!)} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}',
                                                                      style:
                                                                          TextStyle(
                                                                        // color: AppColor.lightBlue,
                                                                        fontSize:
                                                                            17.sp,
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
                                                      curve:
                                                          Curves.easeInOutSine),
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
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 5),
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
                              : BlocBuilder<OwnerIncomingShipmentsBloc,
                                  OwnerIncomingShipmentsState>(
                                  builder: (context, state) {
                                    if (state
                                        is OwnerIncomingShipmentsLoadedSuccess) {
                                      return state.shipments.isEmpty
                                          ? Center(
                                              child: Text(AppLocalizations.of(
                                                      context)!
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
                                                    // Navigator.push(
                                                    //     context,
                                                    //     MaterialPageRoute(
                                                    //       builder: (context) =>
                                                    //           IncomingShipmentDetailsScreen(
                                                    //               shipment: state
                                                    //                       .shipments[
                                                    //                   index]),
                                                    //     ));
                                                  },
                                                  child: Card(
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(10),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5.h),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        11),
                                                            child: Text(
                                                              '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.shipments[index].id!}',
                                                              style: TextStyle(
                                                                  // color: AppColor.lightBlue,
                                                                  fontSize:
                                                                      18.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          ListTile(
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            enabled: false,
                                                            leading: Container(
                                                              height: 75.h,
                                                              width: 75.w,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      // color: AppColor.lightGoldenYellow,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                              child: Center(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: localeState
                                                                              .value
                                                                              .languageCode ==
                                                                          'en'
                                                                      ? SvgPicture
                                                                              .asset(
                                                                          "assets/icons/truck_en.svg",
                                                                          height:
                                                                              55.h,
                                                                          width:
                                                                              55.w,
                                                                          fit: BoxFit
                                                                              .fill,
                                                                        )
                                                                          .animate(
                                                                              delay: 600
                                                                                  .ms)
                                                                          .shimmer(
                                                                              duration: playDuration -
                                                                                  200
                                                                                      .ms)
                                                                          .flip()
                                                                      : SvgPicture
                                                                              .asset(
                                                                          "assets/icons/truck_ar.svg",
                                                                          height:
                                                                              55.h,
                                                                          width:
                                                                              55.w,
                                                                          fit: BoxFit
                                                                              .fill,
                                                                        )
                                                                          .animate(
                                                                              delay: 600.ms)
                                                                          .shimmer(duration: playDuration - 200.ms)
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
                                                                    ShipmentPathWidget(
                                                                      loadDate: setLoadDate(state
                                                                          .shipments[
                                                                              index]
                                                                          .pickupDate!),
                                                                      pickupName: state
                                                                          .shipments[
                                                                              index]
                                                                          .pickupCityLocation!,
                                                                      deliveryName: state
                                                                          .shipments[
                                                                              index]
                                                                          .deliveryCityLocation!,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .66,
                                                                      pathwidth:
                                                                          MediaQuery.of(context).size.width *
                                                                              .56,
                                                                    ).animate().slideX(
                                                                        duration: 300
                                                                            .ms,
                                                                        delay: 0
                                                                            .ms,
                                                                        begin:
                                                                            1,
                                                                        end: 0,
                                                                        curve: Curves
                                                                            .easeInOutSine),
                                                                    SizedBox(
                                                                      height:
                                                                          7.h,
                                                                    ),
                                                                    Text(
                                                                      '${AppLocalizations.of(context)!.translate('commodity_type')}: ${state.shipments[index].shipmentItems![0].commodityName!}',
                                                                      style:
                                                                          TextStyle(
                                                                        // color: AppColor.lightBlue,
                                                                        fontSize:
                                                                            17.sp,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          7.h,
                                                                    ),
                                                                    Text(
                                                                      '${AppLocalizations.of(context)!.translate('commodity_weight')}: ${f.format(state.shipments[index].shipmentItems![0].commodityWeight!)} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}',
                                                                      style:
                                                                          TextStyle(
                                                                        // color: AppColor.lightBlue,
                                                                        fontSize:
                                                                            17.sp,
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
                                                      curve:
                                                          Curves.easeInOutSine),
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
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 5),
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
