import 'dart:async';
import 'dart:convert';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/core/auth_bloc.dart';
import 'package:camion/business_logic/bloc/managment/complete_managment_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/managment_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/passcharges_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/permissions_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/price_request_bloc.dart';
import 'package:camion/business_logic/bloc/post_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/services/fcm_service.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/check_point/check_point_log_screen.dart';
import 'package:camion/views/screens/main_screen.dart';
import 'package:camion/views/screens/managment/charges_log_screen.dart';
import 'package:camion/views/screens/managment/log_screen.dart';
import 'package:camion/views/screens/managment/permissions_screen.dart';
import 'package:camion/views/screens/managment/price_request_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';

class CheckPointHomeScreen extends StatefulWidget {
  CheckPointHomeScreen({Key? key}) : super(key: key);

  @override
  State<CheckPointHomeScreen> createState() => _CheckPointHomeScreenState();
}

class _CheckPointHomeScreenState extends State<CheckPointHomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final loc.Location location = loc.Location();
  late SharedPreferences prefs;

  int currentIndex = 0;
  int navigationValue = 0;
  String title = "Home";
  Widget currentScreen = CheckPointLogScreen();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  NotificationServices notificationServices = NotificationServices();
  late TabController _tabController;

  bool userloading = true;
  late UserModel _usermodel;
  getUserData() async {
    prefs = await SharedPreferences.getInstance();
    _usermodel =
        UserModel.fromJson(jsonDecode(prefs.getString("userProfile")!));
    setState(() {
      userloading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    getUserData();

    BlocProvider.of<PostBloc>(context).add(PostLoadEvent());

    notificationServices.requestNotificationPermission();
    // notificationServices.forgroundMessage(context);
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();

    _tabController = TabController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        title = AppLocalizations.of(context)!.translate('home');
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void changeSelectedValue(
      {required int selectedValue, required BuildContext contxt}) async {
    setState(() {
      navigationValue = selectedValue;
    });
    _tabController.animateTo(selectedValue);

    switch (selectedValue) {
      case 0:
        {
          BlocProvider.of<CompleteManagmentShipmentListBloc>(context)
              .add(CompleteManagmentShipmentListLoadEvent("C"));
          setState(() {
            title = AppLocalizations.of(context)!.translate('shippment_log');
            currentScreen = CheckPointLogScreen();
          });
          break;
        }
      case 1:
        {
          BlocProvider.of<PasschargesListBloc>(context)
              .add(PasschargesListLoadEvent());
          setState(() {
            title = AppLocalizations.of(context)!.translate('charges');
            currentScreen = ChargesLogScreen();
          });
          break;
        }
      case 2:
        {
          BlocProvider.of<PermissionsListBloc>(context)
              .add(PermissionsListLoadEvent());
          setState(() {
            title = AppLocalizations.of(context)!.translate('permissions');
            currentScreen = PermissionLogScreen();
          });
          break;
        }
    }
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
            child: InkWell(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                BlocProvider.of<BottomNavBarCubit>(context).emitShow();
              },
              child: Scaffold(
                key: _scaffoldKey,
                resizeToAvoidBottomInset: false,
                appBar: CustomAppBar(
                  title: title,
                  scaffoldKey: _scaffoldKey,
                ),
                drawer: Drawer(
                  backgroundColor: AppColor.deepBlack,
                  elevation: 1,
                  width: MediaQuery.of(context).size.width * .85,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: ListView(children: [
                      SizedBox(
                        height: 35.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColor.deepYellow,
                            radius: 35.h,
                            child: userloading
                                ? const Center(
                                    child: LoadingIndicator(),
                                  )
                                : (_usermodel.image!.isNotEmpty ||
                                        _usermodel.image! != null)
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(180),
                                        child: Image.network(
                                          _usermodel.image!,
                                          fit: BoxFit.fill,
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          "${_usermodel.firstName![0].toUpperCase()} ${_usermodel.lastName![0].toUpperCase()}",
                                          style: TextStyle(
                                            fontSize: 28.sp,
                                          ),
                                        ),
                                      ),
                          ),
                          userloading
                              ? Text(
                                  "",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  "${_usermodel.firstName!} ${_usermodel.lastName!}",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.bold),
                                )
                        ],
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      const Divider(
                        color: Colors.white,
                      ),
                      InkWell(
                        onTap: () async {
                          if (AppLocalizations.of(context)!.isEnLocale!) {
                            BlocProvider.of<LocaleCubit>(context).toArabic();
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString("language", "ar");
                          } else {
                            BlocProvider.of<LocaleCubit>(context).toEnglish();
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString("language", "en");
                          }
                          Future.delayed(const Duration(milliseconds: 500))
                              .then((value) {
                            _scaffoldKey.currentState!.closeDrawer();
                            switch (navigationValue) {
                              case 0:
                                {
                                  setState(() {
                                    title = AppLocalizations.of(context)!
                                        .translate('home');
                                  });
                                  break;
                                }
                              case 1:
                                {
                                  setState(() {
                                    title = AppLocalizations.of(context)!
                                        .translate('incoming_orders');
                                  });
                                  break;
                                }
                              case 2:
                                {
                                  setState(() {
                                    title = AppLocalizations.of(context)!
                                        .translate('shipment_search');
                                  });
                                  break;
                                }
                              case 3:
                                {
                                  setState(() {
                                    title = AppLocalizations.of(context)!
                                        .translate('my_path');
                                  });
                                  break;
                                }
                            }
                          });
                        },
                        child: ListTile(
                          leading: SvgPicture.asset(
                            "assets/icons/settings.svg",
                            height: 20.h,
                          ),
                          title: Text(
                            localeState.value.languageCode != 'en'
                                ? "English"
                                : "العربية",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold),
                          ),
                          // trailing: Container(
                          //   width: 35.w,
                          //   height: 20.h,
                          //   decoration: BoxDecoration(
                          //       color: AppColor.deepYellow,
                          //       borderRadius: BorderRadius.circular(2)),
                          //   child: Center(
                          //     child: Text(
                          //       "soon",
                          //       style: TextStyle(
                          //         color: Colors.white,
                          //         fontSize: 12.sp,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ),
                      ),
                      const Divider(
                        color: Colors.white,
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          "assets/icons/help_info.svg",
                          height: 20.h,
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.translate('help'),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        trailing: Container(
                          width: 35.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                              color: AppColor.deepYellow,
                              borderRadius: BorderRadius.circular(2)),
                          child: Center(
                            child: Text(
                              "soon",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Divider(
                        color: Colors.white,
                      ),
                      InkWell(
                        onTap: () {
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text(AppLocalizations.of(context)!
                                    .translate('log_out')),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(
                                        AppLocalizations.of(context)!
                                            .translate('log_out_confirm'),
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('no'),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('yes'),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    onPressed: () {
                                      BlocProvider.of<AuthBloc>(context)
                                          .add(UserLoggedOut());
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: ListTile(
                          leading: SvgPicture.asset(
                            "assets/icons/log_out.svg",
                            height: 20.h,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.translate('log_out'),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                bottomNavigationBar:
                    BlocBuilder<BottomNavBarCubit, BottomNavBarState>(
                  builder: (context, state) {
                    if (state is BottomNavBarShown) {
                      return Container(
                        height: 88.h,
                        color: AppColor.deepBlack,
                        child: TabBar(
                          labelPadding: EdgeInsets.zero,
                          controller: _tabController,
                          indicatorColor: AppColor.deepYellow,
                          labelColor: AppColor.deepYellow,
                          unselectedLabelColor: Colors.white,
                          labelStyle: TextStyle(fontSize: 15.sp),
                          unselectedLabelStyle: TextStyle(fontSize: 14.sp),
                          padding: EdgeInsets.zero,
                          onTap: (value) {
                            changeSelectedValue(
                                selectedValue: value, contxt: context);
                          },
                          tabs: [
                            Tab(
                              // text: "الحاسبة",
                              height: 66.h,
                              icon: navigationValue == 0
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/listalt_selected.svg",
                                          width: 36.w,
                                          height: 36.h,
                                        ),
                                        localeState.value.languageCode == 'en'
                                            ? const SizedBox(
                                                height: 4,
                                              )
                                            : const SizedBox.shrink(),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 1,
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate('incoming_orders'),
                                              style: TextStyle(
                                                  color: AppColor.deepYellow,
                                                  fontSize: 15.sp),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/listalt.svg",
                                          width: 30.w,
                                          height: 30.h,
                                        ),
                                        localeState.value.languageCode == 'en'
                                            ? const SizedBox(
                                                height: 4,
                                              )
                                            : const SizedBox.shrink(),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 1,
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate('incoming_orders'),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.sp),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                            ),
                            Tab(
                              // text: "طلب مخلص",
                              height: 66.h,
                              icon: navigationValue == 1
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/violation_orange.svg",
                                          width: 36.w,
                                          height: 36.h,
                                        ),
                                        localeState.value.languageCode == 'en'
                                            ? const SizedBox(
                                                height: 4,
                                              )
                                            : const SizedBox.shrink(),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .translate('charges'),
                                          style: TextStyle(
                                              color: AppColor.deepYellow,
                                              fontSize: 15.sp),
                                        )
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/violation_white.svg",
                                          width: 30.w,
                                          height: 30.h,
                                        ),
                                        localeState.value.languageCode == 'en'
                                            ? const SizedBox(
                                                height: 4,
                                              )
                                            : const SizedBox.shrink(),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .translate('charges'),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp),
                                        )
                                      ],
                                    ),
                            ),
                            Tab(
                              height: 66.h,
                              icon: navigationValue == 2
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/crossing.svg",
                                          width: 36.w,
                                          height: 36.h,
                                        ),
                                        localeState.value.languageCode == 'en'
                                            ? const SizedBox(
                                                height: 4,
                                              )
                                            : const SizedBox.shrink(),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 1,
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate('permissions'),
                                              style: TextStyle(
                                                  color: AppColor.deepYellow,
                                                  fontSize: 15.sp),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/crossing.svg",
                                          width: 30.w,
                                          height: 30.h,
                                        ),
                                        localeState.value.languageCode == 'en'
                                            ? const SizedBox(
                                                height: 4,
                                              )
                                            : const SizedBox.shrink(),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 1,
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate('permissions'),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.sp),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                body: currentScreen,
              ),
            ),
          ),
        );
      },
    );
  }
}
