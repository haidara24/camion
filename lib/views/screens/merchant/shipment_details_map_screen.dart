import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/enums.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' as intel;
import 'package:shimmer/shimmer.dart';

class ShipmentDetailsMapScreen extends StatefulWidget {
  final Shipmentv2 shipment;

  ShipmentDetailsMapScreen({Key? key, required this.shipment})
      : super(key: key);

  @override
  State<ShipmentDetailsMapScreen> createState() =>
      _ShipmentDetailsMapScreenState();
}

class _ShipmentDetailsMapScreenState extends State<ShipmentDetailsMapScreen> {
  late GoogleMapController _controller;

  String _mapStyle = "";
  PanelState panelState = PanelState.hidden;
  final panelTransation = const Duration(milliseconds: 500);
  var f = intel.NumberFormat("#,###", "en_US");

  int selectedIndex = 0;
  int selectedTruck = 0;

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  initMapbounds() {
    List<Marker> markers = [];
    var pickuplocation = widget
        .shipment.subshipments![selectedIndex].pathpoints!
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

    var deliverylocation = widget
        .shipment.subshipments![selectedIndex].pathpoints!
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
              // initMapbounds(shipment);
              // setLoadDate(shipment.subshipments![selectedIndex].pickupDate!);
              // setLoadTime(shipment.subshipments![selectedIndex].pickupDate!);
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
                Positioned(
                  top: -5,
                  left: -6,
                  child: shipment.subshipments![selectedIndex].shipmentStatus ==
                          "R"
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
  late BitmapDescriptor parkicon;
  late BitmapDescriptor truckicon;
  late LatLng truckLocation;
  late bool truckLocationassign;
  Set<Marker> markers = Set();

  createMarkerIcons() async {
    pickupicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location1.png");
    deliveryicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location2.png");
    parkicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/locationP.png");
    truckicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/truck.png");

    markers = {};
    var pickupMarker = Marker(
      markerId: const MarkerId("pickup"),
      position: LatLng(
          double.parse(widget.shipment.subshipments![selectedIndex].pathpoints!
              .singleWhere((element) => element.pointType == "P")
              .location!
              .split(",")[0]),
          double.parse(widget.shipment.subshipments![selectedIndex].pathpoints!
              .singleWhere((element) => element.pointType == "P")
              .location!
              .split(",")[1])),
      icon: pickupicon,
    );
    markers.add(pickupMarker);
    var deliveryMarker = Marker(
      markerId: const MarkerId("delivery"),
      position: LatLng(
          double.parse(widget.shipment.subshipments![selectedIndex].pathpoints!
              .singleWhere((element) => element.pointType == "D")
              .location!
              .split(",")[0]),
          double.parse(widget.shipment.subshipments![selectedIndex].pathpoints!
              .singleWhere((element) => element.pointType == "D")
              .location!
              .split(",")[1])),
      icon: deliveryicon,
    );
    markers.add(deliveryMarker);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    createMarkerIcons();
    rootBundle.loadString('assets/style/map_style.json').then((string) {
      _mapStyle = string;
    });
  }

  @override
  void dispose() {
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
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height - 200.h,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) async {
                setState(() {
                  _controller = controller;
                  _controller.setMapStyle(_mapStyle);
                });
                initMapbounds();
              },
              zoomControlsEnabled: false,

              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      double.parse(widget
                          .shipment.subshipments![selectedIndex].pathpoints!
                          .singleWhere((element) => element.pointType == "P")
                          .location!
                          .split(",")[0]),
                      double.parse(widget
                          .shipment.subshipments![selectedIndex].pathpoints!
                          .singleWhere((element) => element.pointType == "P")
                          .location!
                          .split(",")[1])),
                  zoom: 14.47),
              // gestureRecognizers: {},
              markers: markers,
              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: deserializeLatLng(
                      widget.shipment.subshipments![selectedIndex].paths!),
                  color: AppColor.deepYellow,
                  width: 7,
                ),
              },
              // mapType: shipmentProvider.mapType,
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                color: Colors.white,
                height: 200.h,
                width: double.infinity,
                child: Padding(
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
                      const SizedBox(
                        height: 5,
                      ),
                      pathList(widget.shipment),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -60,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    print("asd");
                  },
                  child: AbsorbPointer(
                    absorbing: false,
                    child: Container(
                      margin: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(45),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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

  final ScrollController _scrollController = ScrollController();

  _buildCommodityWidget(List<ShipmentItems>? shipmentItems) {
    return Table(
      border: TableBorder.all(color: AppColor.deepYellow, width: 2),
      children: [
        TableRow(children: [
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  AppLocalizations.of(context)!.translate('commodity_name')),
            ),
          ),
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  AppLocalizations.of(context)!.translate('commodity_weight')),
            ),
          ),
        ]),
        ...List.generate(
          shipmentItems!.length,
          (index) => TableRow(children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(shipmentItems[index].commodityName!),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(shipmentItems[index].commodityWeight!.toString()),
              ),
            ),
          ]),
        ),
      ],
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
                    "${AppLocalizations.of(context)!.translate('total_co2')}: ${f.format(100)} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}",
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
