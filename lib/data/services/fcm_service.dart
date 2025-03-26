import 'dart:convert';
import 'dart:io';

import 'package:camion/business_logic/bloc/core/notification_bloc.dart';
import 'package:camion/business_logic/bloc/requests/driver_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/requests/merchant_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_running_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_task_list_bloc.dart';
import 'package:camion/data/providers/notification_provider.dart';
import 'package:camion/firebase_options.dart';
import 'package:camion/main.dart';
import 'package:camion/views/screens/driver/incoming_shipment_details_screen.dart';
import 'package:camion/views/screens/merchant/approval_request_info_screen.dart';
import 'package:camion/views/screens/merchant/incoming_request_for_driver.dart';
import 'package:camion/views/screens/merchant/shipment_instruction_details_screen.dart';
import 'package:camion/views/screens/merchant/shipment_payment_instruction_details_screeen.dart';
import 'package:camion/views/screens/sub_shipment_details_screen.dart';
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
  static final NotificationServices _instance =
      NotificationServices._internal();

  // Private constructor
  NotificationServices._internal();

  // Factory constructor
  factory NotificationServices() {
    return _instance;
  }

  // Firebase messaging instance
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationProvider? notificationProvider;

  bool _isInitialized = false;

// Initialize Firebase messaging and avoid duplicate listeners
  void firebaseInit(BuildContext context) async {
    if (_isInitialized) return;
    _isInitialized = true;

    notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    requestNotificationPermission();
    getDeviceToken();

    FirebaseMessaging.instance.setAutoInitEnabled(true);

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? ios = message.notification?.apple;

      if (kDebugMode) {
        print("notifications title: ${notification?.title}");
        print("notifications body: ${notification?.body}");
        print('count: ${android?.count}');
        print('count: ${ios?.badge}');
        print('data: ${message.data.toString()}');
      }

      if (notificationProvider != null) {
        print("Adding unread notification...");
        notificationProvider!.addNotReadedNotification();
      } else {
        print("NotificationProvider is null");
      }
      // Handle foreground notifications
      forgroundMessage();
      loadAppAssets(message);
    });

    // setupInteractMessage(context);
  }

  Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    // you need to initialize firebase first
    await Firebase.initializeApp(
      name: "Camion",
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print("Handling a background message: ${message.messageId}");
  }

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

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
    String token = "";
    token = await messaging.getToken() ?? "";
    return token;
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

    print("initialMessage: $initialMessage");
    if (initialMessage != null) {
      RemoteNotification? notification = initialMessage.notification;

      if (kDebugMode) {
        print("notifications title: ${notification?.title}");
        print("notifications body: ${notification?.body}");
      }
      handleMessage(initialMessage);
      loadAppAssets(initialMessage);
    }

    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      RemoteNotification? notification = event.notification;

      if (kDebugMode) {
        print("notifications title: ${notification?.title}");
        print("notifications body: ${notification?.body}");
      }
      handleMessage(event);
      loadAppAssets(event);
    });
  }

// Handle notification response
  void handleMessage(RemoteMessage message) async {
    final context = navigatorKey.currentContext;
    print("open screen");
    print(
        "message.data['notification_type'] = ${message.data['notification_type']}");
    if (!context!.mounted) {
      print("Context is no longer valid. Skipping...");
      return;
    }

    if (message.data['notification_type'] == "A" ||
        message.data['notification_type'] == "J") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApprovalRequestDetailsScreen(
            type: message.data['notification_type'],
            objectId: int.parse(message.data['objectId']),
          ),
        ),
      );
    } else if (message.data['notification_type'] == "O") {
      var prefs = await SharedPreferences.getInstance();
      var userType = prefs.getString("userType");
      if (userType == "Driver") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IncomingShipmentDetailsScreen(
              objectId: int.parse(message.data['objectId']),
            ),
          ),
        );
      } else if (userType == "Merchant") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IncomingRequestForDriverScreen(
              objectId: int.parse(message.data['objectId']),
            ),
          ),
        );
      }
    } else if (message.data['notification_type'] == "T" ||
        message.data['notification_type'] == "C") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubShipmentDetailsScreen(
            objectId: int.parse(message.data['objectId']),
          ),
        ),
      );
    } else if (message.data['notification_type'] == "I") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShipmentInstructionDetailsScreen(
            shipment: int.parse(message.data['objectId']),
          ),
        ),
      );
    } else if (message.data['notification_type'] == "Y") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentInstructionDetailsScreen(
            shipment: int.parse(message.data['objectId']),
          ),
        ),
      );
    }
  }

  void loadAppAssets(
    RemoteMessage message,
  ) async {
    final context = navigatorKey.currentContext;
    print("load App Assets");
    print(
        "message.data['notification_type'] = ${message.data['notification_type']}");
    if (!context!.mounted) {
      print("Context is no longer valid. Skipping...");
      return;
    }
    BlocProvider.of<NotificationBloc>(context).add(NotificationLoadEvent());
    if (message.data['notification_type'] == "J") {
      var prefs = await SharedPreferences.getInstance();
      var userType = prefs.getString("userType");
      if (userType == "Driver") {
        BlocProvider.of<DriverRequestsListBloc>(context)
            .add(const DriverRequestsListLoadEvent(null));
      } else if (userType == "Merchant") {
        BlocProvider.of<ShipmentRunningBloc>(context)
            .add(ShipmentRunningLoadEvent("R"));
        BlocProvider.of<MerchantRequestsListBloc>(context)
            .add(MerchantRequestsListLoadEvent());
        BlocProvider.of<ShipmentTaskListBloc>(context)
            .add(ShipmentTaskListLoadEvent());
      }
    } else if (message.data['notification_type'] == "O") {
      var prefs = await SharedPreferences.getInstance();
      var userType = prefs.getString("userType");
      if (userType == "Driver") {
        BlocProvider.of<DriverRequestsListBloc>(context)
            .add(const DriverRequestsListLoadEvent(null));
      } else if (userType == "Merchant") {
        BlocProvider.of<MerchantRequestsListBloc>(context)
            .add(MerchantRequestsListLoadEvent());
      }
    } else if (message.data['notification_type'] == "A" ||
        message.data['notification_type'] == "T" ||
        message.data['notification_type'] == "C") {
      BlocProvider.of<ShipmentRunningBloc>(context)
          .add(ShipmentRunningLoadEvent("R"));
      BlocProvider.of<MerchantRequestsListBloc>(context)
          .add(MerchantRequestsListLoadEvent());
      BlocProvider.of<ShipmentTaskListBloc>(context)
          .add(ShipmentTaskListLoadEvent());
    }
  }

  Future forgroundMessage() async {
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
    var url = 'https://matjari.app/noti/notifications/$id/';
    var response = await http.patch(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'JWT $jwt'
      },
      body: jsonEncode(
        {"isread": true},
      ),
    );
  }
}
