import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/core/notification_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/requests/request_details_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/providers/notification_provider.dart';
import 'package:camion/data/services/fcm_service.dart';
import 'package:camion/views/screens/driver/incoming_shipment_details_screen.dart';
import 'package:camion/views/screens/merchant/approval_request_info_screen.dart';
import 'package:camion/views/screens/sub_shipment_details_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/no_reaults_widget.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String usertype = "Trader";

  String diffText(Duration diff, String lang) {
    if (diff.inSeconds < 60) {
      return lang == "ar"
          ? "منذ ${diff.inSeconds.toString()} ثانية"
          : "since ${diff.inSeconds.toString()} seconds";
    } else if (diff.inMinutes < 60) {
      return lang == "ar"
          ? "منذ ${diff.inMinutes.toString()} دقيقة"
          : "since ${diff.inMinutes.toString()} minutes";
    } else if (diff.inHours < 24) {
      return lang == "ar"
          ? "منذ ${diff.inHours.toString()} ساعة"
          : "since ${diff.inHours.toString()} hours";
    } else {
      return lang == "ar"
          ? "منذ ${diff.inDays.toString()} يوم"
          : "since ${diff.inDays.toString()} days";
    }
  }

  getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    usertype = prefs.getString("userType") ?? "";
  }

  @override
  void initState() {
    super.initState();
    getUserType();
  }

  Widget getStatusImage(String value) {
    switch (value) {
      case "T":
        return SvgPicture.asset(
          "assets/icons/orange/notification_shipment_complete.svg",
          height: 30.h,
          width: 30.w,
          fit: BoxFit.fill,
        );
      case "A":
        return SvgPicture.asset(
          "assets/icons/orange/notification_shipment_complete.svg",
          height: 30.h,
          width: 30.w,
          fit: BoxFit.fill,
        );
      case "J":
        return SvgPicture.asset(
          "assets/icons/orange/notification_shipment_cancelation.svg",
          height: 30.h,
          width: 30.w,
          fit: BoxFit.fill,
        );

      case "C":
        return SvgPicture.asset(
          "assets/icons/orange/notification_shipment_complete.svg",
          height: 30.h,
          width: 30.w,
          fit: BoxFit.fill,
        );

      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.translate('notifications'),
            ),
            body: SingleChildScrollView(
              child: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoadedSuccess) {
                    return Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, child) {
                        return notificationProvider.notifications.isEmpty
                            ? ListView(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  NoResultsWidget(
                                    text: AppLocalizations.of(context)!
                                        .translate('no_notifications'),
                                  )
                                ],
                              )
                            : ListView.builder(
                                itemCount:
                                    notificationProvider.notifications.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  DateTime now = DateTime.now();
                                  Duration diff = now.difference(DateTime.parse(
                                      notificationProvider
                                          .notifications[index]!.dateCreated!));
                                  return Card(
                                    elevation: 1,
                                    color: notificationProvider
                                            .notifications[index]!.isread!
                                        ? Colors.white
                                        : Colors.blue[50],
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      child: ListTile(
                                        // contentPadding: EdgeInsets.zero,
                                        onTap: () {
                                          if (notificationProvider
                                                      .notifications[index]!
                                                      .noteficationType ==
                                                  "A" ||
                                              notificationProvider
                                                      .notifications[index]!
                                                      .noteficationType ==
                                                  "J") {
                                            BlocProvider.of<RequestDetailsBloc>(
                                                    context)
                                                .add(RequestDetailsLoadEvent(
                                                    notificationProvider
                                                        .notifications[index]!
                                                        .objectId!));

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ApprovalRequestDetailsScreen(
                                                  type: notificationProvider
                                                      .notifications[index]!
                                                      .noteficationType!,
                                                ),
                                              ),
                                            );
                                          } else if (notificationProvider
                                                  .notifications[index]!
                                                  .noteficationType ==
                                              "O") {
                                            BlocProvider.of<
                                                        SubShipmentDetailsBloc>(
                                                    context)
                                                .add(
                                                    SubShipmentDetailsLoadEvent(
                                                        notificationProvider
                                                            .notifications[
                                                                index]!
                                                            .objectId!));
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    IncomingShipmentDetailsScreen(),
                                              ),
                                            );
                                          } else if (notificationProvider
                                                  .notifications[index]!
                                                  .noteficationType ==
                                              "T") {
                                            BlocProvider.of<
                                                        SubShipmentDetailsBloc>(
                                                    context)
                                                .add(
                                                    SubShipmentDetailsLoadEvent(
                                                        notificationProvider
                                                            .notifications[
                                                                index]!
                                                            .objectId!));
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SubShipmentDetailsScreen(),
                                              ),
                                            );
                                          }

                                          if (!notificationProvider
                                              .notifications[index]!.isread!) {
                                            NotificationServices
                                                .markNotificationasRead(
                                                    notificationProvider
                                                        .notifications[index]!
                                                        .id!);
                                            notificationProvider
                                                .markNotificationAsRead(
                                                    notificationProvider
                                                        .notifications[index]!
                                                        .id!);
                                          }
                                        },
                                        leading: Container(
                                          height: 75.h,
                                          width: 50.w,
                                          decoration: BoxDecoration(
                                              // color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              CircleAvatar(
                                                radius: 25.h,
                                                // backgroundColor: AppColor.deepBlue,
                                                child: Center(
                                                  child: (notificationProvider
                                                              .notifications[
                                                                  index]!
                                                              .image!
                                                              .length >
                                                          1)
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      180),
                                                          child: Image.network(
                                                            'https://matjari.app/media/${notificationProvider.notifications[index]!.image!}',
                                                            height: 55.h,
                                                            width: 55.w,
                                                            fit: BoxFit.fill,
                                                          ),
                                                        )
                                                      : Text(
                                                          notificationProvider
                                                              .notifications[
                                                                  index]!
                                                              .image!,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 28.sp,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                              Positioned(
                                                  bottom: -10,
                                                  left: localeState.value
                                                              .languageCode ==
                                                          "en"
                                                      ? null
                                                      : -5,
                                                  right: localeState.value
                                                              .languageCode ==
                                                          "en"
                                                      ? -5
                                                      : null,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              45),
                                                    ),
                                                    child: getStatusImage(
                                                        notificationProvider
                                                            .notifications[
                                                                index]!
                                                            .noteficationType!),
                                                  )),
                                            ],
                                          ),
                                        ),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SectionTitle(
                                              text: localeState
                                                          .value.languageCode ==
                                                      "en"
                                                  ? notificationProvider
                                                      .notifications[index]!
                                                      .titleEn!
                                                  : notificationProvider
                                                      .notifications[index]!
                                                      .title!,
                                            ),
                                            Text(
                                              diffText(
                                                diff,
                                                localeState.value.languageCode,
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SectionBody(
                                                text: localeState.value
                                                            .languageCode ==
                                                        "en"
                                                    ? notificationProvider
                                                        .notifications[index]!
                                                        .descriptionEn!
                                                    : notificationProvider
                                                        .notifications[index]!
                                                        .description!),
                                          ],
                                        ),
                                        dense: true,
                                      ),
                                    ),
                                  );
                                },
                              );
                      },
                    );
                  } else {
                    return ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .75,
                          child: Center(
                            child: LoadingIndicator(),
                          ),
                        )
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
