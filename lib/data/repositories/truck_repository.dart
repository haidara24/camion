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

  Future<bool> updateTruckLocation(int id, String location) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var rs = await HttpHelper.patch(
        '$TRUCKS_ENDPOINT$id/', {'location_lat': location},
        apiToken: jwt);

    if (rs.statusCode == 200) {
      return true;
    } else {
      return false;
    }
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

  Future<List<TruckExpense>> getTruckExpenses() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var truckId = prefs.getInt("truckId");
    print(truckId);

    var rs = await HttpHelper.get('$TRUCK_EXPENSES_ENDPOINT?truck=$truckId',
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

  Future<TruckExpense?> createTruckExpense(TruckExpense fix) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var truckId = prefs.getInt("truckId");
    var response = await HttpHelper.post(
      TRUCK_EXPENSES_ENDPOINT,
      {
        "fix_type": fix.fixType,
        "amount": fix.amount,
        "dob": fix.dob?.toIso8601String(),
        "truck": truckId,
        "expense_type": fix.expenseType!.id!
      },
      apiToken: token,
    );
    if (response.statusCode == 201) {
      var myDataString = utf8.decode(response.bodyBytes);
      var json = jsonDecode(myDataString);
      var fix = TruckExpense.fromJson(jsonDecode(response.body));

      return fix;
    } else {
      return null;
    }
  }
}
