import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/truck/trucks_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/providers/add_shippment_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SelectTruckMultiPathScreen extends StatefulWidget {
  final Shipmentv2 shipment;
  SelectTruckMultiPathScreen({
    Key? key,
    required this.shipment,
  }) : super(key: key);

  @override
  State<SelectTruckMultiPathScreen> createState() =>
      _SelectTruckMultiPathScreenState();
}

class _SelectTruckMultiPathScreenState
    extends State<SelectTruckMultiPathScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<int> truckTypes = [];

  // getTruckTypes(int index) {
  //   truckTypes = [];
  //   for (var element in widget.shipment.subshipments![index].truckTypes!) {
  //     truckTypes.add(element.truckType!);
  //   }
  //   List<int> distinctNumbers = truckTypes.toSet().toList();
  //   setState(() {
  //     truckTypes = distinctNumbers;
  //   });
  // }

  int selectedIndex = 0;

  // Widget pathList() {
  //   return SizedBox(
  //     height: 55.h,
  //     child: ListView.builder(
  //       itemCount: widget.shipment.subshipments!.length,
  //       shrinkWrap: true,
  //       scrollDirection: Axis.horizontal,
  //       itemBuilder: (context, index) {
  //         return InkWell(
  //           onTap: () {
  //             setState(() {
  //               selectedIndex = index;
  //             });
  //             List<int> truckTypeId = [];
  //             for (var element
  //                 in widget.shipment.subshipments![index].truckTypes!) {
  //               truckTypeId.add(element.truckType!);
  //             }
  //             List<int> temp = truckTypeId.toSet().toList();
  //             BlocProvider.of<TrucksListBloc>(context)
  //                 .add(TrucksListLoadEvent(temp));
  //           },
  //           child: Container(
  //             height: 40.h,
  //             width: 60.w,
  //             margin: EdgeInsets.all(5),
  //             padding: EdgeInsets.all(5),
  //             decoration: BoxDecoration(
  //                 color: selectedIndex == index
  //                     ? AppColor.deepYellow
  //                     : Colors.grey[200],
  //                 borderRadius: BorderRadius.circular(5)),
  //             child: Center(
  //               child: Text("Path ${index + 1}"),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  @override
  void initState() {
    super.initState();
    // getTruckTypes(0);
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
              resizeToAvoidBottomInset: false,
              backgroundColor: AppColor.lightGrey200,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.translate('search_result'),
              ),
              body: SingleChildScrollView(
                child: Consumer<AddShippmentProvider>(
                    builder: (context, shipmentProvider, child) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10.h,
                        ),
                        TextFormField(
                          controller: _searchController,
                          onTap: () {
                            _searchController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset:
                                    _searchController.value.text.length);
                          },
                          style: TextStyle(fontSize: 18.sp),
                          scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom +
                                  50),
                          decoration: InputDecoration(
                            // labelText: AppLocalizations.of(context)!
                            //     .translate('search'),
                            hintText: "البحث عن طريق رقم الشاحنة",
                            hintStyle: TextStyle(fontSize: 18.sp),
                            suffixIcon: InkWell(
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();

                                if (_searchController.text.isNotEmpty) {
                                  BlocProvider.of<TrucksListBloc>(context).add(
                                      TrucksListSearchEvent(
                                          _searchController.text));
                                }
                              },
                              child: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              // setState(() {
                              //   isSearch = false;
                              // });
                            }
                          },
                          onFieldSubmitted: (value) {
                            _searchController.text = value;
                            if (value.isNotEmpty) {
                              BlocProvider.of<TrucksListBloc>(context).add(
                                  TrucksListSearchEvent(
                                      _searchController.text));
                            }
                          },
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        BlocBuilder<TrucksListBloc, TrucksListState>(
                          builder: (context, state) {
                            if (state is TrucksListLoadedSuccess) {
                              return state.trucks.isEmpty
                                  ? Center(
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 100,
                                          ),
                                          SizedBox(
                                            height: 100,
                                            width: 100,
                                            child: SvgPicture.asset(
                                                "assets/icons/orange/search_for_truck.svg"),
                                          ),
                                          const Text(
                                            "ابحث عن شاحنة",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: state.trucks.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            shipmentProvider
                                                .setTruck(state.trucks[index]);
                                            Navigator.pop(context);
                                          },
                                          child: Card(
                                            elevation: 1,
                                            clipBehavior: Clip.antiAlias,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 5),
                                            color: Colors.white,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Image.network(
                                                  state.trucks[index].images![0]
                                                      .image!,
                                                  height: 175.h,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      height: 175.h,
                                                      width: double.infinity,
                                                      color: Colors.grey[300],
                                                      child: const Center(
                                                        child: Text(
                                                            "error on loading "),
                                                      ),
                                                    );
                                                  },
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }

                                                    return SizedBox(
                                                      height: 175.h,
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes!
                                                              : null,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                SizedBox(
                                                  height: 7.h,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'اسم السائق: ${state.trucks[index].truckuser!.usertruck!.firstName} ${state.trucks[index].truckuser!.usertruck!.lastName}',
                                                        style: TextStyle(
                                                            // color: AppColor.lightBlue,
                                                            fontSize: 18.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        height: 7.h,
                                                      ),
                                                      Text(
                                                        'وزن الشاحنة الفارغ: ${state.trucks[index].emptyWeight}',
                                                        style: TextStyle(
                                                            // color: AppColor.lightBlue,
                                                            fontSize: 18.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        height: 7.h,
                                                      ),
                                                      Text(
                                                        '${AppLocalizations.of(context)!.translate('truck_number')}: ${state.trucks[index].truckNumber}',
                                                        style: TextStyle(
                                                            // color: AppColor.lightBlue,
                                                            fontSize: 18.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        height: 7.h,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 5),
                                        height: 250.h,
                                        width: double.infinity,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
