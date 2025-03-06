import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/bloc/delete_truck_price_bloc.dart';
import 'package:camion/business_logic/bloc/bloc/truck_prices_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/driver/add_new_price_screen.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart' as intel;

class DriverPricesScreen extends StatefulWidget {
  const DriverPricesScreen({super.key});

  @override
  State<DriverPricesScreen> createState() => _DriverPricesScreenState();
}

class _DriverPricesScreenState extends State<DriverPricesScreen> {
  int truckId = 0;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTruckId();
  }

  Future<void> _loadTruckId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      truckId = prefs.getInt('truckId') ??
          0; // Assuming 'truckId' is the key used to store the value
    });
  }

  var f = intel.NumberFormat("#,###", "en_US");

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
      return SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocConsumer<TruckPricesListBloc, TruckPricesListState>(
              listener: (context, state) {
                // TODO: implement listener
              },
              builder: (context, pricestate) {
                if (pricestate is TruckPricesListLoadedSuccess) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 8.h,
                      ),
                      pricestate.prices.isNotEmpty
                          ? ListView.builder(
                              itemCount: pricestate.prices.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return AbsorbPointer(
                                  absorbing: false,
                                  child: Card(
                                    color: AppColor.lightYellow,
                                    elevation: 1,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      side: BorderSide(
                                        color: AppColor.deepYellow,
                                        width: 2,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const SectionTitle(
                                                  text: "سعر التكلفة"),
                                              BlocConsumer<DeleteTruckPriceBloc,
                                                  DeleteTruckPriceState>(
                                                listener:
                                                    (context, deletestate) {
                                                  if (deletestate
                                                      is DeleteTruckPriceSuccessState) {
                                                    BlocProvider.of<
                                                                TruckPricesListBloc>(
                                                            context)
                                                        .add(
                                                            TruckPricesListLoadEvent());
                                                  }
                                                },
                                                builder:
                                                    (context, deletestate) {
                                                  if (deletestate
                                                          is DeleteTruckPriceLoadingProgressState &&
                                                      selectedIndex == index) {
                                                    return LoadingIndicator();
                                                  } else {
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              selectedIndex =
                                                                  index;
                                                            });
                                                            BlocProvider.of<
                                                                        DeleteTruckPriceBloc>(
                                                                    context)
                                                                .add(
                                                              DeleteTruckPriceButtonPressed(
                                                                  pricestate
                                                                      .prices[
                                                                          index]
                                                                      .id!),
                                                            );
                                                          },
                                                          child: SizedBox(
                                                            height: 25.h,
                                                            width: 25.h,
                                                            child: SvgPicture.asset(
                                                                "assets/icons/delete.svg"),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4.h),
                                          Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .28,
                                                  height: 80.h,
                                                  child: TimelineTile(
                                                    isLast: true,
                                                    isFirst: false,
                                                    axis:
                                                        TimelineAxis.horizontal,
                                                    beforeLineStyle: LineStyle(
                                                      color:
                                                          AppColor.deepYellow,
                                                    ),
                                                    indicatorStyle:
                                                        IndicatorStyle(
                                                      width: 28
                                                          .h, // Match the size of your custom container
                                                      height: 28
                                                          .h, // Ensure height matches as well
                                                      indicator: Container(
                                                        height: 28.h,
                                                        width: 28.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: AppColor
                                                                .deepYellow,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(45),
                                                          color: AppColor
                                                              .deepBlack,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "A",
                                                            style: TextStyle(
                                                              fontSize: 15
                                                                  .sp, // Adjust font size as needed
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // afterLineStyle: LineStyle(),
                                                    alignment:
                                                        TimelineAlign.manual,
                                                    lineXY: .5,
                                                    startChild: SectionBody(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .translate(
                                                              "pickup_address"),
                                                    ),
                                                    endChild: SectionBody(
                                                      text:
                                                          "  ${localeState.value.languageCode == "en" ? pricestate.prices[index].point1En : pricestate.prices[index].point1}",
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .28,
                                                  height: 80.h,
                                                  child: TimelineTile(
                                                    isLast: false,
                                                    isFirst: false,
                                                    axis:
                                                        TimelineAxis.horizontal,
                                                    beforeLineStyle: LineStyle(
                                                      color:
                                                          AppColor.deepYellow,
                                                    ),
                                                    hasIndicator: false,
                                                    alignment:
                                                        TimelineAlign.manual,
                                                    lineXY: .5,
                                                    startChild:
                                                        const SectionBody(
                                                      text: " ",
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .28,
                                                  height: 80.h,
                                                  child: TimelineTile(
                                                    isLast: false,
                                                    isFirst: true,
                                                    axis:
                                                        TimelineAxis.horizontal,
                                                    beforeLineStyle: LineStyle(
                                                      color:
                                                          AppColor.deepYellow,
                                                    ),
                                                    indicatorStyle:
                                                        IndicatorStyle(
                                                      width: 28
                                                          .h, // Match the size of your custom container
                                                      height: 28
                                                          .h, // Ensure height matches as well
                                                      indicator: Container(
                                                        height: 28.h,
                                                        width: 28.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: AppColor
                                                                .deepYellow,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(45),
                                                          color: AppColor
                                                              .deepBlack,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "B",
                                                            style: TextStyle(
                                                              fontSize: 15
                                                                  .sp, // Adjust font size as needed
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // afterLineStyle: LineStyle(),
                                                    alignment:
                                                        TimelineAlign.manual,
                                                    lineXY: .5,

                                                    endChild: SectionBody(
                                                      text:
                                                          "  ${localeState.value.languageCode == "en" ? pricestate.prices[index].point2En : pricestate.prices[index].point2}",
                                                    ),
                                                    startChild: SectionBody(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .translate(
                                                              "delivery_address"),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                child: Container(
                                                  width: 190.w,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: Colors.white,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        AddNewPriceScreen(
                                                                  truckId:
                                                                      truckId,
                                                                  price: pricestate
                                                                          .prices[
                                                                      index],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: SizedBox(
                                                            height: 25.h,
                                                            width: 25.h,
                                                            child: SvgPicture.asset(
                                                                "assets/icons/edit.svg"),
                                                          ),
                                                        ),
                                                        SectionTitle(
                                                          text:
                                                              "${f.format(pricestate.prices[index].value!)} ${localeState.value.languageCode == "en" ? "S.P" : "ل.س"}",
                                                        ),
                                                        SizedBox(
                                                          height: 25.h,
                                                          width: 25.h,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              })
                          : const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "لم يتم إضافة أية أسعار",
                              ),
                            ),
                      SizedBox(
                        height: 8.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              // shipmentProvider
                              //     .additem(
                              //         selectedIndex);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddNewPriceScreen(truckId: truckId),
                                ),
                              );
                            },
                            child: SectionTitle(
                              text: AppLocalizations.of(context)!
                                  .translate("add_price"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(child: LoadingIndicator()),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      );
    });
  }
}
