import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/managment/shipment_update_status_bloc.dart';
import 'package:camion/business_logic/bloc/requests/request_details_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
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

class ApprovalRequestDetailsScreen extends StatelessWidget {
  final String type;
  ApprovalRequestDetailsScreen({Key? key, required this.type})
      : super(key: key);

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
                            return type == "A"
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SectionTitle(
                                            text: AppLocalizations.of(context)!
                                                .translate("request_confirm")),
                                        state.request.extratext!.isNotEmpty
                                            ? SectionBody(
                                                text:
                                                    "وقد طالب ببعض التكاليف الإضافية: ")
                                            : const SizedBox.shrink(),
                                        state.request.extratext!.isNotEmpty
                                            ? SectionBody(
                                                text: state.request.extratext
                                                    .toString(),
                                              )
                                            : const SizedBox.shrink(),
                                        state.request.extratext!.isNotEmpty
                                            ? SectionBody(
                                                text: state.request.extraFees
                                                    .toString(),
                                              )
                                            : const SizedBox.shrink(),
                                        const Divider(),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
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
                                                              builder: (context) =>
                                                                  const ControlView(),
                                                            ),
                                                            (route) => false);
                                                  }
                                                },
                                                builder:
                                                    (context, acceptstate) {
                                                  if (acceptstate
                                                      is ShipmentUpdateStatusLoadingProgress) {
                                                    return CustomButton(
                                                      title: SizedBox(
                                                        width: 120.w,
                                                        child: Center(
                                                          child:
                                                              LoadingIndicator(),
                                                        ),
                                                      ),
                                                      onTap: () {},
                                                      color: Colors.white,
                                                    );
                                                  } else {
                                                    return CustomButton(
                                                      title: SizedBox(
                                                        width: 120.w,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Center(
                                                              child: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'accept'),
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 30.w,
                                                              width: 30.w,
                                                              child: SvgPicture
                                                                  .asset(
                                                                "assets/icons/white/notification_shipment_complete.svg",
                                                                width: 30.w,
                                                                height: 30.w,
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
                                : Column(
                                    children: [
                                      SectionBody(
                                          text: AppLocalizations.of(context)!
                                              .translate("request_reject")),
                                      state.request.reason!.isNotEmpty
                                          ? SectionBody(
                                              text:
                                                  "${AppLocalizations.of(context)!.translate("reason")}: ${state.request.reason!} ")
                                          : const SizedBox.shrink(),
                                      const Divider(),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            CustomButton(
                                              title: SizedBox(
                                                width: 140.w,
                                                child: Center(
                                                  child: Text(AppLocalizations
                                                          .of(context)!
                                                      .translate(
                                                          "search_for_truck")),
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
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
