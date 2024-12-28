// ignore_for_file: prefer_final_fields, non_constant_identifier_names

import 'dart:convert';

import 'package:camion/constants/text_constants.dart';
import 'package:camion/data/models/place_model.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/models/truck_type_model.dart';
import 'package:camion/data/services/places_service.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:camion/views/widgets/snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;

class AddMultiShipmentProvider extends ChangeNotifier {
/*----------------------------------*/
  // google map
  GoogleMapController? _mapController2;
  GoogleMapController? get mapController2 => _mapController2;

  late GoogleMapController _mapController;
  GoogleMapController get mapController => _mapController;

  LatLng _center = const LatLng(35.363149, 35.932120);
  LatLng get center => _center;

  double _zoom = 13.0;
  double get zoom => _zoom;

/*----------------------------------*/

  // commodities
  List<GlobalKey<FormState>> _addShipmentformKey = [GlobalKey<FormState>()];
  List<GlobalKey<FormState>> get addShipmentformKey => _addShipmentformKey;

  List<List<TextEditingController>> _commodityWeight_controllers = [
    [TextEditingController()]
  ];
  List<List<TextEditingController>> get commodityWeight_controllers =>
      _commodityWeight_controllers;

  List<double> _totalWeight = [0.0];

  List<double> get totalWeight => _totalWeight;

  List<List<TextEditingController>> _commodityName_controllers = [
    [TextEditingController()]
  ];
  List<List<TextEditingController>> get commodityName_controllers =>
      _commodityName_controllers;

  List<int> _count = [1];
  List<int> get count => _count;

/*----------------------------------*/
// add path

  List<LatLng> _pathes = [];
  List<LatLng> get pathes => _pathes;

  TextEditingController _pickup_controller = TextEditingController();
  TextEditingController get pickup_controller => _pickup_controller;

  String _pickup_statename = "";
  String get pickup_statename => _pickup_statename;

  String _pickup_placeId = "";
  String get pickup_placeId => _pickup_placeId;

  String _pickup_location = "";
  String get pickup_location => _pickup_location;

  LatLng? _pickup_latlng;
  LatLng? get pickup_latlng => _pickup_latlng;

  Marker? _pickup_marker = const Marker(markerId: MarkerId("pickup"));
  Marker? get pickup_marker => _pickup_marker;

  Position? _pickup_position;
  Position? get pickup_position => _pickup_position;

  Place? _pickup_place;
  Place? get pickup_place => _pickup_place;

  TextEditingController _delivery_controller = TextEditingController();
  TextEditingController get delivery_controller => _delivery_controller;

  String _delivery_statename = "";
  String get delivery_statename => _delivery_statename;

  String _delivery_placeId = "";
  String get delivery_placeId => _delivery_placeId;

  String _delivery_location = "";
  String get delivery_location => _delivery_location;

  Marker? _delivery_marker = const Marker(markerId: MarkerId("delivery"));
  Marker? get delivery_marker => _delivery_marker;

  LatLng? _delivery_latlng;
  LatLng? get delivery_latlng => _delivery_latlng;

  Place? _delivery_place;
  Place? get delivery_place => _delivery_place;

  List<TextEditingController> _stoppoints_controller = [];
  List<TextEditingController> get stoppoints_controller =>
      _stoppoints_controller;

  List<String> _stoppoints_location = [];
  List<String> get stoppoints_location => _stoppoints_location;

  List<LatLng?> _stoppoints_latlng = [];
  List<LatLng?> get stoppoints_latlng => _stoppoints_latlng;

  List<Marker?> _stop_marker = [];
  List<Marker?> get stop_marker => _stop_marker;

  double _distance = 0;
  double get distance => _distance;

  String _period = "";
  String get period => _period;

  TruckType? _truckType;
  TruckType? get truckType => _truckType;

  List<Position?> _stoppoints_position = [];
  List<Position?> get stoppoints_position => _stoppoints_position;

  Position? _delivery_position;
  Position? get delivery_position => _delivery_position;

