import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:flutter/material.dart';

class StoreListTile extends StatelessWidget {
  final String store;
  final Function() onTap;
  StoreListTile({
    super.key,
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          horizontalTitleGap: 0,
          tileColor: Colors.grey[200],
          leading: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
              color: AppColor.darkGrey,
            ),
            padding: const EdgeInsets.all(4),
            child: const Icon(
              Icons.warehouse_outlined,
              color: Colors.white,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            child: SectionBody(
              text: store,
              color: AppColor.darkGrey,
            ),
          ),
        ),
        const Divider(
          height: 2,
          color: Colors.grey,
        ),
      ],
    );
  }
}
