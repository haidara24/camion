import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/core/auth_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/screens/verify_otp_screen.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PhoneSignInScreen extends StatefulWidget {
  const PhoneSignInScreen({Key? key}) : super(key: key);

  @override
  State<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  final focusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();

// Phone number regular expression (e.g., starts with 09 and has 8 digits after)
  final RegExp phoneRegExp = RegExp(r'^09\d{8}$');

  bool isPhoneValid = false;

  Future<void> _login() async {
    _postData(context);
  }

  void _postData(context) {
    BlocProvider.of<AuthBloc>(context).add(
      PhoneSignInButtonPressed(
        _phoneController.text,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {
        // Check if the entered text matches the phone number pattern
        isPhoneValid = phoneRegExp.hasMatch(_phoneController.text);
      });
    });
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
                                          .translate('please_sign_phone'),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .translate('phone'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 19.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4.h,
                                    ),
                                    SizedBox(
                                      width: 350.w,
                                      child: TextFormField(
                                        keyboardType: TextInputType.phone,
                                        // initialValue: widget.initialValue,
                                        controller: _phoneController,
                                        onTap: () {
                                          _phoneController.selection =
                                              TextSelection.collapsed(
                                                  offset: _phoneController
                                                      .text.length);
                                        },
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return AppLocalizations.of(context)!
                                                .translate("phone_required");
                                          } else if (!phoneRegExp
                                              .hasMatch(value)) {
                                            return AppLocalizations.of(context)!
                                                .translate("phone_valid");
                                          }
                                          return null;
                                        },
                                        onSaved: (newValue) {
                                          _phoneController.text = newValue!;
                                        },
                                        // autovalidateMode:
                                        //     AutovalidateMode.onUserInteraction,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 19.sp,
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20.w, vertical: 2.h),
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .translate('enter_phone'),
                                          hintStyle: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 19.sp,
                                          ),
                                          suffixIcon: isPhoneValid
                                              ? Icon(
                                                  Icons.check_circle_outline,
                                                  color: AppColor.deepGreen,
                                                )
                                              : null,
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
                                        print(state);
                                        if (state is AuthFailureState) {
                                          showCustomSnackBar(
                                            context: context,
                                            backgroundColor: Colors.red[300]!,
                                            message: state.errorMessage,
                                          );
                                        } else if (state
                                            is AuthLoggingInProgressState) {
                                        } else {
                                          showCustomSnackBar(
                                            context: context,
                                            backgroundColor: AppColor.deepGreen,
                                            message: localeState
                                                        .value.languageCode ==
                                                    'en'
                                                ? 'sign in successfully!'
                                                : 'تم تسجيل الدخول بنجاح!.',
                                          );

                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ControlView(),
                                            ),
                                            (route) => false,
                                          );
                                        }
                                      },
                                      builder: (context, state) {
                                        if (state
                                            is AuthLoggingInProgressState) {
                                          return CustomButton(
                                            title: LoadingIndicator(),
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
                                    // TermsOfUse(),
                                  ],
                                ),
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
