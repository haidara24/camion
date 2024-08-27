import 'dart:convert';
import 'dart:io';

import 'package:camion/data/models/user_model.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
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

  Future<TruckOwner?> getOwner(int id) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get('$OWNERS_ENDPOINT$id/', apiToken: jwt);
    print(rs.statusCode);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      return TruckOwner.fromJson(result);
    }
    return null;
  }

  Future<Driver?> getDriver(int id) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get('$DRIVERS_ENDPOINT$id/', apiToken: jwt);
    print(rs.statusCode);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      return Driver.fromJson(result);
    }
    return null;
  }

  Future<int?> updateDriver(Driver driver, File? file) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var driverId = prefs.getInt("truckuser");

    var request = http.MultipartRequest('PATCH',
        Uri.parse('$DRIVERS_ENDPOINT${driverId ?? driver.id}/update_profile/'));
    request.headers.addAll({
      HttpHeaders.authorizationHeader: "JWT $jwt",
      HttpHeaders.contentTypeHeader: "multipart/form-data"
    });

    if (file != null) {
      final uploadImages = await http.MultipartFile.fromPath(
        'files',
        file.path,
        filename: file.path.split('/').last,
      );

      request.files.add(uploadImages);
    }

    request.fields['user'] = jsonEncode({
      "first_name": driver.user!.firstName,
      "last_name": driver.user!.lastName,
      "email": driver.user!.email
    });

    var rs = await request.send();
    print('$DRIVERS_ENDPOINT${driverId ?? driver.id}/update_profile/');
    print(rs.statusCode);
    if (rs.statusCode == 200) {
      final respStr = await rs.stream.bytesToString();

      var result = jsonDecode(respStr);

      return result['id'];
    }
    return null;
  }

  Future<Merchant?> updateMerchant(Merchant merchant, File? file) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var merchantId = prefs.getInt("merchant");
    var request = http.MultipartRequest(
        'PATCH', Uri.parse('$MERCHANTS_ENDPOINT$merchantId/update_profile/'));
    request.headers.addAll({
      HttpHeaders.authorizationHeader: "JWT $jwt",
      HttpHeaders.contentTypeHeader: "multipart/form-data"
    });

    if (file != null) {
      final uploadImages = await http.MultipartFile.fromPath(
        'files',
        file.path,
        filename: file.path.split('/').last,
      );

      request.files.add(uploadImages);
    }

    request.fields['user'] = jsonEncode({
      "first_name": merchant.user!.firstName,
      "last_name": merchant.user!.lastName,
      "email": merchant.user!.email
    });
    // request.fields['user[first_name]'] = merchant.user!.firstName!;
    // request.fields['user[last_name]'] = merchant.user!.lastName!;
    // request.fields['user[email]'] = merchant.user!.email!;
    request.fields['address'] = merchant.address!;
    request.fields['company_name'] = merchant.companyName!;

    var rs = await request.send();
    print(merchantId);
    print(rs.statusCode);
    if (rs.statusCode == 200) {
      final respStr = await rs.stream.bytesToString();

      var result = jsonDecode(respStr);
      return Merchant.fromJson(result);
    }
    return null;
  }

  Future<TruckOwner?> updateOwner(TruckOwner owner, File? file) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var ownerId = prefs.getInt("truckowner");

    var request = http.MultipartRequest('PATCH',
        Uri.parse('$OWNERS_ENDPOINT${ownerId ?? owner.id}/update_profile/'));
    request.headers.addAll({
      HttpHeaders.authorizationHeader: "JWT $jwt",
      HttpHeaders.contentTypeHeader: "multipart/form-data"
    });

    if (file != null) {
      final uploadImages = await http.MultipartFile.fromPath(
        'files',
        file.path,
        filename: file.path.split('/').last,
      );

      request.files.add(uploadImages);
    }

    request.fields['user'] = jsonEncode({
      "first_name": owner.user!.firstName,
      "last_name": owner.user!.lastName,
      "email": owner.user!.email
    });

    var rs = await request.send();
    print(rs.statusCode);

    if (rs.statusCode == 200) {
      final respStr = await rs.stream.bytesToString();

      var result = jsonDecode(respStr);
      return TruckOwner.fromJson(result);
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
}
