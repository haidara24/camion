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
    print(rs.statusCode);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        ktrucks.add(KTruck.fromJson(element));
      }
    }
    return ktrucks;
  }

  Future<List<KTruck>> getNearestTrucks(int type, String location) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(
        '${TRUCKS_ENDPOINT}nearest_trucks/?location=$location&truck_type=$type',
        apiToken: jwt);
    ktrucks = [];
    print(rs.statusCode);
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
    print(rs.statusCode);
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
    print(rs.statusCode);
    print(rs.body);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      ktrucks.add(KTruck(
        id: 0,
        truckuser: KTuckUser(
          id: 0,
          usertruck: Usertruck(id: 0, firstName: "All", lastName: ""),
        ),
      ));
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

    print(rs.statusCode);
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

    print(rs.statusCode);
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
    print(!status);
    var rs = await HttpHelper.patch(
        '$TRUCKS_ENDPOINT$truckId/update_active_status/', {'isOn': !status},
        apiToken: jwt);
    print(rs.statusCode);

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
    print("truckId");
    print(truckId);
    var rs =
        await HttpHelper.get('$TRUCKS_ENDPOINT$truckId/isOn/', apiToken: jwt);

    print("rs.statusCode");
    print(rs.statusCode);
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
    print(rs.statusCode);
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

    print(response.statusCode);
    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      var res = jsonDecode(respStr);
      return TruckPaper.fromJson(res);
    } else {
      final respStr = await response.stream.bytesToString();
      print(respStr);
      return null;
    }
  }

  Future<List<ExpenseType>> getExpenseTypes() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(FIXES_TYPE_ENDPOINT, apiToken: jwt);
    fixesType = [];
    print(rs.statusCode);
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
    print(truckId);

    var rs = await HttpHelper.get(
        '$TRUCK_EXPENSES_ENDPOINT?truck=${truckid ?? truckId}',
        apiToken: jwt);
    truckExpenses = [];
    print(rs.statusCode);
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
    print(response.statusCode);
    print(response.body);
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

    request.fields['truckuser'] = truck.truckuser!.id!.toString();
    request.fields['owner'] = truck.owner!.toString();
    request.fields['truck_type'] = truck.truckType!.id!.toString();
    request.fields['location_lat'] = truck.locationLat!;
    request.fields['height'] = truck.height!.toString();
    request.fields['width'] = truck.width!.toString();
    request.fields['long'] = truck.long!.toString();
    request.fields['number_of_axels'] = truck.numberOfAxels!.toString();
    request.fields['truck_number'] = truck.truckNumber!.toString();
    request.fields['empty_weight'] = truck.emptyWeight!.toString();
    request.fields['gross_weight'] = truck.grossWeight!.toString();
    request.fields['traffic'] = truck.traffic!.toString();
    request.fields['gpsId'] = truck.gpsId!.toString();

    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      print(respStr);
      return KTruck.fromJson(jsonDecode(respStr));
    } else {
      final respStr = await response.stream.bytesToString();
      print(respStr);
      return null;
    }
  }
}
