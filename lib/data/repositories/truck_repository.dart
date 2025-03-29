import 'dart:convert';
import 'dart:io';

import 'package:camion/data/models/truck_model.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TruckRepository {
  List<KTruck> ktrucks = [];
  List<TruckPaper> truckPapers = [];
  List<TruckExpense> truckExpenses = [];
  List<ExpenseType> fixesType = [];
  late SharedPreferences prefs;

  Future<List<KTruck>> getTrucks(List<int> types) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    String truckTypeParams = types.map((type) => 'truck_type=$type').join('&');

    var rs = await HttpHelper.get('$TRUCKS_ENDPOINT?$truckTypeParams',
        apiToken: jwt);
    ktrucks = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        ktrucks.add(KTruck.fromJson(element));
      }
    }
    return ktrucks;
  }

  Future<List<KTruck>> getNearestTrucks(
      List<int> types, String location, String pol, String pod) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    String truckTypeParams = types.map((type) => 'truck_types=$type').join('&');
    var rs = await HttpHelper.get(
        '${TRUCKS_ENDPOINT}nearest_trucks/?location=$location&$truckTypeParams&loading_place_id=$pol&discharge_place_id=$pod',
        apiToken: jwt);
    ktrucks = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        ktrucks.add(KTruck.fromJson(element));
      }
    }
    return ktrucks;
  }

  Future<List<KTruck>> searchKTrucks(String query) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs =
        await HttpHelper.get('$TRUCKS_ENDPOINT?search=$query', apiToken: jwt);
    ktrucks = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        ktrucks.add(KTruck.fromJson(element));
      }
    }
    return ktrucks;
  }

  Future<List<KTruck>> getTrucksForOwner() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get('${TRUCKS_ENDPOINT}list_for_owner/',
        apiToken: jwt);
    ktrucks = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);

      for (var element in result) {
        ktrucks.add(KTruck.fromJson(element));
      }
    }
    return ktrucks;
  }

  Future<KTruck?> getTruck(int id) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get('$TRUCKS_ENDPOINT$id/', apiToken: jwt);

    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      return KTruck.fromJson(result);
    }
    return null;
  }

  Future<String?> getTruckLocation(int id) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs =
        await HttpHelper.get('$TRUCKS_ENDPOINT$id/location/', apiToken: jwt);

    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      return result["location_lat"];
    }
    return null;
  }

  Future<bool> updateTruckLocation(int id, String location) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var rs = await HttpHelper.patch(
        '$TRUCKS_ENDPOINT$id/update_location/', {'location_lat': location},
        apiToken: jwt);

    if (rs.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool?> updateTruckActiveStatus(bool status) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var truckId = prefs.getInt("truckId");
    var rs = await HttpHelper.patch(
        '$TRUCKS_ENDPOINT$truckId/update_active_status/', {'isOn': !status},
        apiToken: jwt);

    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      return result["isOn"];
    } else {
      return null;
    }
  }

  Future<bool?> getTruckActiveStatus() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var truckId = prefs.getInt("truckId");
    var rs =
        await HttpHelper.get('$TRUCKS_ENDPOINT$truckId/isOn/', apiToken: jwt);

    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      return result["isOn"];
    }
    return null;
  }

  Future<List<TruckPaper>> getTruckPapers(int truck) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get('$TRUCK_PAPERS_ENDPOINT?truck=$truck',
        apiToken: jwt);
    truckPapers = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        truckPapers.add(TruckPaper.fromJson(element));
      }
    }
    return truckPapers;
  }

  Future<TruckPaper?> createTruckPapers(File image, TruckPaper paper) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    var request =
        http.MultipartRequest('POST', Uri.parse(TRUCK_PAPERS_ENDPOINT));
    request.headers.addAll({
      HttpHeaders.authorizationHeader: "JWT $token",
      HttpHeaders.contentTypeHeader: "multipart/form-data"
    });

    final uploadImage = await http.MultipartFile.fromPath(
      'image',
      image.path,
      filename: image.path.split('/').last,
    );

    request.files.add(uploadImage);

    request.fields['paper_type'] = paper.paperType!;
    request.fields['expire_date'] = paper.expireDate.toString();
    request.fields['start_date'] = paper.startDate.toString();
    request.fields['truck'] = paper.truck.toString();
    var response = await request.send();

    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      var res = jsonDecode(respStr);
      return TruckPaper.fromJson(res);
    } else {
      final respStr = await response.stream.bytesToString();
      return null;
    }
  }

  Future<List<ExpenseType>> getExpenseTypes() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(FIXES_TYPE_ENDPOINT, apiToken: jwt);
    fixesType = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        fixesType.add(ExpenseType.fromJson(element));
      }
    }
    return fixesType;
  }

  Future<List<TruckExpense>> getTruckExpenses(int? truckid) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var truckId = prefs.getInt("truckId");

    var rs = await HttpHelper.get(
        '$TRUCK_EXPENSES_ENDPOINT?truck=${truckid ?? truckId}',
        apiToken: jwt);
    truckExpenses = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        truckExpenses.add(TruckExpense.fromJson(element));
      }
    }
    return truckExpenses;
  }

  Future<bool> createTruckExpense(TruckExpense fix) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var truckId = prefs.getInt("truckId");
    var response = await HttpHelper.post(
      TRUCK_EXPENSES_ENDPOINT,
      {
        "fix_type": fix.fixType,
        "amount": fix.amount,
        "note": fix.note,
        "dob": fix.dob?.toIso8601String(),
        "truck": truckId,
        "expense_type": fix.expenseType!.id!
      },
      apiToken: token,
    );
    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<KTruck?> createKTruck(
    KTruck truck,
    List<File> files,
  ) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var request = http.MultipartRequest('POST', Uri.parse(TRUCKS_ENDPOINT));
    request.headers.addAll({
      HttpHeaders.authorizationHeader: "JWT $token",
      // HttpHeaders.contentTypeHeader: "multipart/form-data"
    });

    final uploadImages = <http.MultipartFile>[];
    for (final imageFiles in files) {
      uploadImages.add(
        await http.MultipartFile.fromPath(
          'files',
          imageFiles.path,
          filename: imageFiles.path.split('/').last,
        ),
      );
    }
    for (var element in uploadImages) {
      request.files.add(element);
    }

    request.fields['truckuser'] = truck.truckuser!.toString();
    request.fields['owner'] = truck.phoneowner ?? "0";
    request.fields['truck_type'] = truck.truckType!.id!.toString();
    request.fields['location_lat'] = truck.locationLat!;
    request.fields['height'] = truck.height!.toString();
    request.fields['width'] = truck.width!.toString();
    request.fields['long'] = truck.long!.toString();
    request.fields['number_of_axels'] = truck.numberOfAxels!.toString();
    request.fields['truck_number'] = truck.truckNumber!.toString();
    request.fields['traffic'] = truck.traffic!.toString();
    request.fields['empty_weight'] = truck.emptyWeight!.toString();
    request.fields['gpsId'] = "";
    var response = await request.send();
    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      return KTruck.fromJson(jsonDecode(respStr));
    } else {
      final respStr = await response.stream.bytesToString();
      return null;
    }
  }

  Future<KTruck?> createKTruckForOwner(
    Map<String, dynamic> truck,
    List<File> files,
  ) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var request = http.MultipartRequest(
        'POST', Uri.parse("${TRUCKS_ENDPOINT}create-with-driver/"));
    request.headers.addAll({
      HttpHeaders.authorizationHeader: "JWT $token",
      HttpHeaders.contentTypeHeader: "multipart/form-data"
    });

    final uploadImages = <http.MultipartFile>[];
    for (final imageFiles in files) {
      uploadImages.add(
        await http.MultipartFile.fromPath(
          'files',
          imageFiles.path,
          filename: imageFiles.path.split('/').last,
        ),
      );
    }
    for (var element in uploadImages) {
      request.files.add(element);
    }
    request.fields['driver_first_name'] = truck['driver_first_name'].toString();
    request.fields['driver_last_name'] = truck['driver_last_name'].toString();
    request.fields['driver_phone'] = truck['driver_phone'].toString();
    request.fields['owner'] = truck['owner'].toString();
    request.fields['truck_type'] = truck['truckType'].id.toString();
    request.fields['location_lat'] = "35.363149,35.932120";
    request.fields['height'] = truck['height'].toString();
    request.fields['width'] = truck['width'].toString();
    request.fields['long'] = truck['long'].toString();
    request.fields['number_of_axels'] = truck['numberOfAxels'].toString();
    request.fields['truck_number'] = truck['truckNumber'].toString();
    request.fields['traffic'] = truck['traffic'].toString();
    request.fields['empty_weight'] = truck['emptyWeight'].toString();
    request.fields['gross_weight'] = truck['grossWeight'].toString();
    request.fields['gpsId'] = "";
    var response = await request.send();
    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      return KTruck.fromJson(jsonDecode(respStr));
    } else {
      final respStr = await response.stream.bytesToString();
      return null;
    }
  }
}
