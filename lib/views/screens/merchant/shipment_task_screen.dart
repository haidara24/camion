import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/instructions/read_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/read_payment_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_running_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_task_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/providers/shipment_instructions_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/merchant/shipment_task_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';

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
    BlocProvider.of<ShipmentTaskListBloc>(context)
        .add(ShipmentTaskListLoadEvent());
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
            backgroundColor: Colors.grey[100],
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
                      child: BlocBuilder<ShipmentTaskListBloc,
                          ShipmentTaskListState>(
                        builder: (context, state) {
                          if (state is ShipmentTaskListLoadedSuccess) {
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
                                      return InkWell(
                                        onTap: () {
                                          if (state.shipments[index]
                                                  .shipmentinstructionv2 !=
                                              null) {
                                            BlocProvider.of<
                                                        ReadInstructionBloc>(
                                                    context)
                                                .add(ReadInstructionLoadEvent(
                                                    state.shipments[index]
                                                        .shipmentinstructionv2!));
                                          }
                                          if (state.shipments[index]
                                                  .shipmentpaymentv2 !=
                                              null) {
                                            BlocProvider.of<
                                                        ReadPaymentInstructionBloc>(
                                                    context)
                                                .add(ReadPaymentInstructionLoadEvent(
                                                    state.shipments[index]
                                                        .shipmentpaymentv2!));
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
                                              state.shipments[index], 0);
                                        },
                                        child: AbsorbPointer(
                                          absorbing: false,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4.0,
                                            ),
                                            child: Card(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    height: 48.h,
                                                    color: Colors.grey[300],
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 12,
                                                          ),
                                                          child: Text(
                                                            "${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.shipments[index].shipment!}",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              // color: AppColor.lightBlue,
                                                              fontSize: 17.sp,
                                                            ),
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Container(
                                                          height: 65.h,
                                                          width: 47.w,
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Center(
                                                            child: Stack(
                                                              clipBehavior:
                                                                  Clip.none,
                                                              children: [
                                                                Center(
                                                                  child:
                                                                      SizedBox(
                                                                    height:
                                                                        40.h,
                                                                    width: 40.h,
                                                                    child:
                                                                        Center(
                                                                      child: SvgPicture
                                                                          .asset(
                                                                              "assets/icons/notification.svg"),
                                                                    ),
                                                                  ),
                                                                ),
                                                                getunfinishedTasks(
                                                                            state.shipments[index]) >
                                                                        0
                                                                    ? Positioned(
                                                                        right: localeState.value.languageCode ==
                                                                                'en'
                                                                            ? 0
                                                                            : null,
                                                                        left: localeState.value.languageCode ==
                                                                                'en'
                                                                            ? null
                                                                            : 0,
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              20,
                                                                          width:
                                                                              20,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                AppColor.deepYellow,
                                                                            borderRadius:
                                                                                BorderRadius.circular(45),
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child: Text(getunfinishedTasks(state.shipments[index]).toString(),
                                                                                style: const TextStyle(
                                                                                  color: Colors.white,
                                                                                )),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Positioned(
                                                                        right: localeState.value.languageCode ==
                                                                                'en'
                                                                            ? 0
                                                                            : null,
                                                                        left: localeState.value.languageCode ==
                                                                                'en'
                                                                            ? null
                                                                            : 0,
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              20,
                                                                          width:
                                                                              20,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.green,
                                                                            borderRadius:
                                                                                BorderRadius.circular(45),
                                                                          ),
                                                                          child:
                                                                              const Center(
                                                                            child:
                                                                                Icon(
                                                                              Icons.check,
                                                                              color: Colors.white,
                                                                              size: 15,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  ShipmentPathVerticalWidget(
                                                    pathpoints: state
                                                        .shipments[index]
                                                        .pathpoints!,
                                                    pickupDate: state
                                                        .shipments[index]
                                                        .pickupDate!,
                                                    deliveryDate: state
                                                        .shipments[index]
                                                        .deliveryDate!,
                                                    langCode: localeState
                                                        .value.languageCode,
                                                    mini: true,
                                                  ),
                                                ],
                                              ),
                                            ).animate().slideX(
                                                duration: 350.ms,
                                                delay: 0.ms,
                                                begin: 1,
                                                end: 0,
                                                curve: Curves.easeInOutSine),
                                          ),
                                        ),
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

  int getunfinishedTasks(SubShipment shipment) {
    var count = 0;
    if (shipment.shipmentinstructionv2 == null) {
      count++;
    }
    if (shipment.shipmentpaymentv2 == null) {
      count++;
    }
    return count;
  }
}
