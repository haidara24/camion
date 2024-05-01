import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/truck/trucks_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/truck_details_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class SelectTruckScreen extends StatelessWidget {
  final List<TextEditingController>? commodityName_controllers;
  final List<TextEditingController>? commodityWeight_controllers;
  final int? truckType;
  const SelectTruckScreen(
      {Key? key,
      required this.commodityName_controllers,
      this.commodityWeight_controllers,
      this.truckType})
      : super(key: key);

  String getTruckType(int type) {
    switch (type) {
      case 1:
        return "سطحة";
      case 2:
        return "براد";
      case 3:
        return "حاوية";
      case 4:
        return "شحن";
      case 5:
        return "قاطرة ومقطورة";
      case 6:
        return "tier";
      default:
        return "سطحة";
    }
  }

  String getEnTruckType(int type) {
    switch (type) {
      case 1:
        return "Flatbed";
      case 2:
        return "Refrigerated";
      case 3:
        return "Container";
      case 4:
        return "Semi Trailer";
      case 5:
        return "Jumbo Trailer";
      case 6:
        return "tier";
      default:
        return "FlatBed";
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
              resizeToAvoidBottomInset: false,
              backgroundColor: AppColor.lightGrey200,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.translate('search_result'),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10.h,
                      ),
                      BlocBuilder<TrucksListBloc, TrucksListState>(
                        builder: (context, state) {
                          if (state is TrucksListLoadedSuccess) {
                            return state.trucks.isEmpty
                                ? Center(
                                    child: Text(AppLocalizations.of(context)!
                                        .translate('no_tucks')),
                                  )
                                : ListView.builder(
                                    itemCount: state.trucks.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      // DateTime now = DateTime.now();
                                      // Duration diff = now
                                      //     .difference(state.offers[index].createdDate!);
                                      return InkWell(
                                        onTap: () {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) =>
                                          //         TruckDetailsScreen(
                                          //       truck: state.trucks[index],
                                          //       commodityName_controllers:
                                          //           commodityName_controllers,
                                          //       commodityWeight_controllers:
                                          //           commodityWeight_controllers,
                                          //       truckType: truckType,
                                          //     ),
                                          //   ),
                                          // );
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
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          '${AppLocalizations.of(context)!.translate('truck_type')}: ${localeState.value.languageCode == 'en' ? state.trucks[index].truckType!.name : state.trucks[index].truckType!.nameAr}',
                                                          style: TextStyle(
                                                              // color: AppColor.lightBlue,
                                                              fontSize: 18.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 7.h,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .5,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          state.trucks[index]
                                                                      .rating! >=
                                                                  1
                                                              ? Icon(
                                                                  Icons.star,
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .star_border,
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                ),
                                                          state.trucks[index]
                                                                      .rating! >=
                                                                  2
                                                              ? Icon(
                                                                  Icons.star,
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .star_border,
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                ),
                                                          state.trucks[index]
                                                                      .rating! >=
                                                                  3
                                                              ? Icon(
                                                                  Icons.star,
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .star_border,
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                ),
                                                          state.trucks[index]
                                                                      .rating! >=
                                                                  4
                                                              ? Icon(
                                                                  Icons.star,
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .star_border,
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                ),
                                                          state.trucks[index]
                                                                      .rating! ==
                                                                  5
                                                              ? Icon(
                                                                  Icons.star,
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .star_border,
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                ),
                                                          // Text(
                                                          //   '(${state.trucks[index].rating!.toString()})',
                                                          //   style: TextStyle(
                                                          //     color: AppColor
                                                          //         .deepYellow,
                                                          //     fontSize: 19,
                                                          //     fontWeight:
                                                          //         FontWeight
                                                          //             .bold,
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
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
