import 'package:camion/business_logic/bloc/check_point/charge_types_list_bloc.dart';
import 'package:camion/business_logic/bloc/check_point/check_point_list_bloc.dart';
import 'package:camion/business_logic/bloc/core/auth_bloc.dart';
import 'package:camion/business_logic/bloc/core/notification_bloc.dart';
import 'package:camion/business_logic/bloc/managment/complete_managment_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/managment_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/price_request_bloc.dart';
import 'package:camion/business_logic/bloc/managment/simple_category_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/active_shipment_list_bloc.dart';
import 'package:camion/business_logic/cubit/internet_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/views/screens/check_point/home_screen.dart';
import 'package:camion/views/screens/driver/driver_home_screen.dart';
import 'package:camion/views/screens/managment/managment_home_screen.dart';
import 'package:camion/views/screens/merchant/home_screen.dart';
import 'package:camion/views/screens/owner/owner_home_screen.dart';
import 'package:camion/views/screens/select_user_type.dart';
import 'package:camion/views/screens/select_user_type_screen.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final String storedLocale = prefs.getString('language') ?? 'en';

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
            return const Center(
              child: LoadingIndicator(),
            );
          } else if (state is InternetDisConnected) {
            return const Center(
              child: Text("no internet connection"),
            );
          } else if (state is InternetConnected) {
            // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
            BlocProvider.of<NotificationBloc>(context)
                .add(NotificationLoadEvent());
            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthDriverSuccessState) {
                  return DriverHomeScreen();
                } else if (state is AuthOwnerSuccessState) {
                  return OwnerHomeScreen();
                } else if (state is AuthManagmentSuccessState) {
                  BlocProvider.of<ManagmentShipmentListBloc>(context)
                      .add(ManagmentShipmentListLoadEvent("P"));
                  BlocProvider.of<PriceRequestBloc>(context)
                      .add(PriceRequestLoadEvent());
                  BlocProvider.of<SimpleCategoryListBloc>(context)
                      .add(SimpleCategoryListLoadEvent());
                  return ManagmentHomeScreen();
                } else if (state is AuthCheckPointSuccessState) {
                  BlocProvider.of<CompleteManagmentShipmentListBloc>(context)
                      .add(CompleteManagmentShipmentListLoadEvent("C"));
                  return CheckPointHomeScreen();
                } else if (state is AuthMerchentSuccessState) {
                  BlocProvider.of<ActiveShipmentListBloc>(context)
                      .add(ActiveShipmentListLoadEvent());
                  return HomeScreen();
                } else if (state is AuthInitial) {
                  BlocProvider.of<AuthBloc>(context).add(AuthCheckRequested());
                  return const Center(
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
