import 'dart:convert';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:http/http.dart' as http;

class UserService {
  static Future<List<TruckOwner>> searchTruckOwners(String query) async {
    List<TruckOwner> list = [];
    final url = Uri.parse('${OWNERS_ENDPOINT}search/?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var myDataString = utf8.decode(response.bodyBytes);

      final List truckOwners = jsonDecode(myDataString);
      for (var element in truckOwners) {
        list.add(TruckOwner.fromJson(element));
      }
      return list;
    } else {
      throw Exception('Failed to load truck owners');
    }
  }

  static Future<void> resendOtp(String phone) async {
    var newPhone = "963" + phone.substring(1);

    final response =
        await HttpHelper.post(RESEND_OTP_ENDPOINT, {"phone": newPhone});
  }
}
