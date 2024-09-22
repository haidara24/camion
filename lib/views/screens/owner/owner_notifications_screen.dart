import 'package:camion/business_logic/bloc/core/notification_bloc.dart';
import 'package:camion/business_logic/bloc/core/owner_notifications_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/requests/request_details_bloc.dart';
import 'package:camion/data/providers/notification_provider.dart';
import 'package:camion/data/services/fcm_service.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/driver/incoming_shipment_details_screen.dart';
import 'package:camion/views/screens/merchant/approval_request_info_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class OwnerNotificationsScreen extends StatefulWidget {
  const OwnerNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<OwnerNotificationsScreen> createState() =>
      _OwnerNotificationsScreenState();
}

class _OwnerNotificationsScreenState extends State<OwnerNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int tabIndex = 0;

  NotificationProvider? notificationsProvider;

  String diffText(Duration diff) {
    if (diff.inSeconds < 60) {
      return "منذ ${diff.inSeconds.toString()} ثانية";
    } else if (diff.inMinutes < 60) {
      return "منذ ${diff.inMinutes.toString()} دقيقة";
    } else if (diff.inHours < 24) {
      return "منذ ${diff.inHours.toString()} ساعة";
    } else {
      return "منذ ${diff.inDays.toString()} يوم";
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notificationsProvider =
          Provider.of<NotificationProvider>(context, listen: false);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: CustomAppBar(
          title: "Notifications",
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.grey[200],
                child: TabBar(
                  indicatorColor: AppColor.deepYellow,
                  controller: _tabController,
                  onTap: (value) {
                    switch (value) {
                      case 0:
                        BlocProvider.of<NotificationBloc>(context)
                            .add(NotificationLoadEvent());
                        break;
                      case 1:
                        BlocProvider.of<OwnerNotificationsBloc>(context)
                            .add(OwnerNotificationsLoadEvent());
                        break;
                      default:
                    }
                    setState(() {
                      tabIndex = value;
                    });
                  },
                  tabs: [
                    // first tab [you can add an icon using the icon property]
                    Tab(
                      child: Center(child: Text("إشعاراتي")),
                    ),

                    Tab(
                      child: Center(child: Text("أشعارات السائقين")),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: tabIndex == 0
                    ? BlocBuilder<NotificationBloc, NotificationState>(
                        builder: (context, state) {
                          if (state is NotificationLoadedSuccess) {
                            return Consumer<NotificationProvider>(
                              builder: (context, notificationProvider, child) {
                                return notificationProvider
                                        .notifications.isEmpty
                                    ? ListView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        children: [
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .75,
                                            child: const Center(
                                              child: Text(
                                                  "There are no Notifications to show."),
                                            ),
                                          )
                                        ],
                                      )
                                    : ListView.builder(
                                        itemCount: notificationProvider
                                            .notifications.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          DateTime now = DateTime.now();
                                          Duration diff = now.difference(
                                              DateTime.parse(
                                                  notificationProvider
                                                      .notifications[index]
                                                      .dateCreated!));
                                          return Container(
                                            decoration: BoxDecoration(
                                              border: const Border(
                                                  // bottom: BorderSide(
                                                  //     color: AppColor.deepBlue, width: 2),
                                                  ),
                                              color: notificationProvider
                                                      .notifications[index]
                                                      .isread!
                                                  ? Colors.white
                                                  : Colors.blue[50],
                                            ),
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              onTap: () {
                                                if (notificationProvider
                                                            .notifications[
                                                                index]
                                                            .noteficationType ==
                                                        "A" ||
                                                    notificationProvider
                                                            .notifications[
                                                                index]
                                                            .noteficationType ==
                                                        "J") {
                                                  BlocProvider.of<
                                                              RequestDetailsBloc>(
                                                          context)
                                                      .add(RequestDetailsLoadEvent(
                                                          notificationProvider
                                                              .notifications[
                                                                  index]
                                                              .request!));

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ApprovalRequestDetailsScreen(
                                                        type: notificationProvider
                                                            .notifications[
                                                                index]
                                                            .noteficationType!,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                if (notificationProvider
                                                        .notifications[index]
                                                        .noteficationType ==
                                                    "O") {
                                                  BlocProvider.of<
                                                              SubShipmentDetailsBloc>(
                                                          context)
                                                      .add(SubShipmentDetailsLoadEvent(
                                                          notificationProvider
                                                              .notifications[
                                                                  index]
                                                              .shipment!));
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          IncomingShipmentDetailsScreen(),
                                                    ),
                                                  );
                                                }

                                                if (!notificationProvider
                                                    .notifications[index]
                                                    .isread!) {
                                                  NotificationServices
                                                      .markNotificationasRead(
                                                          notificationProvider
                                                              .notifications[
                                                                  index]
                                                              .id!);
                                                  notificationProvider
                                                      .markNotificationAsRead(
                                                          notificationProvider
                                                              .notifications[
                                                                  index]
                                                              .id!);
                                                }
                                              },
                                              leading: Container(
                                                height: 75.h,
                                                width: 75.w,
                                                decoration: BoxDecoration(
                                                    // color: AppColor.lightGoldenYellow,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: CircleAvatar(
                                                  radius: 25.h,
                                                  // backgroundColor: AppColor.deepBlue,
                                                  child: Center(
                                                    child: (notificationProvider
                                                                .notifications[
                                                                    index]
                                                                .image!
                                                                .length >
                                                            1)
                                                        ? ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        180),
                                                            child:
                                                                Image.network(
                                                              'https://matjari.app/media/${notificationProvider.notifications[index].image!}',
                                                              height: 55.h,
                                                              width: 55.w,
                                                              fit: BoxFit.fill,
                                                            ),
                                                          )
                                                        : Text(
                                                            notificationProvider
                                                                .notifications[
                                                                    index]
                                                                .image!,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 28.sp,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              title: Text(notificationProvider
                                                  .notifications[index].title!),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(notificationProvider
                                                      .notifications[index]
                                                      .description!),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(diffText(diff)),
                                                      SizedBox(
                                                        width: 9.w,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              dense: false,
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
                                  height:
                                      MediaQuery.of(context).size.height * .75,
                                  child: Center(
                                    child: LoadingIndicator(),
                                  ),
                                )
                              ],
                            );
                          }
                        },
                      )
                    : BlocConsumer<OwnerNotificationsBloc,
                        OwnerNotificationsState>(
                        listener: (context, state) {
                          if (state is OwnerNotificationsLoadedSuccess) {
                            notificationsProvider!
                                .initOwnerNotifications(state.notifications);
                          }
                        },
                        builder: (context, state) {
                          if (state is OwnerNotificationsLoadedSuccess) {
                            return Consumer<NotificationProvider>(
                              builder: (context, notificationProvider, child) {
                                return notificationProvider
                                        .ownernotifications.isEmpty
                                    ? ListView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        children: [
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .75,
                                            child: const Center(
                                              child: Text(
                                                  "There are no Notifications to show."),
                                            ),
                                          )
                                        ],
                                      )
                                    : ListView.builder(
                                        itemCount: notificationProvider
                                            .ownernotifications.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          DateTime now = DateTime.now();
                                          Duration diff = now.difference(
                                              DateTime.parse(
                                                  notificationProvider
                                                      .ownernotifications[index]
                                                      .dateCreated!));
                                          return Container(
                                            decoration: BoxDecoration(
                                              border: const Border(
                                                  // bottom: BorderSide(
                                                  //     color: AppColor.deepBlue, width: 2),
                                                  ),
                                              color: notificationProvider
                                                      .ownernotifications[index]
                                                      .isread!
                                                  ? Colors.white
                                                  : Colors.blue[50],
                                            ),
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              onTap: () {
                                                if (notificationProvider
                                                            .ownernotifications[
                                                                index]
                                                            .noteficationType ==
                                                        "A" ||
                                                    notificationProvider
                                                            .ownernotifications[
                                                                index]
                                                            .noteficationType ==
                                                        "J") {
                                                  BlocProvider.of<
                                                              RequestDetailsBloc>(
                                                          context)
                                                      .add(RequestDetailsLoadEvent(
                                                          notificationProvider
                                                              .ownernotifications[
                                                                  index]
                                                              .request!));

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ApprovalRequestDetailsScreen(
                                                        type: notificationProvider
                                                            .ownernotifications[
                                                                index]
                                                            .noteficationType!,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                if (notificationProvider
                                                        .ownernotifications[
                                                            index]
                                                        .noteficationType ==
                                                    "O") {
                                                  BlocProvider.of<
                                                              SubShipmentDetailsBloc>(
                                                          context)
                                                      .add(SubShipmentDetailsLoadEvent(
                                                          notificationProvider
                                                              .ownernotifications[
                                                                  index]
                                                              .shipment!));
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          IncomingShipmentDetailsScreen(),
                                                    ),
                                                  );
                                                }

                                                if (!notificationProvider
                                                    .ownernotifications[index]
                                                    .isread!) {
                                                  NotificationServices
                                                      .markNotificationasRead(
                                                          notificationProvider
                                                              .ownernotifications[
                                                                  index]
                                                              .id!);
                                                  notificationProvider
                                                      .markNotificationAsRead(
                                                          notificationProvider
                                                              .ownernotifications[
                                                                  index]
                                                              .id!);
                                                }
                                              },
                                              leading: Container(
                                                height: 75.h,
                                                width: 75.w,
                                                decoration: BoxDecoration(
                                                    // color: AppColor.lightGoldenYellow,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: CircleAvatar(
                                                  radius: 25.h,
                                                  // backgroundColor: AppColor.deepBlue,
                                                  child: Center(
                                                    child: (notificationProvider
                                                                .ownernotifications[
                                                                    index]
                                                                .image!
                                                                .length >
                                                            1)
                                                        ? ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        180),
                                                            child:
                                                                Image.network(
                                                              'https://matjari.app/media/${notificationProvider.notifications[index].image!}',
                                                              height: 55.h,
                                                              width: 55.w,
                                                              fit: BoxFit.fill,
                                                            ),
                                                          )
                                                        : Text(
                                                            notificationProvider
                                                                .ownernotifications[
                                                                    index]
                                                                .image!,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 28.sp,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              title: Text(notificationProvider
                                                  .ownernotifications[index]
                                                  .title!),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(notificationProvider
                                                      .ownernotifications[index]
                                                      .description!),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(diffText(diff)),
                                                      SizedBox(
                                                        width: 9.w,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              dense: false,
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
                                  height:
                                      MediaQuery.of(context).size.height * .75,
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
            ],
          ),
        ),
      ),
    );
  }
}
