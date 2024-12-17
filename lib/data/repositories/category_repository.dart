import 'dart:convert';

import 'package:camion/data/models/commodity_category_model.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryRepository {
  late SharedPreferences prefs;
  List<SimpleCategory> simpleCategories = [];

  Future<List<SimpleCategory>> getCommodityCategories() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(
        "${COMMODITY_CATEGORIES_ENDPOINT}get_simple_categories/",
        apiToken: jwt);
    simpleCategories = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        simpleCategories.add(SimpleCategory.fromJson(element));
      }
    }
    return simpleCategories;
  }
}
