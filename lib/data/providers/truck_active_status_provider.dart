import 'package:flutter/material.dart';

class TruckActiveStatusProvider extends ChangeNotifier {
  bool _isOn = false;
  bool get isOn => _isOn;

  setStatus(bool value) {
    _isOn = value;
    notifyListeners();
  }
}
