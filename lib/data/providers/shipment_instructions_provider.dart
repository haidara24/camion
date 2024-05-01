import 'dart:convert';

import 'package:camion/data/models/instruction_model.dart';
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

  addSubInstruction(SubShipmentInstruction value) {
    _subShipment!.shipmentinstructionv2!.subinstrucations!.add(value);
    notifyListeners();
  }

  addInstruction(Shipmentinstruction value) {
    _subShipment!.shipmentinstructionv2 = value;
    print(_subShipment!.shipmentinstructionv2);
    notifyListeners();
  }
}
