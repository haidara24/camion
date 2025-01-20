import 'dart:convert';

import 'package:camion/data/models/core_model.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoreRepository {
  late SharedPreferences prefs;
  List<Governorate> governorates = [];

  Future<List<Governorate>> getGovernorates() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(GOVERNORATES_ENDPOINT, apiToken: jwt);
    governorates = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        governorates.add(Governorate.fromJson(element));
      }
    }
    return governorates;
  }
}
