import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  ContactUsScreen({super.key});

  String? _encodeQueryParameters(Map<String, String?> params) {
    return params.entries
        .where((e) => e.value != null)
        .map((e) =>
            "\${Uri.encodeComponent(e.key)}=\${Uri.encodeComponent(e.value!)}")
        .join('&');
  }

  void _sendEmail(String email, {String? subject, String? body}) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters({
        'subject': subject,
        'body': body,
      }),
    );

    final String url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  void _openWhatsApp(String phoneNumber, {String? message}) async {
    final String url = message != null
        ? 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}'
        : 'https://wa.me/$phoneNumber';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _openFacebookPage(String pageId) async {
    // Try launching the Facebook app first
    final String facebookAppUrl = 'fb://page/$pageId';
    final String facebookWebUrl = 'https://www.facebook.com/$pageId';

    if (await canLaunch(facebookAppUrl)) {
      await launch(facebookAppUrl);
    } else if (await canLaunch(facebookWebUrl)) {
      await launch(facebookWebUrl);
    } else {
      throw 'Could not launch $facebookAppUrl or $facebookWebUrl';
    }
  }

  void _launchLinkedIn(String profileIdOrUsername) async {
    // LinkedIn app URL
    final String linkedInAppUrl = 'linkedin://profile/$profileIdOrUsername';
    // LinkedIn web URL
    final String linkedInWebUrl =
        'https://www.linkedin.com/company/$profileIdOrUsername/';

    // Try launching the LinkedIn app
    if (await canLaunch(linkedInAppUrl)) {
      await launch(linkedInAppUrl);
    }
    // If the app is not installed, launch the web URL
    else if (await canLaunch(linkedInWebUrl)) {
      await launch(linkedInWebUrl);
    }
    // If neither works, throw an error
    else {
      throw 'Could not launch LinkedIn';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: AppColor.deepBlack, // Make status bar transparent
              statusBarIconBrightness:
                  Brightness.dark, // Light icons for dark backgrounds
              systemNavigationBarColor: Colors.grey[100], // Works on Android
              systemNavigationBarIconBrightness: Brightness.light,
            ),
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                // backgroundColor: AppColor.deepBlack,
                appBar: CustomAppBar(
                  title: AppLocalizations.of(context)!.translate("contact_us"),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      SectionTitle(
                        text: AppLocalizations.of(context)!
                            .translate("contact_info"),
                      ),
                      SectionBody(
                        text: AppLocalizations.of(context)!
                            .translate("contact_desc"),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      InkWell(
                        onTap: () {
                          _makePhoneCall('+963944506000');
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.call,
                              color: AppColor.deepYellow,
                              size: 30,
                            ),
                            const Directionality(
                                textDirection: TextDirection.ltr,
                                child: SectionBody(text: "+963944506000")),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        onTap: () {
                          _sendEmail(
                            'info@acrossmena.com',
                            subject: 'Camion ',
                            body: 'This is a test email.',
                          );
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.email,
                              color: AppColor.deepYellow,
                              size: 30,
                            ),
                            const SectionBody(text: "info@acrossmena.com"),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Icon(
                        Icons.location_on_rounded,
                        color: AppColor.deepYellow,
                        size: 30,
                      ),
                      SectionBody(
                        text: AppLocalizations.of(context)!
                            .translate("company_address"),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () {
                                _openFacebookPage('acrossmena');
                              },
                              icon: SizedBox(
                                height: 45.h,
                                width: 45.h,
                                child: SvgPicture.asset(
                                    "assets/icons/facebook.svg"),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _launchLinkedIn("across-mena");
                              },
                              icon: SizedBox(
                                height: 45.h,
                                width: 45.h,
                                child: SvgPicture.asset(
                                    "assets/icons/linkedin.svg"),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _openWhatsApp("+963944506000");
                              },
                              icon: SizedBox(
                                height: 45.h,
                                width: 45.h,
                                child: SvgPicture.asset(
                                    "assets/icons/whatsapp.svg"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
