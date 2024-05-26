import 'package:camion/business_logic/bloc/core/notification_bloc.dart';
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
  Function()? onTap;
  CustomAppBar({super.key, required this.title, this.scaffoldKey, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Container(
            height: 70.h,
            padding: EdgeInsets.only(bottom: 6.h),
            color: AppColor.deepBlack,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      scaffoldKey == null
                          ? InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: AbsorbPointer(
                                absorbing: true,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15.h, horizontal: 15.w),
                                  child: SizedBox(
                                    // margin:
                                    //     EdgeInsets.symmetric(vertical: 13.h, horizontal: 3.w),
                                    height: 35.h,
                                    width: 35.w,

                                    child: Center(
                                      child: localeState.value.languageCode ==
                                              'en'
                                          ? SvgPicture.asset(
                                              "assets/icons/arrow-left-en.svg")
                                          : SvgPicture.asset(
                                              "assets/icons/arrow-left-ar.svg"),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                scaffoldKey!.currentState!.openDrawer();
                              },
                              child: AbsorbPointer(
                                absorbing: true,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15.h, horizontal: 15.w),
                                  child: SizedBox(
                                    height: 35.h,
                                    width: 35.w,
                                    child: Center(
                                      child: SvgPicture.asset(localeState
                                                  .value.languageCode ==
                                              'en'
                                          ? "assets/icons/drawer_icon_en.svg"
                                          : "assets/icons/drawer_icon_ar.svg"),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
                        width: 5.w,
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
                                child: InkWell(
                                  // borderRadius: BorderRadius.circular(45),
                                  onTap: () {
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
                                    // scaffoldKey.currentState!.openDrawer();
                                  },
                                  child: AbsorbPointer(
                                    absorbing: true,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 13.h, horizontal: 10.w),
                                      child: Stack(
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
                                                      color:
                                                          AppColor.deepYellow,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              45),
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
                                  ),
                                ),
                              );
                            }),
                    ],
                  ),
                  SizedBox(
                    width: 25.w,
                  ),
                  SizedBox(
                    height: 45.h,
                    // width: MediaQuery.of(context).size,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, 70.h);
}
