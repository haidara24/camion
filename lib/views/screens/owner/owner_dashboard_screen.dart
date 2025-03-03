import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/gps_reports/over_speed_bloc.dart';
import 'package:camion/business_logic/bloc/gps_reports/parking_report_bloc.dart';
import 'package:camion/business_logic/bloc/gps_reports/total_milage_day_bloc.dart';
import 'package:camion/business_logic/bloc/gps_reports/total_statistics_bloc.dart';
import 'package:camion/business_logic/bloc/gps_reports/trip_report_bloc.dart';
import 'package:camion/business_logic/bloc/truck/owner_trucks_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/enums.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/owner/reports/milage_per_day_report_screen.dart';
import 'package:camion/views/screens/owner/reports/over_speed_report_screen.dart';
import 'package:camion/views/screens/owner/reports/parking_report_screen.dart';
import 'package:camion/views/screens/owner/reports/trip_report_screen.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/no_reaults_widget.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' as intel;
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart' show rootBundle;

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController animcontroller;
  late Timer timer;
  late GoogleMapController _controller;
  String? truckLocation = "";

  var f = intel.NumberFormat("#,###", "en_US");

  int selectedIndex = -1;
  int selectedTruck = -1;

  double distance = 0;
  String period = "";

  late BitmapDescriptor pickupicon;
  late BitmapDescriptor deliveryicon;
  late BitmapDescriptor parkicon;
  late BitmapDescriptor truckicon;
  // late LatLng truckLocation;
  late bool truckLocationassign;
  Set<Marker> markers = {};
  bool startTracking = false;

  double _rightPosition = -MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.views.first)
      .size
      .width;

  double _bottomPosition = 0;
  PanelState panelState = PanelState.hidden;

  void _togglePosition() {
    setState(() {
      _rightPosition =
          _rightPosition == 0 ? -MediaQuery.of(context).size.width : 0;
      _bottomPosition = _bottomPosition == 150.h ? 0 : 150.h;
    });
  }

  initMapbounds(List<KTruck> trucks) async {
    setState(() {
      startTracking = false;
    });
    List<Marker> markers = [];
    for (var element in trucks) {
      markers.add(
        Marker(
          markerId: MarkerId("truck${element.id}"),
          position: LatLng(double.parse(element.locationLat!.split(",")[0]),
              double.parse(element.locationLat!.split(",")[1])),
        ),
      );
    }

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
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 130.0);
    _controller.animateCamera(cameraUpdate);
  }

  Widget pathList(List<KTruck> trucks, String language) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(
          top: BorderSide(
            color: AppColor.lightGrey,
          ),
        ),
      ),
      height: 105.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: SectionTitle(
          //       text: AppLocalizations.of(context)!.translate("drivers")),
          // ),
          SizedBox(
            height: 88.h,
            child: ListView.builder(
              itemCount: trucks.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      selectedTruck = index;
                      // subshipment = trucks[index];
                      truckLocation = trucks[index].locationLat!;
                      panelState = PanelState.open;
                    });
                    mymap();

                    _updateMarkers(trucks);
                    _rightPosition = 0;
                    _bottomPosition = 150.h;
                    final now = DateTime.now();
                    final startTime = now.subtract(const Duration(days: 29));
                    final dateFormat = intel.DateFormat('yyyy-MM-dd HH:mm:ss');

                    final formattedStartTime = dateFormat.format(startTime);
                    final formattedEndTime = dateFormat.format(now);
                    if (!(trucks[selectedTruck].gpsId == null ||
                        trucks[selectedTruck].gpsId!.isEmpty ||
                        trucks[selectedTruck].gpsId!.length < 8)) {
                      BlocProvider.of<TotalStatisticsBloc>(context).add(
                          TotalStatisticsLoadEvent(formattedStartTime,
                              formattedEndTime, trucks[index].carId!));
                    }
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
                                  imageUrl: trucks[index].truckType!.image!,
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
                                    width:
                                        selectedTruck == index ? 122.w : 118.w,
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('image_load_error'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 6.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${trucks[index].driver_firstname!} ${trucks[index].driver_lastname!}",
                                style: TextStyle(
                                  fontSize:
                                      selectedTruck == index ? 17.sp : 15.sp,
                                  color: AppColor.deepBlack,
                                ),
                              ),
                              Text(
                                'No: ${trucks[index].truckNumber!}',
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
    );
  }

  Widget truckStatisticsInfo(BuildContext context, List<KTruck> trucks) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border(
            top: BorderSide(
              color: AppColor.lightGrey,
            ),
          ),
        ),
        height: 150.h,
        width: MediaQuery.of(context).size.width,
        child: BlocConsumer<TotalStatisticsBloc, TotalStatisticsState>(
          listener: (context, state) {
            print(state);
          },
          builder: (context, state) {
            if (state is TotalStatisticsLoadingProgress) {
              return LoadingIndicator();
            } else if (state is TotalStatisticsLoadedSuccess) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  selectedTruck >= 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SectionBody(
                              text:
                                  "${AppLocalizations.of(context)!.translate("driver_name")}: ${trucks[selectedTruck].driver_firstname!} ${trucks[selectedTruck].driver_lastname!}",
                            ),
                            SectionBody(
                              text:
                                  '${AppLocalizations.of(context)!.translate("truck_number")}: ${trucks[selectedTruck].truckNumber!}',
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  selectedTruck >= 0
                      ? (trucks[selectedTruck].gpsId == null ||
                              trucks[selectedTruck].gpsId!.isEmpty ||
                              trucks[selectedTruck].gpsId!.length < 8)
                          ? Expanded(
                              child: Center(
                                child: SectionBody(
                                  text: AppLocalizations.of(context)!
                                      .translate("no_gps_device"),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final now = DateTime.now();
                                    final startTime =
                                        now.subtract(const Duration(days: 29));
                                    final dateFormat =
                                        intel.DateFormat('yyyy-MM-dd HH:mm:ss');

                                    final formattedStartTime =
                                        dateFormat.format(startTime);
                                    final formattedEndTime =
                                        dateFormat.format(now);

                                    BlocProvider.of<OverSpeedBloc>(context).add(
                                        OverSpeedLoadEvent(
                                            formattedStartTime,
                                            formattedEndTime,
                                            trucks[selectedTruck].carId!));
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OverSpeedReportScreen(
                                                  start: startTime,
                                                  end: now,
                                                  carId: trucks[selectedTruck]
                                                      .carId!),
                                        ));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: AppColor.lightGrey,
                                        width: 2.w,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/overspeed.svg",
                                          height: 50.h,
                                          width: 50.h,
                                        ),
                                        SectionBody(
                                            text: AppLocalizations.of(context)!
                                                .translate("total_overspeed")),
                                        Text(state.result["overSpeeds"]
                                            .toString()),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final now = DateTime.now();
                                    final startTime =
                                        now.subtract(const Duration(days: 29));
                                    final dateFormat =
                                        intel.DateFormat('yyyy-MM-dd HH:mm:ss');

                                    final formattedStartTime =
                                        dateFormat.format(startTime);
                                    final formattedEndTime =
                                        dateFormat.format(now);

                                    BlocProvider.of<ParkingReportBloc>(context)
                                        .add(ParkingReportLoadEvent(
                                            formattedStartTime,
                                            formattedEndTime,
                                            trucks[selectedTruck].carId!));

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ParkingReportScreen(
                                                  start: startTime,
                                                  end: now,
                                                  carId: trucks[selectedTruck]
                                                      .carId!),
                                        ));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: AppColor.lightGrey,
                                        width: 2.w,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/total_stops.svg",
                                          height: 50.h,
                                          width: 50.h,
                                        ),
                                        SectionBody(
                                            text: AppLocalizations.of(context)!
                                                .translate("total_parking")),
                                        Text(state.result["stops"].toString()),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final now = DateTime.now();
                                    final startTime =
                                        now.subtract(const Duration(days: 29));
                                    final dateFormat =
                                        intel.DateFormat('yyyy-MM-dd HH:mm:ss');

                                    final formattedStartTime =
                                        dateFormat.format(startTime);
                                    final formattedEndTime =
                                        dateFormat.format(now);

                                    BlocProvider.of<TotalMilageDayBloc>(context)
                                        .add(TotalMilageDayLoadEvent(
                                            formattedStartTime,
                                            formattedEndTime,
                                            trucks[selectedTruck].carId!));

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MilagePerDayReportScreen(
                                                  start: startTime,
                                                  end: now,
                                                  carId: trucks[selectedTruck]
                                                      .carId!),
                                        ));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: AppColor.lightGrey,
                                        width: 2.w,
                                      ),
                                    ),
                                    padding: EdgeInsets.all(4.h),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 50.h,
                                          width: 50.h,
                                          child: SvgPicture.asset(
                                            "assets/icons/orange/shipment_path.svg",
                                            height: 50.h,
                                            width: 50.h,
                                          ),
                                        ),
                                        SectionBody(
                                            text: AppLocalizations.of(context)!
                                                .translate("total_mileage")),
                                        Text(state.result["totalMileage"]
                                            .toString()),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final now = DateTime.now();
                                    final startTime =
                                        now.subtract(const Duration(days: 29));
                                    final dateFormat =
                                        intel.DateFormat('yyyy-MM-dd HH:mm:ss');

                                    final formattedStartTime =
                                        dateFormat.format(startTime);
                                    final formattedEndTime =
                                        dateFormat.format(now);

                                    BlocProvider.of<TripReportBloc>(context)
                                        .add(TripReportLoadEvent(
                                            formattedStartTime,
                                            formattedEndTime,
                                            trucks[selectedTruck].carId!));
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TripReportScreen(
                                                  start: startTime,
                                                  end: now,
                                                  carId: trucks[selectedTruck]
                                                      .carId!),
                                        ));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: AppColor.lightGrey,
                                        width: 2.w,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/total_trips.svg",
                                          height: 50.h,
                                          width: 50.h,
                                        ),
                                        SectionBody(
                                            text: AppLocalizations.of(context)!
                                                .translate("total_trips")),
                                        const Text(""),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                      : const SizedBox.shrink(),
                ],
              );
            } else {
              return LoadingIndicator();
            }
          },
        ));
  }

  Future<void> mymap() async {
    await _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            double.parse(truckLocation!.split(",")[0]),
            double.parse(truckLocation!.split(",")[1]),
          ),
          zoom: 14.47,
        ),
      ),
    );
  }

  String _mapStyle = "";

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // _fetchTruckLocation(subshipment!.truck!.id!);
      if (startTracking) {
        mymap();
      }
    });
    rootBundle.loadString('assets/style/map_style.json').then((string) {
      _mapStyle = string;
    });
    animcontroller = BottomSheet.createAnimationController(this);
    animcontroller.duration = const Duration(milliseconds: 1000);
  }

  @override
  void dispose() {
    animcontroller.dispose();
    _controller.dispose();
    timer.cancel();
    super.dispose();
  }

