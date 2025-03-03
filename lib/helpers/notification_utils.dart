// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/requests/request_details_bloc.dart';
import 'package:camion/main.dart';
import 'package:camion/views/screens/driver/incoming_shipment_details_screen.dart';
import 'package:camion/views/screens/merchant/approval_request_info_screen.dart';
import 'package:camion/views/screens/merchant/incoming_request_for_driver.dart';
import 'package:camion/views/screens/sub_shipment_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Initialize local notifications (without BuildContext)
Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Use your app's launcher icon

  final DarwinInitializationSettings initializationSettingsDarwin =
      const DarwinInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (response) {
      onDidReceiveNotificationResponse(response);
    },
    onDidReceiveBackgroundNotificationResponse: (response) {
      onDidReceiveBackgroundNotificationResponse(response);
    },
  );
}

// Show local notification
Future<void> showLocalNotification(RemoteMessage? message) async {
  if (message == null) return;

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    "my_app_channel",
    "default_notification_channel_id",
    importance: Importance.high,
    showBadge: true,
    playSound: true,
  );
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    channel.id, // Use the same channel ID as in strings.xml
    channel.name, // Channel Name
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(
    presentBadge: true,
    presentAlert: true,
    presentSound: true,
    presentBanner: true,
  );

  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.data['title'],
    message.data['body'],
    platformChannelSpecifics,
    payload: jsonEncode({
      'notification_type': message.data['notification_type'],
      'objectId': message.data['objectId'],
    }),
  );
}

// Handle notification response
void onDidReceiveNotificationResponse(NotificationResponse response) async {
  // Handle notification tap
  print("Notification tapped: ${response.payload}");

  // Parse the payload (assuming it's a JSON string)
  final Map<String, dynamic> payload = jsonDecode(response.payload ?? '{}');

  // Extract notification_type and objectId from the payload
  final String? notificationType = payload['notification_type'];
  final int? objectId = int.parse(payload['objectId']);

  if (notificationType == null || objectId == null) {
    print("Invalid payload: Missing notification_type or objectId");
    return;
  }

  final navigator = navigatorKey.currentState;
  if (navigator == null) {
    print("Navigator is null. Cannot handle notification tap.");
    return;
  }
  // Use the same logic as handleMessage
  if (notificationType == "A" || notificationType == "J") {
    navigator.push(
      MaterialPageRoute(
        builder: (context) => ApprovalRequestDetailsScreen(
          type: notificationType,
          objectId: objectId,
        ),
      ),
    );
  } else if (notificationType == "O") {
    var prefs = await SharedPreferences.getInstance();
    var userType = prefs.getString("userType");
    if (userType == "Driver") {
      navigator.push(
        MaterialPageRoute(
          builder: (context) => IncomingShipmentDetailsScreen(
            objectId: objectId,
          ),
        ),
      );
    } else if (userType == "Merchant") {
      BlocProvider.of<SubShipmentDetailsBloc>(navigator.context)
          .add(SubShipmentDetailsLoadEvent(objectId));
      navigator.push(
        MaterialPageRoute(
          builder: (context) => const IncomingRequestForDriverScreen(),
        ),
      );
    }
  } else if (notificationType == "T" || notificationType == "C") {
    BlocProvider.of<SubShipmentDetailsBloc>(navigator.context)
        .add(SubShipmentDetailsLoadEvent(objectId));
    navigator.push(
      MaterialPageRoute(
        builder: (context) => const SubShipmentDetailsScreen(),
      ),
    );
  }
}

// Handle notification response
