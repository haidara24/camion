import 'dart:convert';
import 'dart:core';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_complete_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/shipment_path_widget.dart';
import 'package:camion/views/screens/merchant/shipment_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart' as intel;
import 'package:flutter/services.dart' show rootBundle;

class ShippmentLogScreen extends StatefulWidget {
  ShippmentLogScreen({Key? key}) : super(key: key);

  @override
  State<ShippmentLogScreen> createState() => _ShippmentLogScreenState();
}

class _ShippmentLogScreenState extends State<ShippmentLogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int tabIndex = 0;

  String _mapStyle = "";

  var f = intel.NumberFormat("#,###", "en_US");
  late BitmapDescriptor pickupicon;
  late BitmapDescriptor deliveryicon;
  List<Set<Marker>> markers = [];

  List<GoogleMapController?> _maps = [];

  createMarkerIcons() async {
    pickupicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location1.png");
    deliveryicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location2.png");
    print("sssssssssssssssssssssssssss");
    setState(() {});
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      createMarkerIcons();
    });
    rootBundle.loadString('assets/style/map_style.json').then((string) {
      _mapStyle = string;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  String setLoadDate(DateTime? date) {
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

  String commodityItemsText(List<ShipmentItems> items) {
    String text = '';
    for (var element in items) {
      text = '$text${element.commodityName!}, ';
    }
    return text;
  }

  List<LatLng> deserializeLatLng(String jsonString) {
    List<dynamic> coordinates = json.decode(jsonString);
    List<LatLng> latLngList = [];
    for (var coord in coordinates) {
      latLngList.add(LatLng(coord[0], coord[1]));
    }
    return latLngList;
  }

  Set<Polyline> getRoutes(List<SubShipment> items) {
    Set<Polyline> routes = new Set<Polyline>();
    for (var i = 0; i < items.length; i++) {
      routes.add(Polyline(
        polylineId: PolylineId("route$i"),
        points: deserializeLatLng(items[i].paths!),
        color: AppColor.deepYellow,
        width: 7,
      ));
    }
    return routes;
  }

  Set<Marker> getMarkers(Shipmentv2 shipments) {
    Set<Marker> _marker = Set<Marker>();

    for (var i = 0; i < shipments.subshipments!.length; i++) {
      if (shipments.subshipments![i].pathpoints!.singleWhere(
            (element) => element.pointType == "P",
            orElse: () => PathPoint(id: 0),
          ) ==
          PathPoint(id: 0)) {
        _marker.add(Marker(
          markerId: MarkerId("marker$i"),
          position: LatLng(
              double.parse(shipments.subshipments![i].pathpoints!
                  .singleWhere((element) => element.pointType == "P")
                  .location!
                  .split(",")[0]),
              double.parse(shipments.subshipments![i].pathpoints!
                  .singleWhere((element) => element.pointType == "P")
                  .location!
                  .split(",")[1])),

          // icon: pickupicon,
        ));
      } else if (shipments.subshipments![i].pathpoints!.singleWhere(
            (element) => element.pointType == "D",
            orElse: () => PathPoint(id: 0),
          ) ==
          PathPoint(id: 0)) {
        _marker.add(Marker(
          markerId: MarkerId("marker$i"),
          position: LatLng(
              double.parse(shipments.subshipments![i].pathpoints!
                  .singleWhere((element) => element.pointType == "D")
                  .location!
                  .split(",")[0]),
              double.parse(shipments.subshipments![i].pathpoints!
                  .singleWhere((element) => element.pointType == "D")
                  .location!
                  .split(",")[1])),
          // icon: deliveryicon,
        ));
      }
    }
    return _marker;
  }

  initMapbounds(Shipmentv2 shipment, int index) {
    List<Marker> markers = [];

    for (var i = 0; i < shipment.subshipments!.length; i++) {
      var pickuplocation = shipment.subshipments![i].pathpoints!
          .singleWhere((element) => element.pointType == "P")
          .location!
          .split(",");
      markers.add(
        Marker(
          markerId: MarkerId("pickup$i"),
          position: LatLng(
              double.parse(pickuplocation[0]), double.parse(pickuplocation[1])),
        ),
      );

      var deliverylocation = shipment.subshipments![i].pathpoints!
          .singleWhere((element) => element.pointType == "D")
          .location!
          .split(",");
      markers.add(
        Marker(
          markerId: MarkerId("delivery$i"),
          position: LatLng(double.parse(deliverylocation[0]),
              double.parse(deliverylocation[1])),
        ),
      );

      for (var j = 0; j < shipment.subshipments![i].pathpoints!.length; j++) {
        if (shipment.subshipments![i].pathpoints![j].pointType == "S") {
          var stopLocation =
              shipment.subshipments![i].pathpoints![j].location!.split(',');
          markers.add(
            Marker(
              markerId: MarkerId("stop${(i + j)}"),
              position: LatLng(
                  double.parse(stopLocation[0]), double.parse(stopLocation[1])),
            ),
          );
        }
      }
    }

    double minLat = markers[0].position.latitude;
    double maxLat = markers[0].position.latitude;
    double minLng = markers[0].position.longitude;
    double maxLng = markers[0].position.longitude;

    for (Marker marker in markers) {
      if (marker.position.latitude < minLat) {
        minLat = marker.position.latitude;
      }
      if (marker.position.latitude > maxLat) {
        maxLat = marker.position.latitude;
      }
      if (marker.position.longitude < minLng) {
        minLng = marker.position.longitude;
      }
      if (marker.position.longitude > maxLng) {
        maxLng = marker.position.longitude;
      }
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 20.0);
    _maps[index]!.animateCamera(cameraUpdate);
    // notifyListeners();
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
                            BlocProvider.of<ShipmentListBloc>(context)
                                .add(ShipmentListLoadEvent("P"));
                            break;
                          case 1:
                            BlocProvider.of<ShipmentCompleteListBloc>(context)
                                .add(ShipmentCompleteListLoadEvent());
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
                                  .translate('completed'))),
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
                        ? BlocConsumer<ShipmentListBloc, ShipmentListState>(
                            listener: (context, state) {
                              // if (state is ShipmentListLoadedSuccess) {
                              //   getMarkers(state.shipments);
                              // }
                            },
                            builder: (context, state) {
                              if (state is ShipmentListLoadedSuccess) {
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
                                              BlocProvider.of<
                                                          ShipmentDetailsBloc>(
                                                      context)
                                                  .add(ShipmentDetailsLoadEvent(
                                                      state.shipments[index]
                                                          .id!));
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ShipmentDetailsScreen(
                                                      shipment: state
                                                          .shipments[index],
                                                    ),
                                                  ));
                                            },
                                            child: AbsorbPointer(
                                              absorbing: false,
                                              child: Card(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      height: 48.h,
                                                      color:
                                                          AppColor.deepYellow,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height: 45.h,
                                                            width: 45.w,
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 12,
                                                            ),
                                                            child: Center(
                                                              child: localeState
                                                                          .value
                                                                          .languageCode ==
                                                                      'en'
                                                                  ? SvgPicture
                                                                          .asset(
                                                                      "assets/icons/truck_en.svg",
                                                                      height:
                                                                          30.h,
                                                                      width:
                                                                          30.w,
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
                                                                          30.h,
                                                                      width:
                                                                          30.w,
                                                                      fit: BoxFit
                                                                          .fill,
                                                                    )
                                                                      .animate(
                                                                          delay: 600
                                                                              .ms)
                                                                      .shimmer(
                                                                          duration:
                                                                              playDuration - 200.ms)
                                                                      .flip(),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 100.w,
                                                            child: Text(
                                                              commodityItemsText(state
                                                                  .shipments[
                                                                      index]
                                                                  .subshipments![
                                                                      0]
                                                                  .shipmentItems!),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                // color: AppColor.lightBlue,
                                                                fontSize: 17.sp,
                                                              ),
                                                            ),
                                                          ),
                                                          Spacer(),
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
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 190.h,
                                                      child: AbsorbPointer(
                                                        absorbing: false,
                                                        child: GoogleMap(
                                                          onMapCreated:
                                                              (GoogleMapController
                                                                  controller) async {
                                                            setState(() {
                                                              _maps.add(null);
                                                              _maps[index] =
                                                                  controller;
                                                              _maps[index]!
                                                                  .setMapStyle(
                                                                      _mapStyle);
                                                            });
                                                            initMapbounds(
                                                                state.shipments[
                                                                    index],
                                                                index);
                                                          },
                                                          myLocationButtonEnabled:
                                                              false,
                                                          zoomGesturesEnabled:
                                                              false,
                                                          scrollGesturesEnabled:
                                                              false,
                                                          tiltGesturesEnabled:
                                                              false,
                                                          rotateGesturesEnabled:
                                                              false,
                                                          zoomControlsEnabled:
                                                              false,
                                                          initialCameraPosition:
                                                              const CameraPosition(
                                                                  target: LatLng(
                                                                      35.363149,
                                                                      35.932120),
                                                                  zoom: 14.47),
                                                          gestureRecognizers: {},
                                                          markers: getMarkers(
                                                              state.shipments[
                                                                  index]),
                                                          polylines: getRoutes(
                                                              state
                                                                  .shipments[
                                                                      index]
                                                                  .subshipments!),
                                                          // mapType: shipmentProvider.mapType,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ).animate().slideX(
                                                  duration: 350.ms,
                                                  delay: 0.ms,
                                                  begin: 1,
                                                  end: 0,
                                                  curve: Curves.easeInOutSine),
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
                        : BlocBuilder<ShipmentCompleteListBloc,
                            ShipmentCompleteListState>(
                            builder: (context, state) {
                              if (state is ShipmentCompleteListLoadedSuccess) {
                                return state.shipments.isEmpty
                                    ? Center(
                                        child: Text(
                                            AppLocalizations.of(context)!
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
                                                      child: Text(
                                                        '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.shipments[index].id!}',
                                                        style: TextStyle(
                                                            // color: AppColor.lightBlue,
                                                            fontSize: 18.sp,
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
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                        child: Center(
                                                          child:
                                                              SvgPicture.asset(
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
                                                              ShipmentPathWidget(
                                                                pickupName: state
                                                                    .shipments[
                                                                        index]
                                                                    .subshipments![
                                                                        0]
                                                                    .pathpoints!
                                                                    .singleWhere(
                                                                        (element) =>
                                                                            element.pointType ==
                                                                            "P")
                                                                    .name!,
                                                                deliveryName: state
                                                                    .shipments[
                                                                        index]
                                                                    .subshipments![
                                                                        0]
                                                                    .pathpoints!
                                                                    .singleWhere(
                                                                        (element) =>
                                                                            element.pointType ==
                                                                            "D")
                                                                    .name!,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .66,
                                                                pathwidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .56,
                                                              ).animate().slideX(
                                                                  duration:
                                                                      300.ms,
                                                                  delay: 0.ms,
                                                                  begin: 1,
                                                                  end: 0,
                                                                  curve: Curves
                                                                      .easeInOutSine),
                                                              SizedBox(
                                                                height: 7.h,
                                                              ),
                                                              Text(
                                                                '${AppLocalizations.of(context)!.translate('commodity_type')}: ${state.shipments[index].subshipments![0].shipmentItems![0].commodityName!}',
                                                                style:
                                                                    TextStyle(
                                                                  // color: AppColor.lightBlue,
                                                                  fontSize:
                                                                      17.sp,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 7.h,
                                                              ),
                                                              Text(
                                                                '${AppLocalizations.of(context)!.translate('commodity_weight')}: ${f.format(state.shipments[index].subshipments![0].shipmentItems![0].commodityWeight!)} kg',
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
