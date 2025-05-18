import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/core/auth_bloc.dart';
import 'package:camion/business_logic/bloc/core/commodity_category_bloc.dart';
import 'package:camion/business_logic/bloc/core/k_commodity_category_bloc.dart';
import 'package:camion/business_logic/bloc/core/package_type_bloc.dart';
import 'package:camion/business_logic/bloc/profile/merchant_profile_bloc.dart';
import 'package:camion/business_logic/bloc/requests/merchant_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/active_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_complete_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_running_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_task_list_bloc.dart';
import 'package:camion/business_logic/bloc/store_list_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_type_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/providers/request_num_provider.dart';
import 'package:camion/data/providers/task_num_provider.dart';
import 'package:camion/data/providers/user_provider.dart';
import 'package:camion/data/repositories/gps_repository.dart';
import 'package:camion/data/services/users_services.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/contact_us_screen.dart';
import 'package:camion/views/screens/merchant/active_shipment_screen.dart';
import 'package:camion/views/screens/merchant/add_multi_shipment_screen.dart';
import 'package:camion/views/screens/main_screen.dart';
import 'package:camion/views/screens/merchant/complete_shipment_screen.dart';
import 'package:camion/views/screens/merchant/merchant_profile_screen.dart';
import 'package:camion/views/screens/merchant/shipment_task_screen.dart';
import 'package:camion/views/screens/merchant/shippment_log_screen.dart';
import 'package:camion/views/screens/merchant/storehouse_list_screen.dart';
import 'package:camion/views/widgets/Icon_badge.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int currentIndex = 0;
  int navigationValue = 0;
  String title = "Home";
  Widget currentScreen = MainScreen();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  // AddShippmentProvider? addShippmentProvider;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    GpsRepository.getTokenForGps();

    // getUserData();
    BlocProvider.of<CommodityCategoryBloc>(context)
        .add(CommodityCategoryLoadEvent());
    BlocProvider.of<KCommodityCategoryBloc>(context)
        .add(KCommodityCategoryLoadEvent());
    BlocProvider.of<ShipmentRunningBloc>(context)
        .add(ShipmentRunningLoadEvent("R"));
    BlocProvider.of<MerchantRequestsListBloc>(context)
        .add(MerchantRequestsListLoadEvent());
    BlocProvider.of<ShipmentTaskListBloc>(context)
        .add(ShipmentTaskListLoadEvent());
    BlocProvider.of<StoreListBloc>(context).add(
      StoreListLoadEvent(),
    );
    BlocProvider.of<ActiveShipmentListBloc>(context)
        .add(ActiveShipmentListLoadEvent());
    BlocProvider.of<TruckTypeBloc>(context).add(TruckTypeLoadEvent());
    BlocProvider.of<PackageTypeBloc>(context).add(PackageTypeLoadEvent());

    _tabController = TabController(
      initialIndex: 0,
      length: 5,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // addShippmentProvider =
      //     Provider.of<AddShippmentProvider>(context, listen: false);
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
          setState(() {
            title = AppLocalizations.of(context)!.translate('home');
            currentScreen = MainScreen();
          });
          break;
        }
      case 1:
        {
          setState(() {
            title = AppLocalizations.of(context)!.translate('myshipments');
            currentScreen = ShippmentLogScreen();
          });
          break;
        }
      case 2:
        {
          // addShippmentProvider!.initShipment();
          setState(() {
            title = AppLocalizations.of(context)!.translate('search_truck');
            currentScreen = AddMultiShipmentScreen();
          });
          break;
        }
      case 3:
        {
          print("asdasdasd");
          setState(() {
            title = AppLocalizations.of(context)!.translate('tracking');
            currentScreen = ActiveShipmentScreen();
          });
          break;
        }
      case 4:
        {
          setState(() {
            title = AppLocalizations.of(context)!.translate('tasks');
            currentScreen = ShipmentTaskScreen();
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
                  backgroundColor: AppColor.deepBlack,
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
                        InkWell(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            var merchant = prefs.getInt("merchant");
                            // print(merchant);
                            // ignore: use_build_context_synchronously
                            BlocProvider.of<MerchantProfileBloc>(context)
                                .add(MerchantProfileLoad(merchant!));

                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MerchantProfileScreen(),
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
                                            height: 70.h,
                                            width: 70.h,
                                            fit: BoxFit.fill,
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
                          onTap: () {
                            BlocProvider.of<ShipmentCompleteListBloc>(context)
                                .add(ShipmentCompleteListLoadEvent());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompleteShipmentScreen(),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: SvgPicture.asset(
                              "assets/icons/orange/my_shipments.svg",
                              height: 27.h,
                              width: 27.h,
                            ),
                            title: Text(
                              AppLocalizations.of(context)!
                                  .translate('shippment_log'),
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
                            BlocProvider.of<StoreListBloc>(context)
                                .add(StoreListLoadEvent());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StorehouseListScreen(),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: SvgPicture.asset(
                              "assets/icons/orange/warehouse.svg",
                              height: 27.h,
                              width: 27.h,
                            ),
                            title: Text(
                              AppLocalizations.of(context)!
                                  .translate('my_stores'),
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
                              height: 27.h,
                              width: 27.h,
                            ),
                            title: Text(
                              AppLocalizations.of(context)!
                                  .translate('contact_us'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
                                          .translate('myshipments');
                                    });
                                    break;
                                  }
                                case 2:
                                  {
                                    setState(() {
                                      title = AppLocalizations.of(context)!
                                          .translate('search_truck');
                                    });
                                    break;
                                  }
                                case 3:
                                  {
                                    setState(() {
                                      title = AppLocalizations.of(context)!
                                          .translate('tracking');
                                    });
                                    break;
                                  }
                                case 4:
                                  {
                                    setState(() {
                                      title = AppLocalizations.of(context)!
                                          .translate('tasks');
                                    });
                                    break;
                                  }
                              }
                            });
                          },
                          child: ListTile(
                            leading: SvgPicture.asset(
                              "assets/icons/orange/translate_camion.svg",
                              height: 27.h,
                              width: 27.h,
                            ),
                            title: Text(
                              localeState.value.languageCode != 'en'
                                  ? "English"
                                  : "العربية",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
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
                                        Text(
                                            AppLocalizations.of(context)!
                                                .translate('log_out_confirm'),
                                            style:
                                                const TextStyle(fontSize: 18)),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                          AppLocalizations.of(context)!
                                              .translate('no'),
                                          style: const TextStyle(fontSize: 18)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                          AppLocalizations.of(context)!
                                              .translate('yes'),
                                          style: const TextStyle(fontSize: 18)),
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
                              height: 27.h,
                              width: 27.h,
                            ),
                            title: Text(
                              AppLocalizations.of(context)!
                                  .translate('log_out'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
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
                              dividerColor: Colors.transparent,
                              labelColor: AppColor.deepYellow,
                              unselectedLabelColor: Colors.white,
                              // labelStyle: TextStyle(fontSize: 12.sp),
                              // unselectedLabelStyle: TextStyle(fontSize: 14.sp),
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
                                    return BlocListener<
                                        MerchantRequestsListBloc,
                                        MerchantRequestsListState>(
                                      listener: (context, state) {
                                        if (state
                                            is MerchantRequestsListLoadedSuccess) {
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
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .translate(
                                                                'myshipments'),
                                                        style: TextStyle(
                                                            color: AppColor
                                                                .deepYellow,
                                                            fontSize: 12.sp),
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
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .translate(
                                                                'myshipments'),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12.sp,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                          // value.requestNum > 0
                                          //     ? Positioned(
                                          //         right: -7.w,
                                          //         top: -5.h,
                                          //         child: Container(
                                          //           height: 22.w,
                                          //           width: 22.w,
                                          //           decoration: BoxDecoration(
                                          //             color:
                                          //                 AppColor.deepYellow,
                                          //             borderRadius:
                                          //                 BorderRadius.circular(
                                          //                     45),
                                          //           ),
                                          //           child: Center(
                                          //             child: Text(
                                          //                 value.requestNum
                                          //                     .toString(),
                                          //                 style:
                                          //                     const TextStyle(
                                          //                   color: Colors.white,
                                          //                 )),
                                          //           ),
                                          //         ),
                                          //       )
                                          //     : const SizedBox.shrink(),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                                Tab(
                                  // text: "الرئيسية",
                                  height: 62.h,
                                  icon: navigationValue == 2
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/orange/search_for_truck.svg",
                                              width: 28.w,
                                              height: 28.w,
                                              fit: BoxFit.fill,
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .translate('search'),
                                                style: TextStyle(
                                                    color: AppColor.deepYellow,
                                                    fontSize: 12.sp),
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
                                              width: 28.w,
                                              height: 28.w,
                                              fit: BoxFit.fill,
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .translate('search'),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.sp),
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
                                                  .translate('tracking'),
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
                                                  .translate('tracking'),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp),
                                            )
                                          ],
                                        ),
                                ),
                                Tab(
                                  height: 62.h,
                                  icon: Consumer<TaskNumProvider>(
                                    builder: (context, value, child) {
                                      return BlocListener<ShipmentTaskListBloc,
                                          ShipmentTaskListState>(
                                        listener: (context, state) {
                                          if (state
                                              is ShipmentTaskListLoadedSuccess) {
                                            var taskNum = 0;
                                            for (var element
                                                in state.shipments) {
                                              if (element
                                                      .shipmentinstructionv2 ==
                                                  null) {
                                                taskNum++;
                                              }
                                              if (element.shipmentpaymentv2 ==
                                                  null) {
                                                taskNum++;
                                              }
                                            }
                                            value.setTaskNum(taskNum);
                                          }
                                        },
                                        child: IconBadge(
                                          top: -5,
                                          right: -7,
                                          count: value.taskNum,
                                          color: AppColor.deepYellow,
                                          icon: navigationValue == 4
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/icons/orange/tasks.svg",
                                                      width: 28.w,
                                                      height: 28.w,
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .translate('tasks'),
                                                      style: TextStyle(
                                                          color: AppColor
                                                              .deepYellow,
                                                          fontSize: 12.sp),
                                                    )
                                                  ],
                                                )
                                              : Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/icons/white/tasks.svg",
                                                      width: 28.w,
                                                      height: 28.w,
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .translate('tasks'),
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12.sp),
                                                    )
                                                  ],
                                                ),
                                        ),
                                      );
                                    },
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
