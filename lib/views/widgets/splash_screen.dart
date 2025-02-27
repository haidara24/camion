import 'package:camion/business_logic/bloc/core/notification_bloc.dart';
import 'package:camion/business_logic/bloc/requests/driver_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/requests/merchant_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_running_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_task_list_bloc.dart';
import 'package:camion/data/services/fcm_service.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  NotificationServices notificationServices = NotificationServices();

  void loadAppAesstes(RemoteMessage message) async {
    if (context == null) {
      print("Context is null. Cannot load app assets.");
      return;
    }
    BlocProvider.of<NotificationBloc>(context).add(NotificationLoadEvent());
    if (message.data['notefication_type'] == "A" ||
        message.data['notefication_type'] == "J") {
      var prefs = await SharedPreferences.getInstance();
      var userType = prefs.getString("userType");
      if (userType == "Driver") {
        BlocProvider.of<DriverRequestsListBloc>(context)
            .add(const DriverRequestsListLoadEvent(null));
      } else if (userType == "Merchant") {
        BlocProvider.of<ShipmentRunningBloc>(context)
            .add(ShipmentRunningLoadEvent("R"));
        BlocProvider.of<MerchantRequestsListBloc>(context)
            .add(MerchantRequestsListLoadEvent());
        BlocProvider.of<ShipmentTaskListBloc>(context)
            .add(ShipmentTaskListLoadEvent());
      }
    } else if (message.data['notefication_type'] == "O") {
      var prefs = await SharedPreferences.getInstance();
      var userType = prefs.getString("userType");
      if (userType == "Driver") {
        BlocProvider.of<DriverRequestsListBloc>(context)
            .add(const DriverRequestsListLoadEvent(null));
      } else if (userType == "Merchant") {
        BlocProvider.of<MerchantRequestsListBloc>(context)
            .add(MerchantRequestsListLoadEvent());
      }
    } else if (message.data['notefication_type'] == "T" ||
        message.data['notefication_type'] == "C") {
      BlocProvider.of<ShipmentRunningBloc>(context)
          .add(ShipmentRunningLoadEvent("R"));
      BlocProvider.of<MerchantRequestsListBloc>(context)
          .add(MerchantRequestsListLoadEvent());
      BlocProvider.of<ShipmentTaskListBloc>(context)
          .add(ShipmentTaskListLoadEvent());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.getDeviceToken();
    notificationServices.setupInteractMessage(context);

    Future.delayed(const Duration(seconds: 4))
        .then((value) => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const ControlView(),
            ),
            (route) => false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Make status bar transparent
        statusBarIconBrightness:
            Brightness.light, // Light icons for dark backgrounds
        systemNavigationBarColor: Colors.white, // Works on Android
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              "assets/images/splash.svg",
              fit: BoxFit.fill,
            ),
          ],
        ),
      ),
    );
  }
}
