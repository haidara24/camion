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
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddStoreHouseScreen extends StatefulWidget {
  final int? id;
  AddStoreHouseScreen({Key? key, this.id}) : super(key: key);

  @override
  State<AddStoreHouseScreen> createState() => _AddStoreHouseScreenState();
}

class _AddStoreHouseScreenState extends State<AddStoreHouseScreen>
    with TickerProviderStateMixin {
  // double topPosition = 0.0;
  double bottomPathStatisticPosition = -300.0;
  double bottomPosition = 70;
  double toptextfeildPosition = 0;

  List<Map<String, dynamic>> cachedSearchResults = [];

  late GoogleMapController mapController;
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(35.363149, 35.932120),
    zoom: 9,
  );
  bool locationLoading = false;

  TextEditingController storeAddressController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();

  final GlobalKey<FormState> _addressformKey = GlobalKey<FormState>();

  LatLng newposition = const LatLng(35.363149, 35.932120);

  List<PlaceSearch> placesResult = [];

  void togglePosition(double height) {
    setState(() {
      bottomPathStatisticPosition = bottomPathStatisticPosition == 0 ? -300 : 0;

      bottomPosition = bottomPosition == 70 ? -height : 70;
    });
  }

  bool storeLoading = false;

  LatLng? selectedPosition;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showCustomSnackBar(
        context: context,
        backgroundColor: Colors.orange,
        message: 'خدمة تحديد الموقع غير مفعلة..',
      );
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showCustomSnackBar(
          context: context,
          backgroundColor: Colors.orange,
          message: 'Location permissions are denied',
        );
        locationLoading = false;

        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      showCustomSnackBar(
        context: context,
        backgroundColor: Colors.orange,
        message:
            'Location permissions are permanently denied, we cannot request permissions.',
      );
      locationLoading = false;

      return false;
    }
    return true;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        bottomPosition = -MediaQuery.sizeOf(context).height;
        if (selectedPosition != null) {
          newposition = selectedPosition!;
        }
      });
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
        // print(_topsearchfieldPosition);
        if (toptextfeildPosition == -300) {
          togglePosition(MediaQuery.sizeOf(context).height);
          // print(_topsearchfieldPosition);

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
                body: SafeArea(
                  child: Stack(
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
                              newposition = LatLng(position.target.latitude,
                                  position.target.longitude);
                              selectedPosition = newposition;
                            });
                            print(selectedPosition);
                            print(selectedPosition != null);
                          },
                          markers: selectedPosition != null
                              ? {
                                  Marker(
                                    markerId:
                                        MarkerId(selectedPosition.toString()),
                                    position: selectedPosition!,
                                    // icon: widget.type == 0 ? pickupicon : deliveryicon,
                                  )
                                }
                              : {},
                          onMapCreated: (controller) {
                            mapController = controller;
                          },
                          onCameraIdle: () {
                            setState(() {
                              selectedPosition = newposition;
                              bottomPathStatisticPosition = 0;
                            });
                          },
                          // myLocationEnabled: true,
                          compassEnabled: true,
                          rotateGesturesEnabled: false,
                          // mapType: controller.currentMapType,
                          mapToolbarEnabled: true,
                        ),
                      ),
                      Visibility(
                        visible: selectedPosition != null,
                        replacement: const SizedBox.shrink(),
                        child: AnimatedPositioned(
                          duration: const Duration(
                              milliseconds: 300), // Animation duration
                          curve: Curves.easeInOut,
                          bottom: bottomPathStatisticPosition,
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            // margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: BlocConsumer<CreateStoreBloc,
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
                                        isEnabled: selectedPosition != null,
                                        onTap: () {
                                          // Navigator.pop(context);
                                          showDialog<void>(
                                            context: context,
                                            barrierDismissible:
                                                false, // user must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: Text(AppLocalizations.of(
                                                        context)!
                                                    .translate('add_store')),
                                                content: SingleChildScrollView(
                                                  child: Form(
                                                    key: _addressformKey,
                                                    child: ListBody(
                                                      children: <Widget>[
                                                        const SectionBody(
                                                            text:
                                                                "الرجاء أدخل اسم المستودع"),
                                                        TextFormField(
                                                          controller:
                                                              storeAddressController,
                                                          onTap: () {
                                                            storeAddressController
                                                                    .selection =
                                                                TextSelection(
                                                                    baseOffset:
                                                                        0,
                                                                    extentOffset:
                                                                        storeAddressController
                                                                            .value
                                                                            .text
                                                                            .length);
                                                          },
                                                          style: TextStyle(
                                                              fontSize: 18.sp),
                                                          scrollPadding: EdgeInsets.only(
                                                              bottom: MediaQuery.of(
                                                                          context)
                                                                      .viewInsets
                                                                      .bottom +
                                                                  50),
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                'اسم المستودع',
                                                            hintStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        18.sp),
                                                          ),
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .translate(
                                                                      'insert_value_validate');
                                                            }
                                                            return null;
                                                          },
                                                          onSaved: (newValue) {
                                                            storeAddressController
                                                                    .text =
                                                                newValue!;
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text(AppLocalizations
                                                            .of(context)!
                                                        .translate('cancel')),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .translate('ok')),
                                                    onPressed: () {
                                                      if (_addressformKey
                                                          .currentState!
                                                          .validate()) {
                                                        _addressformKey
                                                            .currentState!
                                                            .save();
                                                        if (selectedPosition !=
                                                            null) {
                                                          Navigator.of(context)
                                                              .pop();
                                                          Stores store =
                                                              Stores();
                                                          store.address =
                                                              storeAddressController
                                                                  .text;
                                                          store.location =
                                                              "${selectedPosition!.latitude},${selectedPosition!.longitude}";
                                                          BlocProvider.of<
                                                                      CreateStoreBloc>(
                                                                  context)
                                                              .add(
                                                                  CreateStoreButtonPressed(
                                                                      store));
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        title: SizedBox(
                                          height: 30.h,
                                          width: 150.w,
                                          child: Center(
                                            child: SectionTitle(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .translate("confirm"),
                                              // color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
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
                        top: toptextfeildPosition,
                        onEnd: () {
                          // Trigger focus after the animation completes
                          // if (toptextfeildPosition == 0) {
                          //   WidgetsBinding.instance.addPostFrameCallback((_) {
                          //     _searchFocusNode.requestFocus();
                          //   });
                          // }
                        },
                        child: Container(
                          height: 70,
                          width: MediaQuery.sizeOf(context).width,
                          color: Colors.white,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Form(
                                  child: TextFormField(
                                    controller: _searchController,
                                    focusNode: _searchFocusNode,
                                    onChanged: (value) async {
                                      print(value);
                                      if (value.isNotEmpty) {
                                        final results =
                                            await PlaceService.getAutocomplete(
                                                value);

                                        setState(() {
                                          placesResult = List.from(
                                              results); // Assign a new list reference
                                        });
                                      }
                                    },
                                    onTap: () {
                                      setState(() {
                                        bottomPosition = 70;
                                      });
                                    },
                                    onTapOutside: (event) {
                                      setState(() {
                                        bottomPosition =
                                            -MediaQuery.sizeOf(context).height;
                                      });
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!
                                          .translate("search_location"),
                                      suffixIcon: locationLoading
                                          ? LoadingIndicator()
                                          : InkWell(
                                              onTap: () async {
                                                if (!locationLoading) {
                                                  setState(() {
                                                    locationLoading = true;
                                                  });
                                                  setState(() {
                                                    bottomPosition =
                                                        -MediaQuery.sizeOf(
                                                                context)
                                                            .height;
                                                  });

                                                  final hasPermission =
                                                      await _handleLocationPermission();

                                                  if (!hasPermission) {
                                                    locationLoading = false;
                                                    return;
                                                  }

                                                  await Geolocator
                                                          .getCurrentPosition(
                                                              desiredAccuracy:
                                                                  LocationAccuracy
                                                                      .high)
                                                      .then(
                                                          (Position position) {
                                                    setState(() {
                                                      selectedPosition = LatLng(
                                                          position.latitude,
                                                          position.longitude);
                                                      bottomPathStatisticPosition =
                                                          0;
                                                    });
                                                    mapController.animateCamera(
                                                      CameraUpdate
                                                          .newCameraPosition(
                                                        CameraPosition(
                                                            target:
                                                                selectedPosition!,
                                                            zoom: 11),
                                                      ),
                                                    );
                                                  }).catchError((e) {
                                                    setState(() {
                                                      locationLoading = false;
                                                    });
                                                  });
                                                  setState(() {
                                                    placesResult = [];
                                                    _searchController.text = "";
                                                    locationLoading = false;
                                                  });
                                                }
                                              },
                                              child: Icon(
                                                Icons.location_on,
                                                color: AppColor.deepYellow,
                                              ),
                                            ),
                                    ),
                                  ),
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
                        top: bottomPosition,
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
                          child: ListView.builder(
                            itemCount: placesResult.length,
                            itemBuilder: (context, index) => Container(
                              color: Colors.white,
                              child: LocationListTile(
                                location: placesResult[index].description,
                                onTap: () async {
                                  setState(() {
                                    locationLoading = true;
                                  });
                                  if (placesResult[index].description ==
                                      "اللاذقية، Syria") {
                                    setState(() {
                                      selectedPosition = LatLng(
                                        double.parse("35.525131"),
                                        double.parse("35.791570"),
                                      );
                                    });
                                  } else {
                                    var value = await PlaceService.getPlace(
                                        placesResult[index].placeId);
                                    setState(() {
                                      selectedPosition = LatLng(
                                        value.geometry.location.lat,
                                        value.geometry.location.lng,
                                      );
                                    });
                                  }

                                  setState(() {
                                    placesResult = [];
                                    _searchController.text = "";
                                    locationLoading = false;
                                    bottomPathStatisticPosition = 0;
                                  });
                                  mapController.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                          target: selectedPosition!, zoom: 11),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      // AnimatedPositioned(
                      //   duration: const Duration(
                      //       milliseconds: 300), // Animation duration
                      //   curve: Curves.easeInOut,
                      //   bottom: 20.h,
                      //   child: CustomButton(
                      //     onTap: () {
                      //       // toggleMapMode();

                      //       mapController.animateCamera(
                      //         CameraUpdate.newCameraPosition(
                      //           CameraPosition(
                      //               target: selectedPosition!, zoom: 11),
                      //         ),
                      //       );
                      //     },
                      //     title: SizedBox(
                      //       height: 50.h,
                      //       width: MediaQuery.sizeOf(context).width * .9,
                      //       child: Center(
                      //         child: SectionBody(
                      //           text: AppLocalizations.of(context)!
                      //               .translate("ok"),
                      //         ),
                      //       ),
                      //     ),
                      //     // isEnabled: selectedPosition != null,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
