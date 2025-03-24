import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/views/screens/driver/create_truck_for%20driver.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoTruckProfileWidget extends StatelessWidget {
  final String text;
  NoTruckProfileWidget({
    Key? key,
    required this.text,
  }) : super(key: key);

  late SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 280.w,
            height: 175.h,
            child: SvgPicture.asset(
              "assets/icons/grey/no_profile_truck.svg",
              width: 280.w,
              height: 175.h,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Center(
            child: SectionTitle(
              text: text,
            ),
          ),
          const SizedBox(
            height: 60,
          ),
          CustomButton(
            onTap: () async {
              prefs = await SharedPreferences.getInstance();
              var driverId = prefs.getInt("truckuser");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateTruckForDriverScreen(driverId: driverId!),
                ),
              );
            },
            title: SizedBox(
              height: 50.h,
              width: MediaQuery.sizeOf(context).width * .9,
              child: Center(
                child: SectionBody(
                  text: AppLocalizations.of(context)!
                      .translate("create_new_truck"),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
