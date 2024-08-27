import 'dart:async';
import 'dart:convert';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/core/auth_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/driver_active_shipment_bloc.dart';
import 'package:camion/business_logic/bloc/post_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/unassigned_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/profile/driver_profile_bloc.dart';
import 'package:camion/business_logic/bloc/requests/driver_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/truck_active_status_bloc.dart';
import 'package:camion/business_logic/bloc/truck_fixes/fix_type_list_bloc.dart';
import 'package:camion/business_logic/bloc/truck_fixes/truck_fix_list_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/providers/user_provider.dart';
import 'package:camion/data/repositories/gps_repository.dart';
import 'package:camion/data/services/fcm_service.dart';
import 'package:camion/data/services/users_services.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:camion/views/screens/driver/driver_profile_screen.dart';
import 'package:camion/views/screens/driver/fixes_list_screen.dart';
import 'package:camion/views/screens/driver/incoming_shipment_screen.dart';
import 'package:camion/views/screens/driver/search_shipment_screen.dart';
import 'package:camion/views/screens/main_screen.dart';
import 'package:camion/views/screens/driver/tracking_shippment_screen.dart';
import 'package:camion/views/widgets/driver_appbar.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverHomeScreen extends StatefulWidget {
  DriverHomeScreen({Key? key}) : super(key: key);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  int currentIndex = 0;
  int navigationValue = 0;
  String title = "Home";
  Widget currentScreen = MainScreen();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  NotificationServices notificationServices = NotificationServices();
  late TabController _tabController;
  late SharedPreferences prefs;
  Timer? _timer;

  _getLocation() async {
    prefs = await SharedPreferences.getInstance();
    var userprofile =
        UserModel.fromJson(jsonDecode(prefs.getString("userProfile")!));
    var driverId = prefs.getInt("truckuser");

    try {
      final loc.LocationData _locationResult = await location.getLocation();
      // await FirebaseFirestore.instance
      //     .collection('location')
      //     .doc('driver${userprofile.id}')
      //     .set({
      //   'latitude': _locationResult.latitude,
      //   'longitude': _locationResult.longitude,
      //   'name': '${userprofile.firstName!} ${userprofile.lastName!}'
      // }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _listenLocation() async {
    prefs = await SharedPreferences.getInstance();
    int truckId = prefs.getInt("truckId") ?? 0;
    String gpsId = prefs.getString("gpsId") ?? "";
    _locationSubscription?.cancel();
    _timer?.cancel();

    if (gpsId.isEmpty || gpsId.length < 8) {
      _locationSubscription = location.onLocationChanged.handleError((onError) {
        _locationSubscription?.cancel();
        setState(() {
          _locationSubscription = null;
        });
      }).listen((loc.LocationData currentlocation) async {
        if (_timer == null || !_timer!.isActive) {
          if (truckId != 0) {
            var jwt = prefs.getString("token");
            var rs = await HttpHelper.patch(
                '$TRUCKS_ENDPOINT$truckId/',
                {
                  'location_lat':
                      '${currentlocation.latitude},${currentlocation.longitude}'
                },
                apiToken: jwt);
            _timer = Timer(const Duration(minutes: 1), () {});
          }
        }
      });
    }
  }

  _stopListening() {
    _locationSubscription?.cancel();
    // setState(() {
    //   _locationSubscription = null;
    // });
  }

  @override
  void initState() {
    super.initState();
    GpsRepository.getTokenForGps();

    // _getLocation();
    _listenLocation();
    BlocProvider.of<PostBloc>(context).add(PostLoadEvent());
    BlocProvider.of<FixTypeListBloc>(context).add(FixTypeListLoad());

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
    super.dispose();
    _tabController.dispose();
    _stopListening();
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
          setState(() {
            title = AppLocalizations.of(context)!.translate('home');
            currentScreen = MainScreen();
          });
          break;
        }
      case 1:
        {
          BlocProvider.of<DriverRequestsListBloc>(context)
              .add(const DriverRequestsListLoadEvent(null));
          setState(() {
            title = AppLocalizations.of(context)!.translate('incoming_orders');
            currentScreen = IncomingShippmentLogScreen();
          });
          break;
        }
      case 2:
        {
          BlocProvider.of<UnassignedShipmentListBloc>(context)
              .add(UnassignedShipmentListLoadEvent());
          setState(() {
            title = AppLocalizations.of(context)!.translate('shipment_search');
            currentScreen = SearchShippmentScreen();
          });
          break;
        }
      case 3:
        {
          BlocProvider.of<DriverActiveShipmentBloc>(context)
              .add(DriverActiveShipmentLoadEvent("A"));
          setState(() {
            title = AppLocalizations.of(context)!.translate('my_path');

            currentScreen = TrackingShipmentScreen();
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
                // backgroundColor: AppColor.deepBlack,
                appBar: DriverAppBar(
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
                      Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                        return InkWell(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            var driver = prefs.getInt("truckuser");

                            // ignore: use_build_context_synchronously
                            BlocProvider.of<DriverProfileBloc>(context)
                                .add(DriverProfileLoad(driver!));

                            // ignore: use_build_context_synchronously
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DriverProfileScreen(
                                      user: userProvider.driver!.user!),
                                ));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColor.deepYellow,
                                radius: 35.h,
                                child: (userProvider.driver == null)
                                    ? Center(
                                        child: LoadingIndicator(),
                                      )
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(180),
                                        child: Image.network(
                                          userProvider.driver!.user!.image!,
                                          fit: BoxFit.fill,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Center(
                                            child: Text(
                                              "${userProvider.driver!.user!.firstName![0].toUpperCase()} ${userProvider.driver!.user!.lastName![0].toUpperCase()}",
                                              style: TextStyle(
                                                fontSize: 28.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              (userProvider.driver == null)
                                  ? Text(
                                      "",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Text(
                                      "${userProvider.driver!.user!.firstName!} ${userProvider.driver!.user!.lastName!}",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.bold),
                                    )
                            ],
                          ),
                        );
                      }),
                      SizedBox(
                        height: 15.h,
                      ),
                      const Divider(
                        color: Colors.white,
                      ),
                      InkWell(
                        onTap: () async {
                          if (AppLocalizations.of(context)!.isEnLocale) {
                            BlocProvider.of<LocaleCubit>(context).toArabic();
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString("language", "ar");
                            UserService.updateLang("ar");
                          } else {
                            BlocProvider.of<LocaleCubit>(context).toEnglish();
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString("language", "en");
                            UserService.updateLang("en");
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
                            "assets/icons/orange/translate_camion.svg",
                            height: 25.h,
                            width: 25.h,
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
                        ),
                      ),
                      const Divider(
                        color: Colors.white,
                      ),
                      InkWell(
                        onTap: () {
                          BlocProvider.of<TruckFixListBloc>(context)
                              .add(TruckFixListLoad(null));
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FixesListScreen(),
                              ));
                          _scaffoldKey.currentState!.closeDrawer();
                        },
                        child: ListTile(
                          leading: SvgPicture.asset(
                            "assets/icons/help_info.svg",
                            height: 25.h,
                            width: 25.h,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.translate('my_fixes'),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const Divider(
                        color: Colors.white,
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          "assets/icons/help_info.svg",
                          height: 25.h,
                          width: 25.h,
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.translate('help'),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        trailing: Container(
                          width: 36.w,
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
                            height: 25.h,
                            width: 25.h,
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
                bottomNavigationBar: Directionality(
                  textDirection: TextDirection.ltr,
                  child: BlocBuilder<BottomNavBarCubit, BottomNavBarState>(
                    builder: (context, state) {
                      if (state is BottomNavBarShown) {
                        return Container(
                          height: 64.h,
                          color: AppColor.deepBlack,
                          child: TabBar(
                            labelPadding: EdgeInsets.zero,
                            controller: _tabController,
                            indicatorColor: AppColor.deepYellow,
                            labelColor: AppColor.deepYellow,
                            unselectedLabelColor: Colors.white,
                            labelStyle: TextStyle(fontSize: 12.sp),
                            unselectedLabelStyle: TextStyle(fontSize: 14.sp),
                            dividerColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            onTap: (value) {
                              changeSelectedValue(
                                  selectedValue: value, contxt: context);
                            },
                            tabs: [
                              Tab(
                                height: 64.h,
                                icon: navigationValue == 0
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icons/orange/home.svg",
                                            width: 34.w,
                                            height: 34.w,
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
                                                fontSize: 12.sp),
                                          )
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icons/white/home.svg",
                                            width: 30.w,
                                            height: 30.w,
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
                                                fontSize: 12.sp),
                                          )
                                        ],
                                      ),
                              ),
                              Tab(
                                height: 64.h,
                                icon: navigationValue == 1
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icons/orange/my_shipments.svg",
                                            width: 34.w,
                                            height: 34.w,
                                          ),
                                          localeState.value.languageCode == 'en'
                                              ? const SizedBox(
                                                  height: 4,
                                                )
                                              : const SizedBox.shrink(),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 1,
                                              ),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .translate(
                                                        'incoming_orders'),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: AppColor.deepYellow,
                                                    fontSize: 12.sp),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icons/white/my_shipments.svg",
                                            width: 30.w,
                                            height: 30.w,
                                          ),
                                          localeState.value.languageCode == 'en'
                                              ? const SizedBox(
                                                  height: 4,
                                                )
                                              : const SizedBox.shrink(),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 1,
                                              ),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .translate(
                                                        'incoming_orders'),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.sp),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                              ),
                              Tab(
                                height: 64.h,
                                icon: navigationValue == 2
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icons/orange/search_for_truck.svg",
                                            width: 34.w,
                                            height: 34.w,
                                          ),
                                          localeState.value.languageCode == 'en'
                                              ? const SizedBox(
                                                  height: 4,
                                                )
                                              : const SizedBox.shrink(),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 1),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .translate(
                                                        'shipment_search'),
                                                style: TextStyle(
                                                    color: AppColor.deepYellow,
                                                    fontSize: 12.sp),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icons/white/search_for_truck.svg",
                                            width: 30.w,
                                            height: 30.w,
                                          ),
                                          localeState.value.languageCode == 'en'
                                              ? const SizedBox(
                                                  height: 4,
                                                )
                                              : const SizedBox.shrink(),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 1),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .translate(
                                                        'shipment_search'),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.sp),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                              ),
                              Tab(
                                height: 64.h,
                                icon: navigationValue == 3
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icons/orange/location.svg",
                                            width: 34.w,
                                            height: 34.w,
                                          ),
                                          localeState.value.languageCode == 'en'
                                              ? const SizedBox(
                                                  height: 4,
                                                )
                                              : const SizedBox.shrink(),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .translate('my_path'),
                                            style: TextStyle(
                                                color: AppColor.deepYellow,
                                                fontSize: 12.sp),
                                          )
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icons/white/location.svg",
                                            width: 30.w,
                                            height: 30.w,
                                          ),
                                          localeState.value.languageCode == 'en'
                                              ? const SizedBox(
                                                  height: 4,
                                                )
                                              : const SizedBox.shrink(),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .translate('my_path'),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.sp),
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
