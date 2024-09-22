import 'dart:async';
import 'dart:convert';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/core/auth_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/unassigned_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/owner_shipments/owner_active_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/owner_shipments/owner_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/post_bloc.dart';
import 'package:camion/business_logic/bloc/profile/owner_profile_bloc.dart';
import 'package:camion/business_logic/bloc/requests/owner_incoming_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/truck/owner_trucks_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_type_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/providers/user_provider.dart';
import 'package:camion/data/services/fcm_service.dart';
import 'package:camion/data/services/users_services.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/main_screen.dart';
import 'package:camion/views/screens/owner/all_incoming_shipment_screen.dart';
import 'package:camion/views/screens/owner/owner_active_shipment_screen.dart';
import 'package:camion/views/screens/owner/owner_profile_screen.dart';
import 'package:camion/views/screens/owner/owner_search_shipment_screen.dart';
import 'package:camion/views/screens/owner/owner_truck_list_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
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
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    BlocProvider.of<OwnerTrucksBloc>(context).add(OwnerTrucksLoadEvent());

    BlocProvider.of<PostBloc>(context).add(PostLoadEvent());
    BlocProvider.of<OwnerIncomingShipmentsBloc>(context)
        .add(OwnerIncomingShipmentsLoadEvent());
    BlocProvider.of<UnassignedShipmentListBloc>(context)
        .add(UnassignedShipmentListLoadEvent());
    BlocProvider.of<OwnerActiveShipmentsBloc>(context)
        .add(OwnerActiveShipmentsLoadEvent());
    BlocProvider.of<TruckTypeBloc>(context).add(TruckTypeLoadEvent());

    notificationServices.requestNotificationPermission();
    // notificationServices.forgroundMessage(context);
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();

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
      case 3:
        {
          BlocProvider.of<OwnerActiveShipmentsBloc>(context)
              .add(OwnerActiveShipmentsLoadEvent());
          setState(() {
            title = AppLocalizations.of(context)!.translate('tracking');

            currentScreen = OwnerActiveShipmentScreen();
          });
          break;
        }
      case 4:
        {
          BlocProvider.of<OwnerTrucksBloc>(context).add(OwnerTrucksLoadEvent());
          setState(() {
            title = AppLocalizations.of(context)!.translate('my_trucks');

            currentScreen = OwnerTruckListScreen();
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
                      Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                        return InkWell(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            var owner = prefs.getInt("truckowner");
                            // ignore: use_build_context_synchronously
                            BlocProvider.of<OwnerProfileBloc>(context)
                                .add(OwnerProfileLoad(owner!));

                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OwnerProfileScreen(user: _usermodel),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CircleAvatar(
                                  backgroundColor: AppColor.deepYellow,
                                  radius: 35.h,
                                  child: (userProvider.owner == null)
                                      ? Center(
                                          child: LoadingIndicator(),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(180),
                                          child: Image.network(
                                            userProvider.owner!.image!,
                                            fit: BoxFit.fill,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Center(
                                              child: Text(
                                                "${userProvider.owner!.firstname![0].toUpperCase()} ${userProvider.owner!.lastname![0].toUpperCase()}",
                                                style: TextStyle(
                                                  fontSize: 28.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                              (userProvider.owner == null)
                                  ? Text(
                                      "",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Text(
                                      "${userProvider.owner!.firstname!} ${userProvider.owner!.lastname!}",
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
                              case 4:
                                {
                                  setState(() {
                                    title = AppLocalizations.of(context)!
                                        .translate('my_trucks');
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
                      ListTile(
                        leading: SvgPicture.asset(
                          "assets/icons/orange/help_info.svg",
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
                                      Text(
                                          AppLocalizations.of(context)!
                                              .translate('log_out_confirm'),
                                          style: TextStyle(fontSize: 18)),
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
                        height: 62.h,
                        color: AppColor.deepBlack,
                        child: TabBar(
                          labelPadding: EdgeInsets.zero,
                          controller: _tabController,
                          indicatorColor: AppColor.deepYellow,
                          labelColor: AppColor.deepYellow,
                          dividerColor: Colors.transparent,
                          unselectedLabelColor: Colors.white,
                          labelStyle: TextStyle(fontSize: 12.sp),
                          unselectedLabelStyle: TextStyle(fontSize: 14.sp),
                          padding: EdgeInsets.zero,
                          onTap: (value) {
                            changeSelectedValue(
                                selectedValue: value, contxt: context);
                          },
                          tabs: [
                            Tab(
                              // text: "طلب مخلص",
                              height: 62.h,
                              icon: navigationValue == 0
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/orange/home.svg",
                                          width: 32.w,
                                          height: 32.w,
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
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/white/home.svg",
                                          width: 28.w,
                                          height: 28.w,
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
                              // text: "الحاسبة",
                              height: 62.h,
                              icon: navigationValue == 1
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/orange/my_shipments.svg",
                                          width: 32.w,
                                          height: 32.w,
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
                                                  fontSize: 12.sp),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/white/my_shipments.svg",
                                          width: 28.w,
                                          height: 28.w,
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
                                                  fontSize: 12.sp),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                            ),
                            Tab(
                              height: 62.h,
                              icon: navigationValue == 2
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/orange/search_for_truck.svg",
                                          width: 36.w,
                                          height: 32.w,
                                          fit: BoxFit.fill,
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
                                                  fontSize: 12.sp),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/white/search_for_truck.svg",
                                          width: 31.w,
                                          height: 28.w,
                                          fit: BoxFit.fill,
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
                                                  fontSize: 12.sp),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                            ),
                            Tab(
                              // text: "التعرفة",
                              height: 62.h,
                              icon: navigationValue == 3
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/orange/location.svg",
                                          width: 32.w,
                                          height: 32.w,
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
                                              fontSize: 12.sp),
                                        )
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/white/location.svg",
                                          width: 28.w,
                                          height: 28.w,
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
                                              fontSize: 12.sp),
                                        )
                                      ],
                                    ),
                            ),
                            Tab(
                              // text: "التعرفة",
                              height: 62.h,
                              icon: navigationValue == 4
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/orange/truck_order.svg",
                                          width: 36.w,
                                          height: 32.w,
                                          fit: BoxFit.fill,
                                        ),
                                        localeState.value.languageCode == 'en'
                                            ? const SizedBox(
                                                height: 4,
                                              )
                                            : const SizedBox.shrink(),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .translate('my_trucks'),
                                          style: TextStyle(
                                              color: AppColor.deepYellow,
                                              fontSize: 12.sp),
                                        )
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/white/truck_order.svg",
                                          width: 31.w,
                                          height: 28.w,
                                          fit: BoxFit.fill,
                                        ),
                                        localeState.value.languageCode == 'en'
                                            ? const SizedBox(
                                                height: 4,
                                              )
                                            : const SizedBox.shrink(),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .translate('my_trucks'),
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
                body: currentScreen,
              ),
            ),
          ),
        );
      },
    );
  }
}
