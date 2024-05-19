// ignore_for_file: prefer_final_fields, non_constant_identifier_names

import 'dart:convert';
import 'dart:math';

import 'package:camion/data/models/commodity_category_model.dart';
import 'package:camion/data/models/place_model.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/models/truck_type_model.dart';
import 'package:camion/data/services/places_service.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class AddMultiShipmentProvider extends ChangeNotifier {
  Shipmentv2? _shipment;

  Shipmentv2? get shipment => _shipment;

  GoogleMapController? _mapController2;
  GoogleMapController? get mapController2 => _mapController2;

  late GoogleMapController _mapController;
  GoogleMapController get mapController => _mapController;

  LatLng _center = const LatLng(35.363149, 35.932120);
  LatLng get center => _center;

  double _zoom = 13.0;
  double get zoom => _zoom;

  List<ScrollController?> _scrollController = [ScrollController()];
  List<ScrollController?> get scrollController => _scrollController;

  List<List<TextEditingController>> _commodityWeight_controllers = [
    [TextEditingController()]
  ];
  List<List<TextEditingController>> get commodityWeight_controllers =>
      _commodityWeight_controllers;

  List<List<TextEditingController>> _commodityName_controllers = [
    [TextEditingController()]
  ];
  List<List<TextEditingController>> get commodityName_controllers =>
      _commodityName_controllers;

  List<List<LatLng>> _pathes = [[]];
  List<List<LatLng>> get pathes => _pathes;

  List<List<CommodityCategory?>> _commodityCategory_controller = [
    [null]
  ];
  List<List<CommodityCategory?>> get commodityCategory_controller =>
      _commodityCategory_controller;

  List<List<int>> _commodityCategories = [
    [0]
  ];
  List<List<int>> get commodityCategories => _commodityCategories;

  List<GlobalKey<FormState>> _addShipmentformKey = [GlobalKey<FormState>()];
  List<GlobalKey<FormState>> get addShipmentformKey => _addShipmentformKey;

  List<TextEditingController> _pickup_controller = [TextEditingController()];
  List<TextEditingController> get pickup_controller => _pickup_controller;

  List<String> _pickup_eng_string = [""];
  List<String> get pickup_eng_string => _pickup_eng_string;

  List<List<TextEditingController>> _stoppoints_controller = [[]];
  List<List<TextEditingController>> get stoppoints_controller =>
      _stoppoints_controller;

  List<List<String>> _stoppoints_eng_string = [[]];
  List<List<String>> get stoppoints_eng_string => _stoppoints_eng_string;

  List<TextEditingController> _delivery_controller = [TextEditingController()];
  List<TextEditingController> get delivery_controller => _delivery_controller;

  List<String> _delivery_eng_string = [""];
  List<String> get delivery_eng_string => _delivery_eng_string;

  List<String> _pickup_location = [""];
  List<String> get pickup_location => _pickup_location;

  List<String> _delivery_location = [""];
  List<String> get delivery_location => _delivery_location;

  List<List<String>> _stoppoints_location = [[]];
  List<List<String>> get stoppoints_location => _stoppoints_location;

  List<LatLng?> _pickup_latlng = [null];
  List<LatLng?> get pickup_latlng => _pickup_latlng;

  List<List<LatLng?>> _stoppoints_latlng = [[]];
  List<List<LatLng?>> get stoppoints_latlng => _stoppoints_latlng;

  List<LatLng?> _delivery_latlng = [null];
  List<LatLng?> get delivery_latlng => _delivery_latlng;

  List<Marker?> _pickup_marker = [const Marker(markerId: MarkerId("pickup"))];
  List<Marker?> get pickup_marker => _pickup_marker;

  List<List<Marker?>> _stop_marker = [[]];
  List<List<Marker?>> get stop_marker => _stop_marker;

  TruckType? _truckType = null;
  TruckType? get truckType => _truckType;

  List<Marker?> _delivery_marker = [
    const Marker(markerId: MarkerId("delivery"))
  ];
  List<Marker?> get delivery_marker => _delivery_marker;

  List<Position?> _pickup_position = [null];
  List<Position?> get pickup_position => _pickup_position;

  List<List<Position?>> _stoppoints_position = [[]];
  List<List<Position?>> get stoppoints_position => _stoppoints_position;

  List<Position?> _delivery_position = [null];
  List<Position?> get delivery_position => _delivery_position;

  List<Place?> _pickup_place = [null];
  List<Place?> get pickup_place => _pickup_place;

  List<List<Place?>> _stoppoints_place = [[]];
  List<List<Place?>> get stoppoints_place => _stoppoints_place;

  List<Place?> _delivery_place = [null];
  List<Place?> get delivery_place => _delivery_place;

  int _countpath = 1;
  int get countpath => _countpath;

  List<int> _count = [1];
  List<int> get count => _count;

  List<int> _selectedTruck = [];
  List<int> get selectedTruck => _selectedTruck;

  List<KTruck?> _trucks = [null];
  List<KTruck?> get trucks => _trucks;

  List<bool> _truckError = [false];
  List<bool> get truckError => _truckError;

  List<bool> _pathError = [false];
  List<bool> get pathError => _pathError;

  List<bool> _dateError = [false];
  List<bool> get dateError => _dateError;

  List<bool> _pickupLoading = [false];
  List<bool> get pickupLoading => _pickupLoading;

  List<bool> _deliveryLoading = [false];
  List<bool> get deliveryLoading => _deliveryLoading;

  List<List<bool>> _stoppointsLoading = [[]];
  List<List<bool>> get stoppointsLoading => _stoppointsLoading;

  List<bool> _pickuptextLoading = [false];
  List<bool> get pickuptextLoading => _pickuptextLoading;

  List<bool> _deliverytextLoading = [false];
  List<bool> get deliverytextLoading => _deliverytextLoading;

  List<List<bool>> _stoppointstextLoading = [[]];
  List<List<bool>> get stoppointstextLoading => _stoppointstextLoading;

  List<bool> _pickupPosition = [false];
  List<bool> get pickupPosition => _pickupPosition;

  List<bool> _deliveryPosition = [false];
  List<bool> get deliveryPosition => _deliveryPosition;

  List<List<bool>> _stoppointsPosition = [[]];
  List<List<bool>> get stoppointsPosition => _stoppointsPosition;

  List<List<int>> _selectedTruckType = [[]];
  List<List<int>> get selectedTruckType => _selectedTruckType;

  List<List<int>> _truckNum = [[]];
  List<List<int>> get truckNum => _truckNum;

  List<List<TextEditingController>> _truckNumController = [[]];
  List<List<TextEditingController>> get truckNumController =>
      _truckNumController;

  List<double> _distance = [0];
  List<double> get distance => _distance;

  List<String> _period = [""];
  List<String> get period => _period;

  List<DateTime> _loadDate = [DateTime.now()];
  List<DateTime> get loadDate => _loadDate;

  List<DateTime> _loadTime = [DateTime.now()];
  List<DateTime> get loadTime => _loadTime;
  List<TextEditingController> _time_controller = [TextEditingController()];
  List<TextEditingController> get time_controller => _time_controller;

  List<TextEditingController> _date_controller = [TextEditingController()];
  List<TextEditingController> get date_controller => _date_controller;

  // Initialization method
  void initShipment() {
    if (_shipment == null) {
      _shipment = Shipmentv2(subshipments: []);

      notifyListeners();
    }
  }

  initForm() {
    _center = const LatLng(35.363149, 35.932120);

    _zoom = 13.0;

    _scrollController = [ScrollController()];

    _commodityWeight_controllers = [
      [TextEditingController()]
    ];

    _commodityName_controllers = [
      [TextEditingController()]
    ];

    _pathes = [[]];

    _commodityCategory_controller = [
      [null]
    ];

    _commodityCategories = [
      [0]
    ];

    _addShipmentformKey = [GlobalKey<FormState>()];

    _pickup_controller = [TextEditingController()];

    _pickup_eng_string = [""];

    _stoppoints_controller = [[]];

    _stoppoints_eng_string = [[]];

    _delivery_controller = [TextEditingController()];

    _delivery_eng_string = [""];

    _pickup_location = [""];

    _delivery_location = [""];

    _stoppoints_location = [[]];

    _pickup_latlng = [null];

    _stoppoints_latlng = [[]];

    _delivery_latlng = [null];

    _pickup_marker = [const Marker(markerId: MarkerId("pickup"))];

    _stop_marker = [[]];

    _truckType = null;

    _delivery_marker = [const Marker(markerId: MarkerId("delivery"))];

    _pickup_position = [null];

    _stoppoints_position = [[]];

    _delivery_position = [null];

    _pickup_place = [null];

    _stoppoints_place = [[]];

    _delivery_place = [null];

    _countpath = 1;

    _count = [1];

    _selectedTruck = [];

    _trucks = [null];

    _truckError = [false];

    _pathError = [false];

    _dateError = [false];

    _pickupLoading = [false];

    _deliveryLoading = [false];

    _stoppointsLoading = [[]];

    _pickuptextLoading = [false];

    _deliverytextLoading = [false];

    _stoppointstextLoading = [[]];

    _pickupPosition = [false];

    _deliveryPosition = [false];

    _stoppointsPosition = [[]];

    _selectedTruckType = [[]];

    _truckNum = [[]];

    _truckNumController = [[]];

    _distance = [0];

    _period = [""];

    _loadDate = [DateTime.now()];

    _loadTime = [DateTime.now()];
    _time_controller = [TextEditingController()];

    _date_controller = [TextEditingController()];
  }

  setTruckType(TruckType type) {
    _truckType = type;
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller, String style) {
    _mapController = controller;
    _mapController.setMapStyle(style);
    notifyListeners();
  }

  void onMap2Created(GoogleMapController controller, String style) {
    _mapController2 = controller;
    _mapController2!.setMapStyle(style);
    notifyListeners();
  }

  void setMapStyle(String style) async {
    await _mapController
        .setMapStyle(style)
        .onError((error, stackTrace) => print(error));
    notifyListeners();
  }

  void setMapStyle2(String style) async {
    await _mapController2!
        .setMapStyle(style)
        .onError((error, stackTrace) => print(error));
    notifyListeners();
  }

  void dispose() {
    _mapController.dispose();
    _mapController2!.dispose();
  }

  void getPolyPoints(int index) async {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PolylineWayPoint> waypoints = [];
    for (var element in _stoppoints_location[index]) {
      waypoints.add(PolylineWayPoint(location: element, stopOver: true));
    }

    await polylinePoints
        .getRouteBetweenCoordinates(
      "AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w",
      PointLatLng(
        _pickup_latlng[index]!.latitude,
        _pickup_latlng[index]!.longitude,
      ),
      PointLatLng(
        _delivery_latlng[index]!.latitude,
        _delivery_latlng[index]!.longitude,
      ),
      wayPoints: waypoints,
    )
        .then(
      (result) {
        _pathes[index] = [];
        // _isThereARoute[index] = true;
        if (result.points.isNotEmpty) {
          // _isThereARoute = true;
          // _isThereARouteError = false;
          // _thereARoute = true;
          result.points.forEach((element) {
            _pathes[index].add(
              LatLng(
                element.latitude,
                element.longitude,
              ),
            );
          });
        }
        initMapbounds(index);
      },
    ).onError(
      (error, stackTrace) {
        // _isThereARoute = false;
        // _thereARoute = false;
        print(error);

        notifyListeners();
      },
    );

    var response = await HttpHelper.get(
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${_delivery_latlng[index]!.latitude},${_delivery_latlng[index]!.longitude}&origins=${_pickup_latlng[index]!.latitude},${_pickup_latlng[index]!.longitude}&key=AIzaSyCl_H8BXqnTm32umdYVQrKMftTiFpRqd-c&mode=DRIVING');

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      _distance[index] = double.parse(result["rows"][0]['elements'][0]
              ['distance']['text']
          .replaceAll(" km", ""));
      print(_distance[index]);
      _period[index] = result["rows"][0]['elements'][0]['duration']['text'];
      print(_period[index]);
    }
    notifyListeners();
  }

  initMapbounds(int index) {
    if (_pickup_controller[index].text.isNotEmpty &&
        _delivery_controller[index].text.isNotEmpty) {
      setPathError(false, index);
      List<Marker> markers = [];
      var pickuplocation = _pickup_location[index].split(",");
      markers.add(
        Marker(
          markerId: const MarkerId("pickup"),
          position: LatLng(
              double.parse(pickuplocation[0]), double.parse(pickuplocation[1])),
        ),
      );
      print(_stoppoints_location[index].length);
      for (var i = 0; i < _stoppoints_location[index].length; i++) {
        var stopLocation = _stoppoints_location[index][i].split(',');
        print(stopLocation[0]);
        markers.add(
          Marker(
            markerId: MarkerId("stop$i"),
            position: LatLng(
                double.parse(stopLocation[0]), double.parse(stopLocation[1])),
          ),
        );
      }

      var deliverylocation = _delivery_location[index].split(",");

      markers.add(
        Marker(
          markerId: const MarkerId("delivery"),
          position: LatLng(double.parse(deliverylocation[0]),
              double.parse(deliverylocation[1])),
        ),
      );

      double minLat = markers[0].position.latitude;
      double maxLat = markers[0].position.latitude;
      double minLng = markers[0].position.longitude;
      double maxLng = markers[0].position.longitude;

      for (Marker marker in markers) {
        if (marker.position.latitude < minLat) {
          minLat = marker.position.latitude;
        }
        if (marker.position.latitude > maxLat) {
          maxLat = marker.position.latitude;
        }
        if (marker.position.longitude < minLng) {
          minLng = marker.position.longitude;
        }
        if (marker.position.longitude > maxLng) {
          maxLng = marker.position.longitude;
        }
      }

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50.0);
      _mapController.animateCamera(cameraUpdate);
      _mapController2!.animateCamera(cameraUpdate);
      // notifyListeners();
    } else {}
  }

  setLoadTime(DateTime time, int index) {
    String am = time.hour > 12 ? 'pm' : 'am';
    _time_controller[index].text = '${time.hour}:${time.minute} $am';
    _loadTime[index] = time;
    notifyListeners();
  }

  setLoadDate(DateTime date, int index) {
    List months = [
      'jan',
      'feb',
      'mar',
      'april',
      'may',
      'jun',
      'july',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec'
    ];
    var mon = date.month;
    var month = months[mon - 1];
    _date_controller[index].text = '${date.year}-$month-${date.day}';
    _loadDate[index] = date;
    notifyListeners();
  }

  addTruckType(int id, int index) {
    _selectedTruckType[index].add(id);
    _truckNum[index].add(1);
    _truckNumController[index].add(TextEditingController(text: "1"));
    notifyListeners();
  }

  removeTruckType(int id, int index) {
    if (_selectedTruckType[index].indexWhere((item) => item == id) != -1) {
      var removeIndex =
          _selectedTruckType[index].indexWhere((item) => item == id);
      _truckNum[index].removeAt(removeIndex);
      _truckNumController[index][removeIndex].text = "";
      notifyListeners();
      _truckNumController[index].removeAt(removeIndex);
      _selectedTruckType[index].removeAt(removeIndex);
    }
    notifyListeners();
  }

  increaseTruckType(int id, int index) {
    if (_selectedTruckType[index].indexWhere((item) => item == id) != -1) {
      _truckNum[index]
          [_selectedTruckType[index].indexWhere((item) => item == id)]++;
      _truckNumController[index]
              [_selectedTruckType[index].indexWhere((item) => item == id)]
          .text = _truckNum[index]
              [_selectedTruckType[index].indexWhere((item) => item == id)]
          .toString();
    }
    notifyListeners();
  }

  addSelectedTruck(int id) {
    _selectedTruck.add(id);
    notifyListeners();
  }

  removeSelectedTruck(int id) {
    _selectedTruck.remove(id);
    notifyListeners();
  }

  decreaseTruckType(int id, int index) {
    if (_selectedTruckType[index].indexWhere((item) => item == id) != -1) {
      if (_truckNum[index]
              [_selectedTruckType[index].indexWhere((item) => item == id)] >
          1) {
        _truckNum[index]
            [_selectedTruckType[index].indexWhere((item) => item == id)]--;

        _truckNumController[index]
                [_selectedTruckType[index].indexWhere((item) => item == id)]
            .text = _truckNum[index]
                [_selectedTruckType[index].indexWhere((item) => item == id)]
            .toString();
      }
    }
    notifyListeners();
  }

  setPickupLoading(bool value, int index) {
    _pickupLoading[index] = value;
    notifyListeners();
  }

  setPickupTextLoading(bool value, int index) {
    _pickuptextLoading[index] = value;
    print(_pickuptextLoading[index]);
    notifyListeners();
  }

  setPickupPositionClick(bool value, int index) {
    _pickupPosition[index] = value;
    notifyListeners();
  }

  setDeliveryLoading(bool value, int index) {
    _deliveryLoading[index] = value;
    notifyListeners();
  }

  setDeliveryTextLoading(bool value, int index) {
    _deliverytextLoading[index] = value;
    notifyListeners();
  }

  setDeliveryPositionClick(bool value, int index) {
    _deliveryPosition[index] = value;
    notifyListeners();
  }

  setStopPointLoading(bool value, int index, int index2) {
    _stoppointsLoading[index][index2] = value;
    notifyListeners();
  }

  setStopPointTextLoading(bool value, int index, int index2) {
    _stoppointstextLoading[index][index2] = value;
    notifyListeners();
  }

  setStopPointPositionClick(bool value, int index, int index2) {
    _stoppointsPosition[index][index2] = value;
    notifyListeners();
  }

  setPickupInfo(dynamic suggestion, int index) async {
    print(_pickuptextLoading[index]);
    var sLocation = await PlaceService.getPlace(suggestion.placeId);
    _pickup_place[index] = sLocation;
    _pickup_latlng[index] = LatLng(
        sLocation.geometry.location.lat, sLocation.geometry.location.lng);

    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);

      _pickup_controller[index].text =
          '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    }
    // var responseEng = await http.get(
    //   Uri.parse(
    //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    // );
    // if (responseEng.statusCode == 200) {
    //   var result = jsonDecode(responseEng.body);

    //   _pickup_eng_string[index] =
    //       '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    // }

    _pickup_location[index] =
        "${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}";

    if (_mapController2 != null) {
      if (_delivery_controller[index].text.isNotEmpty &&
          _pickup_controller[index].text.isNotEmpty) {
        getPolyPoints(index);
      } else {
        animateCameraToLatLng(index);
      }
    }

    _pickuptextLoading[index] = false;

    notifyListeners();
    if (_mapController2 == null) {
      if (_delivery_controller[index].text.isNotEmpty &&
          _pickup_controller[index].text.isNotEmpty) {
        getPolyPoints(index);
      } else {
        animateCameraToLatLng(index);
      }
    }
  }

  Future<void> getAddressForPickupFromMapPicker(
      LatLng position, int index) async {
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      _pickup_latlng[index] = position;
      _pickup_controller[index].text =
          '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
      _pickup_location[index] = "${position.latitude},${position.longitude}";
    }
    // var responseEng = await http.get(
    //   Uri.parse(
    //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    // );
    // if (responseEng.statusCode == 200) {
    //   var result = jsonDecode(responseEng.body);

    //   _pickup_eng_string[index] =
    //       '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    // }
    if (_delivery_controller[index].text.isNotEmpty &&
        _pickup_controller[index].text.isNotEmpty) {
      getPolyPoints(index);
    } else {
      animateCameraToLatLng(index);
    }
    _pickupLoading[index] = false;
    notifyListeners();
  }

  animateCameraToLatLng(int index) {
    var pickuplocation = _pickup_location[index].split(",");

    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
              double.parse(pickuplocation[0]),
              double.parse(pickuplocation[1]),
            ),
            zoom: 14.47),
      ),
    );
    _mapController2!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
              double.parse(pickuplocation[0]),
              double.parse(pickuplocation[1]),
            ),
            zoom: 14.47),
      ),
    );
  }

  Future<void> getAddressForDeliveryFromMapPicker(
      LatLng position, int index) async {
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      _delivery_latlng[index] = position;
      _delivery_controller[index].text =
          '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
      _delivery_location[index] = "${position.latitude},${position.longitude}";
    }

    // var responseEng = await http.get(
    //   Uri.parse(
    //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    // );
    // if (responseEng.statusCode == 200) {
    //   var result = jsonDecode(responseEng.body);

    //   _delivery_eng_string[index] =
    //       '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    // }
    if (_delivery_controller[index].text.isNotEmpty &&
        _pickup_controller[index].text.isNotEmpty) {
      getPolyPoints(index);
    } else {
      animateCameraToLatLng(index);
    }
    _deliveryLoading[index] = false;
    notifyListeners();
  }

  setDeliveryInfo(dynamic suggestion, int index) async {
    // _deliverytextLoading[index] = true;
    // notifyListeners();
    var sLocation = await PlaceService.getPlace(suggestion.placeId);
    _delivery_place[index] = sLocation;
    _delivery_latlng[index] = LatLng(
        sLocation.geometry.location.lat, sLocation.geometry.location.lng);
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);

      _delivery_controller[index].text =
          '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    }
    // var responseEng = await http.get(
    //   Uri.parse(
    //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    // );
    // if (responseEng.statusCode == 200) {
    //   var result = jsonDecode(responseEng.body);

    //   _delivery_eng_string[index] =
    //       '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    // }
    _delivery_location[index] =
        "${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}";
    if (_delivery_controller[index].text.isNotEmpty &&
        _pickup_controller[index].text.isNotEmpty) {
      getPolyPoints(index);
    } else {
      animateCameraToLatLng(index);
    }
    _deliverytextLoading[index] = false;

    notifyListeners();
  }

  setStopPointInfo(dynamic suggestion, int index, int index2) async {
    // _stoppointstextLoading[index][index2] = true;
    // notifyListeners();
    var sLocation = await PlaceService.getPlace(suggestion.placeId);
    _stoppoints_place[index][index2] = sLocation;
    _stoppoints_latlng[index][index2] = LatLng(
        sLocation.geometry.location.lat, sLocation.geometry.location.lng);
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);

      _stoppoints_controller[index][index2].text =
          '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    }

    // var responseEng = await http.get(
    //   Uri.parse(
    //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    // );
    // if (responseEng.statusCode == 200) {
    //   var result = jsonDecode(responseEng.body);

    //   _stoppoints_eng_string[index][index2] =
    //       '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    // }
    _stoppoints_location[index][index2] =
        "${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}";
    if (_delivery_controller[index].text.isNotEmpty &&
        _pickup_controller[index].text.isNotEmpty) {
      getPolyPoints(index);
    } else {
      animateCameraToLatLng(index);
    }
    _stoppointstextLoading[index][index2] = false;

    notifyListeners();
  }

  Future<bool> _handleLocationPermission(
      BuildContext context, int index) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          dismissDirection: DismissDirection.up,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 10,
              right: 10),
          content: const Text(
            'Location services are disabled. Please enable the services',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
      // setState(() {
      //   pickupLoading = false;
      // });
      // return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange,
            dismissDirection: DismissDirection.up,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 10,
                right: 10),
            content: const Text(
              'Location permissions are denied',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        );
        _pickupLoading[index] = false;

        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          dismissDirection: DismissDirection.up,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 10,
              right: 10),
          content: const Text(
            'Location permissions are permanently denied, we cannot request permissions.',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
      _pickupLoading[index] = false;

      return false;
    }
    return true;
  }

  Future<void> getCurrentPositionForPickup(
      BuildContext context, int index) async {
    final hasPermission = await _handleLocationPermission(context, index);

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      print(position);
      _pickup_latlng[index] = LatLng(position.latitude, position.longitude);
      _pickup_position[index] = position;
      _pickup_location[index] = "${position.latitude},${position.longitude}";
      getAddressForPickupFromLatLng(position, index);
    }).catchError((e) {
      _pickupLoading[index] = false;

      debugPrint(e);
    });
    // _pickupLoading[index] = false;

    notifyListeners();
  }

  Future<void> getAddressForPickupFromLatLng(
      Position position, int index) async {
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);

      _pickup_controller[index].text =
          '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    }
    _pickupLoading[index] = false;
    if (_delivery_controller[index].text.isNotEmpty &&
        _pickup_controller[index].text.isNotEmpty) {
      getPolyPoints(index);
    } else {
      animateCameraToLatLng(index);
    }
    notifyListeners();
  }

  Future<void> getCurrentPositionForStop(
      BuildContext context, int index, int index2) async {
    final hasPermission = await _handleLocationPermission(context, index);

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      print(position);
      _stoppoints_latlng[index][index2] =
          LatLng(position.latitude, position.longitude);
      _stoppoints_position[index][index2] = position;
      _stoppoints_location[index][index2] =
          "${position.latitude},${position.longitude}";
      getAddressForStopPointFromLatLng(position, index, index2);
    }).catchError((e) {
      pickupLoading[index] = false;

      debugPrint(e);
    });
    notifyListeners();
  }

  Future<void> getAddressForStopPointFromLatLng(
      Position position, int index, int index2) async {
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);

      _stoppoints_controller[index][index2].text =
          '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    }

    // var responseEng = await http.get(
    //   Uri.parse(
    //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    // );
    // if (responseEng.statusCode == 200) {
    //   var result = jsonDecode(responseEng.body);

    //   _stoppoints_eng_string[index][index2] =
    //       '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    // }
    _pickupLoading[index] = false;

    if (_delivery_controller[index].text.isNotEmpty &&
        _pickup_controller[index].text.isNotEmpty) {
      getPolyPoints(index);
    } else {
      animateCameraToLatLng(index);
    }
    notifyListeners();
  }

  Future<void> getCurrentPositionForDelivery(
      BuildContext context, int index) async {
    final hasPermission = await _handleLocationPermission(context, index);
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      _delivery_latlng[index] = LatLng(position.latitude, position.longitude);
      _delivery_position[index] = position;
      _delivery_location[index] = "${position.latitude},${position.longitude}";
      getAddressForDeliveryFromLatLng(position, index);
    }).catchError((e) {
      _deliveryLoading[index] = false;

      debugPrint(e);
    });
    // _deliveryLoading[index] = false;

    notifyListeners();
  }

  Future<void> getAddressForDeliveryFromLatLng(
      Position position, int index) async {
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      _delivery_controller[index].text =
          '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    }

    // var responseEng = await http.get(
    //   Uri.parse(
    //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    // );
    // if (responseEng.statusCode == 200) {
    //   var result = jsonDecode(responseEng.body);

    //   _delivery_eng_string[index] =
    //       '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    // }
    _deliveryLoading[index] = false;
    if (_delivery_controller[index].text.isNotEmpty &&
        _pickup_controller[index].text.isNotEmpty) {
      getPolyPoints(index);
    } else {
      animateCameraToLatLng(index);
    }
    notifyListeners();
  }

  void addstoppoint(int index) {
    TextEditingController stoppoint_controller = TextEditingController();
    _stoppoints_controller[index].add(stoppoint_controller);
    _stoppoints_location[index].add("");
    _stoppoints_eng_string[index].add("");
    _stoppoints_latlng[index].add(null);
    _stoppoints_position[index].add(null);
    _stoppoints_place[index].add(null);
    _stoppointsLoading[index].add(false);
    _stoppointstextLoading[index].add(false);
    _stoppointsPosition[index].add(false);
    _stop_marker[index]
        .add(Marker(markerId: MarkerId("stop${_stop_marker[index].length}")));
    notifyListeners();
  }

  void removestoppoint(int index, int index2) {
    _stoppoints_controller[index].removeAt(index2);
    _stoppoints_eng_string[index].removeAt(index2);
    _stoppoints_location[index].removeAt(index2);
    _stoppoints_latlng[index].removeAt(index2);
    _stoppoints_position[index].removeAt(index2);
    _stoppoints_place[index].removeAt(index2);
    _stoppointsLoading[index].removeAt(index2);
    _stoppointstextLoading[index].removeAt(index2);
    _stoppointsPosition[index].removeAt(index2);
    _stop_marker[index].removeAt(index2);
    notifyListeners();
  }

  void addpath() {
    TextEditingController commodityWeight_controller = TextEditingController();
    TextEditingController commodityName_controller = TextEditingController();
    _scrollController.add(ScrollController());
    _commodityWeight_controllers.add([commodityWeight_controller]);
    _commodityName_controllers.add([commodityName_controller]);
    _commodityCategories.add([0]);

    _trucks.add(null);

    _pathError.add(false);
    _truckError.add(false);
    _dateError.add(false);
    _commodityCategory_controller.add([null]);
    _pathes.add([]);
    _addShipmentformKey.add(GlobalKey<FormState>());

    _pickup_controller.add(TextEditingController());
    _pickup_eng_string.add("");
    _delivery_controller.add(TextEditingController());
    _delivery_eng_string.add("");
    _stoppoints_controller.add([]);
    _stoppoints_eng_string.add([]);

    _pickup_location.add("");
    _delivery_location.add("");
    _stoppoints_location.add([""]);

    _pickup_latlng.add(null);
    _delivery_latlng.add(null);
    _stoppoints_latlng.add([null]);

    _pickup_position.add(null);
    _delivery_position.add(null);
    _stoppoints_position.add([null]);

    _pickup_place.add(null);
    _delivery_place.add(null);
    _stoppoints_place.add([null]);

    _pickupLoading.add(false);
    _pickuptextLoading.add(false);
    _deliveryLoading.add(false);
    _deliverytextLoading.add(false);
    _stoppointsLoading.add([false]);
    _stoppointstextLoading.add([false]);

    _pickupPosition.add(false);
    _deliveryPosition.add(false);
    _stoppointsPosition.add([false]);

    _pickup_marker.add(null);
    _delivery_marker.add(null);
    _stop_marker.add([null]);

    _selectedTruckType.add([]);
    _truckNum.add([]);
    _truckNumController.add([]);

    _date_controller.add(TextEditingController());
    _time_controller.add(TextEditingController());
    _loadDate.add(DateTime.now());
    _loadTime.add(DateTime.now());

    _count.add(0);
    _distance.add(0);
    _period.add("");
    _countpath++;
    _count[_countpath - 1]++;
    notifyListeners();
  }

  void removePath(int index) {
    _scrollController.removeAt(index);
    _commodityWeight_controllers.removeAt(index);
    _commodityName_controllers.removeAt(index);
    _commodityCategories.removeAt(index);

    _trucks.removeAt(index);

    _pathError.removeAt(index);
    _truckError.removeAt(index);
    _dateError.removeAt(index);
    _commodityCategory_controller.removeAt(index);
    _pathes.removeAt(index);
    _addShipmentformKey.removeAt(index);

    _pickup_controller.removeAt(index);
    _pickup_eng_string.removeAt(index);
    _delivery_controller.removeAt(index);
    _delivery_eng_string.removeAt(index);
    _stoppoints_controller.removeAt(index);
    _stoppoints_eng_string.removeAt(index);

    _pickup_location.removeAt(index);
    _delivery_location.removeAt(index);
    _stoppoints_location.removeAt(index);

    _pickup_latlng.removeAt(index);
    _delivery_latlng.removeAt(index);
    _stoppoints_latlng.removeAt(index);

    _pickup_position.removeAt(index);
    _delivery_position.removeAt(index);
    _stoppoints_position.removeAt(index);

    _pickup_place.removeAt(index);
    _delivery_place.removeAt(index);
    _stoppoints_place.removeAt(index);

    _pickupLoading.removeAt(index);
    _deliveryLoading.removeAt(index);
    _pickuptextLoading.removeAt(index);
    _deliverytextLoading.removeAt(index);
    _stoppointsLoading.removeAt(index);
    _stoppointstextLoading.removeAt(index);

    _pickupPosition.removeAt(index);
    _deliveryPosition.removeAt(index);
    _stoppointsPosition.removeAt(index);

    _pickup_marker.removeAt(index);
    _delivery_marker.removeAt(index);
    _stop_marker.removeAt(index);

    _selectedTruckType.removeAt(index);
    _truckNum.removeAt(index);
    _truckNumController.removeAt(index);

    _date_controller.removeAt(index);
    _time_controller.removeAt(index);
    _loadDate.removeAt(index);
    _loadTime.removeAt(index);

    _distance.removeAt(index);
    _period.removeAt(index);
    _count.removeAt(index);
    _countpath--;
    notifyListeners();
  }

  void additem(int index) {
    TextEditingController commodityWeight_controller = TextEditingController();
    TextEditingController commodityName_controller = TextEditingController();

    _commodityWeight_controllers[index].add(commodityWeight_controller);
    _commodityName_controllers[index].add(commodityName_controller);
    _commodityCategories[index].add(0);
    _commodityCategory_controller[index].add(null);

    _count[index]++;
    notifyListeners();
  }

  void removeitem(int index, int index2) {
    _commodityWeight_controllers[index].removeAt(index2);
    _commodityName_controllers[index].removeAt(index2);
    _commodityCategories[index].removeAt(index2);
    _commodityCategory_controller[index].removeAt(index2);
    _count[index]--;
    notifyListeners();
  }

  setTruck(KTruck truck, int index) {
    _trucks[index] = truck;
    setTruckError(false, index);

    notifyListeners();
  }

  // Add a shipment
  void addShipment(Shipmentv2 shipment) {
    _shipment = shipment;
    notifyListeners();
  }

  // Remove the shipment
  void removeShipment() {
    _shipment = null;
    notifyListeners();
  }

  // Add a sub-shipment
  void addSubShipment(SubShipment subShipment) {
    if (_shipment != null) {
      _shipment!.subshipments ??= [];
      _shipment!.subshipments!.add(subShipment);
      notifyListeners();
    }
  }

  // Remove a sub-shipment
  void removeSubShipment(int index) {
    if (_shipment != null &&
        index >= 0 &&
        index < _shipment!.subshipments!.length) {
      _shipment!.subshipments!.removeAt(index);
      notifyListeners();
    }
  }

  // Add a shipment item to a sub-shipment
  void addShipmentItem(int subShipmentIndex, ShipmentItems shipmentItem) {
    if (_shipment != null &&
        subShipmentIndex >= 0 &&
        subShipmentIndex < _shipment!.subshipments!.length) {
      _shipment!.subshipments![subShipmentIndex].shipmentItems ??= [];
      _shipment!.subshipments![subShipmentIndex].shipmentItems!
          .add(shipmentItem);
      notifyListeners();
    }
  }

  // Remove a shipment item from a sub-shipment
  void removeShipmentItem(int subShipmentIndex, int itemIndex) {
    if (_shipment != null &&
        subShipmentIndex >= 0 &&
        subShipmentIndex < _shipment!.subshipments!.length &&
        itemIndex >= 0 &&
        itemIndex <
            _shipment!.subshipments![subShipmentIndex].shipmentItems!.length) {
      _shipment!.subshipments![subShipmentIndex].shipmentItems!
          .removeAt(itemIndex);
      notifyListeners();
    }
  }

  // Add a path point to a sub-shipment
  void addPathPoint(int subShipmentIndex, PathPoint pathPoint) {
    if (_shipment != null &&
        subShipmentIndex >= 0 &&
        subShipmentIndex < _shipment!.subshipments!.length) {
      _shipment!.subshipments![subShipmentIndex].pathpoints ??= [];
      _shipment!.subshipments![subShipmentIndex].pathpoints!.add(pathPoint);
      notifyListeners();
    }
  }

  // Remove a path point from a sub-shipment
  void removePathPoint(int subShipmentIndex, int pointIndex) {
    if (_shipment != null &&
        subShipmentIndex >= 0 &&
        subShipmentIndex < _shipment!.subshipments!.length &&
        pointIndex >= 0 &&
        pointIndex <
            _shipment!.subshipments![subShipmentIndex].pathpoints!.length) {
      _shipment!.subshipments![subShipmentIndex].pathpoints!
          .removeAt(pointIndex);
      notifyListeners();
    }
  }

  void setPathError(bool value, int index) {
    _pathError[index] = value;
    notifyListeners();
  }

  void setTruckError(bool value, int index) {
    _truckError[index] = value;
    notifyListeners();
  }

  void setDateError(bool value, int index) {
    _dateError[index] = value;
    notifyListeners();
  }
}
