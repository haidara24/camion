import 'dart:convert';
import 'dart:io';

import 'package:camion/helpers/http_helper.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
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
print("gps response ${response.statusCode}");
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

      if (response.statusCode == 200) {
        var jsonObject = jsonDecode(response.body);
        var data = jsonObject['data'];
        if (data != null) {
          // Extract required fields
          int carId = data['carId'] ?? 0;
          int online = data['carStatus']['online'];
          double speed = (data['carStatus']['speed'] as num).toDouble();

          // Store these values in SharedPreferences
          await prefs.setInt('carId', carId);
          await prefs.setInt('online', online);
          await prefs.setDouble('speed', speed);

          return data;
        }
      }
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> getStatisticsData({
    required int carId,
    required String startTime,
    required String endTime,
  }) async {
    const url = "https://www.whatsgps.com/position/mileageStaData.do";
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("gpsToken") ?? "";
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Adding form data
      request.fields['carId'] = carId.toString();
      request.fields['startTime'] = startTime;
      request.fields['endTime'] = endTime;
      request.fields['token'] = token;

      // Adding headers
      request.headers.addAll({
        HttpHeaders.contentTypeHeader: 'multipart/form-data',
        HttpHeaders.acceptHeader: 'application/json',
      });

      // Sending the request
      var streamedResponse = await request.send();
      print(streamedResponse.statusCode);
      // Handling the response
      if (streamedResponse.statusCode == 200) {
        var response = await http.Response.fromStream(streamedResponse);
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['ret'] == 1) {
          // Extracting the required data
          var data = jsonResponse['data'];
          return {
            'fuelConsumptionSum': data['fuelConsumptionSum'],
            'overSpeeds': data['overSpeeds'],
            'stops': data['stops'],
            'totalMileage': data['totalMileage'],
            'totalMileageMeter': data['totalMileageMeter'],
          };
        } else {
          throw Exception("Invalid response: ${jsonResponse['ret']}");
        }
      } else {
        throw Exception(
            "Failed to fetch data. Status code: ${streamedResponse.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error fetching mileage data: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getTruckMileageDetailsPerDay({
    required int carId,
    required String startTime,
    required String endTime,
  }) async {
    const url = "https://www.whatsgps.com/position/mileageStaByDay.do";
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("gpsToken") ?? "";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Adding form data
      request.fields['carId'] = carId.toString();
      request.fields['startTime'] = startTime;
      request.fields['endTime'] = endTime;
      request.fields['token'] = token;

      // Adding headers
      request.headers.addAll({
        HttpHeaders.contentTypeHeader: 'multipart/form-data',
        HttpHeaders.acceptHeader: 'application/json',
      });

      // Sending the request
      var streamedResponse = await request.send();

      // Handling the response
      if (streamedResponse.statusCode == 200) {
        var response = await http.Response.fromStream(streamedResponse);
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['ret'] == 1) {
          // Extracting the 'data' array
          List<dynamic> data = jsonResponse['data'];
          return data
              .map((item) => {
                    'day': item['day'],
                    'mileage': item['mileage'],
                    'overSpeedCount': item['overSpeedCount'],
                    'overSpeedValue': item['overSpeedValue'],
                    'stopCount': item['stopCount'],
                  })
              .toList();
        } else {
          throw Exception("Invalid response: ${jsonResponse['ret']}");
        }
      } else {
        throw Exception(
            "Failed to fetch data. Status code: ${streamedResponse.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error fetching truck mileage details: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getOverSpeedReport({
    required int carId,
    required String startTime,
    required String endTime,
  }) async {
    const url = "https://www.whatsgps.com/position/getOverSpeedDetail.do";
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("gpsToken") ?? "";
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Adding form data
      request.fields['carId'] = carId.toString();
      request.fields['startTime'] = startTime;
      request.fields['endTime'] = endTime;
      request.fields['token'] = token;

      // Adding headers
      request.headers.addAll({
        HttpHeaders.contentTypeHeader: 'multipart/form-data',
        HttpHeaders.acceptHeader: 'application/json',
      });

      // Sending the request
      var streamedResponse = await request.send();

      // Handling the response
      if (streamedResponse.statusCode == 200) {
        var response = await http.Response.fromStream(streamedResponse);
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['ret'] == 1) {
          // Extracting the 'data' array
          List<dynamic> data = jsonResponse['data'];
          return data
              .map((item) => {
                    'isStop': item['isStop'],
                    'lat': item['lat'],
                    'lon': item['lon'],
                    'pointDt': item['pointDt'],
                    'speed': item['speed']
                  })
              .toList();
        } else {
          throw Exception("Invalid response: ${jsonResponse['ret']}");
        }
      } else {
        throw Exception(
            "Failed to fetch data. Status code: ${streamedResponse.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error fetching overspeed report: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getStopDetails({
    required int carId,
    required String startTime,
    required String endTime,
  }) async {
    const url = "https://www.whatsgps.com/position/getStopDetail.do";
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("gpsToken") ?? "";
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Adding form data
      request.fields['carId'] = carId.toString();
      request.fields['startTime'] = startTime;
      request.fields['endTime'] = endTime;
      request.fields['token'] = token;

      // Adding headers
      request.headers.addAll({
        HttpHeaders.contentTypeHeader: 'multipart/form-data',
        HttpHeaders.acceptHeader: 'application/json',
      });

      // Sending the request
      var streamedResponse = await request.send();

      // Handling the response
      if (streamedResponse.statusCode == 200) {
        var response = await http.Response.fromStream(streamedResponse);
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['ret'] == 1) {
          // Extracting the 'data' array
          List<dynamic> data = jsonResponse['data'];
          return data
              .map((item) => {
                    'startTime': item['startTime'],
                    'endTime': item['endTime'],
                    'lat': item['lat'],
                    'lon': item['lon'],
                    'latc': item['latc'],
                    'lonc': item['lonc'],
                    'stopTime': item['stopTime'],
                  })
              .toList();
        } else {
          throw Exception("Invalid response: ${jsonResponse['ret']}");
        }
      } else {
        throw Exception(
            "Failed to fetch data. Status code: ${streamedResponse.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error fetching stop details: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getDistanceDetails({
    required int carId,
    required String startTime,
    required String endTime,
  }) async {
    const url = "https://www.whatsgps.com/position/distanceSta.do";
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("gpsToken") ?? "";
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add form data
      request.fields['carId'] = carId.toString();
      request.fields['startTime'] = startTime;
      request.fields['endTime'] = endTime;
      request.fields['token'] = token;

      // Add headers
      request.headers.addAll({
        HttpHeaders.contentTypeHeader: 'multipart/form-data',
        HttpHeaders.acceptHeader: 'application/json',
      });

      // Send request
      var streamedResponse = await request.send();

      // Process response
      if (streamedResponse.statusCode == 200) {
        var response = await http.Response.fromStream(streamedResponse);
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['ret'] == 1) {
          // Extract the 'data' array
          List<dynamic> data = jsonResponse['data'];
          return data
              .map((item) => {
                    'averageSpeed': item['averageSpeed'],
                    'maxSpeed': item['maxSpeed'],
                    'mileage': item['mileage'],
                    'startTime': item['startTime'],
                    'endTime': item['endTime'],
                    'startLat': item['startLat'],
                    'startLon': item['startLon'],
                    'endLat': item['endLat'],
                    'endLon': item['endLon'],
                  })
              .toList();
        } else {
          throw Exception("Invalid response: ${jsonResponse['ret']}");
        }
      } else {
        throw Exception(
            "Failed to fetch data. Status code: ${streamedResponse.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error fetching distance details: $e");
    }
  }
}
