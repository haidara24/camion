import 'dart:async';
import 'dart:convert';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/core/auth_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/unassigned_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/owner_shipments/owner_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/post_bloc.dart';
import 'package:camion/business_logic/bloc/truck/owner_trucks_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/services/fcm_service.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/main_screen.dart';
import 'package:camion/views/screens/owner/all_incoming_shipment_screen.dart';
import 'package:camion/views/screens/owner/owner_search_shipment_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';

class OwnerHomeScreen extends StatefulWidget {
  OwnerHomeScreen({Key? key}) : super(key: key);

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  late SharedPreferences prefs;

  int currentIndex = 0;
  int navigationValue = 0;
  String title = "Home";
  Widget currentScreen = MainScreen();
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
    print("_usermodel.truckowner!");
    print(_usermodel.truckowner!);
    BlocProvider.of<OwnerTrucksBloc>(context).add(OwnerTrucksLoadEvent());
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
      length: 4,
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
    // Remove the WidgetsBindingObserver when the state is disposed
    // scroll.dispose();
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
          BlocProvider.of<PostBloc>(context).add(PostLoadEvent());
          print("sdfsdf");
          setState(() {
            title = AppLocalizations.of(context)!.translate('home');
            currentScreen = MainScreen();
          });
          break;
        }
      case 1:
        {
          BlocProvider.of<OwnerShipmentListBloc>(context)
              .add(OwnerShipmentListLoadEvent("P"));
          setState(() {
            title = AppLocalizations.of(context)!.translate('incoming_orders');
            currentScreen = AllIncomingShippmentLogScreen();
          });
          break;
        }
      case 2:
        {
          BlocProvider.of<UnassignedShipmentListBloc>(context)
              .add(UnassignedShipmentListLoadEvent());
          setState(() {
            title = AppLocalizations.of(context)!.translate('shipment_search');
            currentScreen = OwnerSearchShippmentScreen();
          });
          break;
        }
      // case 3:
      //   {
      //     BlocProvider.of<OwnerActiveShipmentsBloc>(context)
      //         .add(OwnerActiveShipmentsLoadEvent());
      //     setState(() {
      //       title = AppLocalizations.of(context)!.translate('tracking');

      //       currentScreen = OwnerActiveShipmentScreen();
      //     });
      //     break;
      //   }
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
                                      Text(AppLocalizations.of(context)!
                                          .translate('log_out_confirm')),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(AppLocalizations.of(context)!
                                        .translate('no')),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text(AppLocalizations.of(context)!
                                        .translate('yes')),
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
                              // text: "طلب مخلص",
                              height: 66.h,
                              icon: navigationValue == 0
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/home_selected.svg",
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
                                              .translate('home'),
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
                                          "assets/icons/home.svg",
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
                                              .translate('home'),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp),
                                        )
                                      ],
                                    ),
                            ),
                            Tab(
                              // text: "الحاسبة",
                              height: 66.h,
                              icon: navigationValue == 1
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
                              height: 66.h,
                              icon: navigationValue == 2
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/truck_order_selected.svg",
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
                                                  .translate('shipment_search'),
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
                                          "assets/icons/truck_order.svg",
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
                                                  .translate('shipment_search'),
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
                              // text: "التعرفة",
                              height: 66.h,
                              icon: navigationValue == 3
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/location_selected.svg",
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
                                              .translate('tracking'),
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
                                          "assets/icons/location.svg",
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
                                              .translate('tracking'),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp),
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
