import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMapDetailScreen extends StatefulWidget {
  final LatLng location;
  LocationMapDetailScreen({
    super.key,
    required this.location,
  });

  @override
  State<LocationMapDetailScreen> createState() =>
      _LocationMapDetailScreenState();
}

class _LocationMapDetailScreenState extends State<LocationMapDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
            title: "${widget.location.latitude},${widget.location.longitude}"),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.location,
            zoom: 11,
          ),
          myLocationButtonEnabled: false,
          markers: {
            Marker(
              markerId: const MarkerId('location'),
              position: widget.location,
            ),
          },
        ),
      ),
    );
  }
}
