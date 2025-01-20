import 'dart:convert';

import 'package:camion/data/models/core_model.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TruckPriceRepository {
  late SharedPreferences prefs;
  List<TruckPrice> truckPrices = [];

  Future<TruckPrice?> createTruckPrice(
    Map<String, dynamic> price,
  ) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var truckId = prefs.getInt("truckId") ?? 0;

    Response response = await HttpHelper.post(
        TRUCK_PRICES_ENDPOINT,
        {
          "truck": truckId,
          "value": price['value'],
          "point1": price['point1'],
          "point2": price['point2'],
        },
        apiToken: token);
    if (response.statusCode == 201) {
      var myDataString = utf8.decode(response.bodyBytes);

      var result = jsonDecode(myDataString);
      return TruckPrice.fromJson(result);
    } else {
      return null;
    }
  }

  Future<List<TruckPrice>> getPrices() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(TRUCK_PRICES_ENDPOINT, apiToken: jwt);
    truckPrices = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        truckPrices.add(TruckPrice.fromJson(element));
      }
    }
    return truckPrices;
  }
}
