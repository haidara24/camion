import 'dart:convert';
import 'dart:io';

import 'package:camion/business_logic/bloc/core/notification_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_details_bloc.dart';
import 'package:camion/data/providers/notification_provider.dart';
import 'package:camion/firebase_options.dart';
import 'package:camion/views/screens/merchant/active_shipment_details_from_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationServices {
  //initialising firebase message plugin
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationProvider? notificationProvider;

  void firebaseInit(BuildContext context) {
    notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (kDebugMode) {
        print("notifications title:${notification!.title}");
        print("notifications body:${notification.body}");
        print('count:${android!.count}');
        print('data:${message.data.toString()}');
      }

      if (Platform.isIOS) {
        forgroundMessage(context, notificationProvider!);
      }

      if (Platform.isAndroid) {
        // initLocalNotifications(context, message);
        // showNotification(message);
      }
      if (notificationProvider != null) {
        notificationProvider!.addNotReadedNotification();
        BlocProvider.of<NotificationBloc>(context).add(NotificationLoadEvent());
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // you need to initialize firebase first
    await Firebase.initializeApp(
      name: "Camion",
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (notificationProvider != null) {
      notificationProvider!.addNotReadedNotification();
      // BlocProvider.of<NotificationBloc>(context).add(NotificationLoadEvent());
    }
    print("Handling a background message: ${message.messageId}");
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      // carPlay: true,
      // criticalAlert: true,
      // provisional: true,
      sound: true,
    );

    // messaging.re

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('user granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('user granted provisional permission');
      }
    } else {
      //appsetting.AppSettings.openNotificationSettings();
      if (kDebugMode) {
        print('user denied permission');
      }
    }
  }

  //function to get device token on which we will send the notifications
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print('refresh');
      }
    });
  }

  //handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage(BuildContext context) async {
    // when app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // ignore: use_build_context_synchronously
      handleMessage(context, initialMessage);
    }

    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    // if (message.data['notefication_type'] == "A") {
    //   BlocProvider.of<ShipmentDetailsBloc>(context)
    //       .add(ShipmentDetailsLoadEvent(int.parse(message.data['shipmentId'])));

    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => ActiveShipmentDetailsFromNotificationScreen(
    //           user_id: 'driver${int.parse(message.data['sender'])}',
    //         ),
    //       ));
    // }
  }

  Future forgroundMessage(
      BuildContext context, NotificationProvider provider) async {
    if (notificationProvider != null) {
      notificationProvider!.addNotReadedNotification();
      BlocProvider.of<NotificationBloc>(context).add(NotificationLoadEvent());
    }
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> markNotificationasRead(int id) async {
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var url = 'https://matjari.app/camion/notifecations/$id/';
    var response = await http.patch(Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'JWT $jwt'
        },
        body: jsonEncode({"isread": true}));
  }
}
