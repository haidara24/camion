import 'dart:convert';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/core/auth_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final focusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    _postData(context);
  }

  void _postData(context) {
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: Text("aasdasd")));
    BlocProvider.of<AuthBloc>(context).add(SignInButtonPressed(
        _usernameController.text, _passwordController.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage("assets/images/camion_backgroung_image.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 150.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 17.w),
                      child: Card(
                        elevation: 1,
                        clipBehavior: Clip.antiAlias,
                        color: AppColor.deepBlack,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(45),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 60.h, horizontal: 20.w),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 75.h,
                                    width: 150.w,
                                    child: SvgPicture.asset(
                                        "assets/images/camion_logo_sm.svg"),
                                  ),
                                  SizedBox(
                                    height: 110.h,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .translate('please_sign_in'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 19.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .translate('username'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 19.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 350.w,
                                    child: TextFormField(
                                      // focusNode: focusNode,
                                      // keyboardType: TextInputType.phone,
                                      // initialValue: widget.initialValue,
                                      controller: _usernameController,
                                      onTap: () {
                                        _usernameController.selection =
                                            TextSelection.collapsed(
                                                offset: _usernameController
                                                    .text.length);
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty ||
                                            value.length < 3) {
                                          return AppLocalizations.of(context)!
                                              .translate('username_error');
                                        }
                                        return null;
                                      },
                                      onSaved: (newValue) {
                                        _usernameController.text = newValue!;
                                      },
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 19.sp,
                                      ),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20.w, vertical: 2.h),
                                        hintText: AppLocalizations.of(context)!
                                            .translate('username'),
                                        // labelText: AppLocalizations.of(context)!
                                        //     .translate('username'),
                                        // floatingLabelStyle: TextStyle(
                                        //   color: AppColor.deepYellow,
                                        //   fontSize: 24.sp,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 19.sp,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .translate('password'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 19.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 350.w,
                                    child: TextFormField(
                                      controller: _passwordController,
                                      onTap: () {
                                        _passwordController.selection =
                                            TextSelection.collapsed(
                                                offset: _passwordController
                                                    .text.length);
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty ||
                                            value.length < 3) {
                                          return AppLocalizations.of(context)!
                                              .translate('password_error');
                                        }
                                        return null;
                                      },
                                      onSaved: (newValue) {
                                        _passwordController.text = newValue!;
                                      },
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 19.sp,
                                      ),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20.w, vertical: 2.h),
                                        hintText: AppLocalizations.of(context)!
                                            .translate('password'),
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 19.sp,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30.h,
                                  ),
                                  BlocConsumer<AuthBloc, AuthState>(
                                    listener: (context, state) async {
                                      if (state is AuthDriverSuccessState ||
                                          state is AuthOwnerSuccessState ||
                                          state is AuthMerchentSuccessState ||
                                          state is AuthManagmentSuccessState ||
                                          state is AuthCheckPointSuccessState) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          backgroundColor: AppColor.deepGreen,
                                          dismissDirection: DismissDirection.up,
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  150,
                                              left: 10,
                                              right: 10),
                                          content: localeState.value.languageCode ==
                                                  'en'
                                              ? const Text(
                                                  'sign in successfully, welcome.')
                                              : const Text(
                                                  'تم تسجيل الدخول بنجاح! أهلا بك.'),
                                          duration: const Duration(seconds: 3),
                                        ));

                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ControlView(),
                                          ),
                                          (route) => false,
                                        );
                                        var prefs = await SharedPreferences
                                            .getInstance();
                                        var jwt = prefs.getString("token");
                                        Response userresponse =
                                            await HttpHelper.get(
                                                PROFILE_ENDPOINT,
                                                apiToken: jwt);
                                        if (userresponse.statusCode == 200) {
                                          var prefs = await SharedPreferences
                                              .getInstance();
                                          var userType =
                                              prefs.getString("userType") ?? "";
                                          if (userType.isNotEmpty) {
                                            var myDataString = utf8
                                                .decode(userresponse.bodyBytes);
                                            print("myDataString");
                                            print(myDataString);
                                            prefs.setString(
                                                "userProfile", myDataString);
                                            var result =
                                                jsonDecode(myDataString);
                                            var userProfile =
                                                UserModel.fromJson(result);
                                            if (userProfile.merchant != null) {
                                              prefs.setInt("merchant",
                                                  userProfile.merchant!);
                                            }
                                            if (userProfile.truckowner !=
                                                null) {
                                              prefs.setInt("truckowner",
                                                  userProfile.truckowner!);
                                            }
                                            if (userProfile.truckuser != null) {
                                              prefs.setInt("truckuser",
                                                  userProfile.truckuser!);
                                              print("userProfile.truckuser");
                                              print(userProfile.truckuser);
                                              Response driverResponse =
                                                  await HttpHelper.get(
                                                      '$DRIVERS_ENDPOINT${userProfile.truckuser}/',
                                                      apiToken: jwt);
                                              if (driverResponse.statusCode ==
                                                  200) {
                                                var driverDataString =
                                                    utf8.decode(driverResponse
                                                        .bodyBytes);
                                                var res = jsonDecode(
                                                    driverDataString);
                                                prefs.setInt(
                                                    "truckId", res['truck2']);
                                              }
                                            }
                                          }
                                        }
                                      }

                                      if (state is AuthLoginErrorState) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          backgroundColor: Colors.red[300],
                                          dismissDirection: DismissDirection.up,
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  150,
                                              left: 10,
                                              right: 10),
                                          content: localeState.value.languageCode ==
                                                  'en'
                                              ? const Text(
                                                  'there is no active account for this credentials.')
                                              : const Text(
                                                  "لا يوجد حساب فعال وفقا للبيانات المدخلة."),
                                          duration: const Duration(seconds: 3),
                                        ));
                                      }
                                    },
                                    builder: (context, state) {
                                      if (state is AuthLoggingInProgressState) {
                                        return CustomButton(
                                          title: const LoadingIndicator(),
                                          onTap: () {},
                                        );
                                      } else {
                                        return CustomButton(
                                          title: Text(
                                            AppLocalizations.of(context)!
                                                .translate('sign_in'),
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                            ),
                                          ),
                                          onTap: () {
                                            _formKey.currentState?.save();

                                            if (_formKey.currentState!
                                                .validate()) {
                                              _login();
                                            }
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
