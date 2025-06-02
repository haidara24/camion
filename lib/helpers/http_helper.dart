// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const DOMAIN = 'https://api.camion.app/';

const OWNER_TRUCKS_GPS_LOCATION_ENDPOINT = '${DOMAIN}update-truck-locations/';
const OWNER_TRUCKS_LIST_GPS_LOCATION_ENDPOINT = '${DOMAIN}get-truck-locations/';

const LOGIN_ENDPOINT = '${DOMAIN}camionauth/jwt/create/';
const PHONE_LOGIN_ENDPOINT = '${DOMAIN}accounts/login/';
const PHONE_REGISTER_ENDPOINT = '${DOMAIN}accounts/register/';
const VERIFY_OTP_ENDPOINT = '${DOMAIN}accounts/verify-otp/';
const RESEND_OTP_ENDPOINT = '${DOMAIN}accounts/resend-otp/';
const LOGOUT_ENDPOINT = '${DOMAIN}accounts/logout/';
const USERS_ENDPOINT = '${DOMAIN}accounts/users/';
const DRIVERS_ENDPOINT = '${DOMAIN}accounts/drivers/';
const MERCHANTS_ENDPOINT = '${DOMAIN}accounts/merchants/';
const OWNERS_ENDPOINT = '${DOMAIN}accounts/owners/';

const PROFILE_ENDPOINT = '${DOMAIN}auth/users/me';

const TRUCK_TYPES_ENDPOINT = '${DOMAIN}core/trucktypes/';
const COMMODITY_CATEGORIES_ENDPOINT = '${DOMAIN}core/commoditycategories/';
const PACKAGE_TYPES_ENDPOINT = '${DOMAIN}core/packagestypes/';

const POSTS_ENDPOINT = '${DOMAIN}camion/posts/';
const SAVED_POSTS_ENDPOINT = '${DOMAIN}camion/savedposts/';
const GROUPS_ENDPOINT = '${DOMAIN}camion/groups/';
const STATE_CUSTOMES_ENDPOINT = '${DOMAIN}camion/statecustomes/';
const APPROVAL_REQUESTS_ENDPOINT = '${DOMAIN}camion/approvalrequests/';
const PERMISSIONS_ENDPOINT = '${DOMAIN}camion/permessions/';
const STORES_ENDPOINT = '${DOMAIN}camion/storehouses/';
const GOVERNORATES_ENDPOINT = '${DOMAIN}core/governorates/';
const TRUCKS_ENDPOINT = '${DOMAIN}camion/trucks2/';
const TRUCK_PAPERS_ENDPOINT = '${DOMAIN}camion/truckpapers/';
const TRUCK_PRICES_ENDPOINT = '${DOMAIN}camion/truckprices/';
const TRUCK_EXPENSES_ENDPOINT = '${DOMAIN}camion/truckfixes/';
const FIXES_TYPE_ENDPOINT = '${DOMAIN}camion/fixestype/';
const PRICEREQUEST_ENDPOINT = '${DOMAIN}camion/pricerequests/';
const SHIPPMENTSV2_ENDPOINT = '${DOMAIN}camion/shipmentV2s/';
const SUB_SHIPPMENTSV2_ENDPOINT = '${DOMAIN}camion/subshippments/';
const SHIPPMENTS_PAYMENT_ENDPOINT = '${DOMAIN}camion/shipmentpayment/';
const SHIPPMENTS_INSTRUCTION_ENDPOINT =
    '${DOMAIN}camion/shippmentinstructions/';

const NOTIFICATIONS_ENDPOINT = '${DOMAIN}noti/notifications/';

const GPS_DOMAIN = 'https://www.whatsgps.com/';
const GPS_LOGIN = '${GPS_DOMAIN}user/login.do?name=Acrossmena&password=abc123';
const GPS_CARINFO = '${GPS_DOMAIN}car/getByImei.do?token=';

class HttpHelper {
  static Future<http.Response> post(String url, Map<String, dynamic> body,
      {String? apiToken}) async {
    return (await http.post(Uri.parse(url), body: jsonEncode(body), headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'JWT $apiToken'
    }));
  }

  static Future<http.Response> put(String url, Map<String, dynamic> body,
      {String? apiToken}) async {
    return (await http.put(Uri.parse(url), body: jsonEncode(body), headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'JWT $apiToken'
    }));
  }

  static Future<http.Response> patch(String url, Map<String, dynamic> body,
      {String? apiToken}) async {
    return (await http.patch(Uri.parse(url), body: jsonEncode(body), headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'JWT $apiToken'
    }));
  }

  static Future<http.Response> get(String url, {String? apiToken}) async {
    return await http.get(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'JWT $apiToken'});
  }

  static Future<http.Response> delete(String url, {String? apiToken}) async {
    return await http.delete(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'JWT $apiToken'});
  }

  static Future<http.Response> getAuth(String url, {String? apiToken}) async {
    return await http.get(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'JWT $apiToken'});
  }
}
