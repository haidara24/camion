import 'dart:convert';

import 'package:camion/data/models/user_model.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreRepository {
  late SharedPreferences prefs;
  List<Stores> stores = [];

  Future<Stores?> createStore(
    Stores store,
  ) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var merchant = prefs.getInt("merchant") ?? 0;

    Response response = await HttpHelper.post(
        STORES_ENDPOINT,
        {
          "address": store.address,
          "location": store.location,
          "merchant": merchant
        },
        apiToken: token);
    if (response.statusCode == 201) {
      var myDataString = utf8.decode(response.bodyBytes);

      var result = jsonDecode(myDataString);
      return Stores.fromJson(result);
    } else {
      return null;
    }
  }

  Future<List<Stores>> getStoress() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var merchant = prefs.getInt("merchant") ?? 0;
    var rs = await HttpHelper.get("$STORES_ENDPOINT?merchant=$merchant",
        apiToken: jwt);
    stores = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        stores.add(Stores.fromJson(element));
      }
    }
    return stores;
  }
}
