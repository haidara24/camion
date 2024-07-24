import 'package:camion/data/providers/add_shippment_provider.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:camion/views/widgets/custom_botton.dart';

class ShippmentPickUpMapScreen extends StatefulWidget {
  int type;
  int? index;
  LatLng? location;
  ShippmentPickUpMapScreen(
      {Key? key, required this.type, this.index, this.location})
      : super(key: key);

  @override
  State<ShippmentPickUpMapScreen> createState() =>
      _ShippmentPickUpMapScreenState();
}

class _ShippmentPickUpMapScreenState extends State<ShippmentPickUpMapScreen> {
  static CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(35.363149, 35.932120),
    zoom: 9,
  );
  Set<Marker> myMarker = new Set();
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    initlocation();
  }

  bool pickupLoading = false;
  bool deliveryLoading = false;
  AddShippmentProvider? addShippmentProvider;

  LatLng? selectedPosition;
  late BitmapDescriptor pickupicon;
  late BitmapDescriptor deliveryicon;

  createMarkerIcons() async {
    pickupicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(30, 50)),
        "assets/icons/location1.png");
    deliveryicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location2.png");
    setState(() {});
  }

  initlocation() async {
    if (widget.location != null) {
      await mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: widget.location!, zoom: 14.47)));
    }
  }

  @override
  void initState() {
    print(widget.location);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      addShippmentProvider =
          Provider.of<AddShippmentProvider>(context, listen: false);
      addShippmentProvider!.initMapbounds();
      createMarkerIcons();
      // initlocation();
    });
    super.initState();
  }

  // bool evaluateCo2() {
  //   if (addShippmentProvider!.delivery_location_name.isNotEmpty &&
  //       addShippmentProvider!.pickup_location_name.isNotEmpty) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  // void calculateCo2Report() {
  //   ShippmentDetail detail = ShippmentDetail();
  //   detail.legs = [];
  //   detail.load = [];
  //   Legs leg = Legs();
  //   leg.mode = "LTL";
  //   print("report!.title!");
  //   Origin origin = Origin();
  //   leg.origin = origin;
  //   Origin destination = Origin();
  //   leg.destination = destination;

  //   leg.origin!.latitude = addShippmentProvider!.pickup_lat;
  //   leg.origin!.longitude = addShippmentProvider!.pickup_lang;
  //   leg.destination!.latitude = addShippmentProvider!.delivery_lat;
  //   leg.destination!.longitude = addShippmentProvider!.delivery_lang;

  //   detail.legs!.add(leg);

  //   // for (var i = 0; i < commodityWeight_controllers.length; i++) {
  //   // }
  //   Load load = Load();
  //   load.unitWeightKg = 25000;
  //   load.unitType = "pallets";
  //   detail.load!.add(load);

  //   // for (var i = 0; i < commodityWeight_controllers.length; i++) {
  //   //   Load load = Load();
  //   //   load.unitWeightKg =
  //   //       double.parse(commodityWeight_controllers[i].text.replaceAll(",", ""));
  //   //   load.unitType = "pallets";
  //   //   detail.load!.add(load);
  //   // }

  //   Co2Service.getCo2Calculate(
  //           detail,
  //           LatLng(addShippmentProvider!.pickup_lat,
  //               addShippmentProvider!.pickup_lang),
  //           LatLng(addShippmentProvider!.delivery_lat,
  //               addShippmentProvider!.delivery_lang))
  //       .then((value) => addShippmentProvider!.setCo2Report(value!));

  //   print("calculation end");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pick Location",
          style: TextStyle(
            // color: AppColor.lightBlue,
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  zoomControlsEnabled: false,

                  onCameraMove: (position) {
                    setState(() {
                      selectedPosition = LatLng(
                          position.target.latitude, position.target.longitude);
                      myMarker = new Set();
                      var newposition = LatLng(
                          position.target.latitude, position.target.longitude);
                      myMarker.add(Marker(
                          markerId: MarkerId(newposition.toString()),
                          position: newposition,
                          icon: widget.type == 0 ? pickupicon : deliveryicon));
                    });
                    // Get.find<PropertyController>()
                    //     .setCurrentPosition(position);
                  },
                  markers: myMarker,
                  myLocationEnabled: true,
                  onMapCreated: _onMapCreated,
                  compassEnabled: true,
                  rotateGesturesEnabled: false,
                  // mapType: controller.currentMapType,
                  mapToolbarEnabled: true,
                ),
                // const Icon(
                //   Icons.location_pin,
                //   size: 45,
                //   color: Colors.red,
                // )
              ],
            ),
            selectedPosition != null
                ? Positioned(
                    bottom: 25.h,
                    child: pickupLoading
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
                        : CustomButton(
                            onTap: () {
                              setState(() {
                                pickupLoading = true;
                              });
                              if (widget.type == 0) {
                                addShippmentProvider!
                                    .getAddressForPickupFromMapPicker(
                                      LatLng(selectedPosition!.latitude,
                                          selectedPosition!.longitude),
                                    )
                                    .then((value) => Navigator.pop(context));
                              } else if (widget.type == 1) {
                                addShippmentProvider!
                                    .getAddressForDeliveryFromMapPicker(
                                      LatLng(selectedPosition!.latitude,
                                          selectedPosition!.longitude),
                                    )
                                    .then((value) => Navigator.pop(context));
                              } else if (widget.type == 2) {
                                addShippmentProvider!
                                    .getAddressForStopPointFromMapPicker(
                                        LatLng(selectedPosition!.latitude,
                                            selectedPosition!.longitude),
                                        widget.index!)
                                    .then((value) => Navigator.pop(context));
                              }
                            },
                            title: Container(
                              height: 50.h,
                              width: 150.w,
                              child: const Center(
                                child: Text(
                                  "confirm",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  )
                : const SizedBox.shrink(),
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
    );
  }
}
