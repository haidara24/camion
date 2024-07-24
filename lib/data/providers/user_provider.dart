import 'package:camion/data/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  Merchant? _merchant;
  Merchant? get merchant => _merchant;

  Driver? _driver;
  Driver? get driver => _driver;

  TruckOwner? _owner;
  TruckOwner? get owner => _owner;

  setMerchant(Merchant? value) {
    _merchant = value;
    notifyListeners();
  }

  setDriver(Driver? value) {
    _driver = value;
    notifyListeners();
  }

  setTruckOwner(TruckOwner? value) {
    _owner = value;
    notifyListeners();
  }
}
