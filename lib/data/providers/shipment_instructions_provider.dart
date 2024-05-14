import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:flutter/material.dart';

class ShipmentInstructionsProvider extends ChangeNotifier {
  SubShipment? _subShipment = null;
  SubShipment? get subShipment => _subShipment;

  int _subShipmentIndex = 0;
  int get subShipmentIndex => _subShipmentIndex;

  setSubShipment(SubShipment value, int index) {
    _subShipment = value;
    _subShipmentIndex = index;
    notifyListeners();
  }

  setSubShipmentIndex(int value) {
    notifyListeners();
  }
}
