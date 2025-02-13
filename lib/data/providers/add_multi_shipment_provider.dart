// ignore_for_file: prefer_final_fields, non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:camion/constants/text_constants.dart';
import 'package:camion/data/models/place_model.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/models/truck_type_model.dart';
import 'package:camion/data/services/map_service.dart';
import 'package:camion/data/services/places_service.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:camion/views/widgets/snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

class AddMultiShipmentProvider extends ChangeNotifier {
/*----------------------------------*/
  // google map
  GoogleMapController? _mapController2;
  GoogleMapController? get mapController2 => _mapController2;

  late GoogleMapController _mapController;
  GoogleMapController get mapController => _mapController;

  LatLng _center = const LatLng(35.363149, 35.932120);
  LatLng get center => _center;

  double _zoom = 11.0;
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

  List<List<LatLng>> _subPathes = [[]];
  List<List<LatLng>> get subPathes => _subPathes;

  List<String> _stoppoints_statename = ["", ""];
  List<String> get stoppoints_statename => _stoppoints_statename;

  List<String> _stoppoints_placeId = ["", ""];
  List<String> get stoppoints_placeId => _stoppoints_placeId;

  List<TextEditingController> _stoppoints_controller = [
    TextEditingController(text: "أضف عنوان نقطة تحميل/تفريغ"),
    TextEditingController(text: "أضف عنوان نقطة تحميل/تفريغ")
  ];
  List<TextEditingController> get stoppoints_controller =>
      _stoppoints_controller;

  List<String> _stoppoints_location = ["", ""];
  List<String> get stoppoints_location => _stoppoints_location;

  List<LatLng?> _stoppoints_latlng = [null, null];
  List<LatLng?> get stoppoints_latlng => _stoppoints_latlng;

  List<Marker> _stop_marker = [
    const Marker(markerId: MarkerId("0")),
    const Marker(markerId: MarkerId("1"))
  ];
  List<Marker> get stop_marker => _stop_marker;

  double _distance = 0;
  double get distance => _distance;

  String _period = "";
  String get period => _period;

  List<double> _subDistance = [0];
  List<double> get subDistance => _subDistance;

  List<int> _subPeriod = [0];
  List<int> get subPeriod => _subPeriod;

  TruckType? _truckType;
  TruckType? get truckType => _truckType;

  List<Position?> _stoppoints_position = [null, null];
  List<Position?> get stoppoints_position => _stoppoints_position;

  List<Place?> _stoppoints_place = [null, null];
  List<Place?> get stoppoints_place => _stoppoints_place;

  List<bool> _stoppointsLoading = [false, false];
  List<bool> get stoppointsLoading => _stoppointsLoading;

  List<bool> _stoppointstextLoading = [false, false];
  List<bool> get stoppointstextLoading => _stoppointstextLoading;

  List<bool> _stoppointsPosition = [false, false];
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

  double _topPosition = 0.0;
  double get topPosition => _topPosition;

  double _bottomPathStatisticPosition = 0.0;
  double get bottomPathStatisticPosition => _bottomPathStatisticPosition;

  double _bottomPosition = -900.0;
  double get bottomPosition => _bottomPosition;

  double _toptextfeildPosition = -250;
  double get toptextfeildPosition => _toptextfeildPosition;

  bool _pickMapMode = false;
  bool get pickMapMode => _pickMapMode;

  bool _showStores = false;
  bool get showStores => _showStores;

  List<Map<String, dynamic>> _cachedSearchResults = [];
  List<Map<String, dynamic>> get cachedSearchResults => _cachedSearchResults;

  List<Map<String, dynamic>> _pickupCachedSearchResults = [];
  List<Map<String, dynamic>> get pickupCachedSearchResults =>
      _pickupCachedSearchResults;

