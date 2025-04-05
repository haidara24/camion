import 'dart:async';
import 'dart:convert';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/bloc/truck_prices_list_bloc.dart';
import 'package:camion/business_logic/bloc/core/auth_bloc.dart';
import 'package:camion/business_logic/bloc/core/governorates_list_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/driver_active_shipment_bloc.dart';
import 'package:camion/business_logic/bloc/post_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/unassigned_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/profile/driver_profile_bloc.dart';
import 'package:camion/business_logic/bloc/requests/driver_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_type_bloc.dart';
import 'package:camion/business_logic/bloc/truck_active_status_bloc.dart';
import 'package:camion/business_logic/bloc/truck_fixes/fix_type_list_bloc.dart';
import 'package:camion/business_logic/bloc/truck_fixes/truck_fix_list_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/providers/request_num_provider.dart';
import 'package:camion/data/providers/user_provider.dart';
import 'package:camion/data/repositories/gps_repository.dart';
import 'package:camion/data/services/users_services.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:camion/views/screens/contact_us_screen.dart';
import 'package:camion/views/screens/driver/driver_prices_screen.dart';
import 'package:camion/views/screens/driver/driver_profile_screen.dart';
import 'package:camion/views/screens/driver/fixes_list_screen.dart';
import 'package:camion/views/screens/driver/incoming_shipment_screen.dart';
import 'package:camion/views/screens/driver/search_shipment_screen.dart';
import 'package:camion/views/screens/main_screen.dart';
import 'package:camion/views/screens/driver/tracking_shippment_screen.dart';
import 'package:camion/views/widgets/driver_appbar.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  StreamSubscription<Position>? _locationSubscription;

  int currentIndex = 0;
  int navigationValue = 0;
  String title = "Home";
  Widget currentScreen = MainScreen();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late TabController _tabController;
  late SharedPreferences prefs;
  Timer? _timer;

  Future<void> _requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showCustomSnackBar(
        context: context,
        backgroundColor: Colors.orange,
        message: 'خدمة تحديد الموقع غير مفعلة..',
      );
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showCustomSnackBar(
          context: context,
          backgroundColor: Colors.orange,
          message: 'Location permissions are denied',
        );
      }
    }
    if (permission == LocationPermission.deniedForever) {
      showCustomSnackBar(
        context: context,
        backgroundColor: Colors.orange,
        message:
            'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
  }

  Future<void> _listenLocation() async {
    prefs = await SharedPreferences.getInstance();
    int truckId = prefs.getInt("truckId") ?? 0;
    String gpsId = prefs.getString("gpsId") ?? "";

    await _requestPermission();
    print(gpsId.isEmpty || gpsId.length < 8 || gpsId == "NaN");
    if (gpsId.isEmpty || gpsId.length < 8 || gpsId == "NaN") {
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update when moving 10 meters
        ),
      ).listen((Position position) async {
        print(position);
        if (_timer == null || !_timer!.isActive) {
          if (truckId != 0) {
            var jwt = prefs.getString("token");
            var rs = await HttpHelper.patch('$TRUCKS_ENDPOINT$truckId/',
                {'location_lat': '${position.latitude},${position.longitude}'},
                apiToken: jwt);
          }
        }
      });
    } else {
      if (_timer == null || !_timer!.isActive) {
        if (truckId != 0) {
          var data = await GpsRepository.getCarInfo(gpsId);
          String location =
              '${data["carStatus"]["lat"]},${data["carStatus"]["lon"]}';
          var jwt = prefs.getString("token");
          var rs = await HttpHelper.patch(
              '$TRUCKS_ENDPOINT$truckId/', {'location_lat': location},
              apiToken: jwt);
        }
      }
    }
  }

  int truckId = 0;

  void getTruckId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      truckId = prefs.getInt("truckId") ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    GpsRepository.getTokenForGps();
    getTruckId();

    // _getLocation();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      print("timer");
      _listenLocation();
    });
    BlocProvider.of<PostBloc>(context).add(PostLoadEvent());
    BlocProvider.of<FixTypeListBloc>(context).add(FixTypeListLoad());
    BlocProvider.of<TruckTypeBloc>(context).add(TruckTypeLoadEvent());
    BlocProvider.of<GovernoratesListBloc>(context)
        .add(GovernoratesListLoadEvent());
    BlocProvider.of<TruckPricesListBloc>(context)
        .add(TruckPricesListLoadEvent());
    BlocProvider.of<DriverRequestsListBloc>(context)
        .add(const DriverRequestsListLoadEvent(null));
    BlocProvider.of<TruckActiveStatusBloc>(context).add(
      LoadTruckActiveStatusEvent(),
    );
    BlocProvider.of<UnassignedShipmentListBloc>(context)
        .add(UnassignedShipmentListLoadEvent());
    BlocProvider.of<DriverActiveShipmentBloc>(context)
        .add(DriverActiveShipmentLoadEvent("R"));
    _tabController = TabController(
      initialIndex: 0,
      length: 5,
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
    _locationSubscription?.cancel();
    _timer?.cancel();
    _tabController.dispose();
    _locationSubscription?.cancel();
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
          setState(() {
            title = AppLocalizations.of(context)!.translate('home');
            currentScreen = MainScreen();
          });
          break;
        }
      case 1:
        {
          setState(() {
            title = AppLocalizations.of(context)!.translate('incoming_orders');
            currentScreen = IncomingShippmentLogScreen(
              truckId: truckId,
            );
          });
          break;
        }
      case 2:
        {
          setState(() {
            title = AppLocalizations.of(context)!.translate('shipment_search');
            currentScreen = SearchShippmentScreen(
              truckId: truckId,
            );
          });
          break;
        }
      case 3:
        {
          setState(() {
            title = AppLocalizations.of(context)!.translate('my_path');

            currentScreen = TrackingShipmentScreen();
          });
          break;
        }
      case 4:
        {
          setState(() {
            title = AppLocalizations.of(context)!.translate('my_prices');

            currentScreen = DriverPricesScreen(
              truckId: truckId,
            );
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
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor:
                      AppColor.deepBlack, // Make status bar transparent
                  statusBarIconBrightness:
                      Brightness.dark, // Light icons for dark backgrounds
                  systemNavigationBarColor:
                      AppColor.deepBlack, // Works on Android
                  systemNavigationBarIconBrightness: Brightness.dark,
                ),
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
                        InkWell(
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
                                builder: (context) =>
                                    const DriverProfileScreen(),
                              ),
                            );
                          },
                          child: Consumer<UserProvider>(
                              builder: (context, userProvider, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColor.deepYellow,
                                  radius: 35.h,
                                  child: (userProvider.user == null)
                                      ? Center(
                                          child: LoadingIndicator(),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(45),
                                          child: Image.network(
                                            userProvider.user!.image!,
                                            fit: BoxFit.fill,
                                            height: 70.h,
                                            width: 70.h,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Center(
                                              child: Text(
                                                "${userProvider.user!.firstName![0].toUpperCase()} ${userProvider.user!.lastName![0].toUpperCase()}",
                                                style: TextStyle(
                                                  fontSize: 28.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                                (userProvider.user == null)
                                    ? Text(
                                        "",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Text(
                                        "${userProvider.user!.firstName!} ${userProvider.user!.lastName!}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                              ],
                            );
                          }),
                        ),
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
                                case 4:
                                  {
                                    setState(() {
                                      title = AppLocalizations.of(context)!
                                          .translate('my_prices');
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
                                  builder: (context) => FixesListScreen(
                                    truckId: truckId,
                                  ),
                                ));
                            _scaffoldKey.currentState!.closeDrawer();
                          },
                          child: ListTile(
                            leading: SvgPicture.asset(
                              "assets/icons/fixes.svg",
                              height: 25.h,
                              width: 25.h,
                            ),
                            title: Text(
                              AppLocalizations.of(context)!
                                  .translate('my_fixes'),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContactUsScreen(),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: SvgPicture.asset(
                              "assets/icons/orange/help_info.svg",
                              height: 25.h,
                              width: 25.h,
                            ),
                            title: Text(
                              AppLocalizations.of(context)!
                                  .translate('contact_us'),
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
                            showDialog<void>(
                              context: context,
                              barrierDismissible:
                                  false, // user must tap button!
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
                              "assets/icons/orange/log_out.svg",
                              height: 25.h,
                              width: 25.h,
                            ),
                            title: Text(
                              AppLocalizations.of(context)!
                                  .translate('log_out'),
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
                            height: 75.h,
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
                                  height: 62.h,
                                  icon: navigationValue == 0
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/orange/home.svg",
                                              width: 28.w,
                                              height: 28.w,
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
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
                                              width: 28.w,
                                              height: 28.w,
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
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
                                  height: 62.h,
                                  icon: Consumer<RequestNumProvider>(
                                      builder: (context, value, child) {
                                    return BlocListener<DriverRequestsListBloc,
                                        DriverRequestsListState>(
                                      listener: (context, state) {
                                        // TODO: implement listener
                                        if (state
                                            is DriverRequestsListLoadedSuccess) {
                                          var taskNum = 0;

                                          value.setRequestNum(
                                              state.requests.length);
                                        }
                                      },
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          navigationValue == 1
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/icons/orange/my_shipments.svg",
                                                      width: 28.w,
                                                      height: 28.w,
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 1,
                                                        ),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .translate(
                                                                  'incoming_orders'),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: AppColor
                                                                  .deepYellow,
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
                                                      width: 28.w,
                                                      height: 28.w,
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 1,
                                                        ),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .translate(
                                                                  'incoming_orders'),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12.sp),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                          value.requestNum > 0
                                              ? Positioned(
                                                  right: -2.w,
                                                  top: -5.h,
                                                  child: Container(
                                                    height: 22.w,
                                                    width: 22.w,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColor.deepYellow,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              45),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                          value.requestNum
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                          )),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                                Tab(
                                  height: 62.h,
                                  icon: navigationValue == 2
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/orange/search_shipment.svg",
                                              width: 28.w,
                                              height: 28.w,
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
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
                                                      color:
                                                          AppColor.deepYellow,
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
                                              "assets/icons/white/search_shipment.svg",
                                              width: 28.w,
                                              height: 28.w,
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
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
                                  height: 62.h,
                                  icon: navigationValue == 3
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/orange/location.svg",
                                              width: 28.w,
                                              height: 28.w,
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
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
                                              width: 28.w,
                                              height: 28.w,
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
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
                                Tab(
                                  height: 62.h,
                                  icon: navigationValue == 4
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/orange/my_prices.svg",
                                              width: 28.w,
                                              height: 28.w,
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .translate('my_prices'),
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
                                              "assets/icons/white/my_prices.svg",
                                              width: 28.w,
                                              height: 28.w,
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .translate('my_prices'),
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
          ),
        );
      },
    );
  }
}
