import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/requests/driver_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/driver/incoming_shipment_details_screen.dart';
import 'package:camion/views/widgets/no_reaults_widget.dart';
import 'package:camion/views/widgets/no_truck_profile_widget.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:camion/views/widgets/shipments_widgets/shimmer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intel;
import 'package:shared_preferences/shared_preferences.dart';

class IncomingShippmentLogScreen extends StatefulWidget {
  const IncomingShippmentLogScreen({Key? key}) : super(key: key);

  @override
  State<IncomingShippmentLogScreen> createState() =>
      _IncomingShippmentLogScreenState();
}

class _IncomingShippmentLogScreenState extends State<IncomingShippmentLogScreen>
    with SingleTickerProviderStateMixin {
  var f = intel.NumberFormat("#,###", "en_US");

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
    BlocProvider.of<DriverRequestsListBloc>(context)
        .add(const DriverRequestsListLoadEvent(null));
  }

  int truckId = 0;

  void getTruckId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      truckId = prefs.getInt("truckId") ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    getTruckId();
  }

  @override
  Widget build(BuildContext context) {
    final playDuration = 600.ms;
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            body: SingleChildScrollView(
              // physics: const NeverScrollableScrollPhysics(),
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    truckId == 0
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: NoTruckProfileWidget(
                              text: AppLocalizations.of(context)!
                                  .translate("no_in_orders_no_truck_profile"),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: BlocConsumer<DriverRequestsListBloc,
                                DriverRequestsListState>(
                              listener: (context, state) {
                                print(state);
                              },
                              builder: (context, state) {
                                if (state is DriverRequestsListLoadedSuccess) {
                                  return state.requests.isEmpty
                                      ? NoResultsWidget(
                                          text: AppLocalizations.of(context)!
                                              .translate("no_in_orders"),
                                        )
                                      : ListView.builder(
                                          itemCount: state.requests.length,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: () {
                                                // BlocProvider.of<
                                                //             SubShipmentDetailsBloc>(
                                                //         context)
                                                //     .add(SubShipmentDetailsLoadEvent(
                                                //         state.requests[index]
                                                //             .subshipment!.id!));
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          IncomingShipmentDetailsScreen(
                                                        objectId: state
                                                            .requests[index]
                                                            .subshipment!
                                                            .id!,
                                                      ),
                                                    ));
                                              },
                                              child: AbsorbPointer(
                                                absorbing: false,
                                                child: Card(
                                                  color: Colors.white,
                                                  elevation: 1,
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 8,
                                                  ),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        height: 48.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: AppColor
                                                                .deepYellow,
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .vertical(
                                                            top:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          4),
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.translate("merchant_name")}: ${state.requests[index].subshipment!.firstname!} ${state.requests[index].subshipment!.lastname!}",
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  // color: AppColor.lightBlue,
                                                                  fontSize:
                                                                      17.sp,
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          4),
                                                              child: Text(
                                                                '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.requests[index].subshipment!.id!}',
                                                                style:
                                                                    TextStyle(
                                                                  // color: AppColor.lightBlue,
                                                                  fontSize:
                                                                      18.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      ShipmentPathVerticalWidget(
                                                        pathpoints: state
                                                            .requests[index]
                                                            .subshipment!
                                                            .pathpoints!,
                                                        pickupDate: state
                                                            .requests[index]
                                                            .subshipment!
                                                            .pickupDate!,
                                                        deliveryDate: state
                                                            .requests[index]
                                                            .subshipment!
                                                            .pickupDate!,
                                                        langCode: localeState
                                                            .value.languageCode,
                                                        mini: true,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                } else {
                                  return const ShimmerLoadingWidget();
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
}
