import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/driver_shipments/driver_active_shipment_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/complete_sub_shipment_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/enums.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/providers/active_shipment_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/widgets/commodity_info_widget.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/path_statistics_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intel;
import 'package:shimmer/shimmer.dart';

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
  String _mapStyle = "";
  PanelState panelState = PanelState.hidden;
  final panelTransation = const Duration(milliseconds: 500);
  var f = intel.NumberFormat("#,###", "en_US");

  late final AnimationController _animationController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );

  double distance = 0;
  String period = "";

  initMapbounds(OwnerSubShipment subshipment) async {
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
    var cameraUpdate = CameraUpdate.newLatLngBounds(_bounds, 130.0);
    _controller.animateCamera(cameraUpdate);

    var response = await HttpHelper.get(
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${deliverylocation[0]},${deliverylocation[1]}&origins=${subshipment.truck!.location_lat!.split(",")[0]},${subshipment.truck!.location_lat!.split(",")[1]}&key=AIzaSyCl_H8BXqnTm32umdYVQrKMftTiFpRqd-c&mode=DRIVING');

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      distance = double.parse(result["rows"][0]['elements'][0]['distance']
              ['text']
          .replaceAll(" km", ""));
      period = result["rows"][0]['elements'][0]['duration']['text'];
    }
  }

  late BitmapDescriptor pickupicon;
  late BitmapDescriptor deliveryicon;
  late BitmapDescriptor parkicon;
  late BitmapDescriptor truckicon;
  late LatLng truckLocation;
  late bool truckLocationassign;
  Set<Marker> markers = Set();

  Widget pathList(OwnerSubShipment subshipment, String language) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        _onVerticalGesture(details, subshipment, language);
      },
      child: Container(
        color: Colors.grey[200],
        height: 115.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 4.h,
                      width: 25.w,
                      child: SvgPicture.asset(
                        "assets/icons/arrow_up.svg",
                        fit: BoxFit.contain,
                        height: 8.h,
                        width: 25.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      height: 58.w,
                      width: 58.w,
                      decoration: BoxDecoration(
                          // color: AppColor.lightGoldenYellow,
                          borderRadius: BorderRadius.circular(5)),
                      child: CircleAvatar(
                        radius: 25.h,
                        // backgroundColor: AppColor.deepBlue,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(180),
                            child: Image.network(
                              subshipment.shipment!.merchant!.user!.image!,
                              height: 55.w,
                              width: 55.w,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                child: Text(
                                  "${subshipment.shipment!.merchant!.user!.firstName![0].toUpperCase()} ${subshipment.shipment!.merchant!.user!.lastName![0].toUpperCase()}",
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "${subshipment.shipment!.merchant!.user!.firstName!} ${subshipment.shipment!.merchant!.user!.lastName!}",
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
                        imageUrl: subshipment.truck!.truck_type!.image!,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                Shimmer.fromColors(
                          baseColor: (Colors.grey[300])!,
                          highlightColor: (Colors.grey[100])!,
                          enabled: true,
                          child: Container(
                            height: 25.h,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 35.h,
                          width: 155.w,
                          color: Colors.grey[300],
                          child: Center(
                            child: Text(AppLocalizations.of(context)!
                                .translate('image_load_error')),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "${language == 'en' ? subshipment.truck!.truck_type!.name! : subshipment.truck!.truck_type!.nameAr!}  ",
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
          ],
        ),
      ),
    );
  }

  void _onVerticalGesture(DragUpdateDetails details,
      OwnerSubShipment subshipment, String language) {
    if (details.primaryDelta! < -7) {
      panelState = PanelState.open;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        // isDismissible: false,
        // enableDrag: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(0),
          ),
        ),
        builder: (context) => GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! > 7) {
              Navigator.pop(context);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            // constraints:
            //     BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            width: double.infinity,
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: AbsorbPointer(
                        absorbing: false,
                        child: Container(
                          width: MediaQuery.of(context).size.width * .8,
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: SizedBox(
                              height: 8.h,
                              width: 25.w,
                              child: SvgPicture.asset(
                                "assets/icons/arrow_down.svg",
                                fit: BoxFit.contain,
                                height: 8.h,
                                width: 25.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 58.w,
                              width: 58.w,
                              decoration: BoxDecoration(
                                  // color: AppColor.lightGoldenYellow,
                                  borderRadius: BorderRadius.circular(5)),
                              child: CircleAvatar(
                                radius: 25.h,
                                // backgroundColor: AppColor.deepBlue,
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(180),
                                    child: Image.network(
                                      subshipment
                                          .shipment!.merchant!.user!.image!,
                                      height: 55.w,
                                      width: 55.w,
                                      fit: BoxFit.fill,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Center(
                                        child: Text(
                                          "${subshipment.shipment!.merchant!.user!.firstName![0].toUpperCase()} ${subshipment.shipment!.merchant!.user!.lastName![0].toUpperCase()}",
                                          style: TextStyle(
                                            fontSize: 28.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "${subshipment.shipment!.merchant!.user!.firstName!} ${subshipment.shipment!.merchant!.user!.lastName!}",
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
                                imageUrl: subshipment.truck!.truck_type!.image!,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        Shimmer.fromColors(
                                  baseColor: (Colors.grey[300])!,
                                  highlightColor: (Colors.grey[100])!,
                                  enabled: true,
                                  child: Container(
                                    height: 25.h,
                                    color: Colors.white,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 35.h,
                                  width: 155.w,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Text(AppLocalizations.of(context)!
                                        .translate('image_load_error')),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "${language == 'en' ? subshipment.truck!.truck_type!.name! : subshipment.truck!.truck_type!.nameAr!}  ",
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
                    const Divider(),
                    SectionTitle(
                      text: AppLocalizations.of(context)!
                          .translate("shipment_route"),
                    ),
                    ShipmentPathVerticalWidget(
                      pathpoints: subshipment.pathpoints!,
                      pickupDate: subshipment.pickupDate!,
                      deliveryDate: subshipment.deliveryDate!,
                      langCode: language,
                      mini: false,
                    ),
                    const Divider(),
                    SectionTitle(
                      text: AppLocalizations.of(context)!
                          .translate("commodity_info"),
                    ),
                    const SizedBox(height: 4),
                    Commodity_info_widget(
                        shipmentItems: subshipment.shipmentItems!),
                    const Divider(),
                    SectionTitle(
                      text: AppLocalizations.of(context)!
                          .translate("shipment_route_statistics"),
                    ),
                    const SizedBox(height: 4),
                    PathStatisticsWidget(
                      distance: subshipment.distance!,
                      period: subshipment.period!,
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: BlocConsumer<CompleteSubShipmentBloc,
                          CompleteSubShipmentState>(
                        listener: (context, completestate) {
                          if (completestate
                              is CompleteSubShipmentLoadedSuccess) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ControlView(),
                                ),
                                (route) => false);
                          }
                        },
                        builder: (context, completestate) {
                          if (completestate
                              is CompleteSubShipmentLoadingProgress) {
                            return CustomButton(
                              title: SizedBox(
                                width: 90.w,
                                child: Center(
                                  child: LoadingIndicator(),
                                ),
                              ),
                              onTap: () {},
                              // color: Colors.white,
                            );
                          } else {
                            return CustomButton(
                              title: SizedBox(
                                width: 110.w,
                                child: Row(
                                  children: [
                                    Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('accept'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    SizedBox(
                                      height: 30.w,
                                      width: 30.w,
                                      child: SvgPicture.asset(
                                        "assets/icons/white/notification_shipment_complete.svg",
                                        width: 30.w,
                                        height: 30.w,
                                      ),
                                    ),
                                  ],
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
                                      title: Text(AppLocalizations.of(context)!
                                          .translate('finish')),
                                      content: Text(
                                        AppLocalizations.of(context)!
                                            .translate('finish_confirm'),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate('cancel')),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate('ok')),
                                          onPressed: () {
                                            BlocProvider.of<
                                                        CompleteSubShipmentBloc>(
                                                    context)
                                                .add(
                                              CompleteSubShipmentButtonPressed(
                                                subshipment.id!,
                                              ),
                                            );
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else if (details.primaryDelta! > 7 && panelState == PanelState.open) {
      // changeToHidden();
    }
  }

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
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return SafeArea(
          child: Scaffold(
            body: BlocBuilder<DriverActiveShipmentBloc,
                DriverActiveShipmentState>(
              builder: (context, state) {
                if (state is DriverActiveShipmentLoadedSuccess) {
                  if (state.shipments.isEmpty) {
                    return Center(
                      child: SectionTitle(
                          text: AppLocalizations.of(context)!
                              .translate('no_active')),
                    );
                  } else {
                    return Consumer<ActiveShippmentProvider>(
                        builder: (context, shipmentProvider, child) {
                      return Stack(
                        alignment: Alignment.bottomCenter,
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

                                initMapbounds(state.shipments[0]);
                                markers = {};
                                var pickupMarker = Marker(
                                  markerId: const MarkerId("pickup"),
                                  position: LatLng(
                                      double.parse(state
                                          .shipments[0].pathpoints!
                                          .singleWhere((element) =>
                                              element.pointType == "P")
                                          .location!
                                          .split(",")[0]),
                                      double.parse(state
                                          .shipments[0].pathpoints!
                                          .singleWhere((element) =>
                                              element.pointType == "P")
                                          .location!
                                          .split(",")[1])),
                                  icon: pickupicon,
                                  infoWindow: InfoWindow(
                                      title: state.shipments[0].pathpoints!
                                          .singleWhere((element) =>
                                              element.pointType == "P")
                                          .name!),
                                );
                                markers.add(pickupMarker);
                                var deliveryMarker = Marker(
                                  markerId: const MarkerId("delivery"),
                                  position: LatLng(
                                      double.parse(state
                                          .shipments[0].pathpoints!
                                          .singleWhere((element) =>
                                              element.pointType == "D")
                                          .location!
                                          .split(",")[0]),
                                      double.parse(state
                                          .shipments[0].pathpoints!
                                          .singleWhere((element) =>
                                              element.pointType == "D")
                                          .location!
                                          .split(",")[1])),
                                  icon: deliveryicon,
                                  infoWindow: InfoWindow(
                                    title: state.shipments[0].pathpoints!
                                        .singleWhere((element) =>
                                            element.pointType == "D")
                                        .name!,
                                  ),
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

                              initialCameraPosition: const CameraPosition(
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
                                        width: 4,
                                      ),
                                    }
                                  : {},
                              // mapType: shipmentProvider.mapType,
                            ),
                          ),
                          pathList(
                            state.shipments[0],
                            localeState.value.languageCode,
                          ),
                        ],
                      );
                    });
                  }
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
    var cameraUpdate = CameraUpdate.newLatLngBounds(_bounds, 100.0);
    mapcontroller.animateCamera(cameraUpdate);
    print("asd3");

    setState(() {});
  }
}
