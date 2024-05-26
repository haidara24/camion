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
import 'package:camion/helpers/http_helper.dart';
import 'package:camion/views/widgets/commodity_info_widget.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
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

class _ActiveShipmentScreenState extends State<ActiveShipmentScreen> {
  late GoogleMapController _controller;

  String _mapStyle = "";
  PanelState panelState = PanelState.hidden;
  final panelTransation = const Duration(milliseconds: 500);
  var f = intel.NumberFormat("#,###", "en_US");

  int selectedIndex = 0;
  int selectedTruck = 0;

  double distance = 0;
  String period = "";

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  initMapbounds(SubShipment subshipment) async {
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

  void _onVerticalGesture(DragUpdateDetails details,
      List<SubShipment> subshipments, String language) {
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
                                  child: (subshipments[selectedIndex]
                                              .truck!
                                              .truckuser!
                                              .user!
                                              .image!
                                              .length >
                                          1)
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(180),
                                          child: Image.network(
                                            subshipments[selectedIndex]
                                                .truck!
                                                .truckuser!
                                                .user!
                                                .image!,
                                            height: 55.w,
                                            width: 55.w,
                                            fit: BoxFit.fill,
                                          ),
                                        )
                                      : Text(
                                          subshipments[selectedIndex]
                                              .truck!
                                              .truckuser!
                                              .user!
                                              .firstName!,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28.sp,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Text(
                              "${subshipments[selectedIndex].truck!.truckuser!.user!.firstName!} ${subshipments[selectedIndex].truck!.truckuser!.user!.lastName!}",
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
                                    .truck_type!
                                    .image!,
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
                              "${language == 'en' ? subshipments[selectedIndex].truck!.truck_type!.name! : subshipments[selectedIndex].truck!.truck_type!.nameAr!}  ",
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
                    Text(
                      "مسار الشحنة",
                      style: TextStyle(
                        // color: AppColor.lightBlue,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ShipmentPathVerticalWidget(
                      pathpoints: subshipments[selectedIndex].pathpoints!,
                      pickupDate: subshipments[selectedIndex].pickupDate!,
                      deliveryDate: subshipments[selectedIndex].deliveryDate!,
                      langCode: language,
                      mini: false,
                    ),
                    const Divider(),
                    Text(
                      "تفاصيل بضاعة الشاحنة",
                      style: TextStyle(
                        // color: AppColor.lightBlue,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Commodity_info_widget(
                        shipmentItems:
                            subshipments[selectedIndex].shipmentItems!),
                    const Divider(),
                    Text(
                      "احصائيات مسار الشاحنة",
                      style: TextStyle(
                        // color: AppColor.lightBlue,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PathStatisticsWidget(
                      distance: subshipments[selectedIndex].distance!,
                      period: subshipments[selectedIndex].period!,
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

  Widget pathList(List<SubShipment> subshipments, String language) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        _onVerticalGesture(details, subshipments, language);
      },
      child: Container(
        color: Colors.grey[200],
        height: 110.h,
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
            const Spacer(),
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
                    child: Padding(
                      padding: EdgeInsets.all(selectedTruck == index ? 0 : 3.0),
                      child: Container(
                        // height: selectedTruck == index ? 88.h : 80.h,
                        width: selectedTruck == index ? 150.w : 145.w,
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
                                      offset: Offset(1, 2),
                                      color: Colors.grey[400]!)
                                ]
                              : null,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 25.h,
                              width: selectedTruck == index ? 145.w : 135.w,
                              child: CachedNetworkImage(
                                imageUrl: subshipments[index]
                                    .truck!
                                    .truck_type!
                                    .image!,
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
                                  height: 25.h,
                                  width: selectedTruck == index ? 145.w : 135.w,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Text(AppLocalizations.of(context)!
                                        .translate('image_load_error')),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: selectedTruck == index ? 7.h : 2.h,
                            ),
                            Text(
                              "${subshipments[index].truck!.truckuser!.user!.firstName!} ${subshipments[index].truck!.truckuser!.user!.lastName!}",
                              style: TextStyle(
                                fontSize:
                                    selectedTruck == index ? 17.sp : 15.sp,
                                color: AppColor.deepBlack,
                              ),
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
  _buildCo2Report(SubShipment shipment) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          // height: 50.h,
          width: MediaQuery.of(context).size.width * .29,
          child: BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * .29,
                child: Text(
                  "${AppLocalizations.of(context)!.translate('total_co2')}:\n ${f.format(100)} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}",
                  style: const TextStyle(
                    // color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          // height: 50.h,
          width: MediaQuery.of(context).size.width * .29,
          child: BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * .29,
                child: Text(
                  "المسافة المتبقية: ${shipment.distance} ${localeState.value.languageCode == 'en' ? "km" : "كم"}",
                  style: const TextStyle(
                    // color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          // height: 50.h,
          width: MediaQuery.of(context).size.width * .29,
          child: BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * .7,
                child: Text(
                  "الوقت المتبقي: \n ${period.replaceAll("hours", "ساعة").replaceAll("hour", "ساعة").replaceAll("mins", "دقيقة").replaceAll("min", "دقيقة")} ",
                  style: const TextStyle(
                    // color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

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
                                    double.parse(state.shipments[selectedIndex]
                                        .truck!.location_lat!
                                        .split(",")[0]),
                                    double.parse(state.shipments[selectedIndex]
                                        .truck!.location_lat!
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
                                      points: deserializeLatLng(state
                                          .shipments[selectedIndex].paths!),
                                      color: AppColor.deepYellow,
                                      width: 4,
                                    ),
                                  }
                                : {},
                            // mapType: shipmentProvider.mapType,
                          ),
                        ),
                        pathList(
                          state.shipments,
                          localeState.value.languageCode,
                        ),
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
