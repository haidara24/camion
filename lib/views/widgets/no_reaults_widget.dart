import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class NoResultsWidget extends StatelessWidget {
  final String text;
  final double? height;
  const NoResultsWidget({
    Key? key,
    required this.text,
     this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:height?? MediaQuery.of(context).size.height * .7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/images/no_search_result.json',
            width: 550.w,
            height: 175.h,
            fit: BoxFit.fill,
          ),
          const SizedBox(
            height: 8,
          ),
          Center(
            child: SectionTitle(
              text: text,
            ),
          ),
        ],
      ),
    );
  }
}
