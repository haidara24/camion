import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/constants/user_type.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/sign_in_screen.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class SelectUserTypeScreen extends StatefulWidget {
  SelectUserTypeScreen({Key? key}) : super(key: key);

  @override
  State<SelectUserTypeScreen> createState() => _SelectUserTypeScreenState();
}

class _SelectUserTypeScreenState extends State<SelectUserTypeScreen> {
  UserType userType = UserType.none;

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
              image: DecorationImage(
                image: AssetImage("assets/images/camion_backgroung_image.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
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
                                    .translate('select_user_type'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 30.h,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .25,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 35.h,
                                          width: 35.h,
                                          child: SvgPicture.asset(
                                              "assets/icons/crossing.svg"),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .translate('check_point'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Transform.scale(
                                          scale: 1.4,
                                          child: Radio(
                                            value: UserType.checkpoint,
                                            groupValue: userType,
                                            activeColor: AppColor.deepYellow,
                                            fillColor: MaterialStateProperty
                                                .resolveWith<Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                              if (states.contains(
                                                  MaterialState.disabled)) {
                                                return Colors.white
                                                    .withOpacity(.32);
                                              }
                                              return Colors.white;
                                            }),
                                            onChanged: (value) {
                                              setState(() {
                                                userType = UserType.checkpoint;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .25,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 35.h,
                                          width: 35.h,
                                          child: SvgPicture.asset(
                                              "assets/icons/Administration.svg"),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .translate('managment'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Transform.scale(
                                          scale: 1.4,
                                          child: Radio(
                                            value: UserType.managment,
                                            groupValue: userType,
                                            activeColor: AppColor.deepYellow,
                                            fillColor: MaterialStateProperty
                                                .resolveWith<Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                              if (states.contains(
                                                  MaterialState.disabled)) {
                                                return Colors.white
                                                    .withOpacity(.32);
                                              }
                                              return Colors.white;
                                            }),
                                            onChanged: (value) {
                                              setState(() {
                                                userType = UserType.managment;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .25,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 35.h,
                                          width: 35.h,
                                          child: SvgPicture.asset(
                                              "assets/icons/merchant.svg"),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .translate('merchent'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Transform.scale(
                                          scale: 1.4,
                                          child: Radio(
                                            value: UserType.merchent,
                                            groupValue: userType,
                                            activeColor: AppColor.deepYellow,
                                            fillColor: MaterialStateProperty
                                                .resolveWith<Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                              if (states.contains(
                                                  MaterialState.disabled)) {
                                                return Colors.white
                                                    .withOpacity(.32);
                                              }
                                              return Colors.white;
                                            }),
                                            onChanged: (value) {
                                              setState(() {
                                                userType = UserType.merchent;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30.h,
                              ),
                              CustomButton(
                                title: Text(
                                  AppLocalizations.of(context)!.translate('ok'),
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                  ),
                                ),
                                isEnabled: userType != UserType.none,
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignInScreen(),
                                      ));
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();

                                  String usertype = "none";
                                  switch (userType) {
                                    case UserType.checkpoint:
                                      usertype = "CheckPoint";
                                      break;
                                    case UserType.managment:
                                      usertype = "Managment";
                                      break;
                                    case UserType.merchent:
                                      usertype = "Merchent";
                                      break;
                                    default:
                                  }
                                  print(usertype);
                                  prefs.setString("userType", usertype);
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
        );
      },
    );
  }
}
