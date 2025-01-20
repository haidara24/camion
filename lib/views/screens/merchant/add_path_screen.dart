import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/data/providers/add_multi_shipment_provider.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:camion/views/widgets/custom_botton.dart';

class AddPathScreen extends StatefulWidget {
  AddPathScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AddPathScreen> createState() => _AddPathScreenState();
}

class _AddPathScreenState extends State<AddPathScreen> {
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(35.363149, 35.932120),
    zoom: 9,
  );
  Set<Marker> myMarker = {};
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // initlocation();
  }

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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      addShippmentProvider =
          Provider.of<AddMultiShipmentProvider>(context, listen: false);
      //   createMarkerIcons().then((_) => initlocation());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate("choose_shippment_path"),
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
            GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              zoomControlsEnabled: false,

              onCameraMove: (position) {
                setState(() {
                  selectedPosition = LatLng(
                      position.target.latitude, position.target.longitude);
                  myMarker = {};
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
      ),
    );
  }
}
