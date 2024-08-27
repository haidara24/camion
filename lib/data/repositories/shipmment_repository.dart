// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:camion/data/models/commodity_category_model.dart';
import 'package:camion/data/models/kshipment_model.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:camion/data/models/truck_type_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ShipmentRepository {
  late SharedPreferences prefs;
  List<TruckType> truckTypes = [];
  List<PackageType> packageTypes = [];
  List<CommodityCategory> commodityCategories = [];
  List<KCommodityCategory> kcommodityCategories = [];
  List<KCategory> kCategories = [];
  List<SubShipment> subshipments = [];
  List<SubShipment> subshipmentsA = [];
  List<SubShipment> subshipmentsR = [];
  List<SubShipment> taskSubshipments = [];
  List<OwnerSubShipment> ownersubshipmentsA = [];
  List<OwnerSubShipment> ownersubshipmentsR = [];
  List<Shipmentv2> kshipments = [];
  List<Shipmentv2> shipmentsC = [];
  List<ManagmentShipment> mshipments = [];

  Future<bool> cancelShipment(int shipmentId) async {
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var response = await HttpHelper.patch(
      "$SHIPPMENTSV2_ENDPOINT$shipmentId/cancel/",
      {},
      apiToken: jwt,
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> reActiveShipment(int shipmentId) async {
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var response = await HttpHelper.patch(
      "$SHIPPMENTSV2_ENDPOINT$shipmentId/reactive/",
      {},
      apiToken: jwt,
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<CommodityCategory>> getCommodityCategories() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(COMMODITY_CATEGORIES_ENDPOINT, apiToken: jwt);
    commodityCategories = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        commodityCategories.add(CommodityCategory.fromJson(element));
      }
    }
    return commodityCategories;
  }

  Future<List<KCategory>> getKCommodityCategories() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(K_CATEGORIES_ENDPOINT, apiToken: jwt);
    kCategories = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        kCategories.add(KCategory.fromJson(element));
      }
    }
    return kCategories;
  }

  Future<List<KCommodityCategory>> searchKCommodityCategories(
      String query) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(
        "$KCOMMODITY_CATEGORIES_ENDPOINT?search=$query",
        apiToken: jwt);
    kcommodityCategories = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        kcommodityCategories.add(KCommodityCategory.fromJson(element));
      }
    }
    return kcommodityCategories;
  }

  Future<List<Shipmentv2>> getShipmentList(String status) async {
    kshipments = [];
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var merchant = prefs.getInt("merchant") ?? 0;

    var response = await HttpHelper.get(
      "$SHIPPMENTSV2_ENDPOINT?shipment_status=$status&merchant=$merchant&driver=",
      apiToken: jwt,
    );
    var myDataString = utf8.decode(response.bodyBytes);
    var json = jsonDecode(myDataString);
    if (response.statusCode == 200) {
      for (var element in json) {
        kshipments.add(Shipmentv2.fromJson(element));
      }

      return kshipments.reversed.toList();
    } else {
      return kshipments;
    }
  }

  Future<List<SubShipment>> getSubShipmentList(String status) async {
    switch (status) {
      case "R":
        {
          subshipmentsR = [];
          var prefs = await SharedPreferences.getInstance();
          var jwt = prefs.getString("token");
          var merchant = prefs.getInt("merchant") ?? 0;

          var response = await HttpHelper.get(
            "${SUB_SHIPPMENTSV2_ENDPOINT}merchant/$merchant/status/$status/",
            apiToken: jwt,
          );
          print(response.statusCode);
          print(
              "${SUB_SHIPPMENTSV2_ENDPOINT}merchant/$merchant/status/$status/");
          if (response.statusCode == 200) {
            var myDataString = utf8.decode(response.bodyBytes);
            var json = jsonDecode(myDataString);
            print(json.length);
            for (var element in json) {
              subshipmentsR.add(SubShipment.fromJson(element));
            }
            return subshipmentsR.reversed.toList();
          } else {
            return subshipmentsR;
          }
        }
      default:
        {
          subshipments = [];
          var prefs = await SharedPreferences.getInstance();
          var jwt = prefs.getString("token");
          var merchant = prefs.getInt("merchant") ?? 0;

          var response = await HttpHelper.get(
            "${SUB_SHIPPMENTSV2_ENDPOINT}merchant/$merchant/status/$status/",
            apiToken: jwt,
          );
          var myDataString = utf8.decode(response.bodyBytes);
          var json = jsonDecode(myDataString);
          if (response.statusCode == 200) {
            for (var element in json) {
              subshipments.add(SubShipment.fromJson(element));
            }

            return subshipments.reversed.toList();
          } else {
            return subshipments;
          }
        }
    }
  }

  Future<List<SubShipment>> getSubShipmentListForTasks() async {
    taskSubshipments = [];
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var response = await HttpHelper.get(
      "${SUB_SHIPPMENTSV2_ENDPOINT}list_for_tasks/",
      apiToken: jwt,
    );

    if (response.statusCode == 200) {
      var myDataString = utf8.decode(response.bodyBytes);
      var json = jsonDecode(myDataString);
      print(json.length);
      for (var element in json) {
        taskSubshipments.add(SubShipment.fromJson(element));
      }
      return taskSubshipments.reversed.toList();
    } else {
      return taskSubshipments;
    }
  }

  Future<List<Shipmentv2>> getLogShipmentList() async {
    shipmentsC = [];
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var response = await HttpHelper.get(
      "${SHIPPMENTSV2_ENDPOINT}list_for_log/",
      apiToken: jwt,
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      var myDataString = utf8.decode(response.bodyBytes);
      var json = jsonDecode(myDataString);
      for (var element in json) {
        shipmentsC.add(Shipmentv2.fromJson(element));
      }

      return shipmentsC.reversed.toList();
    } else {
      return shipmentsC;
    }
  }

  Future<List<Shipmentv2>> getKShipmentList(String status) async {
    shipmentsC = [];
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var merchant = prefs.getInt("merchant") ?? 0;

    var response = await HttpHelper.get(
      "$SHIPPMENTSV2_ENDPOINT?shipment_status=$status&merchant=$merchant",
      apiToken: jwt,
    );
    var myDataString = utf8.decode(response.bodyBytes);
    var json = jsonDecode(myDataString);
    print(response.statusCode);
    if (response.statusCode == 200) {
      for (var element in json["results"]) {
        shipmentsC.add(Shipmentv2.fromJson(element));
      }

      return shipmentsC.reversed.toList();
    } else {
      return shipmentsC;
    }
  }

  Future<List<ManagmentShipment>> getManagmentKShipmentList(
      String status) async {
    mshipments = [];
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var response = await HttpHelper.get(
      "${SHIPPMENTSV2_ENDPOINT}filter_by_status/?shipment_status=$status",
      apiToken: jwt,
    );
    var myDataString = utf8.decode(response.bodyBytes);
    var json = jsonDecode(myDataString);
    if (response.statusCode == 200) {
      for (var element in json) {
        mshipments.add(ManagmentShipment.fromJson(element));
        print(response.statusCode);
      }

      return mshipments.reversed.toList();
    } else {
      return mshipments;
    }
  }

  Future<List<OwnerSubShipment>> getDriverActiveShipmentList(
      String status) async {
    ownersubshipmentsA = [];
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var response = await HttpHelper.get(
      "${SUB_SHIPPMENTSV2_ENDPOINT}list_for_driver_and_status/$status/",
      apiToken: jwt,
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      var myDataString = utf8.decode(response.bodyBytes);
      var json = jsonDecode(myDataString);
      for (var element in json) {
        ownersubshipmentsA.add(OwnerSubShipment.fromJson(element));
      }

      return ownersubshipmentsA.reversed.toList();
    } else {
      return ownersubshipmentsA;
    }
  }

  Future<List<SubShipment>> getDriverShipmentList(
      String status, int? truckId) async {
    subshipmentsR = [];
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var truck = prefs.getInt("truckId") ?? 0;
    var response = await HttpHelper.get(
      "$SUB_SHIPPMENTSV2_ENDPOINT?shipment_status=$status&truck=${truckId ?? truck}",
      apiToken: jwt,
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      var myDataString = utf8.decode(response.bodyBytes);
      var json = jsonDecode(myDataString);
      for (var element in json["results"]) {
        subshipmentsR.add(SubShipment.fromJson(element));
      }

      return subshipmentsR.reversed.toList();
    } else {
      return subshipmentsR;
    }
  }

  Future<List<OwnerSubShipment>> getDriverRunningShipmentListForOwner(
      String status) async {
    ownersubshipmentsR = [];
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var response = await HttpHelper.get(
      "${SUB_SHIPPMENTSV2_ENDPOINT}list_for_owner_and_status/$status/",
      apiToken: jwt,
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      var myDataString = utf8.decode(response.bodyBytes);
      var json = jsonDecode(myDataString);
      for (var element in json) {
        ownersubshipmentsR.add(OwnerSubShipment.fromJson(element));
      }
      return ownersubshipmentsR.reversed.toList();
    } else {
      return ownersubshipmentsR;
    }
  }

  Future<List<OwnerSubShipment>> getActiveDriverShipmentForOwner(
      String status, int driverId) async {
    ownersubshipmentsA = [];
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var response = await HttpHelper.get(
      "$SUB_SHIPPMENTSV2_ENDPOINT?shipment_status=$status&merchant=&driver=$driverId",
      apiToken: jwt,
    );
    var myDataString = utf8.decode(response.bodyBytes);
    var json = jsonDecode(myDataString);
    if (response.statusCode == 200) {
      for (var element in json) {
        ownersubshipmentsA.add(OwnerSubShipment.fromJson(element));
      }

      return ownersubshipmentsA.reversed.toList();
    } else {
      return ownersubshipmentsA;
    }
  }

  Future<List<SubShipment>> getActiveTruckShipments() async {
    subshipmentsA = [];
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var merchant = prefs.getInt("merchant") ?? 0;
    var response = await HttpHelper.get(
      "${SUB_SHIPPMENTSV2_ENDPOINT}merchant/$merchant/status/A/",
      apiToken: jwt,
    );
    var myDataString = utf8.decode(response.bodyBytes);
    var json = jsonDecode(myDataString);
    if (response.statusCode == 200) {
      for (var element in json) {
        subshipmentsA.add(SubShipment.fromJson(element));
      }

      return subshipmentsA.reversed.toList();
    } else {
      return subshipmentsA;
    }
  }

  Future<List<SubShipment>> getUnAssignedShipmentList() async {
    subshipments = [];
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var response = await HttpHelper.get(
      "${SUB_SHIPPMENTSV2_ENDPOINT}no_driver_shipments/",
      apiToken: jwt,
    );
    if (response.statusCode == 200) {
      var myDataString = utf8.decode(response.bodyBytes);
      var json = jsonDecode(myDataString);
      for (var element in json) {
        subshipments.add(SubShipment.fromJson(element));
      }
      return subshipments.reversed.toList();
    } else {
      return subshipments;
    }
  }

  Future<List<TruckType>> getTruckTypes() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(TRUCK_TYPES_ENDPOINT, apiToken: jwt);
    truckTypes = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        truckTypes.add(TruckType.fromJson(element));
      }
    }
    return truckTypes;
  }

  Future<List<PackageType>> getPackageTypes() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(PACKAGE_TYPES_ENDPOINT, apiToken: jwt);
    packageTypes = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        packageTypes.add(PackageType.fromJson(element));
      }
    }
    return packageTypes;
  }

  Future<Shipmentv2?> createShipmentv2(
    Shipmentv2 shipment,
  ) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var request =
        http.MultipartRequest('POST', Uri.parse(SHIPPMENTSV2_ENDPOINT));
    request.headers.addAll({
      HttpHeaders.authorizationHeader: "JWT $token",
      HttpHeaders.contentTypeHeader: "multipart/form-data"
    });

    List<Map<String, dynamic>> sub_shipments = [];
    for (var element in shipment.subshipments!) {
      var item = element.toJson();
      sub_shipments.add(item);
    }
    var dataString = prefs.getString("userProfile");
    UserModel userModel = UserModel.fromJson(jsonDecode(dataString!));

    request.fields['merchant'] = userModel.merchant!.toString();
    request.fields['subshipments'] = jsonEncode(sub_shipments);
    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      var resString = jsonDecode(respStr);
      var res = Shipmentv2.fromJson(resString);
      return res;
    } else {
      final respStr = await response.stream.bytesToString();
      print(respStr);
      return null;
    }
  }

  Future<int?> createKShipment(KShipment shipment) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var request =
        http.MultipartRequest('POST', Uri.parse(SHIPPMENTSV2_ENDPOINT));
    request.headers.addAll({
      HttpHeaders.authorizationHeader: "JWT $token",
      HttpHeaders.contentTypeHeader: "multipart/form-data"
    });

    List<Map<String, dynamic>> shipment_items = [];
    for (var element in shipment.shipmentItems!) {
      var item = element.toJson();
      shipment_items.add(item);
    }

    List<Map<String, dynamic>> path_points = [];
    for (var element in shipment.pathPoints!) {
      var item = element.toJson();
      path_points.add(item);
    }

    var dataString = prefs.getString("userProfile");
    UserModel userModel = UserModel.fromJson(jsonDecode(dataString!));

    request.fields['merchant'] = userModel.merchant!.toString();
    request.fields['truck'] = shipment.truck!.id!.toString();
    request.fields['shipment_type'] = shipment.shipmentType!;
    request.fields['total_weight'] = shipment.totalWeight.toString();
    request.fields['truck_type'] = shipment.truckType!.id!.toString();
    request.fields['shipment_items'] = jsonEncode(shipment_items);
    request.fields['path_points'] = jsonEncode(path_points);
    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      var res = jsonDecode(respStr);
      return res['truck_type'];
    } else {
      final respStr = await response.stream.bytesToString();
      print(respStr);
      return null;
    }
  }

  Future<bool> assignShipment(int shipmentId, int driver) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var response = await HttpHelper.patch(
      "$SUB_SHIPPMENTSV2_ENDPOINT$shipmentId/assign_shipment/",
      {"truck": driver},
      apiToken: token,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> assignDriver(int shipmentId, int driver) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var response = await HttpHelper.patch(
      "$SUB_SHIPPMENTSV2_ENDPOINT$shipmentId/assign_driver/",
      {"truck": driver},
      apiToken: token,
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateShipmentStatus(int id, String status) async {
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var response = await HttpHelper.patch(
      "$SUB_SHIPPMENTSV2_ENDPOINT$id/update_status/",
      {"shipment_status": status},
      apiToken: jwt,
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> activeShipmentStatus(int id) async {
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var response = await HttpHelper.patch(
      "$SUB_SHIPPMENTSV2_ENDPOINT$id/active_shipment/",
      {"shipment_status": "A"},
      apiToken: jwt,
    );
    print(response.statusCode);
    final Map<String, dynamic> data = <String, dynamic>{};
    data["status"] = response.statusCode;
    var jsonObject = jsonDecode(response.body);

    data["details"] = jsonObject["details"];
    return data;
  }

  Future<dynamic> completeSubShipment(int id) async {
    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var response = await HttpHelper.patch(
      "$SUB_SHIPPMENTSV2_ENDPOINT$id/complete_subshipment/",
      {"shipment_status": "C", "complete_notes": "_"},
      apiToken: jwt,
    );
    print(response.statusCode);
    final Map<String, dynamic> data = <String, dynamic>{};
    data["status"] = response.statusCode;
    var jsonObject = jsonDecode(response.body);

    data["details"] = jsonObject["details"];
    return data;
  }

  Future<Shipmentv2?> getShipment(int id) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get('$SHIPPMENTSV2_ENDPOINT$id/', apiToken: jwt);
    print(rs.statusCode);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      return Shipmentv2.fromJson(result);
    }
    return null;
  }

  Future<SubShipment?> getSubShipment(int id) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs =
        await HttpHelper.get('$SUB_SHIPPMENTSV2_ENDPOINT$id/', apiToken: jwt);

    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      return SubShipment.fromJson(result);
    }
    return null;
  }
}