  Future<void> _saveCachedResults() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_cachedSearchResults);
    await prefs.setString('cached_search_results', jsonString);
  }

  Future<void> _loadCachedResults() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cached_search_results');
    if (jsonString != null) {
      _cachedSearchResults = List<Map<String, dynamic>>.from(
        jsonDecode(jsonString),
      );
      notifyListeners();
    }
  }

  Future<void> _savePickUpCachedResults() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_pickupCachedSearchResults);
    await prefs.setString('pickup_cached_search_results', jsonString);
  }

  Future<void> _loadPickUpCachedResults() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('pickup_cached_search_results');
    if (jsonString != null) {
      _pickupCachedSearchResults = List<Map<String, dynamic>>.from(
        jsonDecode(jsonString),
      );
      notifyListeners();
    }
  }

  void initProvider() async {
    await _loadCachedResults();
    await _loadPickUpCachedResults();
  }

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
    _subPathes = [[]];

    _stoppoints_controller = [
      TextEditingController(text: "أضف عنوان نقطة تحميل/تفريغ"),
      TextEditingController(text: "أضف عنوان نقطة تحميل/تفريغ")
    ];
    _stoppoints_statename = ["", ""];
    _stoppoints_placeId = ["", ""];
    _stoppoints_location = ["", ""];
    _stoppoints_latlng = [null, null];
    _stop_marker = [
      const Marker(markerId: MarkerId("0")),
      const Marker(markerId: MarkerId("1"))
    ];
    _stoppoints_position = [null, null];
    _stoppoints_place = [null, null];

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
    _selectedTruckId = [];

    // Reset date/time-related fields
    _loadDate = [DateTime.now()];
    _loadTime = [DateTime.now()];
    _time_controller = [TextEditingController()];
    _date_controller = [TextEditingController()];

    // Reset errors
    _pathError = false;
    _dateError = [false];

    // Reset loading indicators
    _stoppointsLoading = [false, false];
    _stoppointstextLoading = [false, false];

    // Reset boolean flags
    _stoppointsPosition = [false, false];
    _pathConfirm = false;

    // Reset other fields
    _distance = 0;
    _subDistance = [0];

    _period = "";
    _subPeriod = [0];

    _topPosition = 0.0;
    _bottomPathStatisticPosition = 0.0;
    _bottomPosition = -900.0;
    _toptextfeildPosition = -250;
    _pickMapMode = false;
    _showStores = false;
  }

  void setShowStores() {
    _showStores = !_showStores;
    notifyListeners();
  }

  void toggleMapMode(int? selectedPointIndex) {
    _pickMapMode = !_pickMapMode;

    // If pickMapMode is true, ensure _topPosition stays -300
    if (_pickMapMode) {
      _topPosition = -300;
      _bottomPathStatisticPosition = -300;
      if (selectedPointIndex != null) {
        if (_stoppoints_location[selectedPointIndex].isNotEmpty) {
          if (_mapController2 != null) {
            _mapController2!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(
                      double.parse(_stoppoints_location[selectedPointIndex]
                          .split(",")[0]),
                      double.parse(_stoppoints_location[selectedPointIndex]
                          .split(",")[1]),
                    ),
                    zoom: 11),
              ),
            );
          }
        } else {
          if (_mapController2 != null) {
            _mapController2!.animateCamera(
              CameraUpdate.newCameraPosition(
                const CameraPosition(
                  target: LatLng(34.723142, 36.730519),
                  zoom: 9,
                ),
              ),
            );
          }
        }
      }
    } else {
      _topPosition = 0.0; // Reset when map mode is turned off
      _bottomPathStatisticPosition = 0;
    }
    notifyListeners();
  }

  void togglePosition(double height) {
    _topPosition = _pickMapMode ? -300 : (_topPosition == 0.0 ? -300 : 0.0);
    _bottomPathStatisticPosition =
        _pickMapMode ? -300 : (_bottomPathStatisticPosition == 0 ? -300 : 0);

    _toptextfeildPosition = _toptextfeildPosition == 0 ? -250 : 0;

    _bottomPosition = _bottomPosition == 111 ? -height : 111;
    notifyListeners();
  }

  void setbottomPosition(double height) {
    _bottomPosition = -height;
    notifyListeners();
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

  Future<void> getPolyPoints(
    double screenHeight,
    int index,
    bool add,
  ) async {
    // _pathConfirm = true;
    try {
      if (_stoppoints_location.isEmpty) {
        return;
      }

      final polylinePoints = PolylinePoints();
      _pathes = [];
      double totalDistance = 0.0;
      int totalMinutes = 0;
      if (!add) {
        if (index == _stoppoints_latlng.length) {
          _subPathes[index - 2] = [];
          final origin2 = _stoppoints_latlng[index - 2];
          final destination2 = _stoppoints_latlng[index - 1];

          var result2 = await polylinePoints.getRouteBetweenCoordinates(
            googleApiKey: "AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w",
            request: PolylineRequest(
              origin: PointLatLng(origin2!.latitude, origin2.longitude),
              destination:
                  PointLatLng(destination2!.latitude, destination2.longitude),
              mode: TravelMode.driving,
            ),
          );

          if (result2.points.isNotEmpty) {
            _subPathes[index - 2].addAll(result2.points
                .map((point) => LatLng(point.latitude, point.longitude)));
          }

          // Fetch distance and duration for this segment
          final distanceData2 = await MapService.fetchDistanceMatrix(
            pickup: origin2,
            delivery: destination2,
          );

          if (distanceData2 != null) {
            _subDistance[index - 2] = distanceData2["distance"] ?? 0.0;
            _subPeriod[index - 2] = MapService.parseDurationToMinutes(
                distanceData2["duration"] ?? "");
          }
          _stoppointstextLoading[index - 1] = false;
          _stoppointsLoading[index - 1] = false;
          notifyListeners();
        } else {
          _subPathes[index - 1] = [];
          final origin = _stoppoints_latlng[index - 1];
          final destination = _stoppoints_latlng[index];

          var result = await polylinePoints.getRouteBetweenCoordinates(
            googleApiKey: "AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w",
            request: PolylineRequest(
              origin: PointLatLng(origin!.latitude, origin.longitude),
              destination:
                  PointLatLng(destination!.latitude, destination.longitude),
              mode: TravelMode.driving,
            ),
          );

          if (result.points.isNotEmpty) {
            _subPathes[index - 1].addAll(result.points
                .map((point) => LatLng(point.latitude, point.longitude)));
          }

          // Fetch distance and duration for this segment
          final distanceData = await MapService.fetchDistanceMatrix(
            pickup: origin,
            delivery: destination,
          );

          if (distanceData != null) {
            _subDistance[index - 1] = distanceData["distance"] ?? 0.0;
            _subPeriod[index - 1] = MapService.parseDurationToMinutes(
                distanceData["duration"] ?? "");
          }
          _stoppointstextLoading[index] = false;
          _stoppointsLoading[index] = false;
          notifyListeners();
        }
      } else {
        print("last point");
        if (index == 0) {
          _subPathes[index] = [];
          final origin = _stoppoints_latlng[index];
          final destination = _stoppoints_latlng[index + 1];

          var result = await polylinePoints.getRouteBetweenCoordinates(
            googleApiKey: "AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w",
            request: PolylineRequest(
              origin: PointLatLng(origin!.latitude, origin.longitude),
              destination:
                  PointLatLng(destination!.latitude, destination.longitude),
              mode: TravelMode.driving,
            ),
          );
          print("result.points.isNotEmpty ${result.points.isNotEmpty}");
          if (result.points.isNotEmpty) {
            _subPathes[index].addAll(result.points
                .map((point) => LatLng(point.latitude, point.longitude)));
          }

          // Fetch distance and duration for this segment
          final distanceData = await MapService.fetchDistanceMatrix(
            pickup: origin,
            delivery: destination,
          );

          if (distanceData != null) {
            print("distanceData ${distanceData["distance"]}");
            _subDistance[index] = distanceData["distance"] ?? 0.0;
            _subPeriod[index] = MapService.parseDurationToMinutes(
                distanceData["duration"] ?? "");
            print("_subDistance ${_subDistance[index]}");
          }
        } else {
          _subPathes[index - 1] = [];
          final origin = _stoppoints_latlng[index - 1];
          final destination = _stoppoints_latlng[index];

          var result = await polylinePoints.getRouteBetweenCoordinates(
            googleApiKey: "AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w",
            request: PolylineRequest(
              origin: PointLatLng(origin!.latitude, origin.longitude),
              destination:
                  PointLatLng(destination!.latitude, destination.longitude),
              mode: TravelMode.driving,
            ),
          );
          print("result.points.isNotEmpty ${result.points.isNotEmpty}");
          if (result.points.isNotEmpty) {
            _subPathes[index - 1].addAll(result.points
                .map((point) => LatLng(point.latitude, point.longitude)));
          }

          // Fetch distance and duration for this segment
          final distanceData = await MapService.fetchDistanceMatrix(
            pickup: origin,
            delivery: destination,
          );

          if (distanceData != null) {
            print("distanceData ${distanceData["distance"]}");
            _subDistance[index - 1] = distanceData["distance"] ?? 0.0;
            _subPeriod[index - 1] = MapService.parseDurationToMinutes(
                distanceData["duration"] ?? "");
            print("_subDistance ${_subDistance[index - 1]}");
          }
        }
        _stoppointstextLoading[index] = false;
        _stoppointsLoading[index] = false;
        notifyListeners();
      }

      _pathes = [];
      for (var element in _subPathes) {
        _pathes.addAll(element);
      }
      for (var i = 0; i < _subDistance.length; i++) {
        totalDistance += _subDistance[i];
        totalMinutes += _subPeriod[i];
      }
      // Store total distance and period
      _distance = totalDistance;
      _period = MapService.formatMinutesToDuration(
          totalMinutes); // Convert back to readable format
    } catch (error) {
      print("Error fetching route: $error");
    }
  }

  void initMapBounds(double screenHeight) {
    setPathError(false);

    if (_stoppoints_location.first.isEmpty || _stoppoints_location.last.isEmpty)
      return; // Ensure there are stop points
    print("initMap bound");

    List<Marker> markers = [
      MapService.createMarker(
          "pickup", _stoppoints_location.first), // First stop is Pickup
      MapService.createMarker(
          "delivery", _stoppoints_location.last), // Last stop is Delivery
      ..._stoppoints_location
          .sublist(1, _stoppoints_location.length - 1) // Exclude first & last
          .asMap()
          .entries
          .map((entry) => MapService.createMarker(
              "stop${entry.key + 1}", entry.value)), // Adjust index
    ];

    if (markers.isEmpty) return;

    // Get min/max latitude & longitude using `reduce()`
    double minLat =
        markers.map((m) => m.position.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat =
        markers.map((m) => m.position.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = markers
        .map((m) => m.position.longitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLng = markers
        .map((m) => m.position.longitude)
        .reduce((a, b) => a > b ? a : b);

// Calculate latitude and longitude ranges
    double latRange = maxLat - minLat;
    double lngRange = maxLng - minLng;

    // Determine if the bounds are horizontal or vertical
    bool isHorizontal = lngRange > latRange;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    // Calculate padding based on the screen height
    double topPadding = _stoppoints_location.length > 2
        ? screenHeight * 0.24
        : screenHeight * 0.2; // Hide top third

    // Apply camera update with calculated padding
    _mapController2?.animateCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        isHorizontal ? 50 : 170, // Adjust padding
      ),
    );

    // Optionally, you can add a delay to ensure the camera update is applied
    Future.delayed(const Duration(milliseconds: 500), () {
      _mapController2?.animateCamera(
        CameraUpdate.scrollBy(0, -topPadding / 2), // Adjust the camera position
      );
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    print("initMap bound end");
  }

  setLoadTime(DateTime time, int index) {
    _time_controller[index].text = '${intl.DateFormat.jm().format(time)} ';
    _loadTime[index] = time;
    print(_loadTime[index]);
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
          // Remove the truck associated with the previous truck type for this path
          var truckToRemove = _selectedTruck.firstWhere(
            (truck) => truck.truckType?.id == _selectedTruckTypeId[pathIndex],
            orElse: () => KTruck(
              id: 0,
            ),
          );
          if (truckToRemove.id != 0) {
            removeSelectedTruck(truckToRemove, _selectedTruckTypeId[pathIndex]);
          }
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
    // Notify listeners for state update
    notifyListeners();
  }

  void addSingleSelectedTruck(KTruck truck, int truckTypeId) {
    var index = _truckTypeGroupId.indexOf(truckTypeId);

    // Check if another truck of the same type is already selected
    var existingTruckIndex =
        _selectedTruck.indexWhere((t) => t.truckType!.id == truckTypeId);

    // If another truck of the same type is selected, remove it first
    if (existingTruckIndex != -1) {
      var existingTruck = _selectedTruck[existingTruckIndex];
      _selectedTruckId.remove(existingTruck.id); // Remove the existing truck ID
      _selectedTruck
          .removeAt(existingTruckIndex); // Remove the existing truck itself
      _selectedTruckTypeNum[index]++; // Increase the truck type count back
    }

    // Add the new truck
    _selectedTruckId.add(truck.id!); // Add the new truck ID
    _selectedTruck.add(truck); // Add the new truck itself
    _selectedTruckTypeNum[index]--; // Decrease the truck type count

    notifyListeners(); // Notify listeners to update the UI
  }

  void removeSingleSelectedTruck(KTruck truck, int truckTypeId) {
    var index = _truckTypeGroupId.indexOf(truckTypeId);

    // Check if another truck of the same type is already selected
    var existingTruckIndex =
        _selectedTruck.indexWhere((t) => t.truckType!.id == truckTypeId);

    // If another truck of the same type is selected, remove it first
    if (existingTruckIndex != -1) {
      var existingTruck = _selectedTruck[existingTruckIndex];
      _selectedTruckId.remove(existingTruck.id); // Remove the existing truck ID
      _selectedTruck
          .removeAt(existingTruckIndex); // Remove the existing truck itself
      _selectedTruckTypeNum[index]++; // Increase the truck type count back
    }

    notifyListeners(); // Notify listeners to update the UI
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

  setStopPointLoading(bool value, int index) {
    _stoppointsLoading[index] = value;
    _stoppointstextLoading[index] = value;
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
      // 'administrative_area_level_2',
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

  animateCameraToLatLng() {
    var pickuplocation;
    if (_stoppoints_location.first.isNotEmpty) {
      pickuplocation = _stoppoints_location.first.split(",");
    } else if (_stoppoints_location.last.isNotEmpty) {
      pickuplocation = _stoppoints_location.last.split(",");
    }
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
              double.parse(pickuplocation[0]),
              double.parse(pickuplocation[1]),
            ),
            zoom: 11),
      ),
    );
    if (_mapController2 != null) {
      _mapController2!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                double.parse(pickuplocation[0]),
                double.parse(pickuplocation[1]),
              ),
              zoom: 11),
        ),
      );
    }
  }

  void updateLocationData({
    required LatLng position,
    required TextEditingController controller,
    required Function(String) setStateName,
    required Function(LatLng) setLatLng,
    required Function(String) setPlaceId,
    required Function(String) setLocation,
  }) async {
    // final result = await MapService.fetchGeocodeData(position);

    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      if (result != null) {
        setLocation("${position.latitude},${position.longitude}");
        setLatLng(LatLng(position.latitude, position.longitude));
        controller.text = getAddressName(result);

        setStateName(getAdministrativeAreaName(result));
        setPlaceId(getAdministrativeAreaPlaceId(result));
      }
    }
    notifyListeners();
  }

  Future<void> getCurrentPosition(
      Function(LatLng) onSuccess, int index, BuildContext context) async {
    final hasPermission = await _handleLocationPermission(
      context,
      index,
    );
    if (!hasPermission) {
      print("Location permission denied.");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("Raw Position Data: $position");

      // Directly assign to double variables
      double? lat = position.latitude;
      double? lng = position.longitude;

      // Ensure they are not NaN
      if (lat.isNaN || lng.isNaN) {
        throw Exception("Invalid latitude or longitude received.");
      }

      print("Latitude: $lat, Longitude: $lng");

      // Ensure `onSuccess` receives a valid `LatLng`
      onSuccess(LatLng(lat, lng));
    } catch (e, stacktrace) {
      print("Error getting location: ${e.toString()}");
      print("Stacktrace: $stacktrace");
    }
  }

  void _handleMapUpdate(double screenHeight, int index, bool add) {
    if (_stoppoints_location.first.isNotEmpty &&
        _stoppoints_location.last.isNotEmpty) {
      getPolyPoints(
        screenHeight,
        index,
        add,
      ).then(
        (value) {
          initMapBounds(screenHeight);
        },
      );
    } else {
      animateCameraToLatLng();
      _stoppointstextLoading[index] = false;
      _stoppointsLoading[index] = false;
      notifyListeners();
    }
    notifyListeners();
  }

  void setStopPointInfo(
    dynamic suggestion,
    int index,
    bool cached,
    double screenHeight,
  ) async {
    _stoppointstextLoading[index] = true;
    _stoppointsLoading[index] = true;
    notifyListeners();
    late LatLng position;
    if (cached) {
      if (suggestion.description == "اللاذقية، Syria") {
        position = LatLng(double.parse("35.525131"), double.parse("35.791570"));
      } else {
        var value = await PlaceService.getPlace(suggestion.placeId);
        _stoppoints_place[index] = value;
        position =
            LatLng(value.geometry.location.lat, value.geometry.location.lng);
      }

      final newResult = {
        'description': suggestion.description,
        'location': "${position.latitude},${position.longitude}",
      };

      // Check if the result already exists in the cache
      final isAlreadyCached = index == 0
          ? _pickupCachedSearchResults.any(
              (result) =>
                  result['description'] == newResult['description'] &&
                  result['location'] == newResult['location'],
            )
          : _cachedSearchResults.any(
              (result) =>
                  result['description'] == newResult['description'] &&
                  result['location'] == newResult['location'],
            );

      if (!isAlreadyCached) {
        if (index == 0) {
          // Add the new result to the cache
          _pickupCachedSearchResults.insert(0, newResult);

          // Limit the cache to the last 5 results
          if (_pickupCachedSearchResults.length > 5) {
            _pickupCachedSearchResults.removeLast();
          }

          // Save the updated cache to local storage
          await _savePickUpCachedResults();
        } else {
          // Add the new result to the cache
          _cachedSearchResults.insert(0, newResult);

          // Limit the cache to the last 5 results
          if (_cachedSearchResults.length > 5) {
            _cachedSearchResults.removeLast();
          }

          // Save the updated cache to local storage
          await _saveCachedResults();
        }
      }
    } else {
      position = LatLng(double.parse(suggestion["location"].split(",")[0]),
          double.parse(suggestion["location"].split(",")[1]));
    }

    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      if (result != null) {
        _stoppoints_controller[index].text = getAddressName(result);
        _stoppoints_statename[index] = getAdministrativeAreaName(result);
        _stoppoints_location[index] =
            "${position.latitude},${position.longitude}";
        stoppoints_placeId[index] = getAdministrativeAreaPlaceId(result);
        _stoppoints_latlng[index] =
            LatLng(position.latitude, position.longitude);
      }
    }

    for (var i = 0; i < _stop_marker.length; i++) {
      if (i == 0) {
        Uint8List markerIcon = await MapService.createCustomMarker(
          "A",
        );

        if (_stoppoints_latlng[i] != null) {
          _stop_marker[i] = Marker(
            markerId: MarkerId("stop$i"),
            position: LatLng(
              _stoppoints_latlng[i]!.latitude,
              _stoppoints_latlng[i]!.longitude,
            ),
            onTap: () {
              toggleMapMode(i);
            },
            icon: BitmapDescriptor.bytes(markerIcon),
          );
        }
      } else {
        Uint8List markerIcon = await MapService.createCustomMarker(
          i == _stop_marker.length - 1 ? "B" : "$i",
        );
        if (_stoppoints_latlng[i] != null) {
          _stop_marker[i] = Marker(
            markerId: MarkerId("stop$i"),
            position: LatLng(
              _stoppoints_latlng[i]!.latitude,
              _stoppoints_latlng[i]!.longitude,
            ),
            onTap: () {
              toggleMapMode(i);
            },
            icon: BitmapDescriptor.bytes(markerIcon),
          );
        }
      }
    }

    _handleMapUpdate(screenHeight, index, true);
    // _stoppointstextLoading[index] = false;
    // _stoppointsLoading[index] = false;
    // notifyListeners();
  }

  void setStopPointStore(
    String location,
    int index,
    double screenHeight,
  ) async {
    _stoppointstextLoading[index] = true;
    _stoppointsLoading[index] = true;
    notifyListeners();
    LatLng position = LatLng(
      double.parse(location.split(",")[0]),
      double.parse(location.split(",")[1]),
    );

    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      if (result != null) {
        _stoppoints_controller[index].text = getAddressName(result);
        _stoppoints_statename[index] = getAdministrativeAreaName(result);
        _stoppoints_location[index] =
            "${position.latitude},${position.longitude}";
        stoppoints_placeId[index] = getAdministrativeAreaPlaceId(result);
        _stoppoints_latlng[index] =
            LatLng(position.latitude, position.longitude);
      }
    }

    for (var i = 0; i < _stop_marker.length; i++) {
      if (i == 0) {
        Uint8List markerIcon = await MapService.createCustomMarker(
          "A",
        );

        if (_stoppoints_latlng[i] != null) {
          _stop_marker[i] = Marker(
            markerId: MarkerId("stop$i"),
            position: LatLng(
              _stoppoints_latlng[i]!.latitude,
              _stoppoints_latlng[i]!.longitude,
            ),
            onTap: () {
              toggleMapMode(i);
            },
            icon: BitmapDescriptor.bytes(markerIcon),
          );
        }
      } else {
        Uint8List markerIcon = await MapService.createCustomMarker(
          i == _stop_marker.length - 1 ? "B" : "$i",
        );
        if (_stoppoints_latlng[i] != null) {
          _stop_marker[i] = Marker(
            markerId: MarkerId("stop$i"),
            position: LatLng(
              _stoppoints_latlng[i]!.latitude,
              _stoppoints_latlng[i]!.longitude,
            ),
            onTap: () {
              toggleMapMode(i);
            },
            icon: BitmapDescriptor.bytes(markerIcon),
          );
        }
      }
    }

    _handleMapUpdate(screenHeight, index, true);
    // _stoppointstextLoading[index] = false;
    // _stoppointsLoading[index] = false;
    // notifyListeners();
  }

  Future<void> getAddressForStopPointFromMapPicker(
    LatLng position,
    int index,
    double screenHeight,
  ) async {
    _stoppointstextLoading[index] = true;
    _stoppointsLoading[index] = true;
    notifyListeners();
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      if (result != null) {
        _stoppoints_controller[index].text = getAddressName(result);
        _stoppoints_statename[index] = getAdministrativeAreaName(result);
        _stoppoints_location[index] =
            "${position.latitude},${position.longitude}";
        stoppoints_placeId[index] = getAdministrativeAreaPlaceId(result);
        _stoppoints_latlng[index] =
            LatLng(position.latitude, position.longitude);
      }
    }

    for (var i = 0; i < _stop_marker.length; i++) {
      if (i == 0) {
        Uint8List markerIcon = await MapService.createCustomMarker(
          "A",
        );

        if (_stoppoints_latlng[i] != null) {
          _stop_marker[i] = Marker(
            markerId: MarkerId("stop$i"),
            position: LatLng(
              _stoppoints_latlng[i]!.latitude,
              _stoppoints_latlng[i]!.longitude,
            ),
            onTap: () {
              toggleMapMode(i);
            },
            icon: BitmapDescriptor.bytes(markerIcon),
          );
        }
      } else {
        Uint8List markerIcon = await MapService.createCustomMarker(
          i == _stop_marker.length - 1 ? "B" : "$i",
        );
        if (_stoppoints_latlng[i] != null) {
          _stop_marker[i] = Marker(
            markerId: MarkerId("stop$i"),
            position: LatLng(
              _stoppoints_latlng[i]!.latitude,
              _stoppoints_latlng[i]!.longitude,
            ),
            onTap: () {
              toggleMapMode(i);
            },
            icon: BitmapDescriptor.bytes(markerIcon),
          );
        }
      }
    }

    _handleMapUpdate(
      screenHeight,
      index,
      true,
    );
    // _stoppointstextLoading[index] = false;
    // _stoppointsLoading[index] = false;
    // notifyListeners();
  }

  Future<bool> _handleLocationPermission(
    BuildContext context,
    int index,
  ) async {
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
        _stoppointsLoading[index] = false;

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
      _stoppointsLoading[index] = false;

      return false;
    }
    return true;
  }

  Future<void> getCurrentPositionForStop(
    BuildContext context,
    int index,
    double screenHeight,
  ) async {
    _stoppointstextLoading[index] = true;
    _stoppointsLoading[index] = true;
    notifyListeners();
    final hasPermission = await _handleLocationPermission(
      context,
      index,
    );

    if (!hasPermission) {
      _stoppointstextLoading[index] = false;
      _stoppointsLoading[index] = false;
      notifyListeners();
      return;
    }

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      _stoppoints_latlng[index] = LatLng(position.latitude, position.longitude);
      _stoppoints_position[index] = position;
      _stoppoints_location[index] =
          "${position.latitude},${position.longitude}";
      getAddressForStopFromLatLng(position, index, screenHeight);
    }).catchError((e) {
      _stoppointstextLoading[index] = false;
      _stoppointsLoading[index] = false;
      notifyListeners();
    });
  }

  Future<void> getAddressForStopFromLatLng(
    Position position,
    int index,
    double screenHeight,
  ) async {
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);

      _stoppoints_controller[index].text = getAddressName(result);
      _stoppoints_statename[index] = getAdministrativeAreaName(result);
      _stoppoints_placeId[index] = getAdministrativeAreaPlaceId(result);

      for (var i = 0; i < _stop_marker.length; i++) {
        if (i == 0) {
          Uint8List markerIcon = await MapService.createCustomMarker(
            "A",
          );

          if (_stoppoints_latlng[i] != null) {
            _stop_marker[i] = Marker(
              markerId: MarkerId("stop$i"),
              position: LatLng(
                _stoppoints_latlng[i]!.latitude,
                _stoppoints_latlng[i]!.longitude,
              ),
              onTap: () {
                toggleMapMode(i);
              },
              icon: BitmapDescriptor.bytes(markerIcon),
            );
          }
        } else {
          Uint8List markerIcon = await MapService.createCustomMarker(
            i == _stop_marker.length - 1 ? "B" : "$i",
          );
          if (_stoppoints_latlng[i] != null) {
            _stop_marker[i] = Marker(
              markerId: MarkerId("stop$i"),
              position: LatLng(
                _stoppoints_latlng[i]!.latitude,
                _stoppoints_latlng[i]!.longitude,
              ),
              onTap: () {
                toggleMapMode(i);
              },
              icon: BitmapDescriptor.bytes(markerIcon),
            );
          }
        }
      }
    }

    if (_stoppoints_location.first.isNotEmpty &&
        _stoppoints_location.last.isNotEmpty) {
      getPolyPoints(
        screenHeight,
        index,
        true,
      ).then(
        (value) {
          initMapBounds(screenHeight);
        },
      );
    } else {
      animateCameraToLatLng();
      _stoppointstextLoading[index] = false;
      _stoppointsLoading[index] = false;
      notifyListeners();
    }
    // notifyListeners();
  }

  Map<String, dynamic> addstoppoint() {
    Map<String, dynamic> data = {"added": false, "point": "B"};
    if (_stoppoints_controller.isNotEmpty) {
      if (_stoppoints_location.last.isNotEmpty &&
          _stoppoints_location.first.isNotEmpty) {
        TextEditingController stoppoint_controller =
            TextEditingController(text: "أضف عنوان نقطة تحميل/تفريغ");
        _stoppoints_controller.add(stoppoint_controller);
        _stoppoints_location.add("");
        _stoppoints_latlng.add(null);
        _stoppoints_position.add(null);
        _stoppoints_place.add(null);
        _stoppoints_placeId.add("");
        _stoppoints_statename.add("");
        _stoppointsLoading.add(false);
        _stoppointstextLoading.add(false);
        _stoppointsPosition.add(false);
        _stop_marker.add(
          Marker(
            markerId: MarkerId("stop${_stop_marker.length}"),
          ),
        );
        _subPathes.add([]);
        _subDistance.add(0);
        _subPeriod.add(0);
        notifyListeners();
        data["added"] = true;
        return data;
      } else {
        notifyListeners();
        data["added"] = false;
        if (_stoppoints_location.last.isEmpty) {
          data["point"] = "B";
        } else if (_stoppoints_location.first.isEmpty) {
          data["point"] = "A";
        }
        return data;
      }
    } else {
      TextEditingController stoppoint_controller =
          TextEditingController(text: "أضف عنوان نقطة تحميل/تفريغ");
      _stoppoints_controller.add(stoppoint_controller);
      _stoppoints_location.add("");
      _stoppoints_latlng.add(null);
      _stoppoints_position.add(null);
      _stoppoints_place.add(null);
      _stoppoints_placeId.add("");
      _stoppoints_statename.add("");
      _stoppointsLoading.add(false);
      _stoppointstextLoading.add(false);
      _stoppointsPosition.add(false);
      _stop_marker.add(
        Marker(
          markerId: MarkerId("stop${_stop_marker.length}"),
        ),
      );
      notifyListeners();

      data["added"] = true;
      return data;
    }
  }

  void removestoppoint(int index2) async {
    _stoppoints_controller.removeAt(index2);
    _stoppoints_location.removeAt(index2);
    _stoppoints_latlng.removeAt(index2);
    _stoppoints_position.removeAt(index2);
    _stoppoints_place.removeAt(index2);
    _stoppoints_placeId.removeAt(index2);
    _stoppoints_statename.removeAt(index2);
    _stoppointsLoading.removeAt(index2);
    _stoppointstextLoading.removeAt(index2);
    _stoppointsPosition.removeAt(index2);
    _stop_marker.removeAt(index2);
    _subPathes.removeAt(index2 - 1);
    _subDistance.removeAt(index2 - 1);
    _subPeriod.removeAt(index2 - 1);
    for (var i = 0; i < _stop_marker.length; i++) {
      if (i == 0) continue;

      Uint8List markerIcon = await MapService.createCustomMarker(
        i == _stop_marker.length - 1 ? "B" : "$i",
      );

      _stop_marker[i] = Marker(
        markerId: MarkerId("stop$i"),
        position: LatLng(
          _stoppoints_latlng[i]!.latitude,
          _stoppoints_latlng[i]!.longitude,
        ),
        icon: BitmapDescriptor.bytes(markerIcon),
      );
    }
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