// Helper method to update markers
  void _updateMarkers(List<KTruck> trucks) {
    markers = {};
    for (var i = 0; i < trucks.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId("truck${trucks[i].id}"),
          position: LatLng(
            double.parse(trucks[i].locationLat!.split(",")[0]),
            double.parse(trucks[i].locationLat!.split(",")[1]),
          ),
          icon: selectedIndex == i
              ? BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueYellow)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () {
            setState(() {
              selectedIndex = i; // Update selected index
              selectedTruck = i;
              truckLocation = trucks[i].locationLat!;
            });
            _updateMarkers(trucks); // Rebuild markers with updated colors

            // Additional logic for handling marker tap
            mymap();
            _rightPosition = 0;
            _bottomPosition = 150.h;
            final now = DateTime.now();
            final startTime = now.subtract(const Duration(days: 29));
            final dateFormat = intel.DateFormat('yyyy-MM-dd HH:mm:ss');
            final formattedStartTime = dateFormat.format(startTime);
            final formattedEndTime = dateFormat.format(now);

            BlocProvider.of<TotalStatisticsBloc>(context).add(
              TotalStatisticsLoadEvent(
                formattedStartTime,
                formattedEndTime,
                trucks[i].carId!,
              ),
            );
          },
        ),
      );
    }
  }

  void _onVerticalGesture(
    DragUpdateDetails? details,
    List<KTruck> trucks,
  ) {
    if (details!.primaryDelta! > 7 && panelState == PanelState.open) {
      initMapbounds(trucks);
      setState(() {
        _rightPosition = -MediaQuery.of(context).size.width;
        _bottomPosition = 0;
        selectedIndex = -1;
        selectedTruck = -1;
        panelState = PanelState.hidden;
      });
      _updateMarkers(trucks);
    }
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
            body: BlocConsumer<OwnerTrucksBloc, OwnerTrucksState>(
              listener: (context, state) {
                if (state is OwnerTrucksLoadedSuccess) {}
              },
              builder: (context, state) {
                if (state is OwnerTrucksLoadedSuccess) {
                  // if (subshipment != null) {
                  //   subshipment = state.shipments[0];
                  //   truckLocation = subshipment!.truck!.location_lat!;
                  // }
                  return Visibility(
                    visible: state.trucks.isNotEmpty,
                    replacement: NoResultsWidget(
                        text: AppLocalizations.of(context)!
                            .translate('no_active')),
                    child: Stack(
                      children: [
                        GoogleMap(
                          onMapCreated: (GoogleMapController controller) async {
                            setState(() {
                              _controller = controller;
                              _controller.setMapStyle(_mapStyle);
                            });
                            initMapbounds(state.trucks);

                            _updateMarkers(state.trucks);
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

                          // mapType: shipmentProvider.mapType,
                        ),
                        Positioned(
                          top: 0,
                          right: 5,
                          child: IconButton(
                            onPressed: () {
                              // _togglePosition();
                              _rightPosition =
                                  -MediaQuery.of(context).size.width;

                              initMapbounds(state.trucks);
                              setState(() {
                                _bottomPosition = 0;
                                selectedIndex = -1;
                                selectedTruck = -1;
                                panelState = PanelState.hidden;
                              });
                              _updateMarkers(state.trucks);
                            },
                            icon: const SizedBox(
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
                        AnimatedPositioned(
                          duration: const Duration(
                              milliseconds: 300), // Animation duration
                          curve: Curves.easeInOut,
                          bottom: _bottomPosition,
                          child: GestureDetector(
                            onVerticalDragUpdate: (details) {
                              _onVerticalGesture(details, state.trucks);
                            },
                            child: Column(
                              children: [
                                Visibility(
                                  visible: panelState == PanelState.open,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      border: Border(
                                        top: BorderSide(
                                          color: AppColor.lightGrey,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            initMapbounds(state.trucks);
                                            setState(() {
                                              _rightPosition =
                                                  -MediaQuery.of(context)
                                                      .size
                                                      .width;
                                              _bottomPosition = 0;
                                              selectedIndex = -1;
                                              selectedTruck = -1;
                                              panelState = PanelState.hidden;
                                            });
                                            _updateMarkers(state.trucks);
                                          },
                                          icon: SizedBox(
                                            width: 32.w,
                                            child: SvgPicture.asset(
                                              "assets/icons/arrow_down.svg",
                                              fit: BoxFit.contain,
                                              height: 8.h,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: pathList(
                                    state.trucks,
                                    localeState.value.languageCode,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(
                              milliseconds: 300), // Animation duration
                          curve: Curves.easeInOut, // Animation curve
                          bottom: 0,
                          right: _rightPosition,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: truckStatisticsInfo(context, state.trucks),
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
            ),
          ),
        );
      },
    );
  }
}
