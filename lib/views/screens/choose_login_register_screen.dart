import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/user_type.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/phone_login_screen.dart';
import 'package:camion/views/screens/phone_signup_screen.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ignore: must_be_immutable
class ChooseLoginRegisterScreen extends StatefulWidget {
  ChooseLoginRegisterScreen({Key? key}) : super(key: key);

  @override
  State<ChooseLoginRegisterScreen> createState() =>
      _ChooseLoginRegisterScreenState();
}

class _ChooseLoginRegisterScreenState extends State<ChooseLoginRegisterScreen> {
  UserType userType = UserType.none;

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
                image: DecorationImage(
                  image:
                      AssetImage("assets/images/camion_backgroung_image.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.white,
                body: Column(
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
                                      .translate('welcome'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 30.h,
                                ),
                                CustomButton(
                                  title: Text(
                                    AppLocalizations.of(context)!
                                        .translate('log_in'),
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                  onTap: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PhoneSignInScreen(),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  height: 30.h,
                                ),
                                CustomButton(
                                  title: Text(
                                    AppLocalizations.of(context)!
                                        .translate('sign_up'),
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                  onTap: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PhoneSignUpScreen(),
                                      ),
                                    );
                                  },
                                ),
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
        );
      },
    );
  }
}
