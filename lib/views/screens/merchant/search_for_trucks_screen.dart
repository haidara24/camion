import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_multi_create_bloc.dart';
import 'package:camion/business_logic/bloc/truck/trucks_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/providers/add_multi_shipment_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/screens/truck_details_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart' as intel;
import 'package:timeline_tile/timeline_tile.dart';

class SearchForTrucksScreen extends StatefulWidget {
  SearchForTrucksScreen({Key? key}) : super(key: key);

  @override
  State<SearchForTrucksScreen> createState() => _SearchForTrucksScreenState();
}

class _SearchForTrucksScreenState extends State<SearchForTrucksScreen> {
  int selectedIndex = 0;

  int truckNum = -1;

  int calculatePrice(
    double distance,
    double weight,
  ) {
    double result = 0.0;
    result = distance * (weight / 1000) * 550;
    return result.toInt();
  }

  var f = intel.NumberFormat("#,###", "en_US");

  Widget selectedTrucksList(
      AddMultiShipmentProvider provider, BuildContext context, String lang) {
    List<KTruck> trucks = [];
    for (var element in provider.selectedTruck) {
      trucks.add(element);
    }
    return trucks.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            height: 105.h,
            child: ListView.builder(
              itemCount: trucks.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  // width: 130.w,
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppColor.deepYellow,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 45.h,
                        width: 155.w,
                        child: CachedNetworkImage(
                          imageUrl: trucks[index].truckType!.image!,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  Shimmer.fromColors(
                            baseColor: (Colors.grey[300])!,
                            highlightColor: (Colors.grey[100])!,
                            enabled: true,
                            child: Container(
                              height: 45.h,
                              width: 155.w,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 45.h,
                            width: 155.w,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(AppLocalizations.of(context)!
                                  .translate('image_load_error')),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      Center(
                        child: SectionBody(
                          text:
                              "${trucks[index].driver_firstname!} ${trucks[index].driver_lastname!}",
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }

  Widget truckTypeList(
      AddMultiShipmentProvider provider, BuildContext context, String lang) {
    return SizedBox(
      height: 105.h,
      child: ListView.builder(
        itemCount: provider.truckTypeGroup.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Container(
            // width: 130.w,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: AppColor.deepYellow,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 45.h,
                  width: 155.w,
                  child: CachedNetworkImage(
                    imageUrl: provider.truckTypeGroup[index].image!,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Shimmer.fromColors(
                      baseColor: (Colors.grey[300])!,
                      highlightColor: (Colors.grey[100])!,
                      enabled: true,
                      child: Container(
                        height: 45.h,
                        width: 155.w,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 45.h,
                      width: 155.w,
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(AppLocalizations.of(context)!
                            .translate('image_load_error')),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SectionBody(
                      text: "${provider.truckTypeGroup[index].nameAr!} ",
                    ),
                    SectionBody(
                      text: "${provider.selectedTruckTypeNum[index]} ",
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: AppColor.deepBlack, // Make status bar transparent
              statusBarIconBrightness:
                  Brightness.light, // Light icons for dark backgrounds
              systemNavigationBarColor: Colors.grey[200], // Works on Android
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: SafeArea(
              child: Consumer<AddMultiShipmentProvider>(
                builder: (context, shipmentProvider, child) {
                  return Scaffold(
                    backgroundColor: Colors.grey[100],
                    appBar: CustomAppBar(
                      title: AppLocalizations.of(context)!
                          .translate('search_for_truck'),
                    ),
                    body: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .32,
                                      height: 80.h,
                                      child: TimelineTile(
                                        isLast: true,
                                        isFirst: false,
                                        axis: TimelineAxis.horizontal,
                                        beforeLineStyle: LineStyle(
                                          color: AppColor.deepYellow,
                                        ),
                                        indicatorStyle: IndicatorStyle(
                                          width: 28
                                              .h, // Match the size of your custom container
                                          height: 28
                                              .h, // Ensure height matches as well
                                          indicator: Container(
                                            height: 28.h,
                                            width: 28.h,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColor.deepYellow,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(45),
                                              color: AppColor.deepBlack,
                                            ),
                                            child: const Center(
                                              child: Text(
                                                "A",
                                                style: TextStyle(
                                                  fontSize:
                                                      15, // Adjust font size as needed
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // afterLineStyle: LineStyle(),
                                        alignment: TimelineAlign.manual,
                                        lineXY: .5,
                                        startChild: SectionBody(
                                          text: AppLocalizations.of(context)!
                                              .translate("pickup_address"),
                                        ),
                                        endChild: SectionBody(
                                          text:
                                              "  ${shipmentProvider.stoppoints_statename.first}",
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .32,
                                      height: 80.h,
                                      child: TimelineTile(
                                        isLast: false,
                                        isFirst: false,
                                        axis: TimelineAxis.horizontal,
                                        beforeLineStyle: LineStyle(
                                          color: AppColor.deepYellow,
                                        ),
                                        hasIndicator: false,
                                        alignment: TimelineAlign.manual,
                                        lineXY: .5,
                                        startChild: SectionBody(
                                          text:
                                              "  ${shipmentProvider.distance} ${localeState.value.languageCode == "en" ? "km" : "كم"}",
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .32,
                                      height: 80.h,
                                      child: TimelineTile(
                                        isLast: false,
                                        isFirst: true,
                                        axis: TimelineAxis.horizontal,
                                        beforeLineStyle: LineStyle(
                                          color: AppColor.deepYellow,
                                        ),
                                        indicatorStyle: IndicatorStyle(
                                          width: 28
                                              .h, // Match the size of your custom container
                                          height: 28
                                              .h, // Ensure height matches as well
                                          indicator: Container(
                                            height: 28.h,
                                            width: 28.h,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColor.deepYellow,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(45),
                                              color: AppColor.deepBlack,
                                            ),
                                            child: const Center(
                                              child: Text(
                                                "B",
                                                style: TextStyle(
                                                  fontSize:
                                                      15, // Adjust font size as needed
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // afterLineStyle: LineStyle(),
                                        alignment: TimelineAlign.manual,
                                        lineXY: .5,

                                        endChild: SectionBody(
                                          text:
                                              "  ${shipmentProvider.stoppoints_statename.last}",
                                        ),
                                        startChild: SectionBody(
                                          text: AppLocalizations.of(context)!
                                              .translate("delivery_address"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            Visibility(
                              visible:
                                  !(shipmentProvider.selectedTruckType.length ==
                                      1),
                              replacement: const SizedBox.shrink(),
                              child: truckTypeList(shipmentProvider, context,
                                  localeState.value.languageCode),
                            ),
                            BlocConsumer<TrucksListBloc, TrucksListState>(
                              listener: (context, state) {
                                if (state is TrucksListLoadedSuccess) {
                                  setState(() {
                                    truckNum = state.trucks.length;
                                  });
                                }
                              },
                              builder: (context, state) {
                                if (state is TrucksListLoadedSuccess) {
                                  return state.trucks.isEmpty
                                      ? Expanded(
                                          child: Center(
                                            child: Column(
                                              children: [
                                                const SizedBox(
                                                  height: 100,
                                                ),
                                                SizedBox(
                                                  height: 100,
                                                  width: 100,
                                                  child: SvgPicture.asset(
                                                      "assets/icons/grey/search_for_truck.svg"),
                                                ),
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .translate('no_trucks'),
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Expanded(
                                          child: ListView.builder(
                                            itemCount: state.trucks.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              return StatefulBuilder(builder:
                                                  (context, menuSetState) {
                                                final isSelected =
                                                    shipmentProvider
                                                        .selectedTruckId
                                                        .contains(state
                                                            .trucks[index].id);

                                                return Column(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        if (!(shipmentProvider
                                                                .selectedTruckType
                                                                .length ==
                                                            1)) {
                                                          isSelected
                                                              ? shipmentProvider
                                                                  .removeSelectedTruck(
                                                                  state.trucks[
                                                                      index],
                                                                  state
                                                                      .trucks[
                                                                          index]
                                                                      .truckType!
                                                                      .id!,
                                                                )
                                                              : shipmentProvider
                                                                  .addSelectedTruck(
                                                                  state.trucks[
                                                                      index],
                                                                  state
                                                                      .trucks[
                                                                          index]
                                                                      .truckType!
                                                                      .id!,
                                                                );
                                                        } else {
                                                          isSelected
                                                              ? shipmentProvider
                                                                  .removeSingleSelectedTruck(
                                                                  state.trucks[
                                                                      index],
                                                                  state
                                                                      .trucks[
                                                                          index]
                                                                      .truckType!
                                                                      .id!,
                                                                )
                                                              : shipmentProvider
                                                                  .addSingleSelectedTruck(
                                                                  state.trucks[
                                                                      index],
                                                                  state
                                                                      .trucks[
                                                                          index]
                                                                      .truckType!
                                                                      .id!,
                                                                );
                                                        }

                                                        menuSetState(() {});
                                                      },
                                                      child: Card(
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        color: Colors.white,
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                          horizontal: 16,
                                                          vertical: 10,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4),
                                                              child: (isSelected)
                                                                  ? Icon(
                                                                      Icons
                                                                          .check_box_outlined,
                                                                      color: AppColor
                                                                          .deepYellow,
                                                                    )
                                                                  : const Icon(
                                                                      Icons
                                                                          .check_box_outline_blank,
                                                                    ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 8.0,
                                                              ),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  SizedBox(
                                                                    width:
                                                                        200.w,
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        SectionTitle(
                                                                          size:
                                                                              16,
                                                                          text:
                                                                              '${AppLocalizations.of(context)!.translate('driver_name')}: ${state.trucks[index].driver_firstname} ${state.trucks[index].driver_lastname}',
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            SectionTitle(
                                                                              size: 16,
                                                                              text: '${AppLocalizations.of(context)!.translate('distance_from_loading')}: ${state.trucks[index].distance} ${localeState.value.languageCode == "en" ? "km" : "كم"}',
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SectionTitle(
                                                                          size:
                                                                              16,
                                                                          text:
                                                                              '${AppLocalizations.of(context)!.translate('truck_type')}: ${localeState.value.languageCode == "en" ? state.trucks[index].truckType!.name : state.trucks[index].truckType!.nameAr} ',
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        100.h,
                                                                    width: 16,
                                                                    child:
                                                                        const VerticalDivider(
                                                                      color: Colors
                                                                          .grey,
                                                                      thickness:
                                                                          1,
                                                                      width: 1,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        ((state.trucks[index].private_price != null && state.trucks[index].private_price! > 0) &&
                                                                                (state.trucks[index].private_price! < calculatePrice(shipmentProvider.distance, shipmentProvider.totalWeight[0])))
                                                                            ? Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  SectionTitle(
                                                                                    size: 20,
                                                                                    text: '${f.format(state.trucks[index].private_price)} ${localeState.value.languageCode == "en" ? "S.P" : "ل.س"}',
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 8,
                                                                                  ),
                                                                                  Text(
                                                                                    '${f.format(calculatePrice(shipmentProvider.distance, shipmentProvider.totalWeight[0]))}  ${localeState.value.languageCode == "en" ? "S.P" : "ل.س"}',
                                                                                    style: const TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontSize: 16,
                                                                                      decoration: TextDecoration.lineThrough,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            : SectionTitle(
                                                                                size: 20,
                                                                                text: '${f.format(calculatePrice(shipmentProvider.distance, shipmentProvider.totalWeight[0]))} ${localeState.value.languageCode == "en" ? "S.P" : "ل.س"}',
                                                                              ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                TruckDetailsScreen(
                                                                          truck:
                                                                              state.trucks[index],
                                                                          index:
                                                                              0,
                                                                          ops:
                                                                              'create_shipment',
                                                                          subshipmentId:
                                                                              0,
                                                                          distance:
                                                                              shipmentProvider.distance,
                                                                          weight:
                                                                              shipmentProvider.totalWeight[0],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .translate(
                                                                            "details"),
                                                                    style:
                                                                        TextStyle(
                                                                      color: AppColor
                                                                          .deepYellow,
                                                                      // fontSize:
                                                                      //     17,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    index ==
                                                            state.trucks
                                                                    .length -
                                                                1
                                                        ? SizedBox(
                                                            height: 80.h,
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
                                                  ],
                                                );
                                              });
                                            },
                                          ),
                                        );
                                } else {
                                  return Expanded(
                                    child: Shimmer.fromColors(
                                      baseColor: (Colors.grey[300])!,
                                      highlightColor: (Colors.grey[100])!,
                                      enabled: true,
                                      direction: ShimmerDirection.ttb,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemBuilder: (_, __) => Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 5),
                                              height: 150.h,
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
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            height: 80.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                top: BorderSide(
                                    color: AppColor.lightGrey, width: 2),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  BlocConsumer<ShipmentMultiCreateBloc,
                                      ShipmentMultiCreateState>(
                                    listener: (context, state) {
                                      if (state
                                          is ShipmentMultiCreateSuccessState) {
                                        showCustomSnackBar(
                                          context: context,
                                          backgroundColor: AppColor.deepGreen,
                                          message: AppLocalizations.of(context)!
                                              .translate(
                                                  'shipment_created_success'),
                                        );
                                        shipmentProvider.initForm();
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ControlView(),
                                          ),
                                          (route) => false,
                                        );
                                      }
                                      if (state
                                          is ShipmentMultiCreateFailureState) {
                                        showCustomSnackBar(
                                          context: context,
                                          backgroundColor: Colors.red[300]!,
                                          message: state.errorMessage,
                                        );
                                        print(state.errorMessage);
                                      }
                                    },
                                    builder: (context, btnstate) {
                                      if (btnstate
                                          is ShippmentLoadingProgressState) {
                                        return SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .92,
                                          child: CustomButton(
                                            title: LoadingIndicator(),
                                            onTap: () {},
                                          ),
                                        );
                                      } else {
                                        return SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .92,
                                          child: CustomButton(
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .translate(truckNum == 0
                                                      ? 'leave_it_public'
                                                      : 'send_request'),
                                              style: TextStyle(
                                                fontSize: 20.sp,
                                              ),
                                            ),
                                            onTap: () {
                                              if (true) {
                                                List<SubShipment>
                                                    subshipmentsitems = [];

                                                List<PathPoint> points = [];

                                                for (var s = 0;
                                                    s <
                                                        shipmentProvider
                                                            .stoppoints_controller
                                                            .length;
                                                    s++) {
                                                  if (s == 0) {
                                                    points.add(
                                                      PathPoint(
                                                        pointType: "P",
                                                        location:
                                                            "${shipmentProvider.stoppoints_latlng[s]!.latitude},${shipmentProvider.stoppoints_latlng[s]!.longitude}",
                                                        name: shipmentProvider
                                                            .stoppoints_controller[
                                                                s]
                                                            .text,
                                                        nameEn: "",
                                                        number: 0,
                                                        city: 1,
                                                      ),
                                                    );
                                                  } else if (s ==
                                                      shipmentProvider
                                                              .stoppoints_controller
                                                              .length -
                                                          1) {
                                                    points.add(
                                                      PathPoint(
                                                        pointType: "D",
                                                        location:
                                                            "${shipmentProvider.stoppoints_latlng[s]!.latitude},${shipmentProvider.stoppoints_latlng[s]!.longitude}",
                                                        name: shipmentProvider
                                                            .stoppoints_controller[
                                                                s]
                                                            .text,
                                                        nameEn: "",
                                                        number: 0,
                                                        city: 1,
                                                      ),
                                                    );
                                                  } else {
                                                    points.add(
                                                      PathPoint(
                                                        pointType: "S",
                                                        location:
                                                            "${shipmentProvider.stoppoints_latlng[s]!.latitude},${shipmentProvider.stoppoints_latlng[s]!.longitude}",
                                                        name: shipmentProvider
                                                            .stoppoints_controller[
                                                                s]
                                                            .text,
                                                        nameEn: "",
                                                        number: s,
                                                        city: 1,
                                                      ),
                                                    );
                                                  }
                                                }
                                                int commodityIndex = 0;
                                                for (var i = 0;
                                                    i <
                                                        shipmentProvider
                                                            .selectedTruckId
                                                            .length;
                                                    i++) {
                                                  List<ShipmentItems>
                                                      shipmentitems = [];

                                                  double totalWeight = 0;
                                                  print(
                                                      "commodityIndex${commodityIndex}");
                                                  print(shipmentProvider
                                                      .commodityWeight_controllers
                                                      .length);
                                                  for (var j = 0;
                                                      j <
                                                          shipmentProvider
                                                              .commodityWeight_controllers[
                                                                  commodityIndex]
                                                              .length;
                                                      j++) {
                                                    ShipmentItems shipmentitem =
                                                        ShipmentItems(
                                                      commodityName: shipmentProvider
                                                          .commodityName_controllers[
                                                              commodityIndex][j]
                                                          .text,
                                                      commodityWeight: double.parse(
                                                              shipmentProvider
                                                                  .commodityWeight_controllers[
                                                                      commodityIndex]
                                                                      [j]
                                                                  .text
                                                                  .replaceAll(
                                                                      ",", ""))
                                                          .toInt(),
                                                    );
                                                    shipmentitems
                                                        .add(shipmentitem);
                                                    totalWeight += double.parse(
                                                            shipmentProvider
                                                                .commodityWeight_controllers[
                                                                    commodityIndex]
                                                                    [j]
                                                                .text
                                                                .replaceAll(
                                                                    ",", ""))
                                                        .toInt();
                                                  }
                                                  SubShipment subshipment =
                                                      SubShipment(
                                                    shipmentStatus: "P",
                                                    paths: jsonEncode(
                                                        shipmentProvider
                                                            .pathes),
                                                    shipmentItems:
                                                        shipmentitems,
                                                    totalWeight:
                                                        totalWeight.toInt(),
                                                    distance: shipmentProvider
                                                        .distance,
                                                    price: calculatePrice(
                                                        shipmentProvider
                                                            .distance,
                                                        totalWeight),
                                                    period:
                                                        shipmentProvider.period,
                                                    pathpoints: points,
                                                    truck: ShipmentTruck(
                                                      id: shipmentProvider
                                                          .selectedTruckId[i],
                                                    ),
                                                    // truckTypes: truckTypes,
                                                    pickupDate: DateTime(
                                                      shipmentProvider
                                                          .loadDate[
                                                              commodityIndex]
                                                          .year,
                                                      shipmentProvider
                                                          .loadDate[
                                                              commodityIndex]
                                                          .month,
                                                      shipmentProvider
                                                          .loadDate[
                                                              commodityIndex]
                                                          .day,
                                                      shipmentProvider
                                                          .loadTime[
                                                              commodityIndex]
                                                          .hour,
                                                      shipmentProvider
                                                          .loadTime[
                                                              commodityIndex]
                                                          .minute,
                                                    ),
                                                    deliveryDate: DateTime(
                                                      shipmentProvider
                                                          .loadDate[
                                                              commodityIndex]
                                                          .year,
                                                      shipmentProvider
                                                          .loadDate[
                                                              commodityIndex]
                                                          .month,
                                                      shipmentProvider
                                                          .loadDate[
                                                              commodityIndex]
                                                          .day,
                                                      shipmentProvider
                                                          .loadTime[
                                                              commodityIndex]
                                                          .hour,
                                                      shipmentProvider
                                                          .loadTime[
                                                              commodityIndex]
                                                          .minute,
                                                    ),
                                                  );
                                                  subshipmentsitems
                                                      .add(subshipment);
                                                  commodityIndex++;
                                                }
                                                print(shipmentProvider
                                                    .selectedTruckTypeNum
                                                    .length);

                                                int totalTrucknum = 0;
                                                for (var element
                                                    in shipmentProvider
                                                        .selectedTruckTypeNum) {
                                                  totalTrucknum += element;
                                                }

                                                int remainingTruck =
                                                    totalTrucknum -
                                                        shipmentProvider
                                                            .selectedTruckId
                                                            .length;

                                                for (var i = 0;
                                                    i < remainingTruck;
                                                    i++) {
                                                  List<ShipmentItems>
                                                      shipmentitems = [];

                                                  double totalWeight = 0;
                                                  for (var j = 0;
                                                      j <
                                                          shipmentProvider
                                                              .commodityWeight_controllers[
                                                                  commodityIndex]
                                                              .length;
                                                      j++) {
                                                    ShipmentItems shipmentitem =
                                                        ShipmentItems(
                                                      commodityName: shipmentProvider
                                                          .commodityName_controllers[
                                                              commodityIndex][j]
                                                          .text,
                                                      commodityWeight: double.parse(
                                                              shipmentProvider
                                                                  .commodityWeight_controllers[
                                                                      commodityIndex]
                                                                      [j]
                                                                  .text
                                                                  .replaceAll(
                                                                      ",", ""))
                                                          .toInt(),
                                                    );
                                                    shipmentitems
                                                        .add(shipmentitem);
                                                    totalWeight += double.parse(
                                                            shipmentProvider
                                                                .commodityWeight_controllers[
                                                                    commodityIndex]
                                                                    [j]
                                                                .text
                                                                .replaceAll(
                                                                    ",", ""))
                                                        .toInt();
                                                  }
                                                  SubShipment subshipment =
                                                      SubShipment(
                                                    shipmentStatus: "P",
                                                    paths: jsonEncode(
                                                        shipmentProvider
                                                            .pathes),
                                                    shipmentItems:
                                                        shipmentitems,
                                                    totalWeight:
                                                        totalWeight.toInt(),
                                                    distance: shipmentProvider
                                                        .distance,
                                                    price: calculatePrice(
                                                        shipmentProvider
                                                            .distance,
                                                        totalWeight),
                                                    period:
                                                        shipmentProvider.period,
                                                    pathpoints: points,
                                                    truck: null,
                                                    // truckTypes: truckTypes,
                                                    pickupDate: DateTime(
                                                      shipmentProvider
                                                          .loadDate[
                                                              commodityIndex]
                                                          .year,
                                                      shipmentProvider
                                                          .loadDate[
                                                              commodityIndex]
                                                          .month,
                                                      shipmentProvider
                                                          .loadDate[
                                                              commodityIndex]
                                                          .day,
                                                      shipmentProvider
                                                          .loadTime[
                                                              commodityIndex]
                                                          .hour,
                                                      shipmentProvider
                                                          .loadTime[
                                                              commodityIndex]
                                                          .day,
                                                    ),
                                                    deliveryDate: DateTime(
                                                      shipmentProvider
                                                          .loadDate[
                                                              commodityIndex]
                                                          .year,
                                                      shipmentProvider
                                                          .loadDate[
                                                              commodityIndex]
                                                          .month,
                                                      shipmentProvider
                                                          .loadDate[
                                                              commodityIndex]
                                                          .day,
                                                      shipmentProvider
                                                          .loadTime[
                                                              commodityIndex]
                                                          .hour,
                                                      shipmentProvider
                                                          .loadTime[
                                                              commodityIndex]
                                                          .day,
                                                    ),
                                                  );
                                                  subshipmentsitems
                                                      .add(subshipment);
                                                  commodityIndex++;
                                                }

                                                Shipmentv2 shipment =
                                                    Shipmentv2(
                                                  subshipments:
                                                      subshipmentsitems,
                                                );
                                                BlocProvider.of<
                                                            ShipmentMultiCreateBloc>(
                                                        context)
                                                    .add(
                                                  ShipmentMultiCreateButtonPressed(
                                                    shipment,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
