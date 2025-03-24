import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/profile/create_store_bloc.dart';
import 'package:camion/business_logic/bloc/profile/merchant_profile_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
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

class _AddStoreHouseScreenState extends State<AddStoreHouseScreen> {
  Set<Marker> myMarker = new Set();

  late GoogleMapController mapController;
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(35.363149, 35.932120),
    zoom: 9,
  );

  TextEditingController storeAddressController = TextEditingController();

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

  // initlocation() async {
  //   if (widget.location != null) {
  //     await mapController.animateCamera(CameraUpdate.newCameraPosition(
  //         CameraPosition(target: widget.location!, zoom: 14.47)));
  //   }
  // }

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
    return BlocBuilder<LocaleCubit, LocaleState>(
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
                  GoogleMap(
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
                              icon: storeicon),
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
                  selectedPosition != null
                      ? Positioned(
                          bottom: 25.h,
                          child: storeLoading
                              ? Container(
                                  height: 50.h,
                                  width: 150.w,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Center(
                                    child: LoadingIndicator(),
                                  ),
                                )
                              : BlocConsumer<CreateStoreBloc, CreateStoreState>(
                                  listener: (context, state) {
                                    if (state is CreateStoreLoadedSuccess) {
                                      BlocProvider.of<MerchantProfileBloc>(
                                              context)
                                          .add(MerchantProfileLoad(
                                              state.store.merchant!));
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
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: storeAddressController,
                          decoration: InputDecoration(
                            filled: true,
                            hintText: AppLocalizations.of(context)!
                                .translate("enter_store_address"),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 25.h,
                    left: 20.w,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // FloatingActionButton(
                        //   foregroundColor: Colors.black,
                        //   onPressed: () {
                        //     controller.gotolocation();
                        //   },
                        //   child: const Icon(Icons.center_focus_strong),
                        // ),
                        // const SizedBox(
                        //   height: 10,
                        // ),
                        // FloatingActionButton(
                        //   tooltip: "تغيير نمط الخريطة",
                        //   foregroundColor: Colors.black,
                        //   onPressed: () => controller.changeMapType(),
                        //   child: controller.currentMapType == MapType.normal
                        //       ? Image.asset("assets/icons/sattalite_map.png")
                        //       : Image.asset("assets/icons/normal_map.png"),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
