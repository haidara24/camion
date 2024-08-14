import 'dart:convert';
import 'dart:io';

import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/providers/user_provider.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  late SharedPreferences prefs;
  late UserProvider userProvider;

  AuthRepository(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  Future<dynamic> loginWithPhone({required String phone}) async {
    try {
      String? firebaseToken = "";
      FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      firebaseToken = await messaging.getToken();
      var prefs = await SharedPreferences.getInstance();
      var userType = prefs.getString("userType") ?? "";
      var newPhone = "963" + phone.substring(1);
      print(newPhone);
      Response response = await post(Uri.parse(PHONE_LOGIN_ENDPOINT),
          body: jsonEncode({
            "phone": newPhone,
            "role": userType,
            "fcm_token": firebaseToken
          }),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
            HttpHeaders.acceptHeader: 'application/json'
          });
      print(response.body);
      final Map<String, dynamic> data = <String, dynamic>{};
      data["status"] = response.statusCode;
      var jsonObject = jsonDecode(response.body);

      if (data["status"] == 200) {
        data["details"] = jsonObject["details"];
        data["success"] = jsonObject["isSuccess"];
        data["isLogin"] = jsonObject["isLogin"];
        prefs.setBool("isLogin", data["isLogin"]);
      } else {
        data["details"] = jsonObject["details"];
        data["success"] = jsonObject["isSuccess"];
      }
      return data;
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<dynamic> verifyOtp({required String otp}) async {
    try {
      Response response = await post(Uri.parse(VERIFY_OTP_ENDPOINT),
          body: jsonEncode({"otp": otp}),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
            HttpHeaders.acceptHeader: 'application/json'
          });
      final Map<String, dynamic> data = <String, dynamic>{};
      data["status"] = response.statusCode;
      var jsonObject = jsonDecode(response.body);
      print(response.statusCode);

      if (response.statusCode == 401 || response.statusCode == 400) {
        data["details"] = jsonObject["details"];
      } else {
        presisteToken(jsonObject);

        data["token"] = jsonObject["access"];
        prefs = await SharedPreferences.getInstance();

        var userType = prefs.getString("userType") ?? "";
        bool isLogin = prefs.getBool("isLogin") ?? false;
        Response userresponse =
            await HttpHelper.get(PROFILE_ENDPOINT, apiToken: data["token"]);
        if (userresponse.statusCode == 200) {
          if (userType.isNotEmpty) {
            var myDataString = utf8.decode(userresponse.bodyBytes);

            prefs.setString("userProfile", myDataString);
            print("userProfile${myDataString}");
            var result = jsonDecode(myDataString);
            var userProfile = UserModel.fromJson(result);
            if (userProfile.merchant != null) {
              prefs.setInt("merchant", userProfile.merchant!);
              Response merchantResponse = await HttpHelper.get(
                  '$MERCHANTS_ENDPOINT${userProfile.merchant}/',
                  apiToken: data["token"]);
              if (merchantResponse.statusCode == 200) {
                var merchantDataString =
                    utf8.decode(merchantResponse.bodyBytes);
                var res = jsonDecode(merchantDataString);
                userProvider.setMerchant(Merchant.fromJson(res));
              }
            }
            if (userProfile.truckowner != null) {
              prefs.setInt("truckowner", userProfile.truckowner!);
              Response ownerResponse = await HttpHelper.get(
                  '$OWNERS_ENDPOINT${userProfile.truckowner}/',
                  apiToken: data["token"]);
              if (ownerResponse.statusCode == 200) {
                var ownerDataString = utf8.decode(ownerResponse.bodyBytes);
                var res = jsonDecode(ownerDataString);
                userProvider.setTruckOwner(TruckOwner.fromJson(res));
              }
            }
            if (userProfile.truckuser != null) {
              prefs.setInt("truckuser", userProfile.truckuser!);
              Response driverResponse = await HttpHelper.get(
                  '$DRIVERS_ENDPOINT${userProfile.truckuser}/',
                  apiToken: data["token"]);
              if (driverResponse.statusCode == 200) {
                var driverDataString = utf8.decode(driverResponse.bodyBytes);
                var res = jsonDecode(driverDataString);
                userProvider.setDriver(Driver.fromJson(res));
                if (isLogin) {
                  prefs.setInt("truckId", res['truck2']["id"]);
                  prefs.setString("gpsId", res['truck2']["gpsId"]);
                }
              }
            }
          }
        }
      }
      return data;
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<dynamic> resendOtp({required String phone}) async {
    try {
      Response response =
          await HttpHelper.post(RESEND_OTP_ENDPOINT, {"phone": phone});
      final Map<String, dynamic> data = <String, dynamic>{};
      data["status"] = response.statusCode;
      var jsonObject = jsonDecode(response.body);
      print(response.statusCode);

      if (response.statusCode == 401 || response.statusCode == 400) {
        data["details"] = jsonObject["details"];
      } else {
        data["details"] = jsonObject["details"];
      }
      return data;
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<dynamic> login(
      {required String username, required String password}) async {
    try {
      String? firebaseToken = "";
      FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      firebaseToken = await messaging.getToken();

      Response response = await HttpHelper.post(LOGIN_ENDPOINT, {
        "username": username,
        "password": password,
        "fcm_token": firebaseToken
      });
      final Map<String, dynamic> data = <String, dynamic>{};
      data["status"] = response.statusCode;
      var jsonObject = jsonDecode(response.body);
      print(response.statusCode);

      if (response.statusCode == 401 || response.statusCode == 400) {
        data["details"] = jsonObject["detail"];
      } else {
        presisteToken(jsonObject);

        data["token"] = jsonObject["access"];
      }
      return data;
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<String> get jwtOrEmpty async {
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    if (jwt == null) return "";
    return jwt;
  }

  Future<bool> isAuthenticated() async {
    final LocaleCubit localeCubit = LocaleCubit();
    await localeCubit.initializeFromPreferences();
    var token = await jwtOrEmpty;

    if (token != "") {
      if (JwtDecoder.isExpired(token)) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  Future<void> presisteToken(dynamic data) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("token", data["access"]);
    prefs.setString("refresh", data["refresh"]);
  }

  Future<void> logout() async {
    var prefs = await SharedPreferences.getInstance();
    String? firebaseToken = "";
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    firebaseToken = await messaging.getToken();

    var refreshToken = prefs.getString("refresh");
    var jwt = prefs.getString("token");

    final response = await HttpHelper.post(
        LOGOUT_ENDPOINT, {'refresh': refreshToken, 'fcm_token': firebaseToken},
        apiToken: jwt);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 204) {
      // Logout successful
      prefs.clear();
    } else {
      // Handle error
      print('Logout failed with status: ${response.statusCode}');
    }
  }

  Future<void> deleteToken() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("refresh");
    prefs.remove("userType");
    // prefs.clear();
  }
}
