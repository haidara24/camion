import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/shipments/cancel_shipment_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_details_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/enums.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/screens/merchant/shipment_details_map_screen.dart';
import 'package:camion/views/widgets/commodity_info_widget.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/path_statistics_widget.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' as intel;
import 'package:shimmer/shimmer.dart';

class ShipmentDetailsScreen extends StatefulWidget {
  final Shipmentv2 shipment;

  ShipmentDetailsScreen({Key? key, required this.shipment}) : super(key: key);

  @override
  State<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends State<ShipmentDetailsScreen> {
  late GoogleMapController _controller;

  String _mapStyle = "";
  PanelState panelState = PanelState.hidden;
  final panelTransation = const Duration(milliseconds: 500);
  var f = intel.NumberFormat("#,###", "en_US");

  int selectedIndex = 0;
  int selectedTruck = 0;

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  initMapbounds(Shipmentv2 shipment) {
    List<Marker> markers = [];
    var pickuplocation = shipment.subshipments![selectedIndex].pathpoints!
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

    var deliverylocation = shipment.subshipments![selectedIndex].pathpoints!
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

    LatLngBounds bounds = LatLngBounds(
      northeast: LatLng(rightMost, topMost),
      southwest: LatLng(leftMost, bottomMost),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50.0);

    _controller.animateCamera(cameraUpdate);
    // _mapController2.animateCamera(cameraUpdate);

    // notifyListeners();
  }

  Widget showLoadDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * .42,
            child: TextFormField(
              controller: dateController,
              enabled: false,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.translate('date'),
                floatingLabelStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 11.0, horizontal: 9.0),
                suffixIcon: Icon(
                  Icons.calendar_month,
                  color: AppColor.deepYellow,
                ),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * .42,
            child: TextFormField(
              controller: timeController,
              enabled: false,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.translate('time'),
                floatingLabelStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 11.0, horizontal: 9.0),
                suffixIcon: Icon(
                  Icons.timer_outlined,
                  color: AppColor.deepYellow,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget truckList(Shipmentv2 shipment) {
    return SizedBox(
      height: 115.h,
      child: ListView.builder(
        itemCount: 1,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () async {
              setState(() {
                selectedTruck = index;
              });
              await _controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(
                        double.parse(shipment
                            .subshipments![selectedIndex].truck!.location_lat!
                            .split(",")[0]),
                        double.parse(shipment
                            .subshipments![selectedIndex].truck!.location_lat!
                            .split(",")[1]),
                      ),
                      zoom: 14.47),
                ),
              );
              markers = {};
              var pickupMarker = Marker(
                markerId: const MarkerId("pickup"),
                position: LatLng(
                    double.parse(shipment
                        .subshipments![selectedIndex].pathpoints!
                        .singleWhere((element) => element.pointType == "P")
                        .location!
                        .split(",")[0]),
                    double.parse(shipment
                        .subshipments![selectedIndex].pathpoints!
                        .singleWhere((element) => element.pointType == "P")
                        .location!
                        .split(",")[1])),
                icon: pickupicon,
              );

              markers.add(pickupMarker);
              var deliveryMarker = Marker(
                markerId: const MarkerId("delivery"),
                position: LatLng(
                    double.parse(shipment
                        .subshipments![selectedIndex].pathpoints!
                        .singleWhere((element) => element.pointType == "D")
                        .location!
                        .split(",")[0]),
                    double.parse(shipment
                        .subshipments![selectedIndex].pathpoints!
                        .singleWhere((element) => element.pointType == "D")
                        .location!
                        .split(",")[1])),
                icon: deliveryicon,
              );
              markers.add(deliveryMarker);
              var truckMarker = Marker(
                markerId: const MarkerId("truck"),
                position: LatLng(
                  double.parse(shipment
                      .subshipments![selectedIndex].truck!.location_lat!
                      .split(",")[0]),
                  double.parse(shipment
                      .subshipments![selectedIndex].truck!.location_lat!
                      .split(",")[1]),
                ),
                icon: truckicon,
              );
              markers.add(truckMarker);
              setState(() {});
            },
            child: Container(
              width: 180.w,
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
              child: Column(
                children: [
                  SizedBox(
                    height: 50.h,
                    width: 175.w,
                    child: CachedNetworkImage(
                      imageUrl: shipment.subshipments![selectedIndex].truck!
                          .truck_type!.image!,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              Shimmer.fromColors(
                        baseColor: (Colors.grey[300])!,
                        highlightColor: (Colors.grey[100])!,
                        enabled: true,
                        child: Container(
                          height: 50.h,
                          width: 175.w,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 50.h,
                        width: 175.w,
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
                    "${shipment.subshipments![selectedIndex].truck!.truckuser!.user!.firstName!} ${shipment.subshipments![selectedIndex].truck!.truckuser!.user!.lastName!}",
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: AppColor.deepBlack,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String getStatusName(String value, String languageCode) {
    switch (value) {
      case "P":
        if (languageCode == "en") {
          return "Pending";
        } else {
          return "معلقة";
        }
      case "R":
        if (languageCode == "en") {
          return "In Progress";
        } else {
          return "قيد المعالجة";
        }
      case "A":
        if (languageCode == "en") {
          return "Active";
        } else {
          return "جارية";
        }
      default:
        if (languageCode == "en") {
          return "Pending";
        } else {
          return "معلقة";
        }
    }
  }

  Widget pathList(Shipmentv2 shipment) {
    return SizedBox(
      height: 115.h,
      child: ListView.builder(
        itemCount: shipment.subshipments!.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                selectedIndex = index;
                selectedTruck = index;
              });
              initMapbounds(shipment);
              setLoadDate(shipment.subshipments![selectedIndex].pickupDate!);
              setLoadTime(shipment.subshipments![selectedIndex].pickupDate!);
              markers = {};
              var pickupMarker = Marker(
                markerId: const MarkerId("pickup"),
                position: LatLng(
                    double.parse(shipment
                        .subshipments![selectedIndex].pathpoints!
                        .singleWhere((element) => element.pointType == "P")
                        .location!
                        .split(",")[0]),
                    double.parse(shipment
                        .subshipments![selectedIndex].pathpoints!
                        .singleWhere((element) => element.pointType == "P")
                        .location!
                        .split(",")[1])),
                icon: pickupicon,
              );
              markers.add(pickupMarker);
              var deliveryMarker = Marker(
                markerId: const MarkerId("delivery"),
                position: LatLng(
                    double.parse(shipment
                        .subshipments![selectedIndex].pathpoints!
                        .singleWhere((element) => element.pointType == "D")
                        .location!
                        .split(",")[0]),
                    double.parse(shipment
                        .subshipments![selectedIndex].pathpoints!
                        .singleWhere((element) => element.pointType == "D")
                        .location!
                        .split(",")[1])),
                icon: deliveryicon,
              );
              markers.add(deliveryMarker);
              for (var element
                  in shipment.subshipments![selectedIndex].pathpoints!) {
                if (element.pointType! == "S") {
                  markers.add(Marker(
                    markerId: const MarkerId("stoppoint"),
                    position: LatLng(
                        double.parse(element.location!.split(",")[0]),
                        double.parse(element.location!.split(",")[1])),
                    icon: stopicon,
                  ));
                }
              }

              setState(() {});
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 180.w,
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
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50.h,
                        width: 175.w,
                        child: CachedNetworkImage(
                          imageUrl: shipment
                              .subshipments![index].truck!.truck_type!.image!,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  Shimmer.fromColors(
                            baseColor: (Colors.grey[300])!,
                            highlightColor: (Colors.grey[100])!,
                            enabled: true,
                            child: Container(
                              height: 50.h,
                              width: 175.w,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 50.h,
                            width: 175.w,
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
                        "${shipment.subshipments![index].truck!.truckuser!.user!.firstName!} ${shipment.subshipments![index].truck!.truckuser!.user!.lastName!}",
                        style: TextStyle(
                          fontSize: 17.sp,
                          color: AppColor.deepBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -5,
                  left: -6,
                  child: shipment.subshipments![index].shipmentStatus == "R"
                      ? const Icon(
                          Icons.circle,
                          color: Colors.green,
                          size: 25,
                        )
                      : Icon(
                          Icons.warning_rounded,
                          color: Colors.orange[300],
                          size: 25,
                        ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  late BitmapDescriptor pickupicon;
  late BitmapDescriptor deliveryicon;
  late BitmapDescriptor stopicon;
  late BitmapDescriptor truckicon;
  late LatLng truckLocation;
  late bool truckLocationassign;
  Set<Marker> markers = Set();

  createMarkerIcons(Shipmentv2 shipment) async {
    pickupicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location1.png");
    deliveryicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location2.png");
    stopicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/locationP.png");
    truckicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/truck.png");
    markers = {};
    var pickupMarker = Marker(
      markerId: const MarkerId("pickup"),
      position: LatLng(
          double.parse(shipment.subshipments![selectedIndex].pathpoints!
              .singleWhere((element) => element.pointType == "P")
              .location!
              .split(",")[0]),
          double.parse(shipment.subshipments![selectedIndex].pathpoints!
              .singleWhere((element) => element.pointType == "P")
              .location!
              .split(",")[1])),
      icon: pickupicon,
    );
    markers.add(pickupMarker);
    var deliveryMarker = Marker(
      markerId: const MarkerId("delivery"),
      position: LatLng(
          double.parse(shipment.subshipments![selectedIndex].pathpoints!
              .singleWhere((element) => element.pointType == "D")
              .location!
              .split(",")[0]),
          double.parse(shipment.subshipments![selectedIndex].pathpoints!
              .singleWhere((element) => element.pointType == "D")
              .location!
              .split(",")[1])),
      icon: deliveryicon,
    );
    markers.add(deliveryMarker);
    for (var element in shipment.subshipments![selectedIndex].pathpoints!) {
      if (element.pointType! == "S") {
        markers.add(Marker(
          markerId: const MarkerId("stoppoint"),
          position: LatLng(double.parse(element.location!.split(",")[0]),
              double.parse(element.location!.split(",")[1])),
          icon: deliveryicon,
        ));
      }
    }

    setState(() {});
  }

  setLoadTime(DateTime time) {
    String am = time.hour > 12 ? 'pm' : 'am';
    setState(() {
      timeController.text = '${time.hour}:${time.minute} $am';
    });
  }

  setLoadDate(DateTime date) {
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
    setState(() {
      dateController.text = '${date.year}-$month-${date.day}';
    });
  }

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/style/map_style.json').then((string) {
      _mapStyle = string;
    });
    // calculateCo2Report();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<LatLng> deserializeLatLng(String jsonString) {
    List<dynamic> coordinates = json.decode(jsonString);
    List<LatLng> latLngList = [];
    for (var coord in coordinates) {
      latLngList.add(LatLng(coord[0], coord[1]));
    }
    return latLngList;
  }

  var count = 25;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return SafeArea(
          child: Scaffold(
            appBar: CustomAppBar(
              title:
                  "${AppLocalizations.of(context)!.translate('shipment_number')}: ${widget.shipment.id!}",
            ),
            body: BlocConsumer<ShipmentDetailsBloc, ShipmentDetailsState>(
              listener: (context, state) {
                if (state is ShipmentDetailsLoadedSuccess) {
                  createMarkerIcons(state.shipment);
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    setLoadDate(state.shipment.subshipments![0].pickupDate!);
                    setLoadTime(state.shipment.subshipments![0].pickupDate!);
                  });
                }
              },
              builder: (context, shipmentstate) {
                if (shipmentstate is ShipmentDetailsLoadedSuccess) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 300.h,
                          child: Stack(
                            children: [
                              GoogleMap(
                                onMapCreated:
                                    (GoogleMapController controller) async {
                                  setState(() {
                                    _controller = controller;
                                    // _controller.setMapStyle(_mapStyle);
                                  });
                                  initMapbounds(shipmentstate.shipment);
                                },
                                myLocationButtonEnabled: false,
                                zoomGesturesEnabled: false,
                                scrollGesturesEnabled: false,
                                tiltGesturesEnabled: false,
                                rotateGesturesEnabled: false,
                                zoomControlsEnabled: false,
                                initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                        double.parse(shipmentstate
                                            .shipment
                                            .subshipments![selectedIndex]
                                            .pathpoints!
                                            .singleWhere((element) =>
                                                element.pointType == "P")
                                            .location!
                                            .split(",")[0]),
                                        double.parse(shipmentstate
                                            .shipment
                                            .subshipments![selectedIndex]
                                            .pathpoints!
                                            .singleWhere((element) =>
                                                element.pointType == "P")
                                            .location!
                                            .split(",")[1])),
                                    zoom: 14.47),
                                gestureRecognizers: {},
                                markers: markers,
                                polylines: {
                                  Polyline(
                                    polylineId: const PolylineId("route"),
                                    points: deserializeLatLng(shipmentstate
                                        .shipment
                                        .subshipments![selectedIndex]
                                        .paths!),
                                    color: AppColor.deepYellow,
                                    width: 4,
                                  ),
                                },
                                // mapType: shipmentProvider.mapType,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 4,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            ShipmentDetailsMapScreen(
                                          shipment: shipmentstate.shipment,
                                        ),
                                        transitionDuration:
                                            const Duration(milliseconds: 1000),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          var begin = const Offset(0.0, -1.0);
                                          var end = Offset.zero;
                                          var curve = Curves.ease;

                                          var tween = Tween(
                                                  begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));

                                          return SlideTransition(
                                            position: animation.drive(tween),
                                            child: child,
                                          );
                                        },
                                      ),
                                    ).then((value) {
                                      initMapbounds(shipmentstate.shipment);
                                    });
                                    // shipmentProvider.setMapMode(MapType.satellite);
                                  },
                                  child: const AbsorbPointer(
                                    absorbing: false,
                                    child: SizedBox(
                                      height: 50,
                                      width: 70,
                                      child: Center(
                                        child: Icon(
                                          Icons.zoom_out_map,
                                          color: Colors.grey,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              SectionTitle(
                                text: AppLocalizations.of(context)!
                                    .translate("assigned_trucks"),
                              ),
                              const SizedBox(height: 4),
                              pathList(shipmentstate.shipment),
                              const Divider(
                                height: 12,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SectionTitle(
                                      text:
                                          "${AppLocalizations.of(context)!.translate("shipment_status")}: "),
                                  SectionBody(
                                    text: getStatusName(
                                      shipmentstate
                                          .shipment
                                          .subshipments![selectedIndex]
                                          .shipmentStatus!,
                                      localeState.value.languageCode,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 12,
                              ),
                              SectionTitle(
                                text: AppLocalizations.of(context)!
                                    .translate("shipment_route"),
                              ),
                              ShipmentPathVerticalWidget(
                                pathpoints: shipmentstate.shipment
                                    .subshipments![selectedIndex].pathpoints!,
                                pickupDate: shipmentstate.shipment
                                    .subshipments![selectedIndex].pickupDate!,
                                deliveryDate: shipmentstate.shipment
                                    .subshipments![selectedIndex].deliveryDate!,
                                langCode: localeState.value.languageCode,
                                mini: false,
                              ),
                              const Divider(),
                              SectionTitle(
                                text: AppLocalizations.of(context)!
                                    .translate("commodity_info"),
                              ),
                              const SizedBox(height: 4),
                              Commodity_info_widget(
                                  shipmentItems: shipmentstate
                                      .shipment
                                      .subshipments![selectedIndex]
                                      .shipmentItems),
                              const Divider(),
                              SectionTitle(
                                text: AppLocalizations.of(context)!
                                    .translate("shipment_route_statistics"),
                              ),
                              const SizedBox(height: 4),
                              PathStatisticsWidget(
                                distance: shipmentstate.shipment
                                    .subshipments![selectedIndex].distance!,
                                period: shipmentstate.shipment
                                    .subshipments![selectedIndex].period!,
                              ),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: BlocConsumer<CancelShipmentBloc,
                                    CancelShipmentState>(
                                  listener: (context, cancelstate) {
                                    if (cancelstate
                                        is CancelShipmentSuccessState) {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ControlView(),
                                          ),
                                          (route) => false);
                                    }
                                  },
                                  builder: (context, cancelstate) {
                                    if (cancelstate
                                        is ShippmentLoadingProgressState) {
                                      return CustomButton(
                                        title: SizedBox(
                                          width: 70.w,
                                          child: Center(
                                            child: LoadingIndicator(),
                                          ),
                                        ),
                                        onTap: () {},
                                        color: Colors.white,
                                      );
                                    } else {
                                      return CustomButton(
                                        title: SizedBox(
                                          width: 70.w,
                                          child: Center(
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate('cancel'),
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          showDialog<void>(
                                            context: context,
                                            barrierDismissible:
                                                false, // user must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: Text(AppLocalizations.of(
                                                        context)!
                                                    .translate('cancel')),
                                                // content:
                                                //     SingleChildScrollView(
                                                //   child: Form(
                                                //     key:
                                                //         _rejectformKey,
                                                //     child: ListBody(
                                                //       children: <Widget>[
                                                //         Text(
                                                //             "الرجاء تحديد سبب الرفض"),
                                                //         TextFormField(
                                                //           controller:
                                                //               rejectTextController,
                                                //           onTap: () {
                                                //             rejectTextController.selection = TextSelection(
                                                //                 baseOffset:
                                                //                     0,
                                                //                 extentOffset: rejectTextController
                                                //                     .value
                                                //                     .text
                                                //                     .length);
                                                //           },
                                                //           style: TextStyle(
                                                //               fontSize:
                                                //                   18.sp),
                                                //           scrollPadding:
                                                //               EdgeInsets.only(
                                                //                   bottom:
                                                //                       MediaQuery.of(context).viewInsets.bottom + 50),
                                                //           decoration:
                                                //               InputDecoration(
                                                //             hintText:
                                                //                 'سبب الرفض',
                                                //             hintStyle:
                                                //                 TextStyle(
                                                //                     fontSize: 18.sp),
                                                //           ),
                                                //           validator:
                                                //               (value) {
                                                //             if (value!
                                                //                 .isEmpty) {
                                                //               return AppLocalizations.of(context)!
                                                //                   .translate('insert_value_validate');
                                                //             }
                                                //             return null;
                                                //           },
                                                //           onSaved:
                                                //               (newValue) {
                                                //             rejectTextController
                                                //                     .text =
                                                //                 newValue!;
                                                //             rejectText =
                                                //                 newValue!;
                                                //           },
                                                //         ),
                                                //       ],
                                                //     ),
                                                //   ),
                                                // ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text(AppLocalizations
                                                            .of(context)!
                                                        .translate('cancel')),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .translate('ok')),
                                                    onPressed: () {
                                                      BlocProvider.of<
                                                                  CancelShipmentBloc>(
                                                              context)
                                                          .add(
                                                        CancelShipmentButtonPressed(
                                                          shipmentstate
                                                              .shipment.id!,
                                                        ),
                                                      );
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        color: Colors.white,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Expanded(
                        //   child: ListView(
                        //     children: [
                        //       Padding(
                        //         padding: const EdgeInsets.all(8.0),
                        //         child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             ],
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  );
                } else {
                  return Center(child: LoadingIndicator());
                }
              },
            ),
          ),
        );
      },
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
    var cameraUpdate = CameraUpdate.newLatLngBounds(_bounds, 50.0);
    mapcontroller.animateCamera(cameraUpdate);
    print("asd3");

    // setState(() {});
  }

  int getunfinishedTasks(Shipmentv2 shipment) {
    var count = 0;
    // if (shipment.shipmentinstruction == null) {
    //   count++;
    // }
    // if (shipment.shipmentpayment == null) {
    //   count++;
    // }
    return count;
  }
}
