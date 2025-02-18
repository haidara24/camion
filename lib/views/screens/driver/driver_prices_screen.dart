import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/bloc/delete_truck_price_bloc.dart';
import 'package:camion/business_logic/bloc/bloc/truck_prices_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/driver/add_new_price_screen.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                          ? Table(
                              columnWidths: {
                                0: const FlexColumnWidth(),
                                1: const FlexColumnWidth(),
                                2: FixedColumnWidth(150.w),
                                3: const FlexColumnWidth(),
                              },
                              border: TableBorder.all(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[400]!,
                                width: 1,
                              ),
                              children: [
                                TableRow(children: [
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.fill,
                                    child: Container(
                                      color: AppColor.lightYellow,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                              "${AppLocalizations.of(context)!.translate("governorate")} 1"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.fill,
                                    child: Container(
                                      color: AppColor.lightYellow,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                              "${AppLocalizations.of(context)!.translate("governorate")} 2"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.fill,
                                    child: Container(
                                      color: AppColor.lightYellow,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate("price")),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      color: AppColor.lightYellow,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Icon(
                                            Icons.settings,
                                            color: AppColor.darkGrey200,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                                ...List.generate(
                                  pricestate.prices.length,
                                  (index) => TableRow(children: [
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(localeState
                                                    .value.languageCode ==
                                                "en"
                                            ? pricestate.prices[index].point1En!
                                            : pricestate.prices[index].point1!),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(localeState
                                                    .value.languageCode ==
                                                "en"
                                            ? pricestate.prices[index].point2En!
                                            : pricestate.prices[index].point2!),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            "${pricestate.prices[index].value!.toString()} ${localeState.value.languageCode == "en" ? "S.P" : "ل.س"}"),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: BlocConsumer<
                                            DeleteTruckPriceBloc,
                                            DeleteTruckPriceState>(
                                          listener: (context, deletestate) {
                                            if (deletestate
                                                is DeleteTruckPriceSuccessState) {
                                              BlocProvider.of<
                                                          TruckPricesListBloc>(
                                                      context)
                                                  .add(
                                                      TruckPricesListLoadEvent());
                                            }
                                          },
                                          builder: (context, deletestate) {
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
                                                        selectedIndex = index;
                                                      });
                                                      BlocProvider.of<
                                                                  DeleteTruckPriceBloc>(
                                                              context)
                                                          .add(
                                                        DeleteTruckPriceButtonPressed(
                                                            pricestate
                                                                .prices[index]
                                                                .id!),
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.delete,
                                                      color:
                                                          AppColor.darkGrey200,
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AddNewPriceScreen(
                                                            truckId: truckId,
                                                            price: pricestate
                                                                .prices[index],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.edit,
                                                      color:
                                                          AppColor.darkGrey200,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ],
                            )
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
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate("add_price"),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColor.deepYellow,
                              ),
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
