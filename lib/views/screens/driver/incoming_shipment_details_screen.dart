import 'dart:convert';
import 'dart:math';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/enums.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' as intel;

class IncomingShipmentDetailsScreen extends StatefulWidget {
  IncomingShipmentDetailsScreen({Key? key}) : super(key: key);

  @override
  State<IncomingShipmentDetailsScreen> createState() =>
      _IncomingShipmentDetailsScreenState();
}

class _IncomingShipmentDetailsScreenState
    extends State<IncomingShipmentDetailsScreen> {
  late GoogleMapController _controller;

  String _mapStyle = "";
  PanelState panelState = PanelState.hidden;
  // final panelTransation = const Duration(milliseconds: 500);
  // Co2Report _report = Co2Report();
  var f = intel.NumberFormat("#,###", "en_US");

  int selectedIndex = 0;
  int selectedTruck = 0;

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

  late BitmapDescriptor pickupicon;
  late BitmapDescriptor deliveryicon;
  late BitmapDescriptor parkicon;
  late BitmapDescriptor truckicon;
  late LatLng truckLocation;
  late bool truckLocationassign;
  Set<Marker> markers = Set();

  createMarkerIcons(SubShipment shipment) async {
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
          double.parse(shipment.pathpoints!
              .singleWhere((element) => element.pointType == "P")
              .location!
              .split(",")[0]),
          double.parse(shipment.pathpoints!
              .singleWhere((element) => element.pointType == "P")
              .location!
              .split(",")[1])),
      icon: pickupicon,
    );
    markers.add(pickupMarker);
    var deliveryMarker = Marker(
      markerId: const MarkerId("delivery"),
      position: LatLng(
          double.parse(shipment.pathpoints!
              .singleWhere((element) => element.pointType == "D")
              .location!
              .split(",")[0]),
          double.parse(shipment.pathpoints!
              .singleWhere((element) => element.pointType == "D")
              .location!
              .split(",")[1])),
      icon: deliveryicon,
    );
    markers.add(deliveryMarker);

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
      // createMarkerIcons();
      setState(() {});
    });
    rootBundle.loadString('assets/style/map_style.json').then((string) {
      _mapStyle = string;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return Directionality(
            textDirection: localeState.value.languageCode == 'en'
                ? TextDirection.ltr
                : TextDirection.rtl,
            child: Scaffold(
              appBar: CustomAppBar(
                title:
                    AppLocalizations.of(context)!.translate('shipment_details'),
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
                    return Column(
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
                                    zoom: 14.47),
                                gestureRecognizers: {},
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
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "مسار الشحنة",
                                      style: TextStyle(
                                        // color: AppColor.lightBlue,
                                        fontSize: 19.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ShipmentPathVerticalWidget(
                                      pathpoints:
                                          shipmentstate.shipment.pathpoints!,
                                      pickupDate:
                                          shipmentstate.shipment.pickupDate!,
                                      deliveryDate:
                                          shipmentstate.shipment.deliveryDate!,
                                      langCode: localeState.value.languageCode,
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
                                    _buildCommodityWidget(
                                        shipmentstate.shipment),
                                    const Divider(),
                                    Text(
                                      "احصائيات مسار الشاحنة",
                                      style: TextStyle(
                                        // color: AppColor.lightBlue,
                                        fontSize: 19.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    _buildCo2Report(shipmentstate.shipment),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: LoadingIndicator());
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  _buildCo2Report(SubShipment shipment) {
    return Column(
      children: [
        SizedBox(
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
        ),
        SizedBox(
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
                  child: SvgPicture.asset("assets/icons/distance.svg"),
                ),
                const SizedBox(
                  width: 5,
                ),
                BlocBuilder<LocaleCubit, LocaleState>(
                  builder: (context, localeState) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      child: Text(
                        "${AppLocalizations.of(context)!.translate('distance')}: ${shipment.distance} ${localeState.value.languageCode == 'en' ? "km" : "كم"}",
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
        ),
        SizedBox(
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
                  child: SvgPicture.asset("assets/icons/time.svg"),
                ),
                const SizedBox(
                  width: 5,
                ),
                BlocBuilder<LocaleCubit, LocaleState>(
                  builder: (context, localeState) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      child: Text(
                        "${AppLocalizations.of(context)!.translate('period')}: ${localeState.value.languageCode == "en" ? shipment.period : shipment.period!.replaceAll("hour", "ساعة").replaceAll("mins", "دقيقة").replaceAll("hours", "ساعات")} ",
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
        ),
      ],
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
    setState(() {});
  }

  int getunfinishedTasks(SubShipment shipment) {
    var count = 0;
    if (shipment.shipmentinstructionv2 == null) {
      count++;
    }
    if (shipment.shipmentpaymentv2 == null) {
      count++;
    }
    return count;
  }

  final ScrollController _scrollController = ScrollController();

  _buildCommodityWidget(SubShipment shipment) {
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
}
