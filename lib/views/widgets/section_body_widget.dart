import 'package:flutter/material.dart';

class SectionBody extends StatelessWidget {
  final String text;
  const SectionBody({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 12,
      // textAlign: TextAlign.start,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
}
