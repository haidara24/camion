import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/bloc/get_owner_trucks_with_gps_locations_bloc.dart';
import 'package:camion/business_logic/bloc/truck/owner_trucks_bloc.dart';
import 'package:camion/business_logic/bloc/update_owner_trucks_locations_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/no_reaults_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' as intel;
import 'package:shimmer/shimmer.dart';

class OwnerActiveShipmentScreen extends StatefulWidget {
  const OwnerActiveShipmentScreen({Key? key}) : super(key: key);

  @override
  State<OwnerActiveShipmentScreen> createState() =>
      _OwnerActiveShipmentScreenState();
}

class _OwnerActiveShipmentScreenState extends State<OwnerActiveShipmentScreen>
    with TickerProviderStateMixin {
  late AnimationController animcontroller;
  int _countdown = 10;
  late Timer? _timer;
  late GoogleMapController _controller;
  String? truckLocation = "";
  ScrollController _scrollController = ScrollController();

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

  double _bottomPosition = 0;

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
          SizedBox(
            height: 88.h,
            child: ListView.builder(
              controller: _scrollController,
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
                      // panelState = PanelState.open;
                    });
                    mymap();
                    markers = {};
                    markers.add(
                      Marker(
                        markerId: const MarkerId("selected truck"),
                        position: LatLng(
                          double.parse(truckLocation!.split(",")[0]),
                          double.parse(truckLocation!.split(",")[1]),
                        ),
                        onTap: () {
                          setState(() {
                            selectedIndex = index; // Update selected index
                            selectedTruck = index;
                            truckLocation = trucks[index].locationLat!;
                          });
                          _updateMarkers(trucks);
                          _scrollController.animateTo(
                            index * 180.w, // Calculate the scroll offset
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          ); // Rebuild markers with updated colors
                          mymap();
                        },
                      ),
                    );
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
    _scrollController = ScrollController();
    startCountdown();
    rootBundle.loadString('assets/style/map_style.json').then((string) {
      _mapStyle = string;
    });
    animcontroller = BottomSheet.createAnimationController(this);
    animcontroller.duration = const Duration(milliseconds: 1000);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    animcontroller.dispose();
    _controller.dispose();
    _timer!.cancel();
    super.dispose();
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        BlocProvider.of<GetOwnerTrucksWithGpsLocationsBloc>(context)
            .add(GetOwnerTrucksWithGpsLocationsLoadEvent());
        // await callApi(); // Wait for API call to complete
        setState(() {
          _countdown = 10; // Reset counter
        });
        // Timer continues automatically for the next cycle
      }
    });
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
          icon: selectedIndex != i
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () {
            setState(() {
              selectedIndex = i; // Update selected index
              selectedTruck = i;
              truckLocation = trucks[i].locationLat!;
            });
            _updateMarkers(trucks);
            _scrollController.animateTo(
              i * 180.w, // Calculate the scroll offset
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ); // Rebuild markers with updated colors
            mymap();
          },
        ),
      );
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
            backgroundColor: Colors.grey[100],
            body: BlocListener<UpdateOwnerTrucksLocationsBloc,
                UpdateOwnerTrucksLocationsState>(
              listener: (context, ownerLocationstate) {
                // TODO: implement listener
                if (ownerLocationstate
                    is UpdateOwnerTrucksLocationsLoadedSuccess) {
                  BlocProvider.of<OwnerTrucksBloc>(context)
                      .add(OwnerTrucksLoadEvent());
                }
              },
              child: BlocListener<GetOwnerTrucksWithGpsLocationsBloc,
                  GetOwnerTrucksWithGpsLocationsState>(
                listener: (context, ownerTruckListstate) {
                  // TODO: implement listener
                  if (ownerTruckListstate
                      is GetOwnerTrucksWithGpsLocationsLoadedSuccess) {
                    _updateMarkers(ownerTruckListstate.trucks);
                  }
                },
                child: BlocConsumer<OwnerTrucksBloc, OwnerTrucksState>(
                  listener: (context, state) {
                    if (state is OwnerTrucksLoadedSuccess) {}
                  },
                  builder: (context, state) {
                    if (state is OwnerTrucksLoadedSuccess) {
                      return Visibility(
                        visible: state.trucks.isNotEmpty,
                        replacement: NoResultsWidget(
                            text: AppLocalizations.of(context)!
                                .translate('no_trucks')),
                        child: Stack(
                          children: [
                            GoogleMap(
                              onMapCreated:
                                  (GoogleMapController controller) async {
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
                                  initMapbounds(state.trucks);
                                  setState(() {
                                    _bottomPosition = 0;
                                    selectedIndex = -1;
                                    selectedTruck = -1;
                                  });
                                  _updateMarkers(state.trucks);
                                },
                                icon: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Icon(
                                      Icons.zoom_out_map,
                                      color: Colors.grey[400],
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
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: pathList(
                                  state.trucks,
                                  localeState.value.languageCode,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: state.trucks.isNotEmpty,
                              child: Positioned(
                                bottom: 110,
                                left: 5,
                                child: InkWell(
                                  onTap: () {
                                    BlocProvider.of<
                                                GetOwnerTrucksWithGpsLocationsBloc>(
                                            context)
                                        .add(
                                            GetOwnerTrucksWithGpsLocationsLoadEvent());
                                  },
                                  child: AbsorbPointer(
                                    absorbing: false,
                                    child: SizedBox(
                                      height: 40.h,
                                      width: 40.h,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(45),
                                          border: Border.all(
                                            color: AppColor.deepYellow,
                                            width: 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$_countdown',
                                            style: const TextStyle(
                                              // color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
