import 'dart:convert';

import 'package:camion/data/models/notification_model.dart';
// import 'package:camion/data/models/offer_model.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepository {
  late SharedPreferences prefs;

  List<NotificationModel> notifications = [];

  Future<List<NotificationModel>> getNotification() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(NOTIFICATIONS_ENDPOINT, apiToken: jwt);
    notifications = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        notifications.add(NotificationModel.fromJson(element));
      }
    }
    return notifications.reversed.toList();
  }

  Future<bool> readNotification(int id) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.patch(
      NOTIFICATIONS_ENDPOINT + id.toString(),
      {"isread": true},
      apiToken: jwt,
    );
    if (rs.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // Future<Offer?> getOfferInfo(int id) async {
  //   prefs = await SharedPreferences.getInstance();
  //   var jwt = prefs.getString("token");

  //   var rs = await HttpHelper.get(
  //     OFFERS_ENDPOINT + id.toString(),
  //     apiToken: jwt,
  //   );
  //   var myDataString = utf8.decode(rs.bodyBytes);
  //   var json = jsonDecode(myDataString);
  //   if (rs.statusCode == 200) {
  //     return Offer.fromJson(json);
  //   } else {
  //     return null;
  //   }
  // }
}
