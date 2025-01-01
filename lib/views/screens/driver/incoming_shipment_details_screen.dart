import 'dart:convert';
import 'dart:math';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/requests/accept_request_for_driver_bloc.dart';
import 'package:camion/business_logic/bloc/requests/accept_request_for_merchant_bloc.dart';
import 'package:camion/business_logic/bloc/requests/reject_request_for_driver_bloc.dart';
import 'package:camion/business_logic/bloc/requests/reject_request_for_merchant_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/enums.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/widgets/commodity_info_widget.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/driver_appbar.dart';
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
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' as intel;

class IncomingShipmentDetailsScreen extends StatefulWidget {
  final String requestOwner;
  IncomingShipmentDetailsScreen({
    Key? key,
    required this.requestOwner,
  }) : super(key: key);

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

  TextEditingController rejectTextController = TextEditingController();
  TextEditingController extraTextController = TextEditingController();
  TextEditingController extraValueController = TextEditingController();

  final GlobalKey<FormState> _acceptformKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _rejectformKey = GlobalKey<FormState>();

  String rejectText = "";
  String extraText = "_";
  double extraValue = 0;

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
              appBar: DriverAppBar(
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
                                  height: 32,
                                ),
                                SectionTitle(
                                  text: AppLocalizations.of(context)!
                                      .translate("commodity_info"),
                                ),
                                const SizedBox(height: 4),
                                Commodity_info_widget(
                                    shipmentItems:
                                        shipmentstate.shipment.shipmentItems!),
                                const Divider(
                                  height: 32,
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
                                  height: 32,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      widget.requestOwner == "T"
                                          ? BlocConsumer<
                                              AcceptRequestForMerchantBloc,
                                              AcceptRequestForMerchantState>(
                                              listener: (context, acceptstate) {
                                                if (acceptstate
                                                    is AcceptRequestForMerchantSuccessState) {
                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const ControlView(),
                                                      ),
                                                      (route) => false);
                                                }
                                              },
                                              builder: (context, acceptstate) {
                                                if (acceptstate
                                                    is AcceptRequestForMerchantLoadingProgressState) {
                                                  return CustomButton(
                                                    title: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .4,
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
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .4,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Center(
                                                            child: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .translate(
                                                                      'accept'),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 30.w,
                                                            width: 30.w,
                                                            child: SvgPicture
                                                                .asset(
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
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                Colors.white,
                                                            title: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .translate(
                                                                      'accept'),
                                                            ),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child: Text(AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'cancel')),
                                                                onPressed: () {
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
                                                                onPressed: () {
                                                                  BlocProvider.of<
                                                                              AcceptRequestForMerchantBloc>(
                                                                          context)
                                                                      .add(
                                                                    AcceptRequestForMerchantButtonPressedEvent(
                                                                      shipmentstate
                                                                          .shipment
                                                                          .approvalrequest!,
                                                                    ),
                                                                  );
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    // color: Colors.white,
                                                  );
                                                }
                                              },
                                            )
                                          : BlocConsumer<
                                              AcceptRequestForDriverBloc,
                                              AcceptRequestForDriverState>(
                                              listener: (context, acceptstate) {
                                                if (acceptstate
                                                    is AcceptRequestForDriverSuccessState) {
                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const ControlView(),
                                                      ),
                                                      (route) => false);
                                                }
                                              },
                                              builder: (context, acceptstate) {
                                                if (acceptstate
                                                    is AcceptRequestLoadingProgressState) {
                                                  return CustomButton(
                                                    title: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .4,
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
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .4,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Center(
                                                            child: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .translate(
                                                                      'accept'),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 30.w,
                                                            width: 30.w,
                                                            child: SvgPicture
                                                                .asset(
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
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                Colors.white,
                                                            title: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .translate(
                                                                      'accept'),
                                                            ),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child: Text(AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'cancel')),
                                                                onPressed: () {
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
                                                                onPressed: () {
                                                                  print("asd");
                                                                  BlocProvider.of<
                                                                              AcceptRequestForDriverBloc>(
                                                                          context)
                                                                      .add(
                                                                    AcceptRequestButtonPressedEvent(
                                                                      shipmentstate
                                                                          .shipment
                                                                          .approvalrequest!,
                                                                    ),
                                                                  );
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    // color: Colors.white,
                                                  );
                                                }
                                              },
                                            ),
                                      widget.requestOwner == "T"
                                          ? BlocConsumer<
                                              RejectRequestForMerchantBloc,
                                              RejectRequestForMerchantState>(
                                              listener: (context, rejectstate) {
                                                if (rejectstate
                                                    is RejectRequestForMerchantSuccessState) {
                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const ControlView(),
                                                      ),
                                                      (route) => false);
                                                }
                                              },
                                              builder: (context, rejectstate) {
                                                if (rejectstate
                                                    is RejectRequestForMerchantLoadingProgressState) {
                                                  return CustomButton(
                                                    title: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .4,
                                                      child: Center(
                                                        child:
                                                            LoadingIndicator(),
                                                      ),
                                                    ),
                                                    onTap: () {},
                                                    color: Colors.white,
                                                  );
                                                } else {
                                                  return CustomButton(
                                                    title: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .4,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Center(
                                                            child: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .translate(
                                                                      'cancel'),
                                                              style: TextStyle(
                                                                color: AppColor
                                                                    .deepYellow,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 30.w,
                                                            width: 30.w,
                                                            child: SvgPicture
                                                                .asset(
                                                              "assets/icons/orange/notification_shipment_cancelation.svg",
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
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                Colors.white,
                                                            title: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'reject')),
                                                            content:
                                                                SingleChildScrollView(
                                                              child: Form(
                                                                key:
                                                                    _rejectformKey,
                                                                child: ListBody(
                                                                  children: <Widget>[
                                                                    SectionBody(
                                                                        text:
                                                                            "الرجاء تحديد سبب الرفض"),
                                                                    TextFormField(
                                                                      controller:
                                                                          rejectTextController,
                                                                      onTap:
                                                                          () {
                                                                        rejectTextController.selection = TextSelection(
                                                                            baseOffset:
                                                                                0,
                                                                            extentOffset:
                                                                                rejectTextController.value.text.length);
                                                                      },
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18.sp),
                                                                      scrollPadding:
                                                                          EdgeInsets.only(
                                                                              bottom: MediaQuery.of(context).viewInsets.bottom + 50),
                                                                      decoration:
                                                                          InputDecoration(
                                                                        hintText:
                                                                            'سبب الرفض',
                                                                        hintStyle:
                                                                            TextStyle(fontSize: 18.sp),
                                                                      ),
                                                                      validator:
                                                                          (value) {
                                                                        if (value!
                                                                            .isEmpty) {
                                                                          return AppLocalizations.of(context)!
                                                                              .translate('insert_value_validate');
                                                                        }
                                                                        return null;
                                                                      },
                                                                      onSaved:
                                                                          (newValue) {
                                                                        rejectTextController.text =
                                                                            newValue!;
                                                                        rejectText =
                                                                            newValue!;
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child: Text(AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'cancel')),
                                                                onPressed: () {
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
                                                                onPressed: () {
                                                                  if (_rejectformKey
                                                                      .currentState!
                                                                      .validate()) {
                                                                    _rejectformKey
                                                                        .currentState!
                                                                        .save();
                                                                    BlocProvider.of<RejectRequestForMerchantBloc>(
                                                                            context)
                                                                        .add(
                                                                      RejectRequestForMerchantButtonPressedEvent(
                                                                        shipmentstate
                                                                            .shipment
                                                                            .approvalrequest!,
                                                                        rejectText,
                                                                      ),
                                                                    );
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  }
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
                                            )
                                          : BlocConsumer<
                                              RejectRequestForDriverBloc,
                                              RejectRequestForDriverState>(
                                              listener: (context, rejectstate) {
                                                if (rejectstate
                                                    is RejectRequestForDriverSuccessState) {
                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const ControlView(),
                                                      ),
                                                      (route) => false);
                                                }
                                              },
                                              builder: (context, rejectstate) {
                                                if (rejectstate
                                                    is RejectRequestLoadingProgressState) {
                                                  return CustomButton(
                                                    title: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .4,
                                                      child: Center(
                                                        child:
                                                            LoadingIndicator(),
                                                      ),
                                                    ),
                                                    onTap: () {},
                                                    color: Colors.white,
                                                  );
                                                } else {
                                                  return CustomButton(
                                                    title: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .4,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Center(
                                                            child: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .translate(
                                                                      'cancel'),
                                                              style: TextStyle(
                                                                color: AppColor
                                                                    .deepYellow,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 30.w,
                                                            width: 30.w,
                                                            child: SvgPicture
                                                                .asset(
                                                              "assets/icons/orange/notification_shipment_cancelation.svg",
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
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                Colors.white,
                                                            title: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'reject')),
                                                            content:
                                                                const SizedBox
                                                                    .shrink(),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child: Text(AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'cancel')),
                                                                onPressed: () {
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
                                                                onPressed: () {
                                                                  if (_rejectformKey
                                                                      .currentState!
                                                                      .validate()) {
                                                                    _rejectformKey
                                                                        .currentState!
                                                                        .save();
                                                                    BlocProvider.of<RejectRequestForDriverBloc>(
                                                                            context)
                                                                        .add(
                                                                      RejectRequestButtonPressedEvent(
                                                                        shipmentstate
                                                                            .shipment
                                                                            .approvalrequest!,
                                                                      ),
                                                                    );
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  }
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
                                    ],
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
          );
        },
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
}
