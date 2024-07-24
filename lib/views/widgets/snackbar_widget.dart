import 'package:camion/helpers/color_constants.dart';
import 'package:flutter/material.dart';

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  Color backgroundColor = Colors.green,
  Duration duration = const Duration(seconds: 3),
  SnackBarBehavior behavior = SnackBarBehavior.floating,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      dismissDirection: DismissDirection.up,
      behavior: behavior,
      // padding: const EdgeInsets.symmetric(
      //   horizontal: 10,
      //   vertical: 8,
      // ),
      content: Text(
        message,
      ),
      duration: duration,
    ),
  );
}
