import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class IconBadge extends StatelessWidget {
  final Widget icon;
  final int count;
  final int top;
  final int? right;
  final int? left;
  final Color color;

  const IconBadge({
    super.key,
    required this.icon,
    required this.count,
    required this.top,
    this.right,
    this.left,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        count > 0
            ? Positioned(
                right: right?.toDouble(),
                left: left?.toDouble(),
                top: top.toDouble(),
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                  child: Text(
                    count.toString(),
                    style: GoogleFonts.instrumentSans(
                      // Apply directly
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink()
      ],
    );
  }
}
