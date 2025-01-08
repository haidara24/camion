import 'dart:convert';

import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/providers/user_provider.dart';
import 'package:camion/data/repositories/auth_repository.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
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
          var userType = prefs.getString("userType") ?? "";

          final hastoken = await authRepository.isAuthenticated();
          print("has token ${hastoken}");
          if (hastoken) {
            if (userType.isNotEmpty) {
              switch (userType) {
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
              var jwt = prefs.getString("token");

              Response userresponse =
                  await HttpHelper.get(PROFILE_ENDPOINT, apiToken: jwt);
              print("userresponse ${userresponse.statusCode}");
              if (userresponse.statusCode == 200) {
                var prefs = await SharedPreferences.getInstance();

                if (userType.isNotEmpty) {
                  var myDataString = utf8.decode(userresponse.bodyBytes);

                  prefs.setString("userProfile", myDataString);
                  var result = jsonDecode(myDataString);
                  var userProfile = UserModel.fromJson(result);
                  userProvider.setUser(UserModel.fromJson(result));
                  if (userProfile.merchant != null && userType == "Merchant") {
                    prefs.setInt("merchant", userProfile.merchant!);
                  }
                  if (userProfile.truckowner != null && userType == "Owner") {
                    prefs.setInt("truckowner", userProfile.truckowner!);
                  }
                  if (userProfile.truckuser != null && userType == "Driver") {
                    prefs.setInt("truckuser", userProfile.truckuser!);
                    Response driverResponse = await HttpHelper.get(
                        '$DRIVERS_ENDPOINT${userProfile.truckuser}/',
                        apiToken: jwt);
                    if (driverResponse.statusCode == 200) {
                      var driverDataString =
                          utf8.decode(driverResponse.bodyBytes);
                      print(driverDataString);
                      var res = jsonDecode(driverDataString);
                      userProvider.setDriver(Driver.fromJson(res));

                      if (res['truck2'] != null) {
                        prefs.setInt("truckId", res['truck2']);
                        prefs.setString("gpsId", res["gpsId"] ?? "");
                        prefs.setInt("carId", int.parse(res["carId"] ?? "0"));
                      }
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
        prefs = await SharedPreferences.getInstance();
        var userType = prefs.getString("userType") ?? "";

        var data = await authRepository.temploginWithPhone(phone: event.phone);

        print("status ${data["status"]}");

        if (data["status"] == 200) {
          switch (userType) {
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
        } else {
          emit(AuthFailureState(data["details"]));
        }
      } catch (e) {
        emit(AuthFailureState(e.toString()));
      }
    });

    on<VerifyButtonPressed>((event, emit) async {
      emit(AuthLoggingInProgressState());
      try {
        prefs = await SharedPreferences.getInstance();
        var userType = prefs.getString("userType") ?? "";

        var data = await authRepository.verifyOtp(
          otp: event.otp,
        );
        if (data["status"] == 200) {
          switch (userType) {
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

    on<SignUpButtonPressed>((event, emit) async {
      emit(AuthLoggingInProgressState());
      try {
        prefs = await SharedPreferences.getInstance();
        var userType = prefs.getString("userType") ?? "";

        var data = await authRepository.tempregisterWithPhone(
          phone: event.phone,
          first_name: event.first_name,
          last_name: event.last_name,
        );
        print("status ${data["status"]}");
        if (data["status"] == 200) {
          switch (userType) {
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
          // emit(PhoneAuthSuccessState(data));
        } else {
          emit(AuthFailureState(data["details"]));
        }
      } catch (e) {
        emit(AuthFailureState(e.toString()));
      }
    });

    on<UserLoggedOut>(
      (event, emit) async {
        emit(AuthInitial());
        await authRepository.logout();
      },
    );
  }
}
