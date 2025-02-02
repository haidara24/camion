import 'package:camion/helpers/color_constants.dart';
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
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(const Duration(seconds: 4))
        .then((value) => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const ControlView(),
            ),
            (route) => false));
    super.initState();
  }

  // @override
  // void dispose() {
  //   SystemChrome.setSystemUIOverlayStyle(
  //     SystemUiOverlayStyle(
  //       statusBarIconBrightness: Brightness.dark, // Reset to default
  //       statusBarColor: AppColor.deepBlack,
  //       systemNavigationBarColor: AppColor.deepBlack,
  //     ),
  //   );
  //   super.dispose();
  // }

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
