import 'package:flutter/material.dart';

class RequestNumProvider extends ChangeNotifier {
  int _requestNum = 0;
  int get requestNum => _requestNum;

  setRequestNum(int value) {
    _requestNum = value;
    notifyListeners();
  }

  increaseRequestNum() {
    _requestNum++;
    notifyListeners();
  }

  decreaseRequestNum() {
    if (_requestNum > 1) {
      _requestNum--;
    }
    notifyListeners();
  }
}
