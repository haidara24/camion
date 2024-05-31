import 'package:camion/data/models/truck_model.dart';
import 'package:flutter/material.dart';

class TruckProvider extends ChangeNotifier {
  KTruck? _selectedTruck;
  KTruck? get selectedTruck => _selectedTruck;

  List<KTruck>? _trucks;
  List<KTruck>? get trucks => _trucks;

  setTrucks(List<KTruck>? value) {
    _trucks = value;
    notifyListeners();
  }

  init() {
    _selectedTruck = null;

    _trucks = [];
  }

  setSelectedTruck(KTruck? value) {
    _selectedTruck = value;
    notifyListeners();
  }
}
