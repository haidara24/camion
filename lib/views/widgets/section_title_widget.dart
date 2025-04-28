import 'package:camion/helpers/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final double? size;
  const SectionTitle({Key? key, required this.text, this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size ?? 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColor.darkGrey,
      ),
    );
  }
}
