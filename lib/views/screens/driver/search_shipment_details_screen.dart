import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/driver_shipments/assign_shipment_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/order_truck_bloc.dart';
import 'package:camion/business_logic/bloc/truck/owner_trucks_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/enums.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/services/map_service.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/widgets/commodity_info_widget.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/driver_appbar.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart'
    show SystemChrome, SystemUiOverlayStyle, rootBundle;
import 'package:intl/intl.dart' as intel;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class SearchShipmentDetailsScreen extends StatefulWidget {
  final SubShipment shipment;
  String userType;
  bool? isOwner;
  SearchShipmentDetailsScreen({
    Key? key,
    required this.shipment,
    required this.userType,
    this.isOwner = false,
  }) : super(key: key);

  @override
  State<SearchShipmentDetailsScreen> createState() =>
      _SearchShipmentDetailsScreenState();
}

class _SearchShipmentDetailsScreenState
    extends State<SearchShipmentDetailsScreen> {
  late GoogleMapController _controller;

  String _mapStyle = "";
  PanelState panelState = PanelState.hidden;
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
  Set<Marker> markers = {};

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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark, // Reset to default
        statusBarColor: AppColor.deepBlack,
        systemNavigationBarColor: AppColor.deepBlack,
      ),
    );
    super.dispose();
  }

  showOwnerTrucksSheet(BuildContext context, String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: AbsorbPointer(
                        absorbing: false,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: lang == 'en'
                              ? const Icon(Icons.arrow_forward)
                              : const Icon(Icons.arrow_back),
                        ),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.translate('select_driver'),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5.h,
              ),
              BlocBuilder<OwnerTrucksBloc, OwnerTrucksState>(
                builder: (context, state) {
                  if (state is OwnerTrucksLoadedSuccess) {
                    return state.trucks.isEmpty
                        ? Center(
                            child: Text(AppLocalizations.of(context)!
                                .translate('no_trucks')),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  BlocProvider.of<AssignShipmentBloc>(context)
                                      .add(AssignShipmentButtonPressed(
                                          widget.shipment.id!,
                                          state.trucks[index].id!));
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 16.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 23.5.h,
                                            width: 115.w,
                                            child: CachedNetworkImage(
                                              imageUrl: state.trucks[index]
                                                  .truckType!.image!,
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      Shimmer.fromColors(
                                                baseColor: (Colors.grey[300])!,
                                                highlightColor:
                                                    (Colors.grey[100])!,
                                                enabled: true,
                                                child: Container(
                                                  height: 23.5.h,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                height: 23.5.h,
                                                width: selectedTruck == index
                                                    ? 119.w
                                                    : 118.w,
                                                color: Colors.grey[300],
                                                child: Center(
                                                  child: Text(AppLocalizations
                                                          .of(context)!
                                                      .translate(
                                                          'image_load_error')),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "${lang == "en" ? state.trucks[index].truckType!.name! : state.trucks[index].truckType!.nameAr!} ",
                                            style: TextStyle(
                                              fontSize: selectedTruck == index
                                                  ? 17.sp
                                                  : 15.sp,
                                              color: AppColor.deepBlack,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            'No: ${state.trucks[index].truckNumber!}',
                                          ),
                                          Text(
                                            "${state.trucks[index].driver_firstname!} ${state.trucks[index].driver_lastname!}",
                                            style: TextStyle(
                                              fontSize: selectedTruck == index
                                                  ? 17.sp
                                                  : 15.sp,
                                              color: AppColor.deepBlack,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemCount: state.trucks.length);
                  } else {
                    return Container();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.deepBlack, // Make status bar transparent
        statusBarIconBrightness:
            Brightness.light, // Light icons for dark backgrounds
        systemNavigationBarColor: Colors.grey[200], // Works on Android
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: BlocBuilder<LocaleCubit, LocaleState>(
          builder: (context, localeState) {
            return Directionality(
              textDirection: localeState.value.languageCode == 'en'
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: Scaffold(
                appBar: DriverAppBar(
                  title: AppLocalizations.of(context)!
                      .translate('shipment_details'),
                ),
                body: BlocConsumer<SubShipmentDetailsBloc,
                    SubShipmentDetailsState>(
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
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 5,
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
                                        deliveryDate: shipmentstate
                                            .shipment.deliveryDate!,
                                        langCode:
                                            localeState.value.languageCode,
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
                                              .shipment.shipmentItems!),
                                      // const Divider(),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            BlocConsumer<AssignShipmentBloc,
                                                AssignShipmentState>(
                                              listener: (context, state) {
                                                if (state
                                                    is AssignShipmentSuccessState) {
                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const ControlView(),
                                                      ),
                                                      (route) => false);
                                                }
                                              },
                                              builder: (context, state) {
                                                if (state
                                                    is AssignShipmentLoadingProgressState) {
                                                  return CustomButton(
                                                    title: SizedBox(
                                                      // width: 70.w,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .89,
                                                      child: Center(
                                                        child:
                                                            LoadingIndicator(),
                                                      ),
                                                    ),
                                                    onTap: () {},
                                                    // color: Colors.white,
                                                  );
                                                } else {
                                                  return CustomButton(
                                                    title: SizedBox(
                                                      // width: 70.w,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .89,
                                                      child: Center(
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .translate(
                                                                  'send_request'),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      if (widget.userType ==
                                                          "Owner") {
                                                        showOwnerTrucksSheet(
                                                          context,
                                                          localeState.value
                                                              .languageCode,
                                                        );
                                                      } else {
                                                        showDialog<void>(
                                                          context: context,
                                                          barrierDismissible:
                                                              false, // user must tap button!
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              title: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'serve'),
                                                              ),
                                                              content:
                                                                  SingleChildScrollView(
                                                                child: ListBody(
                                                                  children: <Widget>[
                                                                    SectionBody(
                                                                      text: AppLocalizations.of(
                                                                              context)!
                                                                          .translate(
                                                                              'serve_shipment_confirm'),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  child: Text(AppLocalizations.of(
                                                                          context)!
                                                                      .translate(
                                                                          'cancel')),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  child: Text(AppLocalizations.of(
                                                                          context)!
                                                                      .translate(
                                                                          'ok')),
                                                                  onPressed:
                                                                      () async {
                                                                    SharedPreferences
                                                                        prefs =
                                                                        await SharedPreferences
                                                                            .getInstance();
                                                                    var truck =
                                                                        prefs.getInt(
                                                                            "truckId");
                                                                    BlocProvider.of<AssignShipmentBloc>(
                                                                            context)
                                                                        .add(
                                                                      AssignShipmentButtonPressed(
                                                                          widget
                                                                              .shipment
                                                                              .id!,
                                                                          truck!),
                                                                    );
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                    },
                                                    // color: Colors.white,
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(child: LoadingIndicator());
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
