import 'dart:convert';

import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/providers/user_provider.dart';
import 'package:camion/data/repositories/auth_repository.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  late UserProvider userProvider;

  late SharedPreferences prefs;

  AuthBloc({required this.authRepository, required this.userProvider})
      : super(AuthInitial()) {
    on<AuthCheckRequested>(
      (event, emit) async {
        emit(AuthInProgressState());
        try {
          prefs = await SharedPreferences.getInstance();
          var userType = prefs.getString("userType");
          var jwt = prefs.getString("token");

          final hastoken = await authRepository.isAuthenticated();
          if (userType != null) {
            if (hastoken) {
              switch (userType) {
                case "Managment":
                  emit(AuthManagmentSuccessState());
                  break;
                case "CheckPoint":
                  emit(AuthCheckPointSuccessState());
                  break;
                case "Driver":
                  emit(AuthDriverSuccessState());
                  break;
                case "Owner":
                  emit(AuthOwnerSuccessState());
                  break;
                case "Merchant":
                  emit(AuthMerchantSuccessState());
                  break;
                default:
              }
              Response userresponse =
                  await HttpHelper.get(PROFILE_ENDPOINT, apiToken: jwt);
              if (userresponse.statusCode == 200) {
                var prefs = await SharedPreferences.getInstance();
                var userType = prefs.getString("userType") ?? "";
                if (userType.isNotEmpty) {
                  var myDataString = utf8.decode(userresponse.bodyBytes);

                  prefs.setString("userProfile", myDataString);
                  var result = jsonDecode(myDataString);
                  var userProfile = UserModel.fromJson(result);
                  if (userProfile.merchant != null) {
                    prefs.setInt("merchant", userProfile.merchant!);
                    Response merchantResponse = await HttpHelper.get(
                        '$MERCHANTS_ENDPOINT${userProfile.merchant}/',
                        apiToken: jwt);
                    if (merchantResponse.statusCode == 200) {
                      var merchantDataString =
                          utf8.decode(merchantResponse.bodyBytes);
                      var res = jsonDecode(merchantDataString);
                      userProvider.setMerchant(Merchant.fromJson(res));
                    }
                  }
                  if (userProfile.truckowner != null) {
                    prefs.setInt("truckowner", userProfile.truckowner!);
                    Response ownerResponse = await HttpHelper.get(
                        '$OWNERS_ENDPOINT${userProfile.truckowner}/',
                        apiToken: jwt);
                    if (ownerResponse.statusCode == 200) {
                      var ownerDataString =
                          utf8.decode(ownerResponse.bodyBytes);
                      var res = jsonDecode(ownerDataString);
                      userProvider.setTruckOwner(TruckOwner.fromJson(res));
                    }
                  }
                  if (userProfile.truckuser != null) {
                    prefs.setInt("truckuser", userProfile.truckuser!);
                    Response driverResponse = await HttpHelper.get(
                        '$DRIVERS_ENDPOINT${userProfile.truckuser}/',
                        apiToken: jwt);
                    if (driverResponse.statusCode == 200) {
                      var driverDataString =
                          utf8.decode(driverResponse.bodyBytes);
                      var res = jsonDecode(driverDataString);
                      userProvider.setDriver(Driver.fromJson(res));

                      prefs.setInt("truckId", res['truck2']["id"]);
                      prefs.setString("gpsId", res['truck2']["gpsId"]);
                    }
                  }
                }
              }
            } else {
              emit(const AuthFailureState("User is not logged in"));
            }
          } else {
            emit(const AuthFailureState("User is not logged in"));
          }
        } catch (e) {
          emit(AuthFailureState(e.toString()));
        }
      },
    );

    on<PhoneSignInButtonPressed>((event, emit) async {
      emit(AuthLoggingInProgressState());
      try {
        var data = await authRepository.loginWithPhone(phone: event.phone);
        if (data["status"] == 200) {
          emit(PhoneAuthSuccessState(data));
        } else {
          emit(PhoneAuthFailedState(data["details"]));
        }
      } catch (e) {
        emit(AuthFailureState(e.toString()));
      }
    });

    on<VerifyButtonPressed>((event, emit) async {
      emit(AuthLoggingInProgressState());
      try {
        prefs = await SharedPreferences.getInstance();
        var userType = prefs.getString("userType");
        var jwt = prefs.getString("token");

        var data = await authRepository.verifyOtp(
          otp: event.otp,
        );
        if (data["status"] == 200) {
          switch (userType) {
            case "Managment":
              emit(AuthManagmentSuccessState());
              break;
            case "CheckPoint":
              emit(AuthCheckPointSuccessState());
              break;
            case "Driver":
              emit(AuthDriverSuccessState());
              break;
            case "Owner":
              emit(AuthOwnerSuccessState());
              break;
            case "Merchant":
              emit(AuthMerchantSuccessState());
              break;
            default:
              emit(const AuthFailureState("خطأ في نوع المستخدم."));
          }
          Response userresponse =
              await HttpHelper.get(PROFILE_ENDPOINT, apiToken: jwt);
          if (userresponse.statusCode == 200) {
            var prefs = await SharedPreferences.getInstance();
            var userType = prefs.getString("userType") ?? "";
            if (userType.isNotEmpty) {
              var myDataString = utf8.decode(userresponse.bodyBytes);

              prefs.setString("userProfile", myDataString);
              var result = jsonDecode(myDataString);
              var userProfile = UserModel.fromJson(result);
              if (userProfile.merchant != null) {
                prefs.setInt("merchant", userProfile.merchant!);
                Response merchantResponse = await HttpHelper.get(
                    '$MERCHANTS_ENDPOINT${userProfile.merchant}/',
                    apiToken: jwt);
                if (merchantResponse.statusCode == 200) {
                  var merchantDataString =
                      utf8.decode(merchantResponse.bodyBytes);
                  var res = jsonDecode(merchantDataString);
                  userProvider.setMerchant(Merchant.fromJson(res));
                }
              }
              if (userProfile.truckowner != null) {
                prefs.setInt("truckowner", userProfile.truckowner!);
                Response ownerResponse = await HttpHelper.get(
                    '$OWNERS_ENDPOINT${userProfile.truckowner}/',
                    apiToken: jwt);
                if (ownerResponse.statusCode == 200) {
                  var ownerDataString = utf8.decode(ownerResponse.bodyBytes);
                  var res = jsonDecode(ownerDataString);
                  userProvider.setTruckOwner(TruckOwner.fromJson(res));
                }
              }
              if (userProfile.truckuser != null) {
                prefs.setInt("truckuser", userProfile.truckuser!);
                Response driverResponse = await HttpHelper.get(
                    '$DRIVERS_ENDPOINT${userProfile.truckuser}/',
                    apiToken: jwt);
                if (driverResponse.statusCode == 200) {
                  var driverDataString = utf8.decode(driverResponse.bodyBytes);
                  var res = jsonDecode(driverDataString);
                  userProvider.setDriver(Driver.fromJson(res));

                  prefs.setInt("truckId", res['truck2']["id"]);
                  prefs.setString("gpsId", res['truck2']["gpsId"]);
                }
              }
            }
          }
        } else if (data["status"] == 401) {
          String? details = "";
          if (data["details"] != null) {
            details = data["details"];
          }
          emit(AuthLoginErrorState(details));
        } else {
          String details = data["details"];
          emit(AuthFailureState(details));
        }
      } catch (e) {
        emit(AuthFailureState(e.toString()));
      }
    });

    on<SignInButtonPressed>((event, emit) async {
      emit(AuthLoggingInProgressState());
      try {
        prefs = await SharedPreferences.getInstance();
        var userType = prefs.getString("userType");

        var data = await authRepository.login(
            username: event.username, password: event.password);
        if (data["status"] == 200) {
          switch (userType) {
            case "Managment":
              emit(AuthManagmentSuccessState());
              break;
            case "CheckPoint":
              emit(AuthCheckPointSuccessState());
              break;
            case "Driver":
              emit(AuthDriverSuccessState());
              break;
            case "Owner":
              emit(AuthOwnerSuccessState());
              break;
            case "Merchant":
              emit(AuthMerchantSuccessState());
              break;
            default:
              emit(const AuthFailureState("خطأ في نوع المستخدم."));
          }
        } else if (data["status"] == 401) {
          String? details = "";
          if (data["details"] != null) {
            details = data["details"];
          }
          emit(AuthLoginErrorState(details));
        } else {
          String details = data["details"];
          emit(AuthFailureState(details));
        }
      } catch (e) {
        emit(AuthFailureState(e.toString()));
      }
    });

    on<UserLoggedOut>(
      (event, emit) async {
        await authRepository.logout();
        emit(AuthInitial());
      },
    );
  }
}
