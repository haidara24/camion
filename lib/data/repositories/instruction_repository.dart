import 'dart:convert';
import 'dart:io';

import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class InstructionRepository {
  late SharedPreferences prefs;

  Future<Shipmentinstruction?> createShipmentInstruction(
      Shipmentinstruction shipment) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var request = http.MultipartRequest(
        'POST', Uri.parse(SHIPPMENTS_INSTRUCTION_ENDPOINT));
    request.headers.addAll({
      HttpHeaders.authorizationHeader: "JWT $token",
      HttpHeaders.contentTypeHeader: "multipart/form-data"
    });

    // List<Map<String, dynamic>> sub_instructions = [];
    // for (var element in shipment.subinstrucations!) {
    //   var item = element.toJson();
    //   sub_instructions.add(item);
    // }

    request.fields['shipment'] = shipment.shipment!.toString();
    request.fields['user_type'] = shipment.userType!;
    request.fields['charger_name'] = shipment.chargerName!;
    request.fields['charger_address'] = shipment.chargerAddress!;
    request.fields['charger_phone'] = shipment.chargerPhone!;
    request.fields['reciever_name'] = shipment.recieverName!;
    request.fields['reciever_address'] = shipment.recieverAddress!;
    request.fields['reciever_phone'] = shipment.recieverPhone!;
    var response = await request.send();
    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      return Shipmentinstruction.fromJson(jsonDecode(respStr));
    } else {
      final respStr = await response.stream.bytesToString();
      return null;
    }
  }

  Future<Shipmentinstruction?> getShipmentInstruction(int id) async {
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get('$SHIPPMENTS_INSTRUCTION_ENDPOINT$id/',
        apiToken: jwt);

    print(rs.statusCode);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      return Shipmentinstruction.fromJson(result);
    }
    return null;
  }

  Future<SubShipmentInstruction?> createSubShipmentInstruction(
      SubShipmentInstruction shipment, int id) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var request = http.MultipartRequest('POST',
        Uri.parse("$SHIPPMENTS_INSTRUCTION_ENDPOINT$id/subinstructions/"));
    request.headers.addAll({
      HttpHeaders.authorizationHeader: "JWT $token",
      HttpHeaders.contentTypeHeader: "multipart/form-data"
    });

    List<Map<String, dynamic>> sub_commodity_items = [];
    for (var element in shipment.commodityItems!) {
      var item = element.toJson();
      sub_commodity_items.add(item);
    }

    request.fields['instruction'] = id.toString();
    request.fields['truck'] = shipment.truck!.toString();
    request.fields['net_weight'] = shipment.netWeight!.toString();
    request.fields['truck_weight'] = shipment.truckWeight!.toString();
    request.fields['final_weight'] = shipment.finalWeight!.toString();
    request.fields['commodity_items'] = jsonEncode(sub_commodity_items);
    var response = await request.send();
    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      return SubShipmentInstruction.fromJson(jsonDecode(respStr));
    } else {
      final respStr = await response.stream.bytesToString();
      return null;
    }
  }

  Future<SubShipmentInstruction?> getSubShipmentInstruction(
      int id, int subId) async {
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(
        '$SHIPPMENTS_INSTRUCTION_ENDPOINT$id/subinstructions/$subId/',
        apiToken: jwt);

    print(rs.statusCode);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      return SubShipmentInstruction.fromJson(result);
    }
    return null;
  }

  Future<int?> createShipmentPayment(ShipmentPayment shipment) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var request =
        http.MultipartRequest('POST', Uri.parse(SHIPPMENTS_PAYMENT_ENDPOINT));
    request.headers.addAll({
      HttpHeaders.authorizationHeader: "JWT $token",
      HttpHeaders.contentTypeHeader: "multipart/form-data"
    });
    request.fields['shipment'] = shipment.shipment!.toString();

    request.fields['amount'] = shipment.amount!.toString();
    request.fields['fees'] = shipment.fees!.toString();
    request.fields['extra_fees'] = shipment.extraFees!.toString();
    request.fields['payment_method'] = shipment.paymentMethod!.toString();

    var response = await request.send();
    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      return 1;
    } else {
      final respStr = await response.stream.bytesToString();
      return 0;
    }
  }
}
