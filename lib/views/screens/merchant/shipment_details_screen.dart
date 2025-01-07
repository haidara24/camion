import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/instructions/read_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/read_payment_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_details_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/enums.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/merchant/shipment_details_map_screen.dart';
import 'package:camion/views/screens/merchant/shipment_instruction_details_screen.dart';
import 'package:camion/views/screens/merchant/shipment_payment_instruction_details_screeen.dart';
import 'package:camion/views/screens/search_truck_screen.dart';
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' as intel;
import 'package:shimmer/shimmer.dart';

class ShipmentDetailsScreen extends StatefulWidget {
  final int shipment;
  final bool preview;
  const ShipmentDetailsScreen({
    Key? key,
    required this.shipment,
    required this.preview,
  }) : super(key: key);

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
          return "Running";
        } else {
          return "جارية";
        }
      case "A":
        if (languageCode == "en") {
          return "Active";
        } else {
          return "جارية";
        }
      case "C":
        if (languageCode == "en") {
          return "Completed";
        } else {
          return "مكتملة";
        }
      case "F":
        if (languageCode == "en") {
          return "Canceled";
        } else {
          return "ملغاة";
        }
      default:
        if (languageCode == "en") {
          return "Pending";
        } else {
          return "معلقة";
        }
    }
  }

  Widget getStatusImage(String value) {
    switch (value) {
      case "P":
        return const Icon(
          Icons.circle,
          color: Colors.orange,
          size: 25,
        );
      // return SvgPicture.asset(
      //   "assets/icons/orange/notification_shipment_pending.svg",
      //   height: 28.h,
      //   width: 28.h,
      //   fit: BoxFit.fill,
      // );
      case "R":
        return const Icon(
          Icons.circle,
          color: Colors.green,
          size: 25,
        );
      // return SvgPicture.asset(
      //   "assets/icons/orange/notification_shipment_waiting.svg",
      //   height: 28.h,
      //   width: 28.h,
      //   fit: BoxFit.fill,
      // );
      case "F":
        return const Icon(
          Icons.circle,
          color: Colors.red,
          size: 25,
        );
      // return SvgPicture.asset(
      //   "assets/icons/orange/notification_shipment_cancelation.svg",
      //   height: 28.h,
      //   width: 28.h,
      //   fit: BoxFit.fill,
      // );
      case "A":
        return const Icon(
          Icons.circle,
          color: Colors.green,
          size: 25,
        );

      default:
        return const Icon(
          Icons.circle,
          color: Colors.green,
          size: 25,
        );
      // return SvgPicture.asset(
      //   "assets/icons/orange/notification_shipment_complete.svg",
      //   height: 28.h,
      //   width: 28.h,
      //   fit: BoxFit.fill,
      // );
    }
  }

  Widget pathList(Shipmentv2 shipment) {
    return SizedBox(
      height: 58.h,
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
                    height: 4.h,
                  ),
                  Text(
                    "sub shipment ${index + 1}",
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

  Widget truckList(Shipmentv2 shipment) {
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
            child: shipment.subshipments![index].truck == null
                ? Container(
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
                    child: Center(
                      child: SectionTitle(
                        text: "sub shipment ${index + 1}",
                      ),
                    ),
                  )
                : Stack(
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
                                imageUrl: shipment.subshipments![index].truck!
                                    .truck_type_image!,
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
                              height: 4.h,
                            ),
                            Text(
                              "${shipment.subshipments![index].driver_first_name!} ${shipment.subshipments![index].driver_last_name!}",
                              style: TextStyle(
                                fontSize: 17.sp,
                                color: AppColor.deepBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Positioned(
                      //   top: -8,
                      //   left: -8,
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //         color: Colors.white,
                      //         borderRadius: BorderRadius.circular(45)),
                      //     child: getStatusImage(
                      //         shipment.subshipments![index].shipmentStatus!),
                      //   ),
                      // )
                    ],
                  ),
          );
        },
      ),
    );
  }

  widgetList(bool preview, Shipmentv2 shipment) {
    if (shipment.shipmentStatus == "C") {
      return truckList(shipment);
    }
    if (widget.preview) {
      return pathList(shipment);
    } else {
      return truckList(shipment);
    }
  }

  late BitmapDescriptor pickupicon;
  late BitmapDescriptor deliveryicon;
  late BitmapDescriptor stopicon;
  late BitmapDescriptor truckicon;
  late LatLng truckLocation;
  late bool truckLocationassign;
  Set<Marker> markers = {};
  bool instructionSelect = true;

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
    super.dispose();
    _controller.dispose();
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
                  "${AppLocalizations.of(context)!.translate('shipment_number')}: ${widget.shipment}",
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
                                    zoom: 14.45),
                                gestureRecognizers: const {},
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
                                    // Navigator.push(
                                    //   context,
                                    //   PageRouteBuilder(
                                    //     pageBuilder: (context, animation,
                                    //             secondaryAnimation) =>
                                    //         ShipmentDetailsMapScreen(
                                    //       shipment: shipmentstate.shipment,
                                    //     ),
                                    //     transitionDuration:
                                    //         const Duration(milliseconds: 1000),
                                    //     transitionsBuilder: (context, animation,
                                    //         secondaryAnimation, child) {
                                    //       var begin = const Offset(0.0, -1.0);
                                    //       var end = Offset.zero;
                                    //       var curve = Curves.ease;

                                    //       var tween = Tween(
                                    //               begin: begin, end: end)
                                    //           .chain(CurveTween(curve: curve));

                                    //       return SlideTransition(
                                    //         position: animation.drive(tween),
                                    //         child: child,
                                    //       );
                                    //     },
                                    //   ),
                                    // ).then((value) {
                                    //   initMapbounds(shipmentstate.shipment);
                                    // });
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
                          padding: const EdgeInsets.all(16.0),
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
                              widgetList(
                                  widget.preview, shipmentstate.shipment),
                              const Divider(
                                height: 16,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SectionTitle(
                                    text:
                                        "${AppLocalizations.of(context)!.translate("shipment_status")}: ",
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: getStatusImage(
                                      shipmentstate
                                          .shipment
                                          .subshipments![selectedIndex]
                                          .shipmentStatus!,
                                    ),
                                  ),
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
                                height: 16,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (shipmentstate
                                                .shipment
                                                .subshipments![selectedIndex]
                                                .shipmentinstructionv2 !=
                                            null) {
                                          BlocProvider.of<ReadInstructionBloc>(
                                                  context)
                                              .add(
                                            ReadInstructionLoadEvent(
                                                shipmentstate
                                                    .shipment
                                                    .subshipments![
                                                        selectedIndex]
                                                    .shipmentinstructionv2!),
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ShipmentInstructionDetailsScreen(
                                                      shipment: shipmentstate
                                                              .shipment
                                                              .subshipments![
                                                          selectedIndex]),
                                            ),
                                          );
                                        }
                                      },
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .4,
                                            margin: const EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                              color: Colors.white,
                                              border: Border.all(
                                                color: shipmentstate
                                                            .shipment
                                                            .subshipments![
                                                                selectedIndex]
                                                            .shipmentinstructionv2 !=
                                                        null
                                                    ? AppColor.deepYellow
                                                    : AppColor.lightGrey,
                                                width: 2,
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      // SizedBox(
                                                      //     height: 25.h,
                                                      //     width: 25.w,
                                                      //     child: SvgPicture.asset(
                                                      //         "assets/icons/instruction.svg")),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .35,
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .translate(
                                                                    'shipment_instruction'),
                                                            style: TextStyle(
                                                                // color: AppColor.lightBlue,
                                                                fontSize: 18.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 7.h,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .4,
                                                    child: shipmentstate
                                                                .shipment
                                                                .subshipments![
                                                                    selectedIndex]
                                                                .shipmentinstructionv2 ==
                                                            null
                                                        ? Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .translate(
                                                                    'instruction_not_complete'),
                                                            maxLines: 2,
                                                          )
                                                        : Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .translate(
                                                                    'instruction_complete'),
                                                            maxLines: 2,
                                                          ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: -5,
                                            right: localeState
                                                        .value.languageCode ==
                                                    "en"
                                                ? -5
                                                : null,
                                            left: localeState
                                                        .value.languageCode ==
                                                    "en"
                                                ? null
                                                : -5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          45)),
                                              child: shipmentstate
                                                          .shipment
                                                          .subshipments![
                                                              selectedIndex]
                                                          .shipmentinstructionv2 ==
                                                      null
                                                  ? Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color:
                                                          AppColor.deepYellow,
                                                    )
                                                  : Icon(
                                                      Icons.check_circle,
                                                      color:
                                                          AppColor.deepYellow,
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (shipmentstate
                                                .shipment
                                                .subshipments![selectedIndex]
                                                .shipmentpaymentv2 !=
                                            null) {
                                          BlocProvider.of<
                                                      ReadPaymentInstructionBloc>(
                                                  context)
                                              .add(
                                            ReadPaymentInstructionLoadEvent(
                                                shipmentstate
                                                    .shipment
                                                    .subshipments![
                                                        selectedIndex]
                                                    .shipmentpaymentv2!),
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PaymentInstructionDetailsScreen(
                                                      shipment: shipmentstate
                                                              .shipment
                                                              .subshipments![
                                                          selectedIndex]),
                                            ),
                                          );
                                        }
                                      },
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .4,
                                            margin: const EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                              color: Colors.white,
                                              border: Border.all(
                                                color: shipmentstate
                                                            .shipment
                                                            .subshipments![
                                                                selectedIndex]
                                                            .shipmentpaymentv2 !=
                                                        null
                                                    ? AppColor.deepYellow
                                                    : AppColor.lightGrey,
                                                width: 2,
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      // SizedBox(
                                                      //     height: 25.h,
                                                      //     width: 25.w,
                                                      //     child: SvgPicture.asset(
                                                      //         "assets/icons/payment.svg")),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .35,
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .translate(
                                                                    'payment_instruction'),
                                                            style: TextStyle(
                                                                // color: AppColor.lightBlue,
                                                                fontSize: 18.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 7.h,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .4,
                                                    child: shipmentstate
                                                                .shipment
                                                                .subshipments![
                                                                    selectedIndex]
                                                                .shipmentpaymentv2 ==
                                                            null
                                                        ? Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .translate(
                                                                    'payment_not_complete'),
                                                            maxLines: 2,
                                                          )
                                                        : Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .translate(
                                                                    'payment_complete'),
                                                            maxLines: 2,
                                                          ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: -5,
                                            right: localeState
                                                        .value.languageCode ==
                                                    "en"
                                                ? -5
                                                : null,
                                            left: localeState
                                                        .value.languageCode ==
                                                    "en"
                                                ? null
                                                : -5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          45)),
                                              child: shipmentstate
                                                          .shipment
                                                          .subshipments![
                                                              selectedIndex]
                                                          .shipmentpaymentv2 ==
                                                      null
                                                  ? Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color:
                                                          AppColor.deepYellow,
                                                    )
                                                  : Icon(
                                                      Icons.check_circle,
                                                      color:
                                                          AppColor.deepYellow,
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 24,
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
                              const Divider(
                                height: 32,
                              ),
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
                              const Divider(
                                height: 32,
                              ),
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
                              const Divider(
                                height: 32,
                              ),
                              Visibility(
                                visible: shipmentstate
                                            .shipment
                                            .subshipments![selectedIndex]
                                            .truck ==
                                        null &&
                                    !widget.preview,
                                replacement: const SizedBox.shrink(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: CustomButton(
                                    title: SizedBox(
                                      width: 200.w,
                                      child: Row(
                                        children: [
                                          Center(
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      'search_for_truck'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            height: 25.w,
                                            width: 30.w,
                                            child: SvgPicture.asset(
                                              "assets/icons/white/search_for_truck.svg",
                                              width: 25.w,
                                              height: 30.w,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SearchTruckScreen(
                                                  subshipmentId: shipmentstate
                                                      .shipment
                                                      .subshipments![
                                                          selectedIndex]
                                                      .id!),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Visibility(
                              //   visible: !widget.preview,
                              //   replacement: shipmentstate
                              //               .shipment.shipmentStatus ==
                              //           "F"
                              //       ? Padding(
                              //           padding: const EdgeInsets.all(10.0),
                              //           child: BlocConsumer<
                              //               ReActiveShipmentBloc,
                              //               ReActiveShipmentState>(
                              //             listener: (context, reActivestate) {
                              //               if (reActivestate
                              //                   is ReActiveShipmentSuccessState) {
                              //                 Navigator.pushAndRemoveUntil(
                              //                     context,
                              //                     MaterialPageRoute(
                              //                       builder: (context) =>
                              //                           const ControlView(),
                              //                     ),
                              //                     (route) => false);
                              //               }
                              //             },
                              //             builder: (context, reActivestate) {
                              //               if (reActivestate
                              //                   is ReActiveShippmentLoadingProgressState) {
                              //                 return CustomButton(
                              //                   title: SizedBox(
                              //                     width: 110.w,
                              //                     child: Center(
                              //                       child: LoadingIndicator(),
                              //                     ),
                              //                   ),
                              //                   onTap: () {},
                              //                   // color: Colors.white,
                              //                 );
                              //               } else {
                              //                 return CustomButton(
                              //                   title: SizedBox(
                              //                     width: 110.w,
                              //                     child: Row(
                              //                       children: [
                              //                         Center(
                              //                           child: Text(
                              //                             AppLocalizations.of(
                              //                                     context)!
                              //                                 .translate(
                              //                                     'reactive'),
                              //                             style:
                              //                                 const TextStyle(
                              //                               color: Colors.white,
                              //                               fontSize: 18,
                              //                               fontWeight:
                              //                                   FontWeight.bold,
                              //                             ),
                              //                           ),
                              //                         ),
                              //                         SizedBox(
                              //                           height: 30.w,
                              //                           width: 30.w,
                              //                           child: SvgPicture.asset(
                              //                             "assets/icons/complete.svg",
                              //                             width: 30.w,
                              //                             height: 30.w,
                              //                           ),
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                   onTap: () {
                              //                     showDialog<void>(
                              //                       context: context,
                              //                       barrierDismissible:
                              //                           false, // user must tap button!
                              //                       builder:
                              //                           (BuildContext context) {
                              //                         return AlertDialog(
                              //                           backgroundColor:
                              //                               Colors.white,
                              //                           title: Text(
                              //                               AppLocalizations.of(
                              //                                       context)!
                              //                                   .translate(
                              //                                       'reactive')),
                              //                           content: Text(
                              //                             AppLocalizations.of(
                              //                                     context)!
                              //                                 .translate(
                              //                                     'reactive_confirm'),
                              //                           ),
                              //                           actions: <Widget>[
                              //                             TextButton(
                              //                               child: Text(
                              //                                   AppLocalizations.of(
                              //                                           context)!
                              //                                       .translate(
                              //                                           'cancel')),
                              //                               onPressed: () {
                              //                                 Navigator.of(
                              //                                         context)
                              //                                     .pop();
                              //                               },
                              //                             ),
                              //                             TextButton(
                              //                               child: Text(
                              //                                   AppLocalizations.of(
                              //                                           context)!
                              //                                       .translate(
                              //                                           'ok')),
                              //                               onPressed: () {
                              //                                 BlocProvider.of<
                              //                                             ReActiveShipmentBloc>(
                              //                                         context)
                              //                                     .add(
                              //                                   ReActiveShipmentButtonPressed(
                              //                                     shipmentstate
                              //                                         .shipment
                              //                                         .id!,
                              //                                   ),
                              //                                 );
                              //                                 Navigator.of(
                              //                                         context)
                              //                                     .pop();
                              //                               },
                              //                             ),
                              //                           ],
                              //                         );
                              //                       },
                              //                     );
                              //                   },
                              //                 );
                              //               }
                              //             },
                              //           ),
                              //         )
                              //       : const SizedBox.shrink(),
                              //   child: Padding(
                              //     padding: const EdgeInsets.all(10.0),
                              //     child: BlocConsumer<CancelShipmentBloc,
                              //         CancelShipmentState>(
                              //       listener: (context, cancelstate) {
                              //         if (cancelstate
                              //             is CancelShipmentSuccessState) {
                              //           Navigator.pushAndRemoveUntil(
                              //               context,
                              //               MaterialPageRoute(
                              //                 builder: (context) =>
                              //                     const ControlView(),
                              //               ),
                              //               (route) => false);
                              //         }
                              //       },
                              //       builder: (context, cancelstate) {
                              //         if (cancelstate
                              //             is ShippmentLoadingProgressState) {
                              //           return CustomButton(
                              //             title: SizedBox(
                              //               width: 90.w,
                              //               child: Center(
                              //                 child: LoadingIndicator(),
                              //               ),
                              //             ),
                              //             onTap: () {},
                              //             // color: Colors.white,
                              //           );
                              //         } else {
                              //           return CustomButton(
                              //             title: SizedBox(
                              //               width: 100.w,
                              //               child: Row(
                              //                 children: [
                              //                   Center(
                              //                     child: Text(
                              //                       AppLocalizations.of(
                              //                               context)!
                              //                           .translate('cancel'),
                              //                       style: const TextStyle(
                              //                         color: Colors.white,
                              //                         fontSize: 18,
                              //                         fontWeight:
                              //                             FontWeight.bold,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                   const SizedBox(width: 8),
                              //                   SizedBox(
                              //                     height: 28.w,
                              //                     width: 28.w,
                              //                     child: SvgPicture.asset(
                              //                       "assets/icons/white/notification_shipment_cancelation.svg",
                              //                       width: 28.w,
                              //                       height: 28.w,
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //             onTap: () {
                              //               showDialog<void>(
                              //                 context: context,
                              //                 barrierDismissible:
                              //                     false, // user must tap button!
                              //                 builder: (BuildContext context) {
                              //                   return AlertDialog(
                              //                     backgroundColor: Colors.white,
                              //                     title: Text(
                              //                         AppLocalizations.of(
                              //                                 context)!
                              //                             .translate('cancel')),
                              //                     content: Text(
                              //                       AppLocalizations.of(
                              //                               context)!
                              //                           .translate(
                              //                               'cancel_confirm'),
                              //                     ),
                              //                     actions: <Widget>[
                              //                       TextButton(
                              //                         child: Text(
                              //                             AppLocalizations.of(
                              //                                     context)!
                              //                                 .translate(
                              //                                     'cancel')),
                              //                         onPressed: () {
                              //                           Navigator.of(context)
                              //                               .pop();
                              //                         },
                              //                       ),
                              //                       TextButton(
                              //                         child: Text(
                              //                             AppLocalizations.of(
                              //                                     context)!
                              //                                 .translate('ok')),
                              //                         onPressed: () {
                              //                           BlocProvider.of<
                              //                                       CancelShipmentBloc>(
                              //                                   context)
                              //                               .add(
                              //                             CancelShipmentButtonPressed(
                              //                               shipmentstate
                              //                                   .shipment.id!,
                              //                             ),
                              //                           );
                              //                           Navigator.of(context)
                              //                               .pop();
                              //                         },
                              //                       ),
                              //                     ],
                              //                   );
                              //                 },
                              //               );
                              //             },
                              //           );
                              //         }
                              //       },
                              //     ),
                              //   ),
                              // ),
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

    LatLngBounds bounds = LatLngBounds(
      northeast: LatLng(rightMost, topMost),
      southwest: LatLng(leftMost, bottomMost),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50.0);
    mapcontroller.animateCamera(cameraUpdate);

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
