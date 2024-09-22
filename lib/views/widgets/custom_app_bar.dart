import 'package:camion/business_logic/bloc/core/notification_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/providers/notification_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/notification_screen.dart';
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
          child: Container(
            height: kToolbarHeight,
            padding: EdgeInsets.only(bottom: 6.h),
            color: color ?? AppColor.deepBlack,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      scaffoldKey == null
                          ? IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: SizedBox(
                                height: 28.w,
                                width: 28.w,
                                child: SvgPicture.asset(
                                    localeState.value.languageCode == 'en'
                                        ? "assets/icons/arrow-left-en.svg"
                                        : "assets/icons/arrow-left-ar.svg"),
                              ),
                            )
                          : IconButton(
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                BlocProvider.of<BottomNavBarCubit>(context)
                                    .emitShow();
                                scaffoldKey!.currentState!.openDrawer();
                              },
                              icon: SizedBox(
                                height: 28.w,
                                width: 28.w,
                                child: SvgPicture.asset(
                                    localeState.value.languageCode == 'en'
                                        ? "assets/icons/orange/drawer_en.svg"
                                        : "assets/icons/orange/drawer_ar.svg"),
                              ),
                            ),
                      SizedBox(
                        width: 4.w,
                      ),
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
                                    notificationProvider
                                        .clearNotReadedNotification();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NotificationScreen(),
                                        ));
                                  },
                                  icon: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      SizedBox(
                                        height: 28.w,
                                        width: 28.w,
                                        child: SvgPicture.asset(
                                            "assets/icons/orange/notification.svg"),
                                      ),
                                      notificationProvider
                                                  .notreadednotifications !=
                                              0
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                            }),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 45.h,
                    // width: MediaQuery.of(context).size.width*.75,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Spacer(),
                  scaffoldKey == null
                      ? SizedBox(
                          width: 50.w,
                        )
                      : SizedBox(
                          width: 85.w,
                        )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
}
