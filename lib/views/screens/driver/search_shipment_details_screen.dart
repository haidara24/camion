import 'dart:math';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/order_truck_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/shipment_update_status_bloc.dart';
import 'package:camion/business_logic/bloc/truck/owner_trucks_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/enums.dart';
import 'package:camion/data/models/shipment_model.dart';
import 'package:camion/data/providers/active_shipment_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/shipment_path_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intel;
import 'package:shared_preferences/shared_preferences.dart';

class SearchShipmentDetailsScreen extends StatefulWidget {
  final Shipment shipment;
  bool? isOwner;
  SearchShipmentDetailsScreen({
    Key? key,
    required this.shipment,
    this.isOwner = false,
  }) : super(key: key);

  @override
  State<SearchShipmentDetailsScreen> createState() =>
      _SearchShipmentDetailsScreenState();
}

class _SearchShipmentDetailsScreenState
    extends State<SearchShipmentDetailsScreen> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  String _mapStyle = "";
  PanelState panelState = PanelState.hidden;
  final panelTransation = const Duration(milliseconds: 500);
  var f = intel.NumberFormat("#,###", "en_US");

  List<LatLng> _polyline = [];

  getpolylineCoordinates(Shipment shipment) async {
    _polyline = [];
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w",
      PointLatLng(shipment.pickupCityLat!, shipment.pickupCityLang!),
      PointLatLng(shipment.deliveryCityLat!, shipment.deliveryCityLang!),
    );
    _polyline = [];
    if (result.points.isNotEmpty) {
      result.points.forEach((element) {
        _polyline.add(
          LatLng(
            element.latitude,
            element.longitude,
          ),
        );
      });
    }
    setState(() {});
    List<Marker> markers = [];
    markers.add(
      Marker(
        markerId: const MarkerId("pickup"),
        position: LatLng(shipment.pickupCityLat!, shipment.pickupCityLang!),
      ),
    );
    markers.add(
      Marker(
        markerId: const MarkerId("delivery"),
        position: LatLng(shipment.deliveryCityLat!, shipment.deliveryCityLang!),
      ),
    );

    getBounds(markers, _controller);
  }

  late BitmapDescriptor pickupicon;
  late BitmapDescriptor deliveryicon;
  late BitmapDescriptor parkicon;
  late BitmapDescriptor truckicon;
  late LatLng truckLocation;
  late bool truckLocationassign;
  bool rejectbotton = false;

  createMarkerIcons() async {
    pickupicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location1.png");
    deliveryicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location2.png");
    parkicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/locationP.png");
    truckicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/truck.png");
    setState(() {});
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
  }

  @override
  void dispose() {
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
              body: SingleChildScrollView(
                child: Consumer<ActiveShippmentProvider>(
                    builder: (context, shipmentProvider, child) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 350.h,
                        child: AbsorbPointer(
                          absorbing: false,
                          child: GoogleMap(
                            mapType: MapType.normal,
                            // zoomControlsEnabled: false,
                            markers: {
                              // Marker(
                              //   position: truckLocation,
                              //   markerId: const MarkerId('parking'),
                              //   icon: parkicon,
                              Marker(
                                markerId: const MarkerId("pickup"),
                                position: LatLng(widget.shipment.pickupCityLat!,
                                    widget.shipment.pickupCityLang!),
                                icon: pickupicon,
                              ),
                              Marker(
                                markerId: const MarkerId("delivery"),
                                position: LatLng(
                                    widget.shipment.deliveryCityLat!,
                                    widget.shipment.deliveryCityLang!),
                                icon: deliveryicon,
                              ),
                            },
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(35.363149, 35.932120),
                              zoom: 13,
                            ),
                            onMapCreated:
                                (GoogleMapController controller) async {
                              setState(() {
                                _controller = controller;
                                _controller.setMapStyle(_mapStyle);
                                // _added = true;
                              });
                              getpolylineCoordinates(widget.shipment);
                              setState(() {});
                            },
                            polylines: {
                              Polyline(
                                polylineId: const PolylineId("route"),
                                points: _polyline,
                                color: AppColor.deepYellow,
                                width: 7,
                              ),
                            },
                          ),
                        ),
                      ),
                      Container(
                        // height: 435.h,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(13),
                            topRight: Radius.circular(13),
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${AppLocalizations.of(context)!.translate('truck_type')}: ${localeState.value.languageCode == 'en' ? widget.shipment.truckType!.name! : widget.shipment.truckType!.nameAr!}",
                                        style: TextStyle(
                                          fontSize: 19.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Text(
                                      //   "commodity name: ${widget.shipment.shipmentItems![0].commodityName!}",
                                      //   style: TextStyle(
                                      //     fontSize: 19.sp,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  Text(
                                    "${AppLocalizations.of(context)!.translate('shipment_number')} ${widget.shipment.id!}",
                                    style: TextStyle(
                                      fontSize: 19.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const Divider(),
                            ShipmentPathWidget(
                              loadDate:
                                  setLoadDate(widget.shipment.pickupDate!),
                              pickupName: widget.shipment.pickupCityLocation!,
                              deliveryName:
                                  widget.shipment.deliveryCityLocation!,
                              width: MediaQuery.of(context).size.width * .8,
                              pathwidth: MediaQuery.of(context).size.width * .7,
                            ).animate().slideX(
                                duration: 300.ms,
                                delay: 0.ms,
                                begin: 1,
                                end: 0,
                                curve: Curves.easeInOutSine),
                            const Divider(),
                            _buildCommodityWidget(
                                widget.shipment.shipmentItems),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  BlocConsumer<OrderTruckBloc, OrderTruckState>(
                                    listener: (context, state) {
                                      if (state is OrderTruckSuccessState) {
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
                                          is OrderTruckLoadingProgressState) {
                                        return CustomButton(
                                          title: SizedBox(
                                            width: 70.w,
                                            child: const Center(
                                              child: LoadingIndicator(),
                                            ),
                                          ),
                                          onTap: () {},
                                          color: Colors.white,
                                        );
                                      } else {
                                        return CustomButton(
                                          title: SizedBox(
                                            width: 70.w,
                                            child: Center(
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .translate('ok'),
                                                style: const TextStyle(
                                                    color: Colors.green),
                                              ),
                                            ),
                                          ),
                                          onTap: () async {
                                            if (widget.isOwner ?? false) {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                useSafeArea: true,
                                                builder: (context) => Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    AbsorbPointer(
                                                                  absorbing:
                                                                      false,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: localeState.value.countryCode ==
                                                                            'en'
                                                                        ? const Icon(Icons
                                                                            .arrow_forward)
                                                                        : const Icon(
                                                                            Icons.arrow_back),
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'select_driver'),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      18.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5.h,
                                                        ),
                                                        BlocBuilder<
                                                            OwnerTrucksBloc,
                                                            OwnerTrucksState>(
                                                          builder:
                                                              (context, state) {
                                                            if (state
                                                                is OwnerTrucksLoadedSuccess) {
                                                              return state.trucks
                                                                      .isEmpty
                                                                  ? Center(
                                                                      child: Text(AppLocalizations.of(
                                                                              context)!
                                                                          .translate(
                                                                              'no_shipments')),
                                                                    )
                                                                  : ListView
                                                                      .separated(
                                                                          shrinkWrap:
                                                                              true,
                                                                          itemBuilder: (context,
                                                                              index) {
                                                                            return index != 0
                                                                                ? InkWell(
                                                                                    onTap: () {
                                                                                      BlocProvider.of<OrderTruckBloc>(context).add(OrderTruckButtonPressed(widget.shipment.id!, state.trucks[index].truckuser!.id!));
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                      child: Text(
                                                                                        "${state.trucks[index].truckuser!.user!.firstName!} ${state.trucks[index].truckuser!.user!.lastName!}",
                                                                                        style: TextStyle(
                                                                                          fontSize: 18.sp,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                : const SizedBox.shrink();
                                                                          },
                                                                          separatorBuilder: (context, index) =>
                                                                              const Divider(),
                                                                          itemCount: state
                                                                              .trucks
                                                                              .length);
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
                                            } else {
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              var driver =
                                                  prefs.getInt("truckuser");
                                              BlocProvider.of<OrderTruckBloc>(
                                                      context)
                                                  .add(OrderTruckButtonPressed(
                                                      widget.shipment.id!,
                                                      driver!));
                                            }
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
                  );
                }),
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

  int getunfinishedTasks(Shipment shipment) {
    var count = 0;
    if (shipment.shipmentinstruction == null) {
      count++;
    }
    if (shipment.shipmentpayment == null) {
      count++;
    }
    return count;
  }

  final ScrollController _scrollController = ScrollController();

  _buildCommodityWidget(List<ShipmentItems>? shipmentItems) {
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
                  itemCount: widget.shipment.shipmentItems!.length,
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
                              "${AppLocalizations.of(context)!.translate('commodity_name')}: ${widget.shipment.shipmentItems![index].commodityName!}",
                              style: TextStyle(
                                fontSize: 17.sp,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "${AppLocalizations.of(context)!.translate('commodity_weight')}: ${widget.shipment.shipmentItems![index].commodityWeight!}",
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
