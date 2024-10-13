import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/policy_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: AppLocalizations.of(context)!.translate("policy_text"),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          children: [
            // TextSpan(
            //   text: "Terms & Conditions ",
            //   style: TextStyle(fontWeight: FontWeight.bold),
            //   recognizer: TapGestureRecognizer()
            //     ..onTap = () {
            //       showModal(
            //         context: context,
            //         configuration: FadeScaleTransitionConfiguration(),
            //         builder: (context) {
            //           return PolicyDialog(
            //             mdFileName: 'terms_and_conditions.md',
            //           );
            //         },
            //       );
            //     },
            // ),
            // TextSpan(text: "and "),
            TextSpan(
              text: AppLocalizations.of(context)!.translate("policy"),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColor.deepYellow,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return PolicyDialog(
                        mdFileName: 'privacy_policy.md',
                      );
                    },
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
