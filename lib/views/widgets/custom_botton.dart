import 'package:camion/helpers/color_constants.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Widget title;
  final bool isEnabled;
  final double hieght;
  final Color? color;
  final Color? bordercolor;
  final Function() onTap;

  const CustomButton(
      {super.key,
      required this.title,
      this.isEnabled = true,
      this.hieght = 50,
      required this.onTap,
      this.color,
      this.bordercolor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: isEnabled ? onTap : () {},
      child: Container(
        // margin: const EdgeInsets.all(4),
        height: hieght,
        decoration: BoxDecoration(
          color: isEnabled ? color ?? AppColor.deepYellow : Colors.grey,
          // color: isEnabled ? color : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColor.deepYellow,
            width: 1,
          ),
        ),
        child: Center(
          child: title,
        ),
      ),
    );
  }
}
