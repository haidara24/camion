import 'package:flutter/material.dart';

class SectionBody extends StatelessWidget {
  final String text;
  final Color? color;

  const SectionBody({
    Key? key,
    required this.text,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 12,
      // textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: 16,
        color: color ?? Colors.black87,
      ),
    );
  }
}
