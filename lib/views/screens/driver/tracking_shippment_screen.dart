import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/driver_shipments/driver_active_shipment_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/enums.dart';
import 'package:camion/data/models/co2_report.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/providers/active_shipment_provider.dart';
import 'package:camion/data/services/co2_service.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intel;

class TrackingShipmentScreen extends StatefulWidget {
  TrackingShipmentScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<TrackingShipmentScreen> createState() => _TrackingShipmentScreenState();
}

class _TrackingShipmentScreenState extends State<TrackingShipmentScreen>
    with TickerProviderStateMixin {
  late Timer timer;
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;
  String _mapStyle = "";
  PanelState panelState = PanelState.hidden;
  final panelTransation = const Duration(milliseconds: 500);
  Co2Report _report = Co2Report();
  var f = intel.NumberFormat("#,###", "en_US");

  late final AnimationController _animationController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );
  initMapbounds(SubShipment subshipment) {
    List<Marker> markers = [];
    var pickuplocation = subshipment.pathpoints!
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

    var deliverylocation = subshipment.pathpoints!
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
    var lngs = markers.map<double>((m) => m.position.longitude).toList();
    var lats = markers.map<double>((m) => m.position.latitude).toList();

    double topMost = lngs.reduce(max);
    double leftMost = lats.reduce(min);
    double rightMost = lats.reduce(max);
    double bottomMost = lngs.reduce(min);

    LatLngBounds _bounds = LatLngBounds(
      northeast: LatLng(rightMost, topMost),
      southwest: LatLng(leftMost, bottomMost),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(_bounds, 50.0);
    print("asd");
    _controller.animateCamera(cameraUpdate);
    // _mapController2.animateCamera(cameraUpdate);
    print("asd");
    // notifyListeners();
  }

  late BitmapDescriptor pickupicon;
  late BitmapDescriptor deliveryicon;
  late BitmapDescriptor parkicon;
  late BitmapDescriptor truckicon;
  late LatLng truckLocation;
  late bool truckLocationassign;
  Set<Marker> markers = Set();

  createMarkerIcons() async {
    pickupicon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/icons/location1.png",
    );
    deliveryicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location2.png");
    truckicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/truck.png");
    print("sssssssssssssssssssssssssss");
    setState(() {});
  }

  List<LatLng> deserializeLatLng(String jsonString) {
    List<dynamic> coordinates = json.decode(jsonString);
    List<LatLng> latLngList = [];
    for (var coord in coordinates) {
      latLngList.add(LatLng(coord[0], coord[1]));
    }
    return latLngList;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      createMarkerIcons();
      setState(() {});
    });
    rootBundle.loadString('assets/style/map_style.json').then((string) {
      _mapStyle = string;
    });
    // calculateCo2Report();
  }

  @override
  void dispose() {
    _animationController.dispose();
    timer.cancel();
    super.dispose();
  }

  void _onVerticalGesture(DragUpdateDetails details) {
    if (details.primaryDelta! < -7 && panelState == PanelState.hidden) {
      changeToOpen();
    } else if (details.primaryDelta! > 7 && panelState == PanelState.open) {
      changeToHidden();
    }
  }

  void changeToOpen() {
    setState(() {
      panelState = PanelState.open;
    });
  }

  void changeToHidden() {
    setState(() {
      panelState = PanelState.hidden;
    });
  }

  List<LatLng> _truckpolyline = [];
  bool _printed = false;

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

  var count = 25;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<DriverActiveShipmentBloc, DriverActiveShipmentState>(
          builder: (context, state) {
            if (state is DriverActiveShipmentLoadedSuccess) {
              if (state.shipments.isEmpty) {
                return Center(
                  child: Text(
                      AppLocalizations.of(context)!.translate('no_shipments')),
                );
              } else {
                return Consumer<ActiveShippmentProvider>(
                    builder: (context, shipmentProvider, child) {
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          GoogleMap(
                            onMapCreated:
                                (GoogleMapController controller) async {
                              setState(() {
                                _controller = controller;
                                _controller.setMapStyle(_mapStyle);
                              });

                              initMapbounds(state.shipments[0]);
                              // setLoadDate(shipment.subshipments![selectedIndex].pickupDate!);
                              // setLoadTime(shipment.subshipments![selectedIndex].pickupDate!);
                              markers = {};
                              var pickupMarker = Marker(
                                markerId: const MarkerId("pickup"),
                                position: LatLng(
                                    double.parse(state.shipments[0].pathpoints!
                                        .singleWhere((element) =>
                                            element.pointType == "P")
                                        .location!
                                        .split(",")[0]),
                                    double.parse(state.shipments[0].pathpoints!
                                        .singleWhere((element) =>
                                            element.pointType == "P")
                                        .location!
                                        .split(",")[1])),
                                icon: pickupicon,
                              );
                              markers.add(pickupMarker);
                              var deliveryMarker = Marker(
                                markerId: const MarkerId("delivery"),
                                position: LatLng(
                                    double.parse(state.shipments[0].pathpoints!
                                        .singleWhere((element) =>
                                            element.pointType == "D")
                                        .location!
                                        .split(",")[0]),
                                    double.parse(state.shipments[0].pathpoints!
                                        .singleWhere((element) =>
                                            element.pointType == "D")
                                        .location!
                                        .split(",")[1])),
                                icon: deliveryicon,
                              );
                              markers.add(deliveryMarker);

                              var truckMarker = Marker(
                                markerId: const MarkerId("truck"),
                                position: LatLng(
                                    double.parse(state
                                        .shipments[0].truck!.location_lat!
                                        .split(",")[0]),
                                    double.parse(state
                                        .shipments[0].truck!.location_lat!
                                        .split(",")[1])),
                                icon: truckicon,
                              );
                              markers.add(truckMarker);
                              setState(() {});
                            },
                            zoomControlsEnabled: false,

                            initialCameraPosition: CameraPosition(
                                target: LatLng(35.363149, 35.932120),
                                zoom: 14.47),
                            // gestureRecognizers: {},
                            markers: markers,
                            polylines: state.shipments.isNotEmpty
                                ? {
                                    Polyline(
                                      polylineId: const PolylineId("route"),
                                      points: deserializeLatLng(
                                          state.shipments[0].paths!),
                                      color: AppColor.deepYellow,
                                      width: 7,
                                    ),
                                  }
                                : {},
                            // mapType: shipmentProvider.mapType,
                          ),
                          AnimatedPositioned(
                            duration: panelTransation,
                            curve: Curves.decelerate,
                            left: 0,
                            right: 0,
                            bottom: _getTopForPanel(),
                            child: GestureDetector(
                              onVerticalDragUpdate: _onVerticalGesture,
                              child: _buildExpandedPanelWidget(
                                  context, state.shipments[0]),
                              // child: AnimatedSwitcher(
                              //   duration: panelTransation,
                              //   child: _buildPanelOption(context),
                              // ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                });
              }
            } else {
              return const Center(child: LoadingIndicator());
            }
          },
        ),
      ),
    );
  }

  void getBounds(List<Marker> markers, GoogleMapController mapcontroller) {
    var lngs = markers.map<double>((m) => m.position.longitude).toList();
    var lats = markers.map<double>((m) => m.position.latitude).toList();

    double topMost = lngs.reduce(max);
    double leftMost = lats.reduce(min);
    double rightMost = lats.reduce(max);
    double bottomMost = lngs.reduce(min);

    LatLngBounds _bounds = LatLngBounds(
      northeast: LatLng(rightMost, topMost),
      southwest: LatLng(leftMost, bottomMost),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(_bounds, 100.0);
    mapcontroller.animateCamera(cameraUpdate);
    print("asd3");

    setState(() {});
  }

  double? _getTopForPanel() {
    if (panelState == PanelState.hidden) {
      return 120.h - 350.h;
    } else if (panelState == PanelState.open) {
      return 0;
    }
  }

  Widget _buildExpandedPanelWidget(BuildContext context, SubShipment shipment) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 350.h,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 7.h,
                  ),
                  ShipmentPathVerticalWidget(
                    pathpoints: shipment.pathpoints!,
                    pickupDate: shipment.pickupDate!,
                    deliveryDate: shipment.deliveryDate!,
                    langCode: localeState.value.languageCode,
                    mini: false,
                  ),
                  const Divider(),
                  _buildCommodityWidget(shipment.shipmentItems, shipment),
                  const Divider(),
                  _buildCo2Report(),
                ],
              ),
            ),
            BlocBuilder<LocaleCubit, LocaleState>(
              builder: (context, localeState) {
                return Positioned(
                  top: -20,
                  right: MediaQuery.of(context).size.width * .45,
                  child: panelState == PanelState.hidden
                      ? InkWell(
                          onTap: () {
                            changeToOpen();
                          },
                          child: AbsorbPointer(
                            absorbing: true,
                            child: Container(
                              height: 45.h,
                              width: 45.w,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(45),
                              ),
                              child: Center(
                                child: SizedBox(
                                  height: 25.h,
                                  width: 25.w,
                                  child: SvgPicture.asset(
                                    "assets/icons/arrow_up.svg",
                                    fit: BoxFit.contain,
                                    height: 25.h,
                                    width: 25.w,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            changeToHidden();
                          },
                          child: AbsorbPointer(
                            absorbing: true,
                            child: Container(
                              height: 45.h,
                              width: 45.w,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(45),
                              ),
                              child: Center(
                                child: SizedBox(
                                  height: 25.h,
                                  width: 25.w,
                                  child: SvgPicture.asset(
                                    "assets/icons/arrow_down.svg",
                                    fit: BoxFit.contain,
                                    height: 25.h,
                                    width: 25.w,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  final ScrollController _scrollController = ScrollController();

  gettruckpolylineCoordinates(LatLng driver, LatLng distination) async {
    _truckpolyline = [];
    PolylinePoints polylinePoints = PolylinePoints();
    print("werwer");
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w",
      PointLatLng(driver.latitude, driver.longitude),
      PointLatLng(distination.latitude, distination.longitude),
    );
    _truckpolyline = [];
    if (result.points.isNotEmpty) {
      result.points.forEach((element) {
        _truckpolyline.add(
          LatLng(
            element.latitude,
            element.longitude,
          ),
        );
      });
    }
    setState(() {});
  }

  _buildCommodityWidget(
      List<ShipmentItems>? shipmentItems, SubShipment shipment) {
    return SizedBox(
      height: 135.h,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                height: 25.h,
                width: 25.w,
                child: SvgPicture.asset("assets/icons/commodity_icon.svg"),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                AppLocalizations.of(context)!.translate('commodity_info'),
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 95.h,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thickness: 3.0,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: shipment.shipmentItems!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "${AppLocalizations.of(context)!.translate('commodity_name')}: ${shipment.shipmentItems![index].commodityName!}",
                              style: TextStyle(
                                fontSize: 17.sp,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "${AppLocalizations.of(context)!.translate('commodity_weight')}: ${shipment.shipmentItems![index].commodityWeight!}",
                              style: TextStyle(
                                fontSize: 17.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildCo2Report() {
    return SizedBox(
      height: 50.h,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 35,
              width: 35,
              child: SvgPicture.asset("assets/icons/co2fingerprint.svg"),
            ),
            const SizedBox(
              width: 5,
            ),
            BlocBuilder<LocaleCubit, LocaleState>(
              builder: (context, localeState) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width * .7,
                  child: Text(
                    "${AppLocalizations.of(context)!.translate('total_co2')}: ${f.format(_report.et!.toInt())} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}",
                    style: const TextStyle(
                      // color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
