import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/requests/merchant_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/requests/request_details_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_running_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/approval_request.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/providers/request_num_provider.dart';
import 'package:camion/data/services/map_service.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/driver/incoming_shipment_details_screen.dart';
import 'package:camion/views/screens/merchant/approval_request_info_screen.dart';
import 'package:camion/views/screens/merchant/incoming_request_for_driver.dart';
import 'package:camion/views/screens/merchant/subshipment_details_screen.dart';
import 'package:camion/views/widgets/no_reaults_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart' as intel;
import 'package:flutter/services.dart' show rootBundle;

class ShippmentLogScreen extends StatefulWidget {
  const ShippmentLogScreen({Key? key}) : super(key: key);

  @override
  State<ShippmentLogScreen> createState() => _ShippmentLogScreenState();
}

class _ShippmentLogScreenState extends State<ShippmentLogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int tabIndex = 0;

  String _mapStyle = "";

  var f = intel.NumberFormat("#,###", "en_US");
  BitmapDescriptor? pickupicon;
  late BitmapDescriptor deliveryicon;
  List<Set<Marker>> markers = [];

  final List<GoogleMapController?> _maps = [];

  List<Color> colors = [
    Colors.yellow[200]!,
    Colors.yellow[400]!,
    Colors.yellow,
    Colors.yellow[700]!,
    Colors.yellow[800]!,
  ];

  createMarkerIcons() async {
    Uint8List markerIcon = await MapService.createCustomMarker(
      "A",
    );
    pickupicon = BitmapDescriptor.bytes(markerIcon);
    Uint8List markerIcon1 = await MapService.createCustomMarker(
      "B",
    );
    deliveryicon = BitmapDescriptor.bytes(markerIcon1);
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
    for (var element in _maps) {
      element!.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  Color getColorByIndex(int index) {
    return colors[index % colors.length];
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

  getIconSvg(ApprovalRequest request) {
    var svgpath = "";

    switch (request.requestOwner) {
      case "T":
        if (request.responseTurn == "D") {
          return "assets/icons/grey/waiting.svg";
        } else {
          return request.isApproved!
              ? "assets/icons/grey/notification_shipment_complete.svg"
              : "assets/icons/grey/notification_shipment_cancelation.svg";
        }
      case "D":
        if (request.responseTurn == "T") {
          return "assets/icons/grey/waiting.svg";
        } else {
          return request.isApproved!
              ? "assets/icons/grey/notification_shipment_complete.svg"
              : "assets/icons/grey/notification_shipment_cancelation.svg";
        }

      default:
        return "assets/icons/grey/waiting.svg";
    }
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

    for (var i = 0; i < items.length; i++) {
      if (i != (items.length - 1)) {
        text = '$text${items[i].commodityName!}, ';
      } else {
        text = '$text${items[i].commodityName!}.';
      }
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

  Set<Polyline> getRoutes(SubShipment items) {
    Set<Polyline> routes = <Polyline>{};
    routes.add(Polyline(
      polylineId: const PolylineId("route"),
      points: deserializeLatLng(items.paths!),
      color: AppColor.deepYellow,
      width: 4,
    ));
    return routes;
  }

  Set<Marker> getMarkers(SubShipment shipments) {
    Set<Marker> marker = <Marker>{};
    if (shipments.pathpoints!
            .singleWhere(
              (element) => element.pointType == "P",
              orElse: () => PathPoint(id: 0),
            )
            .id !=
        0) {
      marker.add(Marker(
        markerId: const MarkerId("pickupmarker"),
        position: LatLng(
            double.parse(shipments.pathpoints!
                .singleWhere((element) => element.pointType == "P")
                .location!
                .split(",")[0]),
            double.parse(shipments.pathpoints!
                .singleWhere((element) => element.pointType == "P")
                .location!
                .split(",")[1])),
        icon: pickupicon!,
      ));
    }
    if (shipments.pathpoints!
            .singleWhere(
              (element) => element.pointType == "D",
              orElse: () => PathPoint(id: 0),
            )
            .id !=
        0) {
      marker.add(Marker(
        markerId: const MarkerId("deliverymarker"),
        position: LatLng(
            double.parse(shipments.pathpoints!
                .singleWhere((element) => element.pointType == "D")
                .location!
                .split(",")[0]),
            double.parse(shipments.pathpoints!
                .singleWhere((element) => element.pointType == "D")
                .location!
                .split(",")[1])),
        icon: deliveryicon,
      ));
    }
    return marker;
  }

  initMapbounds(SubShipment shipment, int index) {
    List<Marker> markers = [];

    var pickuplocation = shipment.pathpoints!
        .singleWhere((element) => element.pointType == "P")
        .location!
        .split(",");
    markers.add(
      Marker(
        markerId: const MarkerId("pickup"),
        position: LatLng(
            double.parse(pickuplocation[0]), double.parse(pickuplocation[1])),
      ),
    );

    var deliverylocation = shipment.pathpoints!
        .singleWhere((element) => element.pointType == "D")
        .location!
        .split(",");
    markers.add(
      Marker(
        markerId: const MarkerId("delivery"),
        position: LatLng(double.parse(deliverylocation[0]),
            double.parse(deliverylocation[1])),
      ),
    );

    for (var j = 0; j < shipment.pathpoints!.length; j++) {
      if (shipment.pathpoints![j].pointType == "S") {
        var stopLocation = shipment.pathpoints![j].location!.split(',');
        markers.add(
          Marker(
            markerId: MarkerId("stop${(j)}"),
            position: LatLng(
                double.parse(stopLocation[0]), double.parse(stopLocation[1])),
          ),
        );
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

    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50.0);
    _maps[index]!.animateCamera(cameraUpdate);
    // notifyListeners();
  }

  Future<void> onRefresh() async {
    tabIndex != 0
        ? BlocProvider.of<MerchantRequestsListBloc>(context)
            .add(MerchantRequestsListLoadEvent())
        : BlocProvider.of<ShipmentRunningBloc>(context)
            .add(ShipmentRunningLoadEvent("R"));
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
            backgroundColor: Colors.grey[100],
            body: RefreshIndicator(
              onRefresh: onRefresh,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: Colors.grey[200],
                      child: TabBar(
                        indicatorColor: AppColor.deepYellow,
                        controller: _tabController,
                        onTap: (value) {
                          // switch (value) {
                          //   case 0:
                          //     BlocProvider.of<ShipmentRunningBloc>(context)
                          //         .add(ShipmentRunningLoadEvent("R"));
                          //     break;
                          //   case 1:
                          //     BlocProvider.of<MerchantRequestsListBloc>(context)
                          //         .add(MerchantRequestsListLoadEvent());
                          //     break;
                          //   default:
                          // }
                          setState(() {
                            tabIndex = value;
                          });
                        },
                        tabs: [
                          // first tab [you can add an icon using the icon property]
                          Tab(
                            child: Center(
                                child: Text(AppLocalizations.of(context)!
                                    .translate('running'))),
                          ),
                          Tab(
                            child: Center(
                              child: Consumer<RequestNumProvider>(
                                builder: (context, value, child) {
                                  return BlocListener<MerchantRequestsListBloc,
                                      MerchantRequestsListState>(
                                    listener: (context, state) {
                                      // TODO: implement listener
                                      if (state
                                          is MerchantRequestsListLoadedSuccess) {
                                        var taskNum = 0;

                                        value.setRequestNum(
                                            state.requests.length);
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(AppLocalizations.of(context)!
                                            .translate('pending')),
                                        const SizedBox(width: 4),
                                        value.requestNum > 0
                                            ? Container(
                                                height: 25.w,
                                                width: 25.w,
                                                decoration: BoxDecoration(
                                                  color: AppColor.deepYellow,
                                                  borderRadius:
                                                      BorderRadius.circular(45),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                      value.requestNum
                                                          .toString(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      )),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: tabIndex == 0
                          ? BlocConsumer<ShipmentRunningBloc,
                              ShipmentRunningState>(
                              listener: (context, state) {},
                              builder: (context, state) {
                                if (state is ShipmentRunningLoadedSuccess &&
                                    pickupicon != null) {
                                  return state.shipments.isEmpty
                                      ? NoResultsWidget(
                                          text: AppLocalizations.of(context)!
                                              .translate('no_shipments'),
                                        )
                                      : ListView.builder(
                                          itemCount: state.shipments.length,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: () {
                                                BlocProvider.of<
                                                            SubShipmentDetailsBloc>(
                                                        context)
                                                    .add(
                                                        SubShipmentDetailsLoadEvent(
                                                  state.shipments[index].id!,
                                                ));
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SubShipmentDetailsScreen(
                                                        shipment: state
                                                            .shipments[index]
                                                            .id!,
                                                        preview: false,
                                                      ),
                                                    ));
                                              },
                                              child: AbsorbPointer(
                                                absorbing: false,
                                                child: Card(
                                                  color: Colors.white,
                                                  elevation: 1,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                                  ),
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        height: 48.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: AppColor
                                                                .deepYellow,
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .vertical(
                                                            top:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              height: 35.w,
                                                              width: 35.w,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 8,
                                                              ),
                                                              child: Center(
                                                                child:
                                                                    SvgPicture
                                                                        .asset(
                                                                  "assets/icons/truck_ar.svg",
                                                                  height: 20.w,
                                                                  width: 20.w,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              // width: 100.w,
                                                              child: Text(
                                                                commodityItemsText(state
                                                                    .shipments[
                                                                        index]
                                                                    .shipmentItems!),
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
                                                            ),
                                                            const Spacer(),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8),
                                                              child:
                                                                  SectionTitle(
                                                                text:
                                                                    '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.shipments[index].id!}',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 190.h,
                                                        child: IgnorePointer(
                                                          ignoring: true,
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
                                                                    zoom:
                                                                        14.47),
                                                            gestureRecognizers: const {},
                                                            markers: getMarkers(
                                                                state.shipments[
                                                                    index]),
                                                            polylines: getRoutes(
                                                                state.shipments[
                                                                    index]),
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
                                                    curve:
                                                        Curves.easeInOutSine),
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
                          : BlocConsumer<MerchantRequestsListBloc,
                              MerchantRequestsListState>(
                              listener: (context, state) {
                                print(state);
                              },
                              builder: (context, state) {
                                if (state
                                    is MerchantRequestsListLoadedSuccess) {
                                  return state.requests.isEmpty
                                      ? NoResultsWidget(
                                          text: AppLocalizations.of(context)!
                                              .translate('no_out_orders'),
                                        )
                                      : ListView.builder(
                                          itemCount: state.requests.length,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: () {
                                                if (state.requests[index]
                                                        .requestOwner ==
                                                    "T") {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ApprovalRequestDetailsScreen(
                                                        type: state
                                                                .requests[index]
                                                                .isApproved!
                                                            ? "A"
                                                            : "J",
                                                        request: state
                                                            .requests[index],
                                                        objectId: state
                                                            .requests[index]
                                                            .id!,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            IncomingRequestForDriverScreen(
                                                          objectId: state
                                                              .requests[index]
                                                              .subshipment!
                                                              .id!,
                                                        ),
                                                      ));
                                                }
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
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        height: 48.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: AppColor
                                                                .deepYellow,
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .vertical(
                                                            top:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8.0),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                height: 28.w,
                                                                width: 28.w,
                                                                margin:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal: 4,
                                                                ),
                                                                child:
                                                                    SvgPicture
                                                                        .asset(
                                                                  getIconSvg(state
                                                                          .requests[
                                                                      index]),
                                                                  height: 22.w,
                                                                  width: 22.w,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                              Text(
                                                                // "${AppLocalizations.of(context)!.translate("driver_name")}: ${state.requests[index].driver!.user!.firstName!} ${state.requests[index].driver!.user!.lastName!}",
                                                                " ${state.requests[index].driver_firstname!} ${state.requests[index].driver_lastname!}",
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  color: AppColor
                                                                      .darkGrey,
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4),
                                                                child:
                                                                    SectionTitle(
                                                                  text:
                                                                      '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.requests[index].subshipment!.id!}',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      ShipmentPathVerticalWidget(
                                                        pathpoints: state
                                                            .requests[index]
                                                            .subshipment!
                                                            .pathpoints!,
                                                        pickupDate: state
                                                            .requests[index]
                                                            .subshipment!
                                                            .pickupDate!,
                                                        deliveryDate: state
                                                            .requests[index]
                                                            .subshipment!
                                                            .pickupDate!,
                                                        langCode: localeState
                                                            .value.languageCode,
                                                        mini: true,
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
                      height: 4,
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
