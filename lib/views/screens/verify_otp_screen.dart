// ignore_for_file: use_build_context_synchronously

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/core/auth_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_type_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/services/users_services.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/driver/create_truck_for%20driver.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyOtpScreen extends StatefulWidget {
  final bool isLogin;
  final String phone;
  VerifyOtpScreen({Key? key, required this.isLogin, required this.phone})
      : super(key: key);

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final focusNode = FocusNode();

  Future<void> _verify(String pin) async {
    BlocProvider.of<AuthBloc>(context).add(
      VerifyButtonPressed(pin),
    );
  }

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  late PinTheme focusedPinTheme;

  late PinTheme submittedPinTheme;

  @override
  void initState() {
    super.initState();

    focusedPinTheme = defaultPinTheme.copyDecorationWith(
      color: Colors.white,
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image:
                      AssetImage("assets/images/camion_backgroung_image.png"),
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
                        height: 100.h,
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
                                        .translate('please_verify'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 19.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: BlocConsumer<AuthBloc, AuthState>(
                                      listener: (context, state) async {
                                        if (state is AuthDriverSuccessState ||
                                            state is AuthOwnerSuccessState ||
                                            state is AuthMerchantSuccessState) {
                                          showCustomSnackBar(
                                            context: context,
                                            backgroundColor: AppColor.deepGreen,
                                            message: localeState
                                                        .value.languageCode ==
                                                    'en'
                                                ? 'sign in successfully, welcome.'
                                                : 'تم تسجيل الدخول بنجاح! أهلا بك.',
                                          );

                                          if (widget.isLogin) {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ControlView(),
                                              ),
                                              (route) => false,
                                            );
                                          } else {
                                            if (state
                                                is AuthDriverSuccessState) {
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              var driverId =
                                                  prefs.getInt("truckuser");
                                              BlocProvider.of<TruckTypeBloc>(
                                                      context)
                                                  .add(TruckTypeLoadEvent());

                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CreateTruckForDriverScreen(
                                                          driverId: driverId!),
                                                ),
                                                (route) => false,
                                              );
                                            } else {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ControlView(),
                                                ),
                                                (route) => false,
                                              );
                                            }
                                          }
                                        }

                                        if (state is AuthLoginErrorState) {
                                          showCustomSnackBar(
                                            context: context,
                                            backgroundColor: Colors.red[300]!,
                                            message: state.error!,
                                          );
                                        }

                                        if (state is AuthFailureState) {
                                          showCustomSnackBar(
                                            context: context,
                                            backgroundColor: Colors.red[300]!,
                                            message: state.errorMessage,
                                          );
                                        }
                                      },
                                      builder: (context, state) {
                                        if (state
                                            is AuthLoggingInProgressState) {
                                          return LoadingIndicator(
                                            color: Colors.white,
                                          );
                                        } else {
                                          return Pinput(
                                            defaultPinTheme: defaultPinTheme,
                                            focusedPinTheme: focusedPinTheme,
                                            submittedPinTheme:
                                                submittedPinTheme,
                                            onCompleted: (pin) => _verify(pin),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        UserService.resendOtp(widget.phone);
                                      },
                                      child: Text("resend otp"))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
