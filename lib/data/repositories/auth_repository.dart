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
        sound: true,
      );
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      firebaseToken = await messaging.getToken();
      var prefs = await SharedPreferences.getInstance();
      var userType = prefs.getString("userType") ?? "";
      print(userType);
      var newPhone = "00963${phone.substring(1)}";
      Response response = await post(
        Uri.parse(PHONE_LOGIN_ENDPOINT),
        body: jsonEncode(
            {"phone": newPhone, "role": userType, "fcm_token": firebaseToken}),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.acceptHeader: 'application/json'
        },
      );

      final Map<String, dynamic> data = <String, dynamic>{};
      data["status"] = response.statusCode;

      print(response.statusCode);
      print(response.body);

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
      throw Exception(e.toString());
    }
  }

  Future<dynamic> registerWithPhone({
    required String phone,
    required String first_name,
    required String last_name,
  }) async {
    try {
      String? firebaseToken = "";
      FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      firebaseToken = await messaging.getToken();
      var prefs = await SharedPreferences.getInstance();
      var userType = prefs.getString("userType") ?? "";
      print(userType);
      var newPhone = "00963${phone.substring(1)}";
      Response response = await post(
        Uri.parse(PHONE_REGISTER_ENDPOINT),
        body: jsonEncode({
          "phone": newPhone,
          "role": userType,
          'first_name': first_name,
          'last_name': last_name,
          "fcm_token": firebaseToken
        }),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.acceptHeader: 'application/json'
        },
      );

      final Map<String, dynamic> data = <String, dynamic>{};
      data["status"] = response.statusCode;

      print(response.statusCode);
      print(response.body);

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
      throw Exception(e.toString());
    }
  }

  Future<dynamic> verifyOtp({required String otp}) async {
    try {
      print(otp);
      Response response = await post(Uri.parse(VERIFY_OTP_ENDPOINT),
          body: jsonEncode({"otp": otp}),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
            HttpHeaders.acceptHeader: 'application/json'
          });
      final Map<String, dynamic> data = <String, dynamic>{};
      data["status"] = response.statusCode;
      var jsonObject = jsonDecode(response.body);

      print("verify otp status${response.statusCode}");
      print("verify otp body${response.body}");

      if (response.statusCode == 401 || response.statusCode == 400) {
        data["details"] = jsonObject["details"];
      } else {
        presisteToken(jsonObject);

        data["token"] = jsonObject["access"];
        prefs = await SharedPreferences.getInstance();
        Response userresponse =
            await HttpHelper.get(PROFILE_ENDPOINT, apiToken: data["token"]);
        if (userresponse.statusCode == 200) {
          var myDataString = utf8.decode(userresponse.bodyBytes);

          prefs.setString("userProfile", myDataString);
          var result = jsonDecode(myDataString);
          userProvider.setUser(UserModel.fromJson(result));
        }
        var userType = prefs.getString("userType") ?? "";
        bool isLogin = prefs.getBool("isLogin") ?? false;

        if (userType.isNotEmpty) {
          if (userType == "Merchant") {
            prefs.setInt("merchant", jsonObject["merchant_id"]);
          }
          if (userType == "Owner") {
            prefs.setInt("truckowner", jsonObject["truck_owner_id"]);
          }
          if (userType == "Driver") {
            prefs.setInt("truckuser", jsonObject["truck_user_id"]);
            prefs.setInt("truckId", jsonObject['truck_id'] ?? 0);
            prefs.setString("gpsId", jsonObject["gps_id"] ?? "");
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
      sound: true,
    );
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    firebaseToken = await messaging.getToken();

    var refreshToken = prefs.getString("refresh");
    var jwt = prefs.getString("token");

    final response = await HttpHelper.post(
        LOGOUT_ENDPOINT, {'refresh': refreshToken, 'fcm_token': firebaseToken},
        apiToken: jwt);
    prefs.clear();
    if (response.statusCode == 204) {
      // Logout successful
    } else {
      // Handle error
      print('Logout failed with status: ${response.statusCode}');
    }
  }

  Future<void> deleteToken() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