  List<Place?> _stoppoints_place = [];
  List<Place?> get stoppoints_place => _stoppoints_place;

  bool _pickupLoading = false;
  bool get pickupLoading => _pickupLoading;

  bool _deliveryLoading = false;
  bool get deliveryLoading => _deliveryLoading;

  List<bool> _stoppointsLoading = [];
  List<bool> get stoppointsLoading => _stoppointsLoading;

  bool _pickuptextLoading = false;
  bool get pickuptextLoading => _pickuptextLoading;

  bool _deliverytextLoading = false;
  bool get deliverytextLoading => _deliverytextLoading;

  List<bool> _stoppointstextLoading = [];
  List<bool> get stoppointstextLoading => _stoppointstextLoading;

  bool _pickupPosition = false;
  bool get pickupPosition => _pickupPosition;

  bool _deliveryPosition = false;
  bool get deliveryPosition => _deliveryPosition;

  List<bool> _stoppointsPosition = [];
  List<bool> get stoppointsPosition => _stoppointsPosition;

  int _countpath = 1;
  int get countpath => _countpath;

  bool _pathConfirm = false;
  bool get pathConfirm => _pathConfirm;

  /*trucks */

  List<KTruck?> _trucks = [null];
  List<KTruck?> get trucks => _trucks;

  List<bool> _truckConfirm = [false];
  List<bool> get truckConfirm => _truckConfirm;

  bool _truckTypeError = false;
  bool get truckTypeError => _truckTypeError;

  List<bool> _truckError = [false];
  List<bool> get truckError => _truckError;

  bool _pathError = false;
  bool get pathError => _pathError;

  List<bool> _dateError = [false];
  List<bool> get dateError => _dateError;

  List<TruckType?> _selectedTruckType = [null];
  List<TruckType?> get selectedTruckType => _selectedTruckType;

  List<int> _selectedTruckTypeId = [-1];
  List<int> get selectedTruckTypeId => _selectedTruckTypeId;

  List<int> _selectedTruckTypeNum = [];
  List<int> get selectedTruckTypeNum => _selectedTruckTypeNum;

  List<TruckType> _truckTypeGroup = [];
  List<TruckType> get truckTypeGroup => _truckTypeGroup;

  List<int> _truckTypeGroupId = [];
  List<int> get truckTypeGroupId => _truckTypeGroupId;

  List<TextEditingController> _truckTypeController = [];
  List<TextEditingController> get truckTypeController => _truckTypeController;

  List<KTruck> _selectedTruck = [];
  List<KTruck> get selectedTruck => _selectedTruck;

  List<int> _selectedTruckId = [];
  List<int> get selectedTruckId => _selectedTruckId;

  List<DateTime> _loadDate = [DateTime.now()];
  List<DateTime> get loadDate => _loadDate;

  List<DateTime> _loadTime = [DateTime.now()];
  List<DateTime> get loadTime => _loadTime;

  List<TextEditingController> _time_controller = [TextEditingController()];
  List<TextEditingController> get time_controller => _time_controller;

  List<TextEditingController> _date_controller = [TextEditingController()];
  List<TextEditingController> get date_controller => _date_controller;

