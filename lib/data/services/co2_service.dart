import 'dart:convert';
import 'dart:io';

import 'package:camion/data/models/co2_report.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Co2Service {
  static Future<Co2Report?> getCo2Calculate(
      ShippmentDetail detail, LatLng origin, LatLng distination) async {
    var url = "https://api.freightos.com/api/v1/co2calc";
    var response = await http
        .post(Uri.parse(url), body: jsonEncode(detail.toJson()), headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      HttpHeaders.acceptHeader: 'application/json',
      'x-apikey': 'PAm7joXg4cr3oSZbbGnASvJuKudzkz76'
    });
    Co2Report? result;
    print(response.statusCode);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      print("co2");
      result = Co2Report.fromJson(res);
    }

    print(origin);
    print(distination);

    var distanceurl =
        "https://maps.googleapis.com/maps/api/distancematrix/json?origins=${origin.latitude}, ${origin.longitude}&destinations=${distination.latitude}, ${distination.longitude}&key=AIzaSyCl_H8BXqnTm32umdYVQrKMftTiFpRqd-c&mode=DRIVING&";
    var distanceresponse = await http.get(Uri.parse(distanceurl));
    DistanceReport? distanceresult;
    print(distanceresponse.statusCode);
    if (distanceresponse.statusCode == 200) {
      var res = jsonDecode(distanceresponse.body);
      distanceresult = DistanceReport.fromJson(res);
      print(distanceresponse.body);
      result!.distance = distanceresult!.rows![0].elements![0].distance!.text!;
      result!.duration = distanceresult!.rows![0].elements![0].duration!.text!;
    }

    return result;
  }

  static Future<Co2Report2?> getCo2Report(
      LatLng origin, LatLng distination) async {
    Co2Report2? result;

    var distanceurl =
        "https://maps.googleapis.com/maps/api/distancematrix/json?origins=${origin.latitude}, ${origin.longitude}&destinations=${distination.latitude}, ${distination.longitude}&key=AIzaSyCl_H8BXqnTm32umdYVQrKMftTiFpRqd-c&mode=DRIVING&";
    var distanceresponse = await http.get(Uri.parse(distanceurl));
    DistanceReport? distanceresult;
    if (distanceresponse.statusCode == 200) {
      var res = jsonDecode(distanceresponse.body);
      distanceresult = DistanceReport.fromJson(res);
      result!.distance = distanceresult!.rows![0].elements![0].distance!.text!;
      result.duration = distanceresult!.rows![0].elements![0].duration!.text!;
    }
    var emission = ((double.parse(result!.distance!) * 1700) / 1000000);
    result.et = emission;

    return result;
  }
}
