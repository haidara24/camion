import 'dart:convert';
import 'dart:io';

import 'package:camion/business_logic/bloc/core/notification_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/requests/driver_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/requests/merchant_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/requests/request_details_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_running_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_task_list_bloc.dart';
import 'package:camion/data/providers/notification_provider.dart';
import 'package:camion/helpers/notification_utils.dart';
import 'package:camion/main.dart';
import 'package:camion/views/screens/driver/incoming_shipment_details_screen.dart';
import 'package:camion/views/screens/merchant/approval_request_info_screen.dart';
import 'package:camion/views/screens/merchant/incoming_request_for_driver.dart';
import 'package:camion/views/screens/sub_shipment_details_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationServices {
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
  void firebaseInit() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final context = navigatorKey.currentContext!;
    notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    requestNotificationPermission();
    getDeviceToken();

    // Initialize local notifications
    await initializeLocalNotifications();

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      showLocalNotification(message);

      // Handle foreground notifications
      forgroundMessage(context, notificationProvider!);
      loadAppAesstes(context, message);
    });

    setupInteractMessage(context);
  }

  void requestNotificationPermission() async {
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
      showLocalNotification(initialMessage);
      // handleMessage(context, initialMessage);
    }

    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      showLocalNotification(event);
      // handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) async {
    if (message.data['notefication_type'] == "A" ||
        message.data['notefication_type'] == "J") {
      BlocProvider.of<RequestDetailsBloc>(context)
          .add(RequestDetailsLoadEvent(message.data['objectId']));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApprovalRequestDetailsScreen(
            type: message.data['notefication_type'].noteficationType!,
          ),
        ),
      );
    } else if (message.data['notefication_type'] == "O") {
      var prefs = await SharedPreferences.getInstance();
      var userType = prefs.getString("userType");
      if (userType == "Driver") {
        BlocProvider.of<SubShipmentDetailsBloc>(context)
            .add(SubShipmentDetailsLoadEvent(message.data['objectId']));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IncomingShipmentDetailsScreen(),
          ),
        );
      } else if (userType == "Merchant") {
        BlocProvider.of<SubShipmentDetailsBloc>(context)
            .add(SubShipmentDetailsLoadEvent(message.data['objectId']));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IncomingRequestForDriverScreen(),
          ),
        );
      }
    } else if (message.data['notefication_type'] == "T" ||
        message.data['notefication_type'] == "C") {
      BlocProvider.of<SubShipmentDetailsBloc>(context)
          .add(SubShipmentDetailsLoadEvent(message.data['objectId']));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubShipmentDetailsScreen(),
        ),
      );
    }
  }

  void loadAppAesstes(BuildContext context, RemoteMessage message) async {
    BlocProvider.of<NotificationBloc>(context).add(NotificationLoadEvent());
    if (message.data['notefication_type'] == "A" ||
        message.data['notefication_type'] == "J") {
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
    } else if (message.data['notefication_type'] == "O") {
      var prefs = await SharedPreferences.getInstance();
      var userType = prefs.getString("userType");
      if (userType == "Driver") {
        BlocProvider.of<DriverRequestsListBloc>(context)
            .add(const DriverRequestsListLoadEvent(null));
      } else if (userType == "Merchant") {
        BlocProvider.of<MerchantRequestsListBloc>(context)
            .add(MerchantRequestsListLoadEvent());
      }
    } else if (message.data['notefication_type'] == "T" ||
        message.data['notefication_type'] == "C") {
      BlocProvider.of<ShipmentRunningBloc>(context)
          .add(ShipmentRunningLoadEvent("R"));
      BlocProvider.of<MerchantRequestsListBloc>(context)
          .add(MerchantRequestsListLoadEvent());
      BlocProvider.of<ShipmentTaskListBloc>(context)
          .add(ShipmentTaskListLoadEvent());
    }
  }

  Future forgroundMessage(
      BuildContext context, NotificationProvider provider) async {
    if (notificationProvider != null) {
      notificationProvider!.addNotReadedNotification();
      // BlocProvider.of<NotificationBloc>(context).add(NotificationLoadEvent());
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