  void initForm() {
    // Reset Google Map-related fields
    _center = const LatLng(35.363149, 35.932120);
    _zoom = 13.0;

    // Reset commodity-related fields
    _commodityWeight_controllers = [
      [TextEditingController()]
    ];
    _commodityName_controllers = [
      [TextEditingController()]
    ];
    _totalWeight = [0.0];
    _addShipmentformKey = [GlobalKey<FormState>()];
    _count = [1];

    // Reset path-related fields
    _pathes = [];
    _pickup_controller.clear();
    _pickup_statename = "";
    _pickup_placeId = "";
    _pickup_location = "";
    _pickup_latlng = null;
    _pickup_marker = const Marker(markerId: MarkerId("pickup"));
    _pickup_position = null;
    _pickup_place = null;

    _delivery_controller.clear();
    _delivery_statename = "";
    _delivery_placeId = "";
    _delivery_location = "";
    _delivery_latlng = null;
    _delivery_marker = const Marker(markerId: MarkerId("delivery"));
    _delivery_position = null;
    _delivery_place = null;

    _stoppoints_controller = [];
    _stoppoints_location = [];
    _stoppoints_latlng = [];
    _stop_marker = [];
    _stoppoints_position = [];
    _stoppoints_place = [];

    _countpath = 1;

    // Reset truck-related fields
    _truckType = null;
    _trucks = [null];
    _selectedTruckType = [null];
    _selectedTruckTypeId = [-1];
    _truckConfirm = [false];
    _truckError = [false];
    _truckTypeError = false;

    _selectedTruckTypeNum = [];
    _truckTypeGroup = [];
    _truckTypeGroupId = [];
    _truckTypeController = [];

    _selectedTruck = [];
    _selectedTruckId = [-1];

    // Reset date/time-related fields
    _loadDate = [DateTime.now()];
    _loadTime = [DateTime.now()];
    _time_controller = [TextEditingController()];
    _date_controller = [TextEditingController()];

    // Reset errors
    _pathError = false;
    _dateError = [false];

    // Reset loading indicators
    _pickupLoading = false;
    _deliveryLoading = false;
    _stoppointsLoading = [];
    _pickuptextLoading = false;
    _deliverytextLoading = false;
    _stoppointstextLoading = [];

    // Reset boolean flags
    _pickupPosition = false;
    _deliveryPosition = false;
    _stoppointsPosition = [];
    _pathConfirm = false;

    // Reset other fields
    _distance = 0;
    _period = "";
  }

