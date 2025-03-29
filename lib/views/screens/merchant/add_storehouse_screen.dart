import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/profile/create_store_bloc.dart';
import 'package:camion/business_logic/bloc/profile/merchant_profile_bloc.dart';
import 'package:camion/business_logic/bloc/store_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/place_model.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/services/places_service.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/location_list_tile.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddStoreHouseScreen extends StatefulWidget {
  final int? id;
  AddStoreHouseScreen({Key? key, this.id}) : super(key: key);

  @override
  State<AddStoreHouseScreen> createState() => _AddStoreHouseScreenState();
}

class _AddStoreHouseScreenState extends State<AddStoreHouseScreen>
    with TickerProviderStateMixin {
  Set<Marker> myMarker = new Set();

  late GoogleMapController mapController;
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(35.363149, 35.932120),
    zoom: 9,
  );
  double _topsearchfieldPosition = 0;
  double _topaddressfieldPosition = -300;

  TextEditingController storeAddressController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  double _bottomPosition = 60.0;

  List<PlaceSearch> placesResult = [];

  void togglePosition(double height) {
    setState(() {
      _topsearchfieldPosition = _topsearchfieldPosition == 0.0 ? -300 : 0.0;
      _topaddressfieldPosition = _topaddressfieldPosition == -300 ? 0.0 : -300;

      _bottomPosition = _bottomPosition == 60 ? -height : 60;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // initlocation();
  }

  bool storeLoading = false;

  LatLng? selectedPosition;

  late BitmapDescriptor storeicon;

  createMarkerIcons() async {
    storeicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(30, 50)),
        "assets/icons/location1.png");

    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      createMarkerIcons();
      // initlocation();
    });
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print(_topsearchfieldPosition);
        if (_topsearchfieldPosition == -300) {
          togglePosition(MediaQuery.sizeOf(context).height);
          print(_topsearchfieldPosition);

          return false; // Prevent exit on the first press
        }
        return true; // Exit the app on the second press within 2 seconds
      },
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: AppColor.deepBlack, // Make status bar transparent
              statusBarIconBrightness:
                  Brightness.light, // Light icons for dark backgrounds
              systemNavigationBarColor:
                  AppColor.landscapeNatural, // Works on Android
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: SafeArea(
              child: Scaffold(
                appBar: CustomAppBar(
                  title: widget.id != null ? "إضافة مستودع " : "المستودع",
                ),
                body: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: GoogleMap(
                        initialCameraPosition: _initialCameraPosition,
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        onCameraMove: (position) {
                          setState(() {
                            selectedPosition = LatLng(position.target.latitude,
                                position.target.longitude);
                            myMarker = new Set();
                            var newposition = LatLng(position.target.latitude,
                                position.target.longitude);
                            myMarker.add(
                              Marker(
                                markerId: MarkerId(newposition.toString()),
                                position: newposition,
                              ),
                            );
                          });
                        },
                        markers: myMarker,
                        myLocationEnabled: true,
                        onMapCreated: _onMapCreated,
                        compassEnabled: true,
                        rotateGesturesEnabled: false,
                        // mapType: controller.currentMapType,
                        mapToolbarEnabled: true,
                      ),
                    ),
                    (selectedPosition != null &&
                            storeAddressController.text.isNotEmpty)
                        ? Positioned(
                            bottom: 25.h,
                            child: storeLoading
                                ? Container(
                                    height: 50.h,
                                    width: 150.w,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Center(
                                      child: LoadingIndicator(),
                                    ),
                                  )
                                : BlocConsumer<CreateStoreBloc,
                                    CreateStoreState>(
                                    listener: (context, state) {
                                      if (state is CreateStoreLoadedSuccess) {
                                        BlocProvider.of<StoreListBloc>(context)
                                            .add(StoreListLoadEvent());
                                        Navigator.pop(context);
                                      }
                                    },
                                    builder: (context, state) {
                                      if (state is CreateStoreLoadingProgress) {
                                        return Container(
                                          height: 50.h,
                                          width: 150.w,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: Center(
                                            child: LoadingIndicator(),
                                          ),
                                        );
                                      } else {
                                        return CustomButton(
                                          onTap: () {
                                            if (selectedPosition != null) {
                                              Stores store = Stores();
                                              store.address =
                                                  storeAddressController.text;
                                              store.location =
                                                  "${selectedPosition!.latitude},${selectedPosition!.longitude}";
                                              BlocProvider.of<CreateStoreBloc>(
                                                      context)
                                                  .add(CreateStoreButtonPressed(
                                                      store));
                                            }
                                          },
                                          title: Container(
                                            height: 50.h,
                                            width: 150.w,
                                            child: const Center(
                                              child: Text(
                                                "Save",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                          )
                        : const SizedBox.shrink(),
                    AnimatedPositioned(
                      duration: const Duration(
                          milliseconds: 300), // Animation duration
                      curve: Curves.easeInOut,
                      top: _topsearchfieldPosition,
                      onEnd: () {
                        // Trigger focus after the animation completes
                        if (_topsearchfieldPosition == 0) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _searchFocusNode.requestFocus();
                          });
                        }
                      },
                      child: Container(
                        height: 60,
                        width: MediaQuery.sizeOf(context).width,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            child: TextFormField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: (value) async {
                                print(value);
                                if (value.isNotEmpty) {
                                  final results =
                                      await PlaceService.getAutocomplete(value);

                                  setState(() {
                                    placesResult = List.from(
                                        results); // Assign a new list reference
                                  });
                                }
                              },
                              onTap: () {
                                // if (shipmentProvider.showStores) {
                                //   shipmentProvider.setShowStores();
                                // }
                              },
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!
                                    .translate("search_location"),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(
                          milliseconds: 300), // Animation duration
                      curve: Curves.easeInOut,
                      top: _topaddressfieldPosition,
                      onEnd: () {
                        // Trigger focus after the animation completes
                        if (_topaddressfieldPosition == 0) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _addressFocusNode.requestFocus();
                          });
                        }
                      },
                      child: Container(
                        height: 60,
                        width: MediaQuery.sizeOf(context).width,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: storeAddressController,
                            focusNode: _addressFocusNode,
                            decoration: InputDecoration(
                              // filled: true,
                              hintText: AppLocalizations.of(context)!
                                  .translate("enter_store_address"),
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(
                          milliseconds: 300), // Animation duration
                      curve: Curves.easeInOut,
                      top: _bottomPosition,
                      child: Container(
                        height: MediaQuery.sizeOf(context).height - 80,
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          border: Border(
                            top: BorderSide(
                              color: AppColor.darkGrey,
                            ),
                          ),
                        ),
                        child: ListView.builder(
                          itemCount: placesResult.length,
                          itemBuilder: (context, index) => Container(
                            color: Colors.white,
                            child: LocationListTile(
                              location: placesResult[index].description,
                              onTap: () async {
                                togglePosition(
                                    MediaQuery.sizeOf(context).height);
                                print(_topsearchfieldPosition);
                                if (placesResult[index].description ==
                                    "اللاذقية، Syria") {
                                  selectedPosition = LatLng(
                                      double.parse("35.525131"),
                                      double.parse("35.791570"));
                                } else {
                                  var value = await PlaceService.getPlace(
                                      placesResult[index].placeId);
                                  selectedPosition = LatLng(
                                      value.geometry.location.lat,
                                      value.geometry.location.lng);
                                }
                                myMarker = new Set();
                                var newposition = LatLng(
                                  selectedPosition!.latitude,
                                  selectedPosition!.longitude,
                                );
                                myMarker.add(
                                  Marker(
                                    markerId: MarkerId(newposition.toString()),
                                    position: newposition,
                                  ),
                                );
                                mapController.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                        selectedPosition!.latitude,
                                        selectedPosition!.longitude,
                                      ),
                                      zoom: 11,
                                    ),
                                  ),
                                );
                                placesResult = [];
                                _searchController.text = "";
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
