import 'package:camion/business_logic/bloc/core/auth_bloc.dart';
import 'package:camion/business_logic/bloc/post_bloc.dart';
import 'package:camion/business_logic/cubit/internet_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/services/fcm_service.dart';
import 'package:camion/views/screens/driver/driver_home_screen.dart';
import 'package:camion/views/screens/merchant/home_screen.dart';
import 'package:camion/views/screens/owner/owner_home_screen.dart';
import 'package:camion/views/screens/select_user_type.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControlView extends StatefulWidget {
  const ControlView({Key? key}) : super(key: key);

  @override
  State<ControlView> createState() => _ControlViewState();
}

class _ControlViewState extends State<ControlView> {
  late SharedPreferences prefs;
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    // notificationServices.forgroundMessage(context);
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    initPrefs();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    initializeFromPreferences();
  }

  void initializeFromPreferences() {
    final String storedLocale = prefs.getString('language') ?? 'ar';

    if (storedLocale == 'en') {
      BlocProvider.of<LocaleCubit>(context).toEnglish();
    } else if (storedLocale == 'ar') {
      BlocProvider.of<LocaleCubit>(context).toArabic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<InternetCubit, InternetState>(
        builder: (context, state) {
          if (state is InternetLoading) {
            return Center(
              child: LoadingIndicator(),
            );
          } else if (state is InternetDisConnected) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/images/no_internet.json',
                  width: 210.w,
                  height: 150.h,
                  fit: BoxFit.fill,
                ),
                const SizedBox(
                  height: 8,
                ),
                const Center(
                  child: SectionTitle(text: "no internet connection"),
                ),
              ],
            );
          } else if (state is InternetConnected) {
            // BlocProvider.of<BottomNavBarCubit>(context).emitShow();

            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthDriverSuccessState) {
                  //driver

                  return DriverHomeScreen();
                } else if (state is AuthOwnerSuccessState) {
                  //owner
                  BlocProvider.of<PostBloc>(context).add(PostLoadEvent());

                  return OwnerHomeScreen();
                } else if (state is AuthMerchantSuccessState) {
                  //merchant
                  return HomeScreen();
                } else if (state is AuthInitial) {
                  BlocProvider.of<AuthBloc>(context).add(AuthCheckRequested());
                  return Center(
                    child: LoadingIndicator(),
                  );
                } else {
                  return SelectUserType();
                }
              },
            );
          } else {
            return const Center();
          }
        },
      ),
    );
  }
}