  calculateTotalWeight(int index) {
    _totalWeight[index] = 0;
    for (var element in _commodityWeight_controllers[index]) {
      if (element.text.isNotEmpty) {
        _totalWeight[index] +=
            double.parse(element.text.replaceAll(",", "")).toInt();
      }
    }
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

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PolylineWayPoint> waypoints = [];
    for (var element in _stoppoints_location) {
      waypoints.add(PolylineWayPoint(location: element, stopOver: true));
    }

    await polylinePoints
        .getRouteBetweenCoordinates(
      "AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w",
      PointLatLng(
        _pickup_latlng!.latitude,
        _pickup_latlng!.longitude,
      ),
      PointLatLng(
        _delivery_latlng!.latitude,
        _delivery_latlng!.longitude,
      ),
      wayPoints: waypoints,
    )
        .then(
      (result) {
        _pathes = [];
        // _isThereARoute[index] = true;
        if (result.points.isNotEmpty) {
          // _isThereARoute = true;
          // _isThereARouteError = false;
          // _thereARoute = true;
          result.points.forEach((element) {
            _pathes.add(
              LatLng(
                element.latitude,
                element.longitude,
              ),
            );
          });
        }
        initMapbounds();
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
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${_delivery_latlng!.latitude},${_delivery_latlng!.longitude}&origins=${_pickup_latlng!.latitude},${_pickup_latlng!.longitude}&key=AIzaSyCl_H8BXqnTm32umdYVQrKMftTiFpRqd-c&mode=DRIVING');

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      _distance = double.parse(result["rows"][0]['elements'][0]['distance']
              ['text']
          .replaceAll(" km", ""));
      _period = result["rows"][0]['elements'][0]['duration']['text'];
    }
    notifyListeners();
  }

  initMapbounds() {
    if (_pickup_controller.text.isNotEmpty &&
        _delivery_controller.text.isNotEmpty) {
      setPathError(false);
      List<Marker> markers = [];
      var pickuplocation = _pickup_location.split(",");
      markers.add(
        Marker(
          markerId: const MarkerId("pickup"),
          position: LatLng(
              double.parse(pickuplocation[0]), double.parse(pickuplocation[1])),
        ),
      );
      for (var i = 0; i < _stoppoints_location.length; i++) {
        var stopLocation = _stoppoints_location[i].split(',');
        markers.add(
          Marker(
            markerId: MarkerId("stop$i"),
            position: LatLng(
                double.parse(stopLocation[0]), double.parse(stopLocation[1])),
          ),
        );
      }

      var deliverylocation = _delivery_location.split(",");

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
    _time_controller[index].text = '${intl.DateFormat.jm().format(time)} ';
    _loadTime[index] = time;
    notifyListeners();
  }

  setLoadDate(DateTime date, String lang, int index) {
    var mon = date.month;
    var month = lang == "en"
        ? TextConstants.monthsEn[mon - 1]
        : TextConstants.monthsAr[mon - 1];
    _date_controller[index].text = '${date.year}-$month-${date.day}';
    _loadDate[index] = date;
    notifyListeners();
  }

  void setTruckType(TruckType truckType, int pathIndex) {
    // Check if the truck type is already selected for this path
    if (_selectedTruckTypeId[pathIndex] != truckType.id) {
      // If the current path has a different truck type, decrease the count of the previously selected type
      if (_selectedTruckTypeId[pathIndex] != -1) {
        int oldTypeIndex =
            _truckTypeGroupId.indexOf(_selectedTruckTypeId[pathIndex]);
        if (oldTypeIndex != -1) {
          _selectedTruckTypeNum[oldTypeIndex]--;
          // If the count becomes zero, remove the truck type from the group
          if (_selectedTruckTypeNum[oldTypeIndex] == 0) {
            _truckTypeGroup.removeAt(oldTypeIndex);
            _truckTypeGroupId.removeAt(oldTypeIndex);
            _selectedTruckTypeNum.removeAt(oldTypeIndex);
          }
        }
      }

      // Now, add the new truck type for the path
      if (!_truckTypeGroupId.contains(truckType.id)) {
        // If the new truck type isn't already in the selected group, add it
        _truckTypeGroup.add(truckType);
        _truckTypeGroupId.add(truckType.id!);
        _selectedTruckTypeNum.add(1);
      } else {
        // If the new truck type is already selected elsewhere, just increase the count
        int newTypeIndex = _truckTypeGroupId.indexOf(truckType.id!);
        _selectedTruckTypeNum[newTypeIndex]++;
      }

      // Update the selected truck type and ID for the current path
      _selectedTruckType[pathIndex] = truckType;
      _selectedTruckTypeId[pathIndex] = truckType.id!;
    }
    print("TruckType$_selectedTruckTypeId");
    print("TypeGroup$_truckTypeGroupId");
    print("TruckTypeNum$_selectedTruckTypeNum");

    // Notify listeners for state update
    notifyListeners();
  }

  void addSelectedTruck(KTruck truck, int truckTypeId) {
    var index = _truckTypeGroupId.indexOf(truckTypeId);

    // Prevent adding the truck if the truck type number is 0
    if (index != -1 && _selectedTruckTypeNum[index] > 0) {
      _selectedTruckId.add(truck.id!); // Add the truck ID
      _selectedTruck.add(truck); // Add the truck itself
      _selectedTruckTypeNum[index]--; // Decrease the truck type count
    } else {
      // Optional: Show a message or handle the case where the truck cannot be added
      print("Cannot add truck: no available selections for this truck type.");
    }

    notifyListeners(); // Notify listeners to update the UI
  }

  void removeSelectedTruck(KTruck truck, int truckTypeId) {
    var index = _truckTypeGroupId.indexOf(truckTypeId);

    // Remove the truck and increment the truck type number
    if (index != -1) {
      _selectedTruckId.remove(truck.id); // Remove the truck ID
      _selectedTruck.remove(truck); // Remove the truck itself
      _selectedTruckTypeNum[index]++; // Increase the truck type count
    }

    notifyListeners(); // Notify listeners to update the UI
  }

  void addpath() {
    TextEditingController commodityWeight_controller = TextEditingController();
    TextEditingController commodityName_controller = TextEditingController();
    _commodityWeight_controllers.add([commodityWeight_controller]);
    _commodityName_controllers.add([commodityName_controller]);
    _addShipmentformKey.add(GlobalKey<FormState>());

    _trucks.add(null);

    _truckConfirm.add(false);
    _truckError.add(false);
    _dateError.add(false);
    _totalWeight.add(0.0);

    _selectedTruckType.add(null);
    _selectedTruckTypeId.add(0);

    _date_controller.add(TextEditingController());
    _time_controller.add(TextEditingController());
    _loadDate.add(DateTime.now());
    _loadTime.add(DateTime.now());

    _count.add(0);
    _countpath++;
    _count[_countpath - 1]++;
    notifyListeners();
  }

  void removePath(int index) {
    _commodityWeight_controllers.removeAt(index);
    _commodityName_controllers.removeAt(index);
    _totalWeight.removeAt(index);

    _trucks.removeAt(index);

    _truckError.removeAt(index);
    _pathes.removeAt(index);
    _dateError.removeAt(index);
    _addShipmentformKey.removeAt(index);

    _selectedTruckType.removeAt(index);
    _selectedTruckTypeId.removeAt(index);

    _date_controller.removeAt(index);
    _time_controller.removeAt(index);
    _loadDate.removeAt(index);
    _loadTime.removeAt(index);

    _count.removeAt(index);
    _countpath--;
    notifyListeners();
  }

  void additem(int index, int index2) {
    TextEditingController commodityWeight_controller = TextEditingController();
    TextEditingController commodityName_controller = TextEditingController();

    _commodityWeight_controllers[index].add(commodityWeight_controller);
    _commodityName_controllers[index].add(commodityName_controller);

    _count[index]++;
    notifyListeners();
  }

  void removeitem(int index, int index2) {
    _commodityWeight_controllers[index].removeAt(index2);
    _commodityName_controllers[index].removeAt(index2);
    _count[index]--;
    notifyListeners();
  }

  setPickupLoading(bool value) {
    _pickupLoading = value;
    notifyListeners();
  }

  setPickupTextLoading(bool value) {
    _pickuptextLoading = value;
    notifyListeners();
  }

  setPickupPositionClick(bool value) {
    _pickupPosition = value;
    notifyListeners();
  }

  setDeliveryLoading(bool value) {
    _deliveryLoading = value;
    notifyListeners();
  }

  setDeliveryTextLoading(bool value) {
    _deliverytextLoading = value;
    notifyListeners();
  }

  setDeliveryPositionClick(bool value) {
    _deliveryPosition = value;
    notifyListeners();
  }

  setStopPointLoading(bool value, int index) {
    _stoppointsLoading[index] = value;
    notifyListeners();
  }

  setStopPointTextLoading(bool value, int index) {
    _stoppointstextLoading[index] = value;
    notifyListeners();
  }

  setStopPointPositionClick(bool value, int index) {
    _stoppointsPosition[index] = value;
    notifyListeners();
  }

  String getAddressName(dynamic result) {
    String str = "";
    List<String> typesToCheck = [
      'route',
      'locality',
      'administrative_area_level_2',
      'administrative_area_level_1'
    ];
    for (var element in result["results"]) {
      if (element['address_components'][0]['types'].contains('route')) {
        for (int i = element['address_components'].length - 1; i >= 0; i--) {
          var element1 = element['address_components'][i];
          if (typesToCheck.any((type) => element1['types'].contains(type)) &&
              element1["long_name"] != null &&
              element1["long_name"] != "طريق بدون اسم") {
            str = str + ('${element1["long_name"]},');
          }
        }
        break;
      }
    }
    if (str.isEmpty) {
      for (int i = result["results"]['address_components'].length - 1;
          i >= 0;
          i--) {
        var element1 = result["results"]['address_components'][i];
        if (typesToCheck.any((type) => element1['types'].contains(type))) {
          str = str + ('${element1["long_name"] ?? ""},');
        }
      }
    }
    return str.replaceRange(str.length - 1, null, ".");
  }

  String getAdministrativeAreaName(dynamic result) {
    String str = "";

    for (var result in result['results']) {
      // List results = result['results'];

      List types = result['types'];
      if (types.contains('administrative_area_level_1')) {
        String name = result['formatted_address']
            .replaceAll("محافظة", "")
            .replaceAll("مُحافظة", "")
            .replaceAll("، سوريا", "");
        print('Place ID for administrative_area_level_1: $name');
        return name; // Stop after finding the first match
      }
    }
    return str;
  }

  String getAdministrativeAreaPlaceId(dynamic result) {
    String str = "";

    if (result['status'] == 'OK') {
      List results = result['results'];

      // Iterate over the results
      for (var result in results) {
        List types = result['types'];
        if (types.contains('administrative_area_level_1')) {
          String placeId = result['place_id'];
          print('Place ID for administrative_area_level_1: $placeId');
          return placeId; // Stop after finding the first match
        }
      }
    } else {
      print('No results found.');
    }
    return str;
  }

  setPickupInfo(dynamic suggestion) async {
    var sLocation = await PlaceService.getPlace(suggestion.placeId);
    _pickup_place = sLocation;
    _pickup_latlng = LatLng(
        sLocation.geometry.location.lat, sLocation.geometry.location.lng);

    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);

      _pickup_controller.text = getAddressName(result);
      _pickup_statename = getAdministrativeAreaName(result);
      _pickup_placeId = getAdministrativeAreaPlaceId(result);
    }
    // var responseEng = await http.get(
    //   Uri.parse(
    //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    // );
    // if (responseEng.statusCode == 200) {
    //   var result = jsonDecode(responseEng.body);

    //   _pickup_eng_string =
    //       '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    // }

    _pickup_location =
        "${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}";

    if (_mapController2 != null) {
      if (_delivery_controller.text.isNotEmpty &&
          _pickup_controller.text.isNotEmpty) {
        getPolyPoints();
      } else {
        animateCameraToLatLng();
      }
    }

    _pickuptextLoading = false;

    notifyListeners();
    if (_mapController2 == null) {
      if (_delivery_controller.text.isNotEmpty &&
          _pickup_controller.text.isNotEmpty) {
        getPolyPoints();
      } else {
        animateCameraToLatLng();
      }
    }
  }

