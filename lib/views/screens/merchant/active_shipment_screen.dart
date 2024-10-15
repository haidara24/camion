import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/shipments/active_shipment_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/enums.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/providers/active_shipment_provider.dart';
import 'package:camion/data/repositories/gps_repository.dart';
import 'package:camion/data/repositories/truck_repository.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:camion/views/widgets/commodity_info_widget.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/no_reaults_widget.dart';
import 'package:camion/views/widgets/path_statistics_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class _ActiveShipmentScreenState extends State<ActiveShipmentScreen>
    with TickerProviderStateMixin {
  late AnimationController animcontroller;
  late Timer timer;
  late GoogleMapController _controller;
  SubShipment? subshipment;
  String? truckLocation = "";

  String _mapStyle = "";
  PanelState panelState = PanelState.hidden;
  final panelTransation = const Duration(milliseconds: 500);
  var f = intel.NumberFormat("#,###", "en_US");

  int selectedIndex = 0;
  int selectedTruck = 0;

  double distance = 0;
  String period = "";

  bool startTracking = false;

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  initMapbounds(SubShipment subshipment) async {
    setState(() {
      startTracking = false;
    });
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

  void _onVerticalGesture(DragUpdateDetails? details,
      List<SubShipment> subshipments, String language) {
    if (details == null || details.primaryDelta! < -7) {
      panelState = PanelState.open;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        transitionAnimationController: animcontroller,
        // isDismissible: false,
        // enableDrag: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(8),
          ),
        ),
        builder: (context) => GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! > 7) {
              Navigator.pop(context);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            // constraints:
            //     BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            width: double.infinity,
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: SizedBox(
                        width: 32.w,
                        child: SvgPicture.asset(
                          "assets/icons/arrow_down.svg",
                          fit: BoxFit.contain,
                          height: 8.h,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
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
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: CircleAvatar(
                                  radius: 25.h,
                                  // backgroundColor: AppColor.deepBlue,
                                  child: Center(
                                    child: (subshipments[selectedIndex]
                                                .driver_image!
                                                .length >
                                            1)
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(180),
                                            child: Image.network(
                                              subshipments[selectedIndex]
                                                  .driver_image!,
                                              height: 55.w,
                                              width: 55.w,
                                              fit: BoxFit.fill,
                                            ),
                                          )
                                        : Text(
                                            subshipments[selectedIndex]
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
                                "${subshipments[selectedIndex].driver_first_name!} ${subshipments[selectedIndex].driver_last_name!}",
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
                                  imageUrl: subshipments[selectedTruck]
                                      .truck!
                                      .truck_type_image!,
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
                                  errorWidget: (context, url, error) =>
                                      Container(
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
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                "${language == 'en' ? subshipments[selectedIndex].truck!.truck_type! : subshipments[selectedIndex].truck!.truck_typeAr!}  ",
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
                        height: 32,
                      ),
                      SectionTitle(
                        text: AppLocalizations.of(context)!
                            .translate("shipment_route"),
                      ),
                      ShipmentPathVerticalWidget(
                        pathpoints: subshipments[selectedIndex].pathpoints!,
                        pickupDate: subshipments[selectedIndex].pickupDate!,
                        deliveryDate: subshipments[selectedIndex].deliveryDate!,
                        langCode: language,
                        mini: false,
                      ),
                      const Divider(
                        height: 32,
                      ),
                      SectionTitle(
                        text: AppLocalizations.of(context)!
                            .translate("commodity_info"),
                      ),
                      Commodity_info_widget(
                          shipmentItems:
                              subshipments[selectedIndex].shipmentItems!),
                      const Divider(
                        height: 32,
                      ),
                      SectionTitle(
                        text: AppLocalizations.of(context)!
                            .translate("shipment_route_statistics"),
                      ),
                      PathStatisticsWidget(
                        distance: subshipments[selectedIndex].distance!,
                        period: subshipments[selectedIndex].period!,
                      ),
                    ],
                  ),
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

  Widget pathList(List<SubShipment> subshipments, String language) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        _onVerticalGesture(details, subshipments, language);
      },
      child: Container(
        color: Colors.grey[200],
        height: 140.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    _onVerticalGesture(null, subshipments, language);
                  },
                  icon: SizedBox(
                    width: 32.w,
                    child: SvgPicture.asset(
                      "assets/icons/arrow_up.svg",
                      fit: BoxFit.contain,
                      height: 8.h,
                    ),
                  ),
                )
              ],
            ),
            // const Spacer(),
            SizedBox(
              height: 88.h,
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
                        subshipment = subshipments[index];
                        truckLocation =
                            subshipments[index].truck!.location_lat!;
                        startTracking = false;
                      });
                      initMapbounds(subshipments[index]);
                      markers = {};
                      var pickupMarker = Marker(
                        markerId: const MarkerId("pickup"),
                        position: LatLng(
                            double.parse(subshipments[selectedIndex]
                                .pathpoints!
                                .singleWhere(
                                    (element) => element.pointType == "P")
                                .location!
                                .split(",")[0]),
                            double.parse(subshipments[selectedIndex]
                                .pathpoints!
                                .singleWhere(
                                    (element) => element.pointType == "P")
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
                                .singleWhere(
                                    (element) => element.pointType == "D")
                                .location!
                                .split(",")[0]),
                            double.parse(subshipments[selectedIndex]
                                .pathpoints!
                                .singleWhere(
                                    (element) => element.pointType == "D")
                                .location!
                                .split(",")[1])),
                        icon: deliveryicon,
                      );
                      markers.add(deliveryMarker);
                      var truckMarker = Marker(
                        markerId: const MarkerId("truck"),
                        position: LatLng(
                            double.parse(truckLocation!.split(",")[0]),
                            double.parse(truckLocation!.split(",")[1])),
                        icon: truckicon,
                      );
                      markers.add(truckMarker);
                      print(index);

                      setState(() {});
                    },
                    child: Padding(
                      padding: EdgeInsets.all(selectedTruck == index ? 0 : 3.0),
                      child: Container(
                        // height: selectedTruck == index ? 88.h : 80.h,
                        width: selectedTruck == index ? 180.w : 175.w,
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: selectedTruck == index
                                ? AppColor.deepYellow
                                : Colors.grey[400]!,
                            width: selectedTruck == index ? 2 : 1,
                          ),
                          boxShadow: selectedTruck == index
                              ? [
                                  BoxShadow(
                                      offset: const Offset(1, 2),
                                      color: Colors.grey[400]!)
                                ]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 25.h,
                                  width: selectedTruck == index ? 122.w : 118.w,
                                  child: CachedNetworkImage(
                                    imageUrl: subshipments[index]
                                        .truck!
                                        .truck_type_image!,
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
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      height: 25.h,
                                      width: selectedTruck == index
                                          ? 122.w
                                          : 118.w,
                                      color: Colors.grey[300],
                                      child: Center(
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .translate('image_load_error')),
                                      ),
                                    ),
                                  ),
                                ),
                                Text('No: ${subshipments[index].id!}')
                              ],
                            ),
                            SizedBox(
                              height: selectedTruck == index ? 7.h : 2.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${subshipments[index].driver_first_name!} ${subshipments[index].driver_last_name!}",
                                  style: TextStyle(
                                    fontSize:
                                        selectedTruck == index ? 17.sp : 15.sp,
                                    color: AppColor.deepBlack,
                                  ),
                                ),
                                Text(
                                  "${subshipments[index].shipmentItems![0].commodityName!} ",
                                  style: TextStyle(
                                    fontSize:
                                        selectedTruck == index ? 17.sp : 15.sp,
                                    color: AppColor.deepBlack,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  late BitmapDescriptor pickupicon;
  late BitmapDescriptor deliveryicon;
  late BitmapDescriptor parkicon;
  late BitmapDescriptor truckicon;
  // late LatLng truckLocation;
  late bool truckLocationassign;
  Set<Marker> markers = Set();
  final TruckRepository _truckRepository = TruckRepository();
  dynamic truckData;

  createMarkerIcons() async {
    pickupicon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/icons/location1.png",
    );
    deliveryicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location2.png");
    truckicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/truck.png");
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
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (startTracking) {
        _fetchTruckLocation(subshipment!.truck!);
        mymap();
      }
    });
    animcontroller = BottomSheet.createAnimationController(this);
    animcontroller.duration = const Duration(milliseconds: 1000);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      createMarkerIcons();
    });
    rootBundle.loadString('assets/style/map_style.json').then((string) {
      _mapStyle = string;
    });
  }

  @override
  void dispose() {
    animcontroller.dispose();
    _controller.dispose();
    timer.cancel();
    super.dispose();
  }

  Future<void> mymap() async {
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              double.parse(truckLocation!.split(",")[0]),
              double.parse(truckLocation!.split(",")[1]),
            ),
            zoom: 14.47)));
  }

  Future<void> _fetchTruckLocation(ShipmentTruck truck) async {
    try {
      String? location;
      dynamic data;
      if (truck.gpsId!.isEmpty || truck.gpsId!.length < 8) {
        location = await _truckRepository.getTruckLocation(truck.id!);
      } else {
        data = await GpsRepository.getCarInfo(truck.gpsId!);
        location = '${data["carStatus"]["lat"]},${data["carStatus"]["lon"]}';
      }
      print(location);
      setState(() {
        truckData = data;
        truckLocation = location;
      });
    } catch (e) {
      print('Failed to fetch truck location: $e');
    }
  }

  Future<void> onRefresh() async {
    // BlocProvider.of<ActiveShipmentListBloc>(context)
    //     .add(ActiveShipmentListLoadEvent());
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
            backgroundColor: Colors.grey[100],
            body: Consumer<ActiveShippmentProvider>(
                builder: (context, activeShipmentProvider, child) {
              activeShipmentProvider.init();
              return BlocConsumer<ActiveShipmentListBloc,
                  ActiveShipmentListState>(
                listener: (context, state) {
                  if (state is ActiveShipmentListLoadedSuccess) {
                    setState(() {
                      selectedIndex = 0;
                      selectedTruck = 0;
                      subshipment = state.shipments[0];
                      truckLocation = state.shipments[0].truck!.location_lat!;
                      startTracking = false;
                    });
                    initMapbounds(state.shipments[0]);
                    markers = {};
                    var pickupMarker = Marker(
                      markerId: const MarkerId("pickup"),
                      position: LatLng(
                          double.parse(state.shipments[0].pathpoints!
                              .singleWhere(
                                  (element) => element.pointType == "P")
                              .location!
                              .split(",")[0]),
                          double.parse(state.shipments[0].pathpoints!
                              .singleWhere(
                                  (element) => element.pointType == "P")
                              .location!
                              .split(",")[1])),
                      icon: pickupicon,
                    );
                    markers.add(pickupMarker);
                    var deliveryMarker = Marker(
                      markerId: const MarkerId("delivery"),
                      position: LatLng(
                          double.parse(state.shipments[0].pathpoints!
                              .singleWhere(
                                  (element) => element.pointType == "D")
                              .location!
                              .split(",")[0]),
                          double.parse(state.shipments[0].pathpoints!
                              .singleWhere(
                                  (element) => element.pointType == "D")
                              .location!
                              .split(",")[1])),
                      icon: deliveryicon,
                    );
                    markers.add(deliveryMarker);
                    var truckMarker = Marker(
                      markerId: const MarkerId("truck"),
                      position: LatLng(
                          double.parse(truckLocation!.split(",")[0]),
                          double.parse(truckLocation!.split(",")[1])),
                      icon: truckicon,
                    );
                    markers.add(truckMarker);

                    setState(() {});
                  }
                },
                builder: (context, state) {
                  if (state is ActiveShipmentListLoadedSuccess) {
                    if (subshipment != null) {
                      subshipment = state.shipments[0];
                      truckLocation = subshipment!.truck!.location_lat!;
                    }
                    return Visibility(
                      visible: state.shipments.isNotEmpty,
                      replacement: NoResultsWidget(
                        text: AppLocalizations.of(context)!
                            .translate('no_active'),
                      ),
                      child: Stack(
                        children: [
                          GoogleMap(
                            onMapCreated:
                                (GoogleMapController controller) async {
                              setState(() {
                                _controller = controller;
                                _controller.setMapStyle(_mapStyle);
                                selectedIndex = 0;
                                selectedTruck = 0;
                              });
                              initMapbounds(subshipment!);

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
                                    double.parse(truckLocation!.split(",")[0]),
                                    double.parse(truckLocation!.split(",")[1])),
                                icon: truckicon,
                              );
                              markers.add(truckMarker);
                              setState(() {});
                            },
                            zoomControlsEnabled: true,
                            mapToolbarEnabled: true,
                            myLocationButtonEnabled: false,
                            myLocationEnabled: false,

                            initialCameraPosition: const CameraPosition(
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
                                      width: 4,
                                    ),
                                  }
                                : {},
                            // mapType: shipmentProvider.mapType,
                          ),
                          Positioned(
                            bottom: 145,
                            left: 5,
                            child: InkWell(
                              onTap: () async {
                                setState(() {
                                  startTracking = !startTracking;
                                });
                                if (startTracking) {
                                  print(truckLocation);
                                  await _controller.animateCamera(CameraUpdate
                                      .newCameraPosition(CameraPosition(
                                          target: LatLng(
                                            double.parse(
                                                truckLocation!.split(",")[0]),
                                            double.parse(
                                                truckLocation!.split(",")[1]),
                                          ),
                                          zoom: 14.47)));
                                }
                              },
                              child: AbsorbPointer(
                                absorbing: false,
                                child: SizedBox(
                                  height: 45,
                                  width: 45,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(45),
                                      border: Border.all(
                                        color: startTracking
                                            ? Colors.orange
                                            : Colors.white,
                                        width: startTracking ? 2 : 0,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(180),
                                      child: Image.asset(
                                          "assets/icons/radar.gif",
                                          gaplessPlayback: true,
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            left: 5,
                            child: InkWell(
                              onTap: () {
                                initMapbounds(subshipment!);
                                markers = {};
                                var pickupMarker = Marker(
                                  markerId: const MarkerId("pickup"),
                                  position: LatLng(
                                      double.parse(subshipment!.pathpoints!
                                          .singleWhere((element) =>
                                              element.pointType == "P")
                                          .location!
                                          .split(",")[0]),
                                      double.parse(subshipment!.pathpoints!
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
                                      double.parse(subshipment!.pathpoints!
                                          .singleWhere((element) =>
                                              element.pointType == "D")
                                          .location!
                                          .split(",")[0]),
                                      double.parse(subshipment!.pathpoints!
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
                                    double.parse(truckLocation!.split(",")[0]),
                                    double.parse(truckLocation!.split(",")[1]),
                                  ),
                                  infoWindow: InfoWindow(),
                                  icon: truckicon,
                                );
                                markers.add(truckMarker);

                                setState(() {});
                              },
                              child: const AbsorbPointer(
                                absorbing: false,
                                child: SizedBox(
                                  height: 40,
                                  width: 40,
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
                          Positioned(
                            bottom: 0,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: pathList(
                                state.shipments,
                                localeState.value.languageCode,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(
                      child: LoadingIndicator(),
                    );
                  }
                },
              );
            }),
          ),
        );
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
