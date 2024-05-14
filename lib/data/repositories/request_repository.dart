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
}
