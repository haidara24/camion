import 'dart:convert';

import 'package:camion/data/models/user_model.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  late SharedPreferences prefs;

  Future<Merchant?> getMerchant(int id) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get('$MERCHANTS_ENDPOINT$id/', apiToken: jwt);
    print(rs.statusCode);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      return Merchant.fromJson(result);
    }
    return null;
  }

  Future<Merchant?> updateMerchant(Merchant merchant) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.patch(
        '$MERCHANTS_ENDPOINT${merchant.id}/update_profile/',
        {
          "address": merchant.address,
          "company_name": merchant.companyName,
          "user": {"email": merchant.user!.email, "phone": merchant.user!.phone}
        },
        apiToken: jwt);

    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      return Merchant.fromJson(result);
    }
    return null;
  }

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

  Future<Merchant?> getDriver(int id) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get('$MERCHANTS_ENDPOINT$id/', apiToken: jwt);

    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      return Merchant.fromJson(result);
    }
    return null;
  }
}
