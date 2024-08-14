import 'package:camion/business_logic/bloc/core/notification_bloc.dart';
import 'package:camion/business_logic/bloc/truck_active_status_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/providers/notification_provider.dart';
import 'package:camion/data/providers/truck_active_status_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/notification_screen.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class DriverAppBar extends StatelessWidget implements PreferredSizeWidget {
  String title;
  GlobalKey<ScaffoldState>? scaffoldKey;
  Color? color;
  Function()? onTap;
  DriverAppBar(
      {super.key,
      required this.title,
      this.scaffoldKey,
      this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: AppBar(
            backgroundColor: color ?? AppColor.deepBlack,
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold),
            ),
            leading: scaffoldKey == null
                ? IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: SizedBox(
                      // margin:
                      //     EdgeInsets.symmetric(vertical: 13.h, horizontal: 3.w),
                      height: 35.h,
                      width: 35.w,

                      child: Center(
                        child: localeState.value.languageCode == 'en'
                            ? SvgPicture.asset("assets/icons/arrow-left-en.svg")
                            : SvgPicture.asset(
                                "assets/icons/arrow-left-ar.svg"),
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: () => scaffoldKey!.currentState!.openDrawer(),
                    icon: SizedBox(
                      // margin:
                      //     EdgeInsets.symmetric(vertical: 13.h, horizontal: 3.w),
                      height: 35.h,
                      width: 35.w,

                      child: Center(
                        child: SvgPicture.asset(
                            localeState.value.languageCode == 'en'
                                ? "assets/icons/drawer_icon_en.svg"
                                : "assets/icons/drawer_icon_ar.svg"),
                      ),
                    ),
                  ),
            centerTitle: true,
            actions: [
              scaffoldKey == null
                  ? const SizedBox.shrink()
                  : Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, child) {
                        return BlocListener<NotificationBloc,
                            NotificationState>(
                          listener: (context, state) {
                            if (state is NotificationLoadedSuccess) {
                              notificationProvider
                                  .initNotifications(state.notifications);
                            }
                          },
                          child: IconButton(
                            onPressed: () {
                              BlocProvider.of<NotificationBloc>(context)
                                  .add(NotificationLoadEvent());
                              notificationProvider.clearNotReadedNotification();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotificationScreen(),
                                  ));
                            },
                            icon: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  height: 35.h,
                                  width: 35.h,
                                  child: Center(
                                    child: SvgPicture.asset(
                                        "assets/icons/notification.svg"),
                                  ),
                                ),
                                notificationProvider.notreadednotifications != 0
                                    ? Positioned(
                                        right: -7.w,
                                        top: -10.h,
                                        child: Container(
                                          height: 20.h,
                                          width: 20.h,
                                          decoration: BoxDecoration(
                                            color: AppColor.deepYellow,
                                            borderRadius:
                                                BorderRadius.circular(45),
                                          ),
                                          child: Center(
                                            child: Text(
                                              notificationProvider
                                                  .notreadednotifications
                                                  .toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink()
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              scaffoldKey == null
                  ? const SizedBox.shrink()
                  : Consumer<TruckActiveStatusProvider>(
                      builder: (context, activeProvider, child) {
                      return BlocConsumer<TruckActiveStatusBloc,
                          TruckActiveStatusState>(
                        listener: (context, state) {
                          if (state is TruckActiveStatusLoadedFailed) {
                            print(state.errortext);
                          }
                          if (state is TruckActiveStatusLoadedSuccess) {
                            print(state.status);
                            activeProvider.setStatus(state.status);
                          }

                          // TODO: implement listener
                        },
                        builder: (context, state) {
                          if (state is TruckActiveStatusLoadedSuccess) {
                            return IconButton(
                              onPressed: () =>
                                  BlocProvider.of<TruckActiveStatusBloc>(
                                          context)
                                      .add(UpdateTruckActiveStatusEvent(
                                          (activeProvider.isOn))),
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  SizedBox(
                                    height: 35.h,
                                    width: 35.h,
                                    child: Center(
                                      child: SvgPicture.asset(
                                          "assets/icons/orange_truck.svg"),
                                    ),
                                  ),
                                  Positioned(
                                    right: -5.w,
                                    top: -5.h,
                                    child: Container(
                                      height: 15.h,
                                      width: 15.h,
                                      decoration: BoxDecoration(
                                        color: activeProvider.isOn
                                            ? Colors.green
                                            : Colors.grey,
                                        borderRadius: BorderRadius.circular(45),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (state
                              is TruckActiveStatusLoadingProgress) {
                            return LoadingIndicator(
                              color: Colors.white,
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      );
                    }),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
}
