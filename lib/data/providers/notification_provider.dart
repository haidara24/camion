import 'package:camion/data/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel?> _notifications = [];
  List<NotificationModel?> get notifications => _notifications;

  List<NotificationModel> _ownernotifications = [];
  List<NotificationModel> get ownernotifications => _ownernotifications;

  int _notreadednotifications = 0;
  int get notreadednotifications => _notreadednotifications;

  initNotifications(List<NotificationModel> noti) async {
    print(noti.length);
    _notifications = noti;
    print(_notifications.length);
    var prefs = await SharedPreferences.getInstance();
    _notreadednotifications = prefs.getInt("notreaded") ?? 0;
    notifyListeners();
  }

  initOwnerNotifications(List<NotificationModel> noti) async {
    _ownernotifications = noti;
    notifyListeners();
  }

  addNotReadedNotification() async {
    _notreadednotifications++;
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt("notreaded", _notreadednotifications);
    notifyListeners();
  }

  removeNotReadedNotification() async {
    if (_notreadednotifications > 0) {
      _notreadednotifications--;
    }
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt("notreaded", _notreadednotifications);
    notifyListeners();
  }

  clearNotReadedNotification() async {
    var prefs = await SharedPreferences.getInstance();
    _notreadednotifications = 0;
    prefs.setInt("notreaded", _notreadednotifications);
    notifyListeners();
  }

  markNotificationAsRead(int id) async {
    var index = _notifications.indexWhere(
      (element) => element!.id! == id,
    );
    _notifications[index]!.isread = true;
    _notreadednotifications--;
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt("notreaded", _notreadednotifications);
    notifyListeners();
  }

  markOwnerNotificationAsRead(int id) {
    var templist = _ownernotifications;
    for (var element in templist) {
      if (element.id! == id) {
        _ownernotifications
            .singleWhere((it) => it.id == element.id,
                orElse: () => NotificationModel())
            .isread = true;
      }
    }
    notifyListeners();
  }

  addNotification(NotificationModel notification) {
    _notifications.add(notification);
    notifyListeners();
  }
}
