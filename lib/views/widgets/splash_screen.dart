import 'package:camion/data/services/fcm_service.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    notificationServices.firebaseInit(context);
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
