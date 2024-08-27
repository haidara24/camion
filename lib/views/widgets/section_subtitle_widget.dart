import 'package:camion/helpers/color_constants.dart';
import 'package:flutter/material.dart';

class SectionSubTitle extends StatelessWidget {
  final String text;
  const SectionSubTitle({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17,
        color: AppColor.darkGrey,
      ),
    );
  }
}
