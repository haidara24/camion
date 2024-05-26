import 'dart:convert';

import 'package:camion/data/models/approval_request.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestRepository {
  late SharedPreferences prefs;
  List<ApprovalRequest> approvalRequests = [];

  Future<List<ApprovalRequest>> getApprovalRequests() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");
    var driver = prefs.getInt("truckuser");
    var rs = await HttpHelper.get('$APPROVAL_REQUESTS_ENDPOINT?driver=$driver',
        apiToken: jwt);
    approvalRequests = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        print(rs.statusCode);
        approvalRequests.add(ApprovalRequest.fromJson(element));
      }
    }
    return approvalRequests;
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