  Future<void> getAddressForPickupFromMapPicker(
    LatLng position,
  ) async {
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      _pickup_latlng = position;
      _pickup_controller.text = getAddressName(result);
      _pickup_statename = getAdministrativeAreaName(result);
      _pickup_placeId = getAdministrativeAreaPlaceId(result);
      _pickup_location = "${position.latitude},${position.longitude}";
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
    if (_delivery_controller.text.isNotEmpty &&
        _pickup_controller.text.isNotEmpty) {
      getPolyPoints();
    } else {
      animateCameraToLatLng();
    }
    _pickupLoading = false;
    notifyListeners();
  }

  animateCameraToLatLng() {
    var pickuplocation = _pickup_location.split(",");

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

  Future<void> getAddressForDeliveryFromMapPicker(LatLng position) async {
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      _delivery_latlng = position;
      _delivery_controller.text = getAddressName(result);
      _delivery_statename = getAdministrativeAreaName(result);
      _delivery_placeId = getAdministrativeAreaPlaceId(result);
      _delivery_location = "${position.latitude},${position.longitude}";
    }

    // var responseEng = await http.get(
    //   Uri.parse(
    //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    // );
    // if (responseEng.statusCode == 200) {
    //   var result = jsonDecode(responseEng.body);

    //   _delivery_eng_string =
    //       '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    // }
    if (_delivery_controller.text.isNotEmpty &&
        _pickup_controller.text.isNotEmpty) {
      getPolyPoints();
    } else {
      animateCameraToLatLng();
    }
    _deliveryLoading = false;
    notifyListeners();
  }

