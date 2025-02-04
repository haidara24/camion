import 'dart:convert';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/store_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/place_model.dart';
import 'package:camion/data/providers/add_multi_shipment_provider.dart';
import 'package:camion/data/services/places_service.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/location_list_tile.dart';
import 'package:camion/views/widgets/path_statistics_widget.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/snackbar_widget.dart';
import 'package:camion/views/widgets/store_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:flutter/services.dart'
    show SystemChrome, SystemUiOverlayStyle, rootBundle;

class AddPathScreen extends StatefulWidget {
  AddPathScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AddPathScreen> createState() => _AddPathScreenState();
}

class _AddPathScreenState extends State<AddPathScreen>
    with TickerProviderStateMixin {
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(35.363149, 35.932120),
    zoom: 9,
  );
  Set<Marker> myMarker = {};

  LatLng? selectedPosition;
  final ScrollController _scrollController = ScrollController();

  AddMultiShipmentProvider? addShippmentProvider;

  late BitmapDescriptor pickupicon;
  late BitmapDescriptor deliveryicon;

  final FocusNode _searchFocusNode = FocusNode();
  TextEditingController _searchController = TextEditingController();

  int selectedPointIndex = 0;
  bool pickLocationLoading = false;

  List<PlaceSearch> placesResult = [];

  LatLng newposition = const LatLng(35.363149, 35.932120);
  late Marker pickMarker;

  List<LatLng> deserializeLatLng(String jsonString) {
    List<dynamic> coordinates = json.decode(jsonString);
    List<LatLng> latLngList = [];
    for (var coord in coordinates) {
      latLngList.add(LatLng(coord[0], coord[1]));
    }
    return latLngList;
  }

  String _mapStyle = "";

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //     statusBarColor:
    //         Colors.white, // iOS ignores this, handled in AnnotatedRegion
    //     statusBarIconBrightness:
    //         Brightness.light, // Set light icons for dark background
    //     systemNavigationBarColor: AppColor.landscapeNatural, // Works on Android
    //     systemNavigationBarIconBrightness: Brightness.light,
    //   ),
    // );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      addShippmentProvider =
          Provider.of<AddMultiShipmentProvider>(context, listen: false);

      addShippmentProvider!
          .setbottomPosition(-MediaQuery.sizeOf(context).height);
    });
    rootBundle.loadString('assets/style/map_style.json').then((string) {
      _mapStyle = string;
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark, // Reset to default
        statusBarColor: AppColor.deepBlack,
        systemNavigationBarColor: AppColor.deepBlack,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.white, // Make status bar transparent
            statusBarIconBrightness:
                Brightness.light, // Light icons for dark backgrounds
            systemNavigationBarColor:
                AppColor.landscapeNatural, // Works on Android
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            body: SafeArea(
              child: Consumer<AddMultiShipmentProvider>(
                  builder: (context, shipmentProvider, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: GoogleMap(
                        initialCameraPosition: _initialCameraPosition,
                        zoomControlsEnabled: false,

                        onCameraMove: (position) {
                          if (shipmentProvider.pickMapMode) {
                            setState(() {
                              selectedPosition = LatLng(
                                  position.target.latitude,
                                  position.target.longitude);

                              newposition = LatLng(position.target.latitude,
                                  position.target.longitude);
                            });
                          }
                        },
                        markers: !shipmentProvider.pickMapMode
                            ? (shipmentProvider
                                    .stoppoints_controller.isNotEmpty)
                                ? shipmentProvider.stop_marker.toSet()
                                : {}
                            : {
                                Marker(
                                  markerId: MarkerId(newposition.toString()),
                                  position: newposition,
                                  // icon: widget.type == 0 ? pickupicon : deliveryicon,
                                )
                              },
                        onMapCreated: (controller) {
                          shipmentProvider.onMap2Created(controller, _mapStyle);
                          shipmentProvider
                              .initMapBounds(MediaQuery.sizeOf(context).height);
                        },
                        // myLocationEnabled: true,
                        compassEnabled: true,
                        rotateGesturesEnabled: false,
                        // mapType: controller.currentMapType,
                        mapToolbarEnabled: true,
                        polylines: shipmentProvider.pickMapMode
                            ? {}
                            : {
                                Polyline(
                                  polylineId: const PolylineId("route"),
                                  points: deserializeLatLng(
                                      jsonEncode(shipmentProvider.pathes)),
                                  color: AppColor.deepYellow,
                                  width: 7,
                                ),
                              },
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(
                          milliseconds: 300), // Animation duration
                      curve: Curves.easeInOut,
                      top: shipmentProvider.topPosition,
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        // margin: const EdgeInsets.all(8.0),
                        constraints: BoxConstraints(
                          maxHeight: 300.h,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          // borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .84,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: 230.h,
                                      ),
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        shrinkWrap:
                                            true, // Shrinks when items are fewer
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        itemCount: shipmentProvider
                                            .stoppoints_controller.length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    height: 30.h,
                                                    width: 30.h,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            AppColor.deepYellow,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              45),
                                                      color: AppColor.deepBlack,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        index == 0
                                                            ? "A"
                                                            : (index ==
                                                                    shipmentProvider
                                                                            .stoppoints_controller
                                                                            .length -
                                                                        1
                                                                ? "B"
                                                                : "$index"),
                                                        style: const TextStyle(
                                                          fontSize:
                                                              18, // Adjust font size as needed
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      shipmentProvider
                                                          .togglePosition(
                                                              MediaQuery.sizeOf(
                                                                      context)
                                                                  .height);
                                                      selectedPointIndex =
                                                          index;
                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 4,
                                                        vertical: 4,
                                                      ),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .6,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 9.0,
                                                        vertical: 11.0,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          shipmentProvider
                                                                      .stoppointstextLoading[
                                                                  index]
                                                              ? Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          4.0),
                                                                  child:
                                                                      SizedBox(
                                                                    height: 25,
                                                                    width: 25,
                                                                    child:
                                                                        LoadingIndicator(),
                                                                  ),
                                                                )
                                                              : const SizedBox
                                                                  .shrink(),
                                                          SizedBox(
                                                            width: shipmentProvider
                                                                        .stoppointstextLoading[
                                                                    index]
                                                                ? MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .45
                                                                : MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .5,
                                                            child: Text(
                                                              shipmentProvider
                                                                  .stoppoints_controller[
                                                                      index]
                                                                  .text,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: (index > 1),
                                                    replacement: Icon(
                                                      Icons.linear_scale,
                                                      color: AppColor.lightGrey,
                                                    ),
                                                    child: InkWell(
                                                      onTap: () {
                                                        shipmentProvider
                                                            .removestoppoint(
                                                                index);
                                                        shipmentProvider
                                                            .getPolyPoints(
                                                          MediaQuery.sizeOf(
                                                                  context)
                                                              .height,
                                                          index,
                                                          false,
                                                        )
                                                            .then(
                                                          (value) {
                                                            shipmentProvider
                                                                .initMapBounds(
                                                                    MediaQuery.sizeOf(
                                                                            context)
                                                                        .height);
                                                          },
                                                        );

                                                        // _showAlertDialog(index);
                                                      },
                                                      child: Container(
                                                        height: 25,
                                                        width: 25,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[400],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(45),
                                                        ),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.close,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Divider(
                                                height: 4,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              width: MediaQuery.sizeOf(context).width,
                              child: IconButton(
                                onPressed: () {
                                  var data = shipmentProvider.addstoppoint();
                                  if (!data["added"]) {
                                    showCustomSnackBar(
                                      context: context,
                                      backgroundColor: AppColor.deepYellow,
                                      message:
                                          "أضف عنوان للنقطة ${data["point"]}.",
                                    );
                                  } else {
                                    _scrollToBottom();
                                  }
                                  setState(() {});
                                },
                                icon: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: SizedBox(
                                        height: 25.h,
                                        width: 25.w,
                                        child: SvgPicture.asset(
                                          "assets/icons/orange/add.svg",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    Text(AppLocalizations.of(context)!
                                        .translate('add_station')),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: shipmentProvider.distance != 0,
                      replacement: const SizedBox.shrink(),
                      child: AnimatedPositioned(
                        duration: const Duration(
                            milliseconds: 300), // Animation duration
                        curve: Curves.easeInOut,
                        bottom: shipmentProvider.bottomPathStatisticPosition,
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          // margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                PathStatisticsWidget(
                                  distance: shipmentProvider.distance,
                                  period: shipmentProvider.period,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CustomButton(
                                    isEnabled: (shipmentProvider
                                            .stoppoints_location
                                            .first
                                            .isNotEmpty &&
                                        shipmentProvider.stoppoints_location
                                            .last.isNotEmpty),
                                    onTap: () {
                                      shipmentProvider.setPathConfirm(
                                        true,
                                      );
                                      Navigator.pop(context);
                                    },
                                    title: SizedBox(
                                      height: 30.h,
                                      width: 150.w,
                                      child: Center(
                                        child: SectionTitle(
                                          text: AppLocalizations.of(context)!
                                              .translate("confirm"),
                                          // color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(
                          milliseconds: 300), // Animation duration
                      curve: Curves.easeInOut,
                      top: shipmentProvider.toptextfeildPosition,
                      onEnd: () {
                        // Trigger focus after the animation completes
                        if (shipmentProvider.toptextfeildPosition == 0) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _searchFocusNode.requestFocus();
                          });
                        }
                      },
                      child: Container(
                        height: 110,
                        width: MediaQuery.sizeOf(context).width,
                        color: Colors.white,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      shipmentProvider.togglePosition(
                                          MediaQuery.sizeOf(context).height);
                                    },
                                    icon: const Icon(Icons.arrow_back),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .84,
                                    child: Form(
                                      child: TextFormField(
                                        controller: _searchController,
                                        focusNode: _searchFocusNode,
                                        onChanged: (value) async {
                                          print(value);
                                          if (value.isNotEmpty) {
                                            final results = await PlaceService
                                                .getAutocomplete(value);

                                            setState(() {
                                              placesResult = List.from(
                                                  results); // Assign a new list reference
                                            });
                                          }
                                        },
                                        onTap: () {
                                          if (shipmentProvider.showStores) {
                                            shipmentProvider.setShowStores();
                                          }
                                        },
                                        onTapOutside: (event) {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        textInputAction: TextInputAction.search,
                                        decoration: InputDecoration(
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .translate("search_location"),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        shipmentProvider.setStopPointLoading(
                                          true,
                                          selectedPointIndex,
                                        );
                                        shipmentProvider
                                            .getCurrentPositionForStop(
                                          context,
                                          selectedPointIndex,
                                          MediaQuery.sizeOf(context).height,
                                        )
                                            .then(
                                          (value) {
                                            shipmentProvider.togglePosition(
                                                MediaQuery.sizeOf(context)
                                                    .height);
                                            placesResult = [];
                                            _searchController.text = "";
                                            setState(() {});
                                            // valueProvider.setPickupPositionClick(false, selectedIndex);
                                          },
                                        );
                                        if (shipmentProvider.showStores) {
                                          shipmentProvider.setShowStores();
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .translate('pick_my_location'),
                                          ),
                                          Icon(
                                            Icons.location_on,
                                            color: AppColor.deepYellow,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30.h,
                                    width: 16,
                                    child: const VerticalDivider(
                                      color: Colors.grey,
                                      thickness: 1,
                                      width: 1,
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        shipmentProvider
                                            .toggleMapMode(selectedPointIndex);
                                        shipmentProvider.togglePosition(
                                            MediaQuery.sizeOf(context).height);
                                        if (shipmentProvider.showStores) {
                                          shipmentProvider.setShowStores();
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .translate('pick_from_map'),
                                          ),
                                          Icon(
                                            Icons.map,
                                            color: AppColor.deepYellow,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30.h,
                                    width: 16,
                                    child: const VerticalDivider(
                                      color: Colors.grey,
                                      thickness: 1,
                                      width: 1,
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        shipmentProvider.setShowStores();
                                      },
                                      child: Container(
                                        height: 30.h,
                                        color: shipmentProvider.showStores
                                            ? AppColor.lightYellow
                                            : Colors.white,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .translate('pick_store'),
                                            ),
                                            Icon(
                                              Icons.warehouse,
                                              color: AppColor.deepYellow,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(
                          milliseconds: 300), // Animation duration
                      curve: Curves.easeInOut,
                      top: shipmentProvider.bottomPosition,
                      child: Container(
                        height: MediaQuery.sizeOf(context).height - 130,
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          border: Border(
                            top: BorderSide(
                              color: AppColor.darkGrey,
                            ),
                          ),
                        ),
                        child: shipmentProvider.showStores
                            ? BlocBuilder<StoreListBloc, StoreListState>(
                                builder: (context, storestate) {
                                  if (storestate is StoreListLoadedSuccess) {
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: storestate.stores.length,
                                      itemBuilder: (context, index) =>
                                          Container(
                                        color: Colors.white,
                                        child: StoreListTile(
                                          store:
                                              storestate.stores[index].address!,
                                          onTap: () {
                                            shipmentProvider
                                                .setStopPointLoading(
                                              true,
                                              selectedPointIndex,
                                            );
                                            shipmentProvider.setStopPointStore(
                                              storestate
                                                  .stores[index].location!,
                                              selectedPointIndex,
                                              MediaQuery.sizeOf(context).height,
                                            );
                                            shipmentProvider.togglePosition(
                                                MediaQuery.sizeOf(context)
                                                    .height);

                                            placesResult = [];
                                            _searchController.text = "";
                                            shipmentProvider.setShowStores();
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    );
                                  } else {
                                    return LoadingIndicator();
                                  }
                                },
                              )
                            : placesResult.isEmpty
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        child: ListTile(
                                          horizontalTitleGap: 0,
                                          leading: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(45),
                                              color: AppColor.darkGrey,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.history,
                                              color: Colors.white,
                                            ),
                                          ),
                                          title: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: SectionBody(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .translate("last_search"),
                                              color: AppColor.darkGrey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.white,
                                        child: const Divider(
                                          height: 8,
                                          thickness: 2,
                                        ),
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: shipmentProvider
                                            .cachedSearchResults.length,
                                        itemBuilder: (context, index) =>
                                            Container(
                                          color: Colors.white,
                                          child: LocationListTile(
                                            location: shipmentProvider
                                                    .cachedSearchResults[index]
                                                ["description"],
                                            onTap: () {
                                              print("asd");
                                              shipmentProvider
                                                  .setStopPointLoading(
                                                true,
                                                selectedPointIndex,
                                              );
                                              shipmentProvider.setStopPointInfo(
                                                shipmentProvider
                                                    .cachedSearchResults[index],
                                                selectedPointIndex,
                                                false,
                                                MediaQuery.sizeOf(context)
                                                    .height,
                                              );
                                              shipmentProvider.togglePosition(
                                                  MediaQuery.sizeOf(context)
                                                      .height);
                                              placesResult = [];
                                              _searchController.text = "";
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    itemCount: placesResult.length,
                                    itemBuilder: (context, index) => Container(
                                      color: Colors.white,
                                      child: LocationListTile(
                                        location:
                                            placesResult[index].description,
                                        onTap: () {
                                          print("asd");
                                          shipmentProvider.setStopPointLoading(
                                            true,
                                            selectedPointIndex,
                                          );
                                          shipmentProvider.setStopPointInfo(
                                            placesResult[index],
                                            selectedPointIndex,
                                            true,
                                            MediaQuery.sizeOf(context).height,
                                          );
                                          shipmentProvider.togglePosition(
                                              MediaQuery.sizeOf(context)
                                                  .height);
                                          placesResult = [];
                                          _searchController.text = "";
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(
                          milliseconds: 300), // Animation duration
                      curve: Curves.easeInOut,
                      bottom: shipmentProvider.pickMapMode ? 20.h : -60,
                      child: CustomButton(
                        onTap: () {
                          setState(() {
                            pickLocationLoading = true;
                          });
                          shipmentProvider.setStopPointLoading(
                            true,
                            selectedPointIndex,
                          );
                          shipmentProvider
                              .getAddressForStopPointFromMapPicker(
                            selectedPosition!,
                            selectedPointIndex,
                            MediaQuery.sizeOf(context).height,
                          )
                              .then(
                            (value) {
                              shipmentProvider
                                  .toggleMapMode(selectedPointIndex);
                              setState(() {
                                pickLocationLoading = false;
                              });
                            },
                          );
                        },
                        title: SizedBox(
                          height: 50.h,
                          width: 150.w,
                          child: Center(
                            child: pickLocationLoading
                                ? LoadingIndicator()
                                : SectionBody(
                                    text: AppLocalizations.of(context)!
                                        .translate("confirm"),
                                  ),
                          ),
                        ),
                        isEnabled: selectedPosition != null,
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(
                          milliseconds: 300), // Animation duration
                      curve: Curves.easeInOut,
                      top: shipmentProvider.pickMapMode ? 20.h : -160,
                      right: localeState.value.languageCode == "en" ? null : 20,
                      left: localeState.value.languageCode == "en" ? 20 : null,
                      child: CustomButton(
                        onTap: () {
                          shipmentProvider.toggleMapMode(selectedPointIndex);
                        },
                        title: SizedBox(
                          height: 40.w,
                          width: 40.w,
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back,
                            ),
                          ),
                        ),
                        hieght: 40,
                        color: Colors.grey[200],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
