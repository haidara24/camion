import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/read_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/read_payment_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_details_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/enums.dart';
import 'package:camion/data/services/map_service.dart';
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
import 'package:camion/views/widgets/shipments_widgets/shipment_instruction_cards_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:flutter/services.dart'
    show SystemChrome, SystemUiOverlayStyle, rootBundle;
import 'package:intl/intl.dart' as intel;
import 'package:shimmer/shimmer.dart';

class SubShipmentDetailsScreen extends StatefulWidget {
  final int shipment;
  final bool preview;
  const SubShipmentDetailsScreen({
    Key? key,
    required this.shipment,
    required this.preview,
  }) : super(key: key);

  @override
  State<SubShipmentDetailsScreen> createState() =>
      _SubShipmentDetailsScreenState();
}

class _SubShipmentDetailsScreenState extends State<SubShipmentDetailsScreen> {
  late GoogleMapController _controller;

  String _mapStyle = "";
  PanelState panelState = PanelState.hidden;
  final panelTransation = const Duration(milliseconds: 500);
  var f = intel.NumberFormat("#,###", "en_US");

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  initMapbounds(SubShipment shipment) {
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

  late BitmapDescriptor truckicon;
  late LatLng truckLocation;
  late bool truckLocationassign;
  Set<Marker> markers = {};
  bool instructionSelect = true;

  createMarkerIcons(SubShipment shipment) async {
    truckicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/truck.png");
    markers = {};

    for (var i = 0; i < shipment.pathpoints!.length; i++) {
      if (i == 0) {
        Uint8List markerIcon = await MapService.createCustomMarker(
          "A",
        );

        var marker = Marker(
          markerId: MarkerId("stop$i"),
          position: LatLng(
            double.parse(shipment.pathpoints![i].location!.split(",")[0]),
            double.parse(shipment.pathpoints![i].location!.split(",")[1]),
          ),
          icon: BitmapDescriptor.bytes(markerIcon),
        );
        markers.add(marker);
      } else {
        Uint8List markerIcon = await MapService.createCustomMarker(
          i == shipment.pathpoints!.length - 1 ? "B" : "$i",
        );
        var marker = Marker(
          markerId: MarkerId("stop$i"),
          position: LatLng(
            double.parse(shipment.pathpoints![i].location!.split(",")[0]),
            double.parse(shipment.pathpoints![i].location!.split(",")[1]),
          ),
          icon: BitmapDescriptor.bytes(markerIcon),
        );
        markers.add(marker);
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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark, // Reset to default
        statusBarColor: AppColor.deepBlack,
        systemNavigationBarColor: AppColor.deepBlack,
      ),
    );

    _controller.dispose();
  }

  List<LatLng> deserializeLatLng(String jsonString) {
    List<dynamic> coordinates = json.decode(jsonString);
    List<LatLng> latLngList = [];
    for (var coord in coordinates) {
      latLngList.add(LatLng(coord["coordinates"][0], coord["coordinates"][1]));
    }
    return latLngList;
  }

  var count = 25;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: AppColor.deepBlack, // Make status bar transparent
            statusBarIconBrightness:
                Brightness.light, // Light icons for dark backgrounds
            systemNavigationBarColor: Colors.grey[200], // Works on Android
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: SafeArea(
            child: Scaffold(
              appBar: CustomAppBar(
                title:
                    "${AppLocalizations.of(context)!.translate('shipment_number')}: ${widget.shipment}",
              ),
              body:
                  BlocConsumer<SubShipmentDetailsBloc, SubShipmentDetailsState>(
                listener: (context, state) {
                  if (state is SubShipmentDetailsLoadedSuccess) {
                    createMarkerIcons(state.shipment);
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      setLoadDate(state.shipment.pickupDate!);
                      setLoadTime(state.shipment.pickupDate!);
                    });
                  }
                },
                builder: (context, shipmentstate) {
                  if (shipmentstate is SubShipmentDetailsLoadedSuccess) {
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
                                      _controller.setMapStyle(_mapStyle);
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
                                              .shipment.pathpoints!
                                              .singleWhere((element) =>
                                                  element.pointType == "P")
                                              .location!
                                              .split(",")[0]),
                                          double.parse(shipmentstate
                                              .shipment.pathpoints!
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
                                      points: deserializeLatLng(
                                          shipmentstate.shipment.paths!),
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
                                          transitionDuration: const Duration(
                                              milliseconds: 1000),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            var begin = const Offset(0.0, -1.0);
                                            var end = Offset.zero;
                                            var curve = Curves.ease;
                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));
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
                                    child: AbsorbPointer(
                                      absorbing: false,
                                      child: SizedBox(
                                        height: 50,
                                        width: 70,
                                        child: Center(
                                          child: Icon(
                                            Icons.zoom_out_map,
                                            color: Colors.grey[400],
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          height: 58.w,
                                          width: 58.w,
                                          decoration: BoxDecoration(
                                            // color: AppColor.lightGoldenYellow,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: CircleAvatar(
                                            radius: 25.h,
                                            // backgroundColor: AppColor.deepBlue,
                                            child: Center(
                                              child: (shipmentstate
                                                          .shipment
                                                          .driver_image!
                                                          .length >
                                                      1)
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              180),
                                                      child: Image.network(
                                                        shipmentstate.shipment
                                                            .driver_image!,
                                                        height: 55.w,
                                                        width: 55.w,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    )
                                                  : Text(
                                                      shipmentstate.shipment
                                                          .driver_first_name!,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 28.sp,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${shipmentstate.shipment.driver_first_name!} ${shipmentstate.shipment.driver_last_name!}",
                                          style: TextStyle(
                                            // color: AppColor.lightBlue,
                                            fontSize: 19.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 35.h,
                                          width: 155.w,
                                          child: CachedNetworkImage(
                                            imageUrl: shipmentstate.shipment
                                                .truck!.truck_type_image!,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Shimmer.fromColors(
                                              baseColor: (Colors.grey[300])!,
                                              highlightColor:
                                                  (Colors.grey[100])!,
                                              enabled: true,
                                              child: Container(
                                                height: 25.h,
                                                color: Colors.white,
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              height: 35.h,
                                              width: 155.w,
                                              color: Colors.grey[300],
                                              child: Center(
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .translate(
                                                        'image_load_error')),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          "${localeState.value.languageCode == 'en' ? shipmentstate.shipment.truck!.truck_type! : shipmentstate.shipment.truck!.truck_typeAr!}  ",
                                          style: TextStyle(
                                            // color: AppColor.lightBlue,
                                            fontSize: 19.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(
                                  height: 24,
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
                                        shipmentstate.shipment.shipmentStatus!,
                                      ),
                                    ),
                                    SectionBody(
                                      text: getStatusName(
                                        shipmentstate.shipment.shipmentStatus!,
                                        localeState.value.languageCode,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  height: 24,
                                ),
                                SectionTitle(
                                  text: AppLocalizations.of(context)!
                                      .translate("shipment_route"),
                                ),
                                ShipmentPathVerticalWidget(
                                  pathpoints:
                                      shipmentstate.shipment.pathpoints!,
                                  pickupDate:
                                      shipmentstate.shipment.pickupDate!,
                                  deliveryDate:
                                      shipmentstate.shipment.deliveryDate!,
                                  langCode: localeState.value.languageCode,
                                  mini: false,
                                ),
                                const Divider(
                                  height: 24,
                                ),
                                SectionTitle(
                                  text: AppLocalizations.of(context)!
                                      .translate("commodity_info"),
                                ),
                                const SizedBox(height: 4),
                                Commodity_info_widget(
                                    shipmentItems:
                                        shipmentstate.shipment.shipmentItems),
                                const Divider(
                                  height: 24,
                                ),
                                SectionTitle(
                                  text: AppLocalizations.of(context)!
                                      .translate("shipment_route_statistics"),
                                ),
                                const SizedBox(height: 4),
                                PathStatisticsWidget(
                                  distance: shipmentstate.shipment.distance!,
                                  period: shipmentstate.shipment.period!,
                                ),
                                const Divider(
                                  height: 24,
                                ),
                                ShipmentInstructionCardsWidget(
                                  subshipment: shipmentstate.shipment,
                                ),
                                const Divider(
                                  height: 24,
                                ),
                                Visibility(
                                  visible:
                                      shipmentstate.shipment.truck == null &&
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
                                                        .shipment.id!),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(child: LoadingIndicator());
                  }
                },
              ),
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
