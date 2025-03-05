import 'dart:convert';

import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/http_helper.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class MapService {
  static Future<Uint8List> createCustomMarker(String label) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    // Define marker size
    const double markerSize = 30.0; // Adjust size as needed

    // Draw yellow border
    paint.color = AppColor.deepYellow;
    canvas.drawCircle(
      const Offset(markerSize / 2, markerSize / 2),
      markerSize / 2,
      paint,
    );

    // Draw black inner circle
    paint.color = AppColor.deepBlack;
    canvas.drawCircle(
      const Offset(markerSize / 2, markerSize / 2),
      (markerSize / 2) - 2, // Adjust to accommodate border width
      paint,
    );

    // Draw label text
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 24, // Adjust font size as needed
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    final textOffset = Offset(
      (markerSize - textPainter.width) / 2,
      (markerSize - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);

    // Convert canvas to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(markerSize.toInt(), markerSize.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  static Future<Map<String, dynamic>?> fetchDistanceMatrix({
    required LatLng pickup,
    required LatLng delivery,
  }) async {
    try {
      final response = await HttpHelper.get(
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?destinations=${delivery.latitude},${delivery.longitude}'
        '&origins=${pickup.latitude},${pickup.longitude}'
        '&key=AIzaSyCl_H8BXqnTm32umdYVQrKMftTiFpRqd-c'
        '&mode=DRIVING',
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final element = result["rows"][0]['elements'][0];

        double? distance =
            double.tryParse(element['distance']['text'].replaceAll(" km", ""));
        String duration = element['duration']['text'];

        return {"distance": distance ?? 0.0, "duration": duration};
      }
    } catch (error) {
      print("Error fetching distance matrix: $error");
    }
    return null; // Return null on failure
  }

  /// Helper function to create a Marker from a comma-separated string location
  static Marker createMarker(String id, String location) {
    final parts = location.split(",");
    if (parts.length < 2) {
      throw Exception("Invalid location format for $id: $location");
    }

    return Marker(
      markerId: MarkerId(id),
      position: LatLng(double.parse(parts[0]), double.parse(parts[1])),
    );
  }

  static Future<Map<String, dynamic>?> fetchGeocodeData(LatLng position) async {
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // static Future<void> getCurrentPosition(Function(LatLng) onSuccess) async {
  //   // final hasPermission = await _handleLocationPermission();
  //   // if (!hasPermission) return;

  //   try {
  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);
  //     onSuccess(LatLng(position.latitude, position.longitude));
  //   } catch (e) {
  //     print("Error getting location: \$e");
  //   }
  // }

  static int parseDurationToMinutes(String duration) {
    final regex = RegExp(r'(\d+)\s*(days?|hours?|minutes?|mins?)');
    int totalMinutes = 0;

    for (final match in regex.allMatches(duration)) {
      final value = int.parse(match.group(1)!);
      final unit = match.group(2)!;

      if (unit.startsWith("day")) {
        totalMinutes += value * 24 * 60; // Convert days to minutes
      } else if (unit.startsWith("hour")) {
        totalMinutes += value * 60; // Convert hours to minutes
      } else if (unit.startsWith("minute") || unit.startsWith("min")) {
        totalMinutes += value; // Add minutes directly
      }
    }

    return totalMinutes;
  }

  static String formatMinutesToDuration(int totalMinutes) {
    final days = totalMinutes ~/ (24 * 60);
    final hours = (totalMinutes % (24 * 60)) ~/ 60;
    final minutes = totalMinutes % 60;

    List<String> parts = [];
    if (days > 0) parts.add("$days days");
    if (hours > 0) parts.add("$hours hours");
    if (minutes > 0) parts.add("$minutes minutes");

    return parts.isNotEmpty ? parts.join(" ") : "0 minutes";
  }
}
