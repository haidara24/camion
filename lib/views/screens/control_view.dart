import 'package:camion/business_logic/bloc/core/auth_bloc.dart';
import 'package:camion/business_logic/bloc/core/notification_bloc.dart';
import 'package:camion/business_logic/bloc/post_bloc.dart';
import 'package:camion/business_logic/cubit/internet_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/services/fcm_service.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/notification_utils.dart';
import 'package:camion/views/screens/driver/driver_home_screen.dart';
import 'package:camion/views/screens/merchant/home_screen.dart';
import 'package:camion/views/screens/owner/owner_home_screen.dart';
import 'package:camion/views/screens/select_user_type.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  @override
  void initState() {
    super.initState();

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

  DateTime? lastBackPressTime;

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark, // Reset to default
        statusBarColor: AppColor.deepBlack,
        systemNavigationBarColor: AppColor.deepBlack,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();

        if (lastBackPressTime == null ||
            now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
          lastBackPressTime = now;

          // Show Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'اضغط مرة أخرى لإغلاق التطبيق',
                style: TextStyle(fontSize: 16),
              ),
              duration: Duration(seconds: 2),
            ),
          );

          return false; // Prevent exit on the first press
        }
        return true; // Exit the app on the second press within 2 seconds
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: AppColor.deepBlack, // Make status bar transparent
          statusBarIconBrightness:
              Brightness.dark, // Light icons for dark backgrounds
          systemNavigationBarColor: AppColor.deepBlack, // Works on Android
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          body: BlocConsumer<InternetCubit, InternetState>(
            listener: (context, state) {
              if (state is InternetConnected) {
                BlocProvider.of<AuthBloc>(context).add(AuthCheckRequested());
              }
            },
            builder: (context, state) {
              if (state is InternetLoading) {
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: const SystemUiOverlayStyle(
                    statusBarColor: Colors.white, // Make status bar transparent
                    statusBarIconBrightness:
                        Brightness.light, // Light icons for dark backgrounds
                    systemNavigationBarColor: Colors.white, // Works on Android
                    systemNavigationBarIconBrightness: Brightness.light,
                  ),
                  child: Scaffold(
                    backgroundColor: Colors.white,
                    body: Center(
                      child: LoadingIndicator(),
                    ),
                  ),
                );
              } else if (state is InternetDisConnected) {
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: const SystemUiOverlayStyle(
                    statusBarColor: Colors.white, // Make status bar transparent
                    statusBarIconBrightness:
                        Brightness.light, // Light icons for dark backgrounds
                    systemNavigationBarColor: Colors.white, // Works on Android
                    systemNavigationBarIconBrightness: Brightness.light,
                  ),
                  child: Scaffold(
                    backgroundColor: Colors.white,
                    body: Column(
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
                    ),
                  ),
                );
              } else if (state is InternetConnected) {
                return BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthFailureState) {
                      print(state.errorMessage);
                    }
                  },
                  builder: (context, state) {
                    BlocProvider.of<PostBloc>(context).add(PostLoadEvent());
                    BlocProvider.of<NotificationBloc>(context)
                        .add(NotificationLoadEvent());
                    if (state is AuthDriverSuccessState) {
                      //driver

                      return const DriverHomeScreen();
                    } else if (state is AuthOwnerSuccessState) {
                      //owner

                      return const OwnerHomeScreen();
                    } else if (state is AuthMerchantSuccessState) {
                      //merchant
                      return const HomeScreen();
                    } else if (state is AuthInitial) {
                      BlocProvider.of<AuthBloc>(context)
                          .add(AuthCheckRequested());
                      return Center(
                        child: LoadingIndicator(),
                      );
                    } else {
                      return const SelectUserType();
                    }
                  },
                );
              } else {
                return const Center();
              }
            },
          ),
        ),
      ),
    );
  }
}
