import 'dart:convert';
import 'dart:io';

import 'package:camion/helpers/http_helper.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GpsRepository {
  late SharedPreferences prefs;

  static Future<void> getTokenForGps() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      Response response = await get(Uri.parse(GPS_LOGIN), headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.acceptHeader: 'application/json'
      });
      print(response.statusCode);

      if (response.statusCode == 200) {
        var jsonObject = jsonDecode(response.body);
        var token = jsonObject['data']['token'];
        prefs.setString("gpsToken", token);
      }
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> getCarInfo(String imei) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("gpsToken");
      Response response =
          await get(Uri.parse("$GPS_CARINFO$token&imei=$imei"), headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.acceptHeader: 'application/json'
      });
      print(response.body);

      if (response.statusCode == 200) {
        var jsonObject = jsonDecode(response.body);
        return jsonObject['data'];
      }
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());
    }
  }
}
