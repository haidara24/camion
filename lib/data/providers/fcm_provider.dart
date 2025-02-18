// import 'dart:io';

// import 'package:camion/data/services/fcm_service.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class FCMProvider with ChangeNotifier {
//   static BuildContext? _context;

//   static void setContext(BuildContext context) => FCMProvider._context = context;

//   /// when app is in the foreground
//   static Future<void> onTapNotification(NotificationResponse? response) async {
//     if (FCMProvider._context == null || response?.payload == null) return;
//     final Map<String, dynamic> _data = FCMProvider.convertPayload(response!.payload!);
//     if (_data.containsKey(...)){
//       await Navigator.of(FCMProvider._context!).push(...);
//     }
//   }

//   static Map<String, dynamic> convertPayload(String payload){
//     final String _payload = payload.substring(1, payload.length - 1);
//     List<String> _split = [];
//     _payload.split(",")..forEach((String s) => _split.addAll(s.split(":")));
//     Map<String, dynamic> _mapped = {};
//     for (int i = 0; i < _split.length + 1; i++) {
//       if (i % 2 == 1) _mapped.addAll({_split[i-1].trim().toString(): _split[i].trim()});
//     }
//     return _mapped;
//   }
  
//   static Future<void> onMessage() async {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       if (FCMProvider._refreshNotifications != null) await FCMProvider._refreshNotifications!(true);
//       // if this is available when Platform.isIOS, you'll receive the notification twice 
//       if (Platform.isAndroid) {
//         await NotificationServices.localNotificationsPlugin.show(
//           0, message.notification!.title,
//           message.notification!.body,
//           NotificationServices.platformChannelSpecifics,
//           payload: message.data.toString(),
//         );
//       }
//     });
//   }

//   static Future<void> backgroundHandler(RemoteMessage message) async {

//   }
// }