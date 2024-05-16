import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/shipments/active_shipment_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/enums.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/providers/active_shipment_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' as intel;
import 'package:shimmer/shimmer.dart';

class ActiveShipmentScreen extends StatefulWidget {
  ActiveShipmentScreen({Key? key}) : super(key: key);

  @override
  State<ActiveShipmentScreen> createState() => _ActiveShipmentScreenState();
}

class _ActiveShipmentScreenState extends State<ActiveShipmentScreen> {
  late GoogleMapController _controller;

  String _mapStyle = "";
  PanelState panelState = PanelState.hidden;
  final panelTransation = const Duration(milliseconds: 500);
  var f = intel.NumberFormat("#,###", "en_US");

  int selectedIndex = 0;
  int selectedTruck = 0;

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

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

  Widget pathList(List<SubShipment> subshipments) {
    return SizedBox(
      height: 90.h,
      child: ListView.builder(
        itemCount: subshipments.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                selectedIndex = index;
                selectedTruck = index;
              });
              initMapbounds(subshipments[index]);
              // setLoadDate(shipment.subshipments![selectedIndex].pickupDate!);
              // setLoadTime(shipment.subshipments![selectedIndex].pickupDate!);
              markers = {};
              var pickupMarker = Marker(
                markerId: const MarkerId("pickup"),
                position: LatLng(
                    double.parse(subshipments[selectedIndex]
                        .pathpoints!
                        .singleWhere((element) => element.pointType == "P")
                        .location!
                        .split(",")[0]),
                    double.parse(subshipments[selectedIndex]
                        .pathpoints!
                        .singleWhere((element) => element.pointType == "P")
                        .location!
                        .split(",")[1])),
                icon: pickupicon,
              );
              markers.add(pickupMarker);
              var deliveryMarker = Marker(
                markerId: const MarkerId("delivery"),
                position: LatLng(
                    double.parse(subshipments[selectedIndex]
                        .pathpoints!
                        .singleWhere((element) => element.pointType == "D")
                        .location!
                        .split(",")[0]),
                    double.parse(subshipments[selectedIndex]
                        .pathpoints!
                        .singleWhere((element) => element.pointType == "D")
                        .location!
                        .split(",")[1])),
                icon: deliveryicon,
              );
              markers.add(deliveryMarker);
              var truckMarker = Marker(
                markerId: const MarkerId("truck"),
                position: LatLng(
                    double.parse(subshipments[selectedIndex]
                        .truck!
                        .location_lat!
                        .split(",")[0]),
                    double.parse(subshipments[selectedIndex]
                        .truck!
                        .location_lat!
                        .split(",")[1])),
                icon: truckicon,
              );
              markers.add(truckMarker);

              setState(() {});
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 155.w,
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: selectedTruck == index
                          ? AppColor.deepYellow
                          : Colors.grey[400]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 25.h,
                        width: 150.w,
                        child: CachedNetworkImage(
                          imageUrl:
                              subshipments[index].truck!.truck_type!.image!,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  Shimmer.fromColors(
                            baseColor: (Colors.grey[300])!,
                            highlightColor: (Colors.grey[100])!,
                            enabled: true,
                            child: Container(
                              height: 25.h,
                              width: 150.w,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 25.h,
                            width: 150.w,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(AppLocalizations.of(context)!
                                  .translate('image_load_error')),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 7.h,
                      ),
                      Text(
                        "${subshipments[index].truck!.truckuser!.user!.firstName!} ${subshipments[index].truck!.truckuser!.user!.lastName!}",
                        style: TextStyle(
                          fontSize: 17.sp,
                          color: AppColor.deepBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
    });
    rootBundle.loadString('assets/style/map_style.json').then((string) {
      _mapStyle = string;
    });
  }

  Future<void> onRefresh() async {
    BlocProvider.of<ActiveShipmentListBloc>(context)
        .add(ActiveShipmentListLoadEvent());
  }

  bool shipmentsLoaded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
            textDirection: localeState.value.languageCode == 'en'
                ? TextDirection.ltr
                : TextDirection.rtl,
            child: Scaffold(
              backgroundColor: AppColor.lightGrey200,
              body: Consumer<ActiveShippmentProvider>(
                  builder: (context, activeShipmentProvider, child) {
                activeShipmentProvider.init();
                return BlocConsumer<ActiveShipmentListBloc,
                    ActiveShipmentListState>(
                  listener: (context, state) {
                    if (state is ActiveShipmentListLoadedSuccess) {}
                  },
                  builder: (context, state) {
                    if (state is ActiveShipmentListLoadedSuccess) {
                      return Stack(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: GoogleMap(
                              onMapCreated:
                                  (GoogleMapController controller) async {
                                setState(() {
                                  _controller = controller;
                                  _controller.setMapStyle(_mapStyle);
                                });
                                setState(() {
                                  selectedIndex = 0;
                                  selectedTruck = 0;
                                });
                                initMapbounds(state.shipments[0]);
                                // setLoadDate(shipment.subshipments![selectedIndex].pickupDate!);
                                // setLoadTime(shipment.subshipments![selectedIndex].pickupDate!);
                                markers = {};
                                var pickupMarker = Marker(
                                  markerId: const MarkerId("pickup"),
                                  position: LatLng(
                                      double.parse(state
                                          .shipments[selectedIndex].pathpoints!
                                          .singleWhere((element) =>
                                              element.pointType == "P")
                                          .location!
                                          .split(",")[0]),
                                      double.parse(state
                                          .shipments[selectedIndex].pathpoints!
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
                                      double.parse(state
                                          .shipments[selectedIndex].pathpoints!
                                          .singleWhere((element) =>
                                              element.pointType == "D")
                                          .location!
                                          .split(",")[0]),
                                      double.parse(state
                                          .shipments[selectedIndex].pathpoints!
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
                                          .shipments[selectedIndex]
                                          .truck!
                                          .location_lat!
                                          .split(",")[0]),
                                      double.parse(state
                                          .shipments[selectedIndex]
                                          .truck!
                                          .location_lat!
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
                                        points: deserializeLatLng(state
                                            .shipments[selectedIndex].paths!),
                                        color: AppColor.deepYellow,
                                        width: 7,
                                      ),
                                    }
                                  : {},
                              // mapType: shipmentProvider.mapType,
                            ),
                          ),
                          pathList(state.shipments),
                        ],
                      );
                    } else {
                      return const Center(
                        child: LoadingIndicator(),
                      );
                    }
                  },
                );
              }),
            ));
      },
    );
  }

  List<LatLng> getpolylineCoordinates(double d, double e, double f, double g) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> _polylineCoordinates = [];

    polylinePoints
        .getRouteBetweenCoordinates(
      "AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w",
      PointLatLng(d, e),
      PointLatLng(f, g),
    )
        .then((result) {
      if (result.points.isNotEmpty) {
        result.points.forEach((element) {
          _polylineCoordinates.add(
            LatLng(
              element.latitude,
              element.longitude,
            ),
          );
        });
      }
    });
    return _polylineCoordinates;
  }
}
