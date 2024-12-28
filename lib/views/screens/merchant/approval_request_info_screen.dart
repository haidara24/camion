import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_update_status_bloc.dart';
import 'package:camion/business_logic/bloc/requests/request_details_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/approval_request.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/screens/search_truck_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class ApprovalRequestDetailsScreen extends StatelessWidget {
  final String type;
  final ApprovalRequest? request;
  ApprovalRequestDetailsScreen({
    Key? key,
    required this.type,
    this.request,
  }) : super(key: key);

  Widget getMainPhoto(ApprovalRequest request) {
    switch (request.requestOwner) {
      case "T":
        if (request.isApproved!) {
          return Lottie.asset(
            'assets/images/accept_order.json',
            width: 550.w,
            height: 400.w,
            fit: BoxFit.fill,
          );
        } else {
          return Lottie.asset(
            'assets/images/reject_order.json',
            width: 550.w,
            height: 400.w,
            fit: BoxFit.fill,
          );
        }
      case "D":
        if (request.isApproved!) {
          return Lottie.asset(
            'assets/images/accept_order.json',
            width: 550.w,
            height: 400.w,
            fit: BoxFit.fill,
          );
        } else {
          return Lottie.asset(
            'assets/images/reject_order.json',
            width: 550.w,
            height: 400.w,
            fit: BoxFit.fill,
          );
        }
      default:
        return Lottie.asset(
          'assets/images/reject_order.json',
          width: 550.w,
          height: 400.w,
          fit: BoxFit.fill,
        );
    }
  }

  Widget getExtraAction(ApprovalRequest request, BuildContext context) {
    switch (request.requestOwner) {
      case "T":
        if (request.responseTurn == "D") {
          return const SizedBox.shrink();
        } else {
          if (request.isApproved!) {
            return Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      BlocConsumer<ShipmentUpdateStatusBloc,
                          ShipmentUpdateStatusState>(
                        listener: (context, acceptstate) {
                          if (acceptstate
                              is ShipmentUpdateStatusLoadedSuccess) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ControlView(),
                                ),
                                (route) => false);
                          }
                        },
                        builder: (context, acceptstate) {
                          if (acceptstate
                              is ShipmentUpdateStatusLoadingProgress) {
                            return CustomButton(
                              title: SizedBox(
                                width: MediaQuery.of(context).size.width * .83,
                                child: Center(
                                  child: LoadingIndicator(),
                                ),
                              ),
                              onTap: () {},
                              // color: Colors.white,
                            );
                          } else {
                            return CustomButton(
                              title: SizedBox(
                                width: MediaQuery.of(context).size.width * .83,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('confirm'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    SizedBox(
                                      height: 30.w,
                                      width: 30.w,
                                      child: SvgPicture.asset(
                                        "assets/icons/white/notification_shipment_complete.svg",
                                        width: 30.w,
                                        height: 30.w,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                BlocProvider.of<ShipmentUpdateStatusBloc>(
                                        context)
                                    .add(
                                  ShipmentStatusUpdateEvent(
                                    request.subshipment!.id!,
                                    "R",
                                  ),
                                );
                              },
                              // color: Colors.white,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomButton(
                        title: SizedBox(
                          width: MediaQuery.of(context).size.width * .83,
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate("search_for_truck"),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchTruckScreen(
                                  subshipmentId: request.subshipment!.id!),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        }
      case "D":
        if (request.responseTurn == "T") {
          return const SizedBox.shrink();
        } else {
          if (request.isApproved!) {
            return Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      BlocConsumer<ShipmentUpdateStatusBloc,
                          ShipmentUpdateStatusState>(
                        listener: (context, acceptstate) {
                          if (acceptstate
                              is ShipmentUpdateStatusLoadedSuccess) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ControlView(),
                                ),
                                (route) => false);
                          }
                        },
                        builder: (context, acceptstate) {
                          if (acceptstate
                              is ShipmentUpdateStatusLoadingProgress) {
                            return CustomButton(
                              title: SizedBox(
                                width: MediaQuery.of(context).size.width * .83,
                                child: Center(
                                  child: LoadingIndicator(),
                                ),
                              ),
                              onTap: () {},
                              // color: Colors.white,
                            );
                          } else {
                            return CustomButton(
                              title: SizedBox(
                                width: MediaQuery.of(context).size.width * .83,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('confirm'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    SizedBox(
                                      height: 30.w,
                                      width: 30.w,
                                      child: SvgPicture.asset(
                                        "assets/icons/white/notification_shipment_complete.svg",
                                        width: 30.w,
                                        height: 30.w,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                BlocProvider.of<ShipmentUpdateStatusBloc>(
                                        context)
                                    .add(
                                  ShipmentStatusUpdateEvent(
                                    request.subshipment!.id!,
                                    "R",
                                  ),
                                );
                              },
                              // color: Colors.white,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      default:
        return const SizedBox.shrink();
    }
  }

  String getMainText(ApprovalRequest request) {
    switch (request.requestOwner) {
      case "T":
        if (request.responseTurn == "D") {
          return "request_waiting";
        } else {
          if (request.isApproved!) {
            return "request_confirm";
          } else {
            return "request_reject";
          }
        }
      case "D":
        if (request.responseTurn == "T") {
          return "request_waiting";
        } else {
          if (request.isApproved!) {
            return "request_confirm";
          } else {
            return "request_reject";
          }
        }
      default:
        return "request_waiting";
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
          child: SafeArea(
            child: Scaffold(
              backgroundColor: AppColor.lightGrey200,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!
                    .translate("approval_request_status"),
              ),
              body: SingleChildScrollView(
                // physics: const NeverScrollableScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height),
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlocBuilder<RequestDetailsBloc, RequestDetailsState>(
                        builder: (context, state) {
                          if (state is RequestDetailsLoadedSuccess) {
                            return (request == null
                                    ? true
                                    : (request!.responseTurn) == "D")
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        getMainPhoto(request!),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        SectionTitle(
                                          text: AppLocalizations.of(context)!
                                              .translate(
                                            getMainText(request!),
                                          ),
                                        ),
                                        getExtraAction(request!, context),
                                      ],
                                    ),
                                  )
                                : type == "A"
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Lottie.asset(
                                              'assets/images/accept_order.json',
                                              width: 550.w,
                                              height: 400.w,
                                              fit: BoxFit.fill,
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            SectionTitle(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .translate(
                                                        "request_confirm")),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  BlocConsumer<
                                                      ShipmentUpdateStatusBloc,
                                                      ShipmentUpdateStatusState>(
                                                    listener:
                                                        (context, acceptstate) {
                                                      if (acceptstate
                                                          is ShipmentUpdateStatusLoadedSuccess) {
                                                        Navigator
                                                            .pushAndRemoveUntil(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const ControlView(),
                                                                ),
                                                                (route) =>
                                                                    false);
                                                      }
                                                    },
                                                    builder:
                                                        (context, acceptstate) {
                                                      if (acceptstate
                                                          is ShipmentUpdateStatusLoadingProgress) {
                                                        return CustomButton(
                                                          title: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .83,
                                                            child: Center(
                                                              child:
                                                                  LoadingIndicator(),
                                                            ),
                                                          ),
                                                          onTap: () {},
                                                          // color: Colors.white,
                                                        );
                                                      } else {
                                                        return CustomButton(
                                                          title: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .83,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Center(
                                                                  child: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .translate(
                                                                            'confirm'),
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 16,
                                                                ),
                                                                SizedBox(
                                                                  height: 30.w,
                                                                  width: 30.w,
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    "assets/icons/white/notification_shipment_complete.svg",
                                                                    width: 30.w,
                                                                    height:
                                                                        30.w,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            BlocProvider.of<
                                                                        ShipmentUpdateStatusBloc>(
                                                                    context)
                                                                .add(
                                                              ShipmentStatusUpdateEvent(
                                                                state
                                                                    .request
                                                                    .subshipment!
                                                                    .id!,
                                                                "R",
                                                              ),
                                                            );
                                                          },
                                                          // color: Colors.white,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Lottie.asset(
                                              'assets/images/reject_order.json',
                                              width: 550.w,
                                              height: 400.w,
                                              fit: BoxFit.fill,
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            SectionBody(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .translate(
                                                        "request_reject")),
                                            state.request.reason!.isNotEmpty
                                                ? SectionBody(
                                                    text:
                                                        "${AppLocalizations.of(context)!.translate("reason")}: ${state.request.reason!} ")
                                                : const SizedBox.shrink(),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  CustomButton(
                                                    title: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .83,
                                                      child: Center(
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .translate(
                                                                  "search_for_truck"),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              SearchTruckScreen(
                                                                  subshipmentId: state
                                                                      .request
                                                                      .subshipment!
                                                                      .id!),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                          } else {
                            return Expanded(
                              child: Center(child: LoadingIndicator()),
                            );
                          }
                        },
                      ),
                      const SizedBox(
                        height: 15,
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
