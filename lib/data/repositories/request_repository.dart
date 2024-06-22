import 'dart:convert';

import 'package:camion/data/models/approval_request.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestRepository {
  late SharedPreferences prefs;
  List<ApprovalRequest> approvalRequests = [];
  List<MerchantApprovalRequest> merchantapprovalRequests = [];

  Future<List<ApprovalRequest>> getApprovalRequests(int? driverId) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var driver = prefs.getInt('truckuser');
    var rs = await HttpHelper.get(
        '${APPROVAL_REQUESTS_ENDPOINT}list_for_driver/${driverId ?? driver}',
        apiToken: jwt);
    approvalRequests = [];
    print(rs.statusCode);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);
      print(myDataString);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        approvalRequests.add(ApprovalRequest.fromJson(element));
      }
    }
    return approvalRequests;
  }

  Future<List<ApprovalRequest>> getApprovalRequestsForOwner() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var rs = await HttpHelper.get(
        '${APPROVAL_REQUESTS_ENDPOINT}list_for_owner/',
        apiToken: jwt);
    approvalRequests = [];
    print(rs.statusCode);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);
      print(myDataString);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        approvalRequests.add(ApprovalRequest.fromJson(element));
      }
    }
    return approvalRequests;
  }

  Future<List<MerchantApprovalRequest>> getApprovalRequestsForMerchant() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var rs = await HttpHelper.get(
        '${APPROVAL_REQUESTS_ENDPOINT}list_for_merchant/',
        apiToken: jwt);
    merchantapprovalRequests = [];
    print(rs.statusCode);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        merchantapprovalRequests.add(MerchantApprovalRequest.fromJson(element));
      }
    }

    return merchantapprovalRequests;
  }

  Future<ApprovalRequest?> getRequestDetails(int id) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs =
        await HttpHelper.get('$APPROVAL_REQUESTS_ENDPOINT$id/', apiToken: jwt);

    print(rs.statusCode);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      return ApprovalRequest.fromJson(result);
    }
    return null;
  }

  Future<bool> acceptRequestForMerchant(
      int id, String text, double extra_fees) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.patch(
        '$APPROVAL_REQUESTS_ENDPOINT$id/accept_request/',
        {
          "response_turn": "T",
          "is_approved": true,
          "extra_fees_text": text,
          "extra_fees": extra_fees
        },
        apiToken: jwt);

    if (rs.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> rejectRequestForMerchant(int id, String text) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.patch(
        '$APPROVAL_REQUESTS_ENDPOINT$id/reject_request/',
        {"response_turn": "T", "is_approved": false, "reason": text},
        apiToken: jwt);
    print(rs.statusCode);
    print(text);
    print(rs.body);
    if (rs.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