  setDeliveryInfo(dynamic suggestion) async {
    // _deliverytextLoading[index] = true;
    // notifyListeners();
    var sLocation = await PlaceService.getPlace(suggestion.placeId);
    _delivery_place = sLocation;
    _delivery_latlng = LatLng(
        sLocation.geometry.location.lat, sLocation.geometry.location.lng);
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);

      _delivery_controller.text = getAddressName(result);
      _delivery_statename = getAdministrativeAreaName(result);
      _delivery_placeId = getAdministrativeAreaPlaceId(result);
    }
    // var responseEng = await http.get(
    //   Uri.parse(
    //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    // );
    // if (responseEng.statusCode == 200) {
    //   var result = jsonDecode(responseEng.body);

    //   _delivery_eng_string =
    //       '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    // }
    _delivery_location =
        "${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}";
    if (_delivery_controller.text.isNotEmpty &&
        _pickup_controller.text.isNotEmpty) {
      getPolyPoints();
    } else {
      animateCameraToLatLng();
    }
    _deliverytextLoading = false;

    notifyListeners();
  }

  setStopPointInfo(dynamic suggestion, int index) async {
    // _stoppointstextLoading[index][index2] = true;
    // notifyListeners();
    var sLocation = await PlaceService.getPlace(suggestion.placeId);
    _stoppoints_place[index] = sLocation;
    _stoppoints_latlng[index] = LatLng(
        sLocation.geometry.location.lat, sLocation.geometry.location.lng);
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);

      _stoppoints_controller[index].text = getAddressName(result);
    }

    // var responseEng = await http.get(
    //   Uri.parse(
    //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    // );
    // if (responseEng.statusCode == 200) {
    //   var result = jsonDecode(responseEng.body);

    //   _stoppoints_eng_string[index] =
    //       '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    // }
    _stoppoints_location[index] =
        "${sLocation.geometry.location.lat},${sLocation.geometry.location.lng}";
    if (_delivery_controller.text.isNotEmpty &&
        _pickup_controller.text.isNotEmpty) {
      getPolyPoints();
    } else {
      animateCameraToLatLng();
    }
    _stoppointstextLoading[index] = false;

    notifyListeners();
  }

  Future<bool> _handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showCustomSnackBar(
        context: context,
        backgroundColor: Colors.orange,
        message: 'خدمة تحديد الموقع غير مفعلة..',
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
        showCustomSnackBar(
          context: context,
          backgroundColor: Colors.orange,
          message: 'Location permissions are denied',
        );
        _pickupLoading = false;

        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      showCustomSnackBar(
        context: context,
        backgroundColor: Colors.orange,
        message:
            'Location permissions are permanently denied, we cannot request permissions.',
      );
      _pickupLoading = false;

      return false;
    }
    return true;
  }

  Future<void> getCurrentPositionForPickup(BuildContext context) async {
    final hasPermission = await _handleLocationPermission(context);

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      _pickup_latlng = LatLng(position.latitude, position.longitude);
      _pickup_position = position;
      _pickup_location = "${position.latitude},${position.longitude}";
      getAddressForPickupFromLatLng(
        position,
      );
    }).catchError((e) {
      _pickupLoading = false;
    });
    // _pickupLoading[index] = false;

    notifyListeners();
  }

  Future<void> getAddressForPickupFromLatLng(
    Position position,
  ) async {
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);

      _pickup_controller.text = getAddressName(result);
      _pickup_statename = getAdministrativeAreaName(result);
      _pickup_placeId = getAdministrativeAreaPlaceId(result);
    }
    _pickupLoading = false;
    if (_delivery_controller.text.isNotEmpty &&
        _pickup_controller.text.isNotEmpty) {
      getPolyPoints();
    } else {
      animateCameraToLatLng();
    }
    notifyListeners();
  }

  Future<void> getCurrentPositionForStop(
      BuildContext context, int index) async {
    final hasPermission = await _handleLocationPermission(context);

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      _stoppoints_latlng[index] = LatLng(position.latitude, position.longitude);
      _stoppoints_position[index] = position;
      _stoppoints_location[index] =
          "${position.latitude},${position.longitude}";
      getAddressForStopPointFromLatLng(
        position,
        index,
      );
    }).catchError((e) {
      _pickupLoading = false;
    });
    notifyListeners();
  }

  Future<void> getAddressForStopPointFromLatLng(
      Position position, int index) async {
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);

      _stoppoints_controller[index].text = getAddressName(result);
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
    _pickupLoading = false;

    if (_delivery_controller.text.isNotEmpty &&
        _pickup_controller.text.isNotEmpty) {
      getPolyPoints();
    } else {
      animateCameraToLatLng();
    }
    notifyListeners();
  }

  Future<void> getCurrentPositionForDelivery(BuildContext context) async {
    final hasPermission = await _handleLocationPermission(context);
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      _delivery_latlng = LatLng(position.latitude, position.longitude);
      _delivery_position = position;
      _delivery_location = "${position.latitude},${position.longitude}";
      getAddressForDeliveryFromLatLng(
        position,
      );
    }).catchError((e) {
      _deliveryLoading = false;
    });
    // _deliveryLoading[index] = false;

    notifyListeners();
  }

  Future<void> getAddressForDeliveryFromLatLng(
    Position position,
  ) async {
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      _delivery_controller.text = getAddressName(result);
      _delivery_statename = getAdministrativeAreaName(result);
      _delivery_placeId = getAdministrativeAreaPlaceId(result);
    }

    // var responseEng = await http.get(
    //   Uri.parse(
    //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    // );
    // if (responseEng.statusCode == 200) {
    //   var result = jsonDecode(responseEng.body);

    //   _delivery_eng_string =
    //       '${(result["results"][0]["address_components"][3]["long_name"]) ?? ""},${(result["results"][0]["address_components"][1]["long_name"]) ?? ""}';
    // }
    _deliveryLoading = false;
    if (_delivery_controller.text.isNotEmpty &&
        _pickup_controller.text.isNotEmpty) {
      getPolyPoints();
    } else {
      animateCameraToLatLng();
    }
    notifyListeners();
  }

  void addstoppoint() {
    if (_stoppoints_controller.length > 0) {
      if (_stoppoints_controller[_stoppoints_controller.length - 1]
          .text
          .isNotEmpty) {
        TextEditingController stoppoint_controller = TextEditingController();
        _stoppoints_controller.add(stoppoint_controller);
        _stoppoints_location.add("");
        _stoppoints_latlng.add(null);
        _stoppoints_position.add(null);
        _stoppoints_place.add(null);
        _stoppointsLoading.add(false);
        _stoppointstextLoading.add(false);
        _stoppointsPosition.add(false);
        _stop_marker
            .add(Marker(markerId: MarkerId("stop${_stop_marker.length}")));
      }
    } else {
      TextEditingController stoppoint_controller = TextEditingController();
      _stoppoints_controller.add(stoppoint_controller);
      _stoppoints_location.add("");
      _stoppoints_latlng.add(null);
      _stoppoints_position.add(null);
      _stoppoints_place.add(null);
      _stoppointsLoading.add(false);
      _stoppointstextLoading.add(false);
      _stoppointsPosition.add(false);
      _stop_marker
          .add(Marker(markerId: MarkerId("stop${_stop_marker.length}")));
    }
    notifyListeners();
  }

  void removestoppoint(int index2) {
    _stoppoints_controller.removeAt(index2);
    _stoppoints_location.removeAt(index2);
    _stoppoints_latlng.removeAt(index2);
    _stoppoints_position.removeAt(index2);
    _stoppoints_place.removeAt(index2);
    _stoppointsLoading.removeAt(index2);
    _stoppointstextLoading.removeAt(index2);
    _stoppointsPosition.removeAt(index2);
    _stop_marker.removeAt(index2);
    notifyListeners();
  }

  setTruck(KTruck truck, int index) {
    // _trucks[index] = truck;
    setTruckError(false, index);

    notifyListeners();
  }

  void setPathError(bool value) {
    _pathError = value;
    notifyListeners();
  }

  void setPathConfirm(bool value) {
    _pathConfirm = value;
    notifyListeners();
  }

  void setTruckConfirm(bool value, int index) {
    _truckConfirm[index] = value;
    notifyListeners();
  }

  void setTruckTypeError(bool value) {
    _truckTypeError = value;
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
