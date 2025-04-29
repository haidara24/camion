import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/constants/enums.dart';
import 'package:camion/data/services/map_service.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' as intel;
import 'package:shimmer/shimmer.dart';

class ShipmentDetailsMapScreen extends StatefulWidget {
  final SubShipment shipment;

  const ShipmentDetailsMapScreen({Key? key, required this.shipment})
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
    var pickuplocation = widget.shipment.pathpoints!
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

    var deliverylocation = widget.shipment.pathpoints!
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
  }

  late BitmapDescriptor truckicon;
  late LatLng truckLocation;
  late bool truckLocationassign;
  Set<Marker> markers = {};

  createMarkerIcons() async {
    truckicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/truck.png");

    markers = {};
    for (var i = 0; i < widget.shipment.pathpoints!.length; i++) {
      if (i == 0) {
        Uint8List markerIcon = await MapService.createCustomMarker(
          "A",
        );

        var marker = Marker(
          markerId: MarkerId("stop$i"),
          position: LatLng(
            double.parse(
                widget.shipment.pathpoints![i].location!.split(",")[0]),
            double.parse(
                widget.shipment.pathpoints![i].location!.split(",")[1]),
          ),
          icon: BitmapDescriptor.bytes(markerIcon),
        );
        markers.add(marker);
      } else {
        Uint8List markerIcon = await MapService.createCustomMarker(
          i == widget.shipment.pathpoints!.length - 1 ? "B" : "$i",
        );
        var marker = Marker(
          markerId: MarkerId("stop$i"),
          position: LatLng(
            double.parse(
                widget.shipment.pathpoints![i].location!.split(",")[0]),
            double.parse(
                widget.shipment.pathpoints![i].location!.split(",")[1]),
          ),
          icon: BitmapDescriptor.bytes(markerIcon),
        );
        markers.add(marker);
      }
    }
    var marker = Marker(
      markerId: const MarkerId("truck"),
      position: LatLng(
        double.parse(widget.shipment.truck!.location_lat!.split(",")[0]),
        double.parse(widget.shipment.truck!.location_lat!.split(",")[1]),
      ),
      icon: truckicon,
    );
    markers.add(marker);
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
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title:
              "${AppLocalizations.of(context)!.translate('shipment_number')}: ${widget.shipment.id!}",
        ),
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 88.h,
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
                        double.parse(widget.shipment.pathpoints!
                            .singleWhere((element) => element.pointType == "P")
                            .location!
                            .split(",")[0]),
                        double.parse(widget.shipment.pathpoints!
                            .singleWhere((element) => element.pointType == "P")
                            .location!
                            .split(",")[1])),
                    zoom: 14.47),
                // gestureRecognizers: {},
                markers: markers,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId("route"),
                    points: deserializeLatLng(widget.shipment.paths!),
                    color: AppColor.deepYellow,
                    width: 7,
                  ),
                },
                myLocationButtonEnabled: false,
                // mapType: shipmentProvider.mapType,
              ),
            ),
          ],
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
