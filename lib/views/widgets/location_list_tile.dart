import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:flutter/material.dart';

class LocationListTile extends StatelessWidget {
  final String location;
  final Function() onTap;
  LocationListTile({
    super.key,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          horizontalTitleGap: 0,
          leading: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
              color: AppColor.darkGrey,
            ),
            padding: const EdgeInsets.all(4),
            child: const Icon(
              Icons.location_on_outlined,
              color: Colors.white,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            child: SectionBody(
              text: location,
              color: AppColor.darkGrey,
            ),
          ),
        ),
        const Divider(
          height: 2,
        ),
      ],
    );
  }
}
