import 'dart:convert';
import 'dart:io';

import 'package:camion/data/models/truck_model.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TruckRepository {
  List<Truck> trucks = [];
  List<KTruck> ktrucks = [];
  List<TruckPaper> truckPapers = [];
  List<TruckExpense> truckExpenses = [];
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
    print(ktrucks);
    return ktrucks;
  }

  Future<List<KTruck>> getKTrucks(int type) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get('$KTRUCKS_ENDPOINT?truck_type=$type',
        apiToken: jwt);
    ktrucks = [];
    print(rs.statusCode);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      print(myDataString);
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
        await HttpHelper.get('$KTRUCKS_ENDPOINT?search=$query', apiToken: jwt);
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

  Future<List<Truck>> getTrucksForOwner(int ownerId) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs =
        await HttpHelper.get('$TRUCKS_ENDPOINT?owner=$ownerId', apiToken: jwt);
    trucks = [];
    print(rs.statusCode);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      trucks.add(Truck(
        id: 0,
        truckuser: Truckuser(
          id: 0,
          user: UserInfo(id: 0, firstName: "All", lastName: ""),
        ),
      ));
      for (var element in result) {
        trucks.add(Truck.fromJson(element));
      }
    }
    return trucks;
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
      print(respStr);
      var res = jsonDecode(respStr);
      return TruckPaper.fromJson(res);
    } else {
      final respStr = await response.stream.bytesToString();
      return null;
    }
  }

  Future<List<TruckExpense>> getTruckExpenses(int truck) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get('$TRUCK_EXPENSES_ENDPOINT?truck=$truck',
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

    var response = await HttpHelper.post(
      TRUCK_EXPENSES_ENDPOINT,
      {
        "fix_type": fix.fixType,
        "amount": fix.amount,
        "dob": fix.dob,
        "is_fixes": fix.isFixes,
        "truck": fix.truck,
        "expense_type": fix.expenseType
      },
      apiToken: token,
    );
    var myDataString = utf8.decode(response.bodyBytes);
    var json = jsonDecode(myDataString);
    if (response.statusCode == 200) {
      var fix = TruckExpense.fromJson(jsonDecode(response.body));

      return fix;
    } else {
      return null;
    }
  }
}
