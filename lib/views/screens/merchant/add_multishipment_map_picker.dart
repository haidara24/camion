import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/data/providers/add_multi_shipment_provider.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:camion/views/widgets/custom_botton.dart';

class MultiShippmentPickUpMapScreen extends StatefulWidget {
  int type;
  // int index;
  LatLng? location;
  MultiShippmentPickUpMapScreen({Key? key, required this.type, this.location})
      : super(key: key);

  @override
  State<MultiShippmentPickUpMapScreen> createState() =>
      _MultiShippmentPickUpMapScreenState();
}

class _MultiShippmentPickUpMapScreenState
    extends State<MultiShippmentPickUpMapScreen> {
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(35.363149, 35.932120),
    zoom: 9,
  );
  Set<Marker> myMarker = {};
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    initlocation();
  }

  bool pickupLoading = false;
  bool deliveryLoading = false;
  AddMultiShipmentProvider? addShippmentProvider;

  LatLng? selectedPosition;
  late BitmapDescriptor pickupicon;
  late BitmapDescriptor deliveryicon;

  createMarkerIcons() async {
    pickupicon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(30, 50)),
        "assets/icons/location1.png");
    deliveryicon = await BitmapDescriptor.asset(
        const ImageConfiguration(), "assets/icons/location2.png");
    setState(() {});
  }

  initlocation() async {
    if (widget.location != null) {
      // Animate the camera to the provided location
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: widget.location!, zoom: 14.47),
        ),
      );

      // Add a marker at the provided location
      myMarker.add(
        Marker(
          markerId: MarkerId(widget.location.toString()),
          position: widget.location!,
          icon: widget.type == 0 ? pickupicon : deliveryicon,
        ),
      );

      // Update the state to display the marker on the map
      setState(() {});
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      addShippmentProvider =
          Provider.of<AddMultiShipmentProvider>(context, listen: false);
      createMarkerIcons().then((_) => initlocation());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate("pick_location"),
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
                      myMarker = {};
                      myMarker.add(
                        Marker(
                          markerId: MarkerId(widget.location.toString()),
                          position: widget.location!,
                          icon: widget.type == 0 ? pickupicon : deliveryicon,
                        ),
                      );
                      var newposition = LatLng(
                          position.target.latitude, position.target.longitude);
                      myMarker.add(Marker(
                          markerId: MarkerId(newposition.toString()),
                          position: newposition,
                          icon: widget.type == 0 ? pickupicon : deliveryicon));
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
                              }
                            },
                            title: SizedBox(
                              height: 50.h,
                              width: 150.w,
                              child: Center(
                                child: SectionBody(
                                  text: AppLocalizations.of(context)!
                                      .translate("confirm"),
                                ),
                              ),
                            ),
                          ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
