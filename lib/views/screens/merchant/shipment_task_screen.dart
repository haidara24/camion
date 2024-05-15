import 'dart:convert';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/instructions/read_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/active_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_running_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/data/models/shipment_model.dart';
import 'package:camion/data/providers/shipment_instructions_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/merchant/shipment_task_details_screen.dart';
import 'package:camion/views/widgets/shipment_path_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timelines/timelines.dart';

class ShipmentTaskScreen extends StatefulWidget {
  ShipmentTaskScreen({Key? key}) : super(key: key);

  @override
  State<ShipmentTaskScreen> createState() => _ShipmentTaskScreenState();
}

class _ShipmentTaskScreenState extends State<ShipmentTaskScreen>
    with SingleTickerProviderStateMixin {
  ShipmentInstructionsProvider? instructionsProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      instructionsProvider =
          Provider.of<ShipmentInstructionsProvider>(context, listen: false);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String setLoadDate(DateTime date) {
    List months = [
      'jan',
      'feb',
      'mar',
      'april',
      'may',
      'jun',
      'july',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec'
    ];
    var mon = date.month;
    var month = months[mon - 1];

    var result = '${date.day}-$month-${date.year}';
    return result;
  }

  String getOfferStatus(String offer) {
    switch (offer) {
      case "P":
        return "معلقة";
      case "R":
        return "جارية";
      case "C":
        return "مكتملة";
      case "F":
        return "مرفوضة";
      default:
        return "خطأ";
    }
  }

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

  String diffEnText(Duration diff) {
    if (diff.inSeconds < 60) {
      return "since ${diff.inSeconds.toString()} seconds";
    } else if (diff.inMinutes < 60) {
      return "since ${diff.inMinutes.toString()} minutes";
    } else if (diff.inHours < 24) {
      return "since ${diff.inHours.toString()} hours";
    } else {
      return "since ${diff.inDays.toString()} days";
    }
  }

  Future<void> onRefresh() async {
    BlocProvider.of<ShipmentRunningBloc>(context)
        .add(ShipmentRunningLoadEvent("R"));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColor.lightGrey200,
            body: RefreshIndicator(
              onRefresh: onRefresh,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 10.0,
                      ),
                      child: BlocBuilder<ShipmentRunningBloc,
                          ShipmentRunningState>(
                        builder: (context, state) {
                          if (state is ShipmentRunningLoadedSuccess) {
                            return state.shipments.isEmpty
                                ? ListView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .75,
                                        child: Center(
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate('no_shipments')),
                                        ),
                                      )
                                    ],
                                  )
                                : ListView.builder(
                                    itemCount: state.shipments.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      // DateTime now = DateTime.now();
                                      // Duration diff = now
                                      //     .difference(state.offers[index].createdDate!);
                                      return InkWell(
                                        onTap: () {
                                          if (state
                                                  .shipments[index]
                                                  .subshipments![0]
                                                  .shipmentinstructionv2 !=
                                              null) {
                                            BlocProvider.of<
                                                        ReadInstructionBloc>(
                                                    context)
                                                .add(ReadInstructionLoadEvent(
                                                    state
                                                        .shipments[index]
                                                        .subshipments![0]
                                                        .shipmentinstructionv2!));

                                            print(state
                                                .shipments[index]
                                                .subshipments![0]
                                                .shipmentinstructionv2!
                                                .toString());
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ShipmentTaskDetailsScreen(
                                                shipment:
                                                    state.shipments[index],
                                              ),
                                            ),
                                          );
                                          instructionsProvider!.setSubShipment(
                                              state.shipments[index]
                                                  .subshipments![0],
                                              0);
                                        },
                                        child: Card(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5.h),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.shipments[index].id!}',
                                                    style: TextStyle(
                                                        // color: AppColor.lightBlue,
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 7.h,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      ShipmentPathWidget(
                                                        loadDate: setLoadDate(
                                                            state
                                                                .shipments[
                                                                    index]
                                                                .subshipments![
                                                                    0]
                                                                .pickupDate!),
                                                        pickupName: state
                                                            .shipments[index]
                                                            .subshipments![0]
                                                            .pathpoints!
                                                            .singleWhere(
                                                                (element) =>
                                                                    element
                                                                        .pointType ==
                                                                    "P")
                                                            .name!,
                                                        deliveryName: state
                                                            .shipments[index]
                                                            .subshipments![0]
                                                            .pathpoints!
                                                            .singleWhere(
                                                                (element) =>
                                                                    element
                                                                        .pointType ==
                                                                    "P")
                                                            .name!,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .8,
                                                        pathwidth:
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .7,
                                                      ).animate().slideX(
                                                          duration: 300.ms,
                                                          delay: 0.ms,
                                                          begin: 1,
                                                          end: 0,
                                                          curve: Curves
                                                              .easeInOutSine),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 7.h,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Text(
                                                            '${AppLocalizations.of(context)!.translate('commodity_type')}: ${state.shipments[index].subshipments![0].shipmentItems![0].commodityName!}',
                                                            style: TextStyle(
                                                              // color: AppColor.lightBlue,
                                                              fontSize: 17.sp,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 7.h,
                                                          ),
                                                          Text(
                                                            '${AppLocalizations.of(context)!.translate('commodity_weight')}: ${state.shipments[index].subshipments![0].shipmentItems![0].commodityWeight!} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}',
                                                            style: TextStyle(
                                                              // color: AppColor.lightBlue,
                                                              fontSize: 17.sp,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        height: 65.h,
                                                        width: 75.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Center(
                                                          child: Stack(
                                                            clipBehavior:
                                                                Clip.none,
                                                            children: [
                                                              Card(
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5)),
                                                                elevation: 2,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Center(
                                                                    child: Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .translate(
                                                                              'tasks'),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              // getunfinishedTasks(
                                                              //             state.shipments[
                                                              //                 index]) >
                                                              //         0
                                                              //     ? Positioned(
                                                              //         right: localeState.value.languageCode ==
                                                              //                 'en'
                                                              //             ? 0
                                                              //             : null,
                                                              //         left: localeState.value.languageCode ==
                                                              //                 'en'
                                                              //             ? null
                                                              //             : 0,
                                                              //         child:
                                                              //             Container(
                                                              //           height:
                                                              //               25,
                                                              //           width:
                                                              //               25,
                                                              //           decoration:
                                                              //               BoxDecoration(
                                                              //             color:
                                                              //                 Colors.red,
                                                              //             borderRadius:
                                                              //                 BorderRadius.circular(45),
                                                              //           ),
                                                              //           child:
                                                              //               Center(
                                                              //             child: Text(
                                                              //                 getunfinishedTasks(state.shipments[index]).toString(),
                                                              //                 style: TextStyle(
                                                              //                   color: Colors.white,
                                                              //                 )),
                                                              //           ),
                                                              //         ),
                                                              //       )
                                                              //     : const SizedBox
                                                              //         .shrink(),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ).animate().slideX(
                                            duration: 350.ms,
                                            delay: 0.ms,
                                            begin: 1,
                                            end: 0,
                                            curve: Curves.easeInOutSine),
                                      );
                                    },
                                  );
                          } else {
                            return Shimmer.fromColors(
                              baseColor: (Colors.grey[300])!,
                              highlightColor: (Colors.grey[100])!,
                              enabled: true,
                              direction: ShimmerDirection.ttb,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemBuilder: (_, __) => Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      height: 250.h,
                                      width: double.infinity,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                                itemCount: 6,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int getunfinishedTasks(Shipment shipment) {
    var count = 0;
    if (shipment.shipmentinstruction == null) {
      count++;
    }
    if (shipment.shipmentpayment == null) {
      count++;
    }
    return count;
  }
}
