import 'package:camion/business_logic/bloc/core/notification_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/providers/notification_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/notification_screen.dart';
import 'package:camion/views/widgets/Icon_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  String title;
  GlobalKey<ScaffoldState>? scaffoldKey;
  Color? color;
  Function()? onTap;
  CustomAppBar(
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
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                      scaffoldKey!.currentState!.openDrawer();
                    },
                    icon: SizedBox(
                      // margin:
                      //     EdgeInsets.symmetric(vertical: 13.h, horizontal: 3.w),
                      height: 35.h,
                      width: 35.w,

                      child: Center(
                        child: SvgPicture.asset(
                          localeState.value.languageCode == 'en'
                              ? "assets/icons/orange/drawer_en.svg"
                              : "assets/icons/orange/drawer_ar.svg",
                          height: 30.h,
                          width: 30.h,
                        ),
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
                            icon: IconBadge(
                              top: -5,
                              right: -7,
                              count:
                                  notificationProvider.notreadednotifications,
                              color: AppColor.deepYellow,
                              icon: SizedBox(
                                height: 30.h,
                                width: 30.h,
                                child: Center(
                                  child: SvgPicture.asset(
                                    "assets/icons/notification.svg",
                                    height: 30.h,
                                    width: 30.h,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(
                width: 15,
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
}
