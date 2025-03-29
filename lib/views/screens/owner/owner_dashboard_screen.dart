import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/gps_reports/total_statistics_bloc.dart';
import 'package:camion/business_logic/bloc/truck/owner_trucks_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/owner/add_new_truck_screen.dart';
import 'package:camion/views/screens/owner/owner_truck_details.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/no_reaults_widget.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intel;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  var f = intel.NumberFormat("#,###", "en_US");
  late SharedPreferences prefs;

  int selectedIndex = -1;
  int selectedTruck = -1;
  int ownerId = 0;

  double distance = 0;
  String period = "";

  late bool truckLocationassign;

  void loadOwnerId() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      ownerId = prefs.getInt("truckowner") ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    loadOwnerId();
  }

  @override
  void dispose() {
    super.dispose();
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
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BlocConsumer<OwnerTrucksBloc, OwnerTrucksState>(
                  listener: (context, state) {
                    if (state is OwnerTrucksLoadedSuccess) {}
                  },
                  builder: (context, state) {
                    if (state is OwnerTrucksLoadedSuccess) {
                      // if (subshipment != null) {
                      //   subshipment = state.shipments[0];
                      //   truckLocation = subshipment!.truck!.location_lat!;
                      // }
                      return Column(
                        children: [
                          state.trucks.isNotEmpty
                              ? ListView.builder(
                                  itemCount: state.trucks.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        if (!(state.trucks[index].gpsId ==
                                                null ||
                                            state
                                                .trucks[index].gpsId!.isEmpty ||
                                            state.trucks[index].gpsId!.length <
                                                8)) {
                                          final now = DateTime.now();
                                          final startTime = now.subtract(
                                              const Duration(days: 29));
                                          final dateFormat = intel.DateFormat(
                                              'yyyy-MM-dd HH:mm:ss');

                                          final formattedStartTime =
                                              dateFormat.format(startTime);
                                          final formattedEndTime =
                                              dateFormat.format(now);

                                          BlocProvider.of<TotalStatisticsBloc>(
                                                  context)
                                              .add(
                                            TotalStatisticsLoadEvent(
                                                formattedStartTime,
                                                formattedEndTime,
                                                state.trucks[index].carId!),
                                          );
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OwnerTruckDetailsScreen(
                                              truck: state.trucks[index],
                                            ),
                                          ),
                                        );
                                      },
                                      child: AbsorbPointer(
                                        absorbing: false,
                                        child: Card(
                                          color: AppColor.lightYellow,
                                          elevation: 1,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                            side: BorderSide(
                                              color: AppColor.deepYellow,
                                              width: 2,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 16.0,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            SizedBox(
                                                              height: 23.5.h,
                                                              width: 115.w,
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: state
                                                                    .trucks[
                                                                        index]
                                                                    .truckType!
                                                                    .image!,
                                                                progressIndicatorBuilder:
                                                                    (context,
                                                                            url,
                                                                            downloadProgress) =>
                                                                        Shimmer
                                                                            .fromColors(
                                                                  baseColor:
                                                                      (Colors.grey[
                                                                          300])!,
                                                                  highlightColor:
                                                                      (Colors.grey[
                                                                          100])!,
                                                                  enabled: true,
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        23.5.h,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Container(
                                                                  height:
                                                                      23.5.h,
                                                                  width: selectedTruck ==
                                                                          index
                                                                      ? 119.w
                                                                      : 118.w,
                                                                  color: Colors
                                                                          .grey[
                                                                      300],
                                                                  child: Center(
                                                                    child: Text(AppLocalizations.of(
                                                                            context)!
                                                                        .translate(
                                                                            'image_load_error')),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              "${localeState.value.languageCode == "en" ? state.trucks[index].truckType!.name! : state.trucks[index].truckType!.nameAr!} ",
                                                              style: TextStyle(
                                                                fontSize:
                                                                    selectedTruck ==
                                                                            index
                                                                        ? 17.sp
                                                                        : 15.sp,
                                                                color: AppColor
                                                                    .deepBlack,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Column(
                                                          children: [
                                                            Text(
                                                              'No: ${state.trucks[index].truckNumber!}',
                                                            ),
                                                            Text(
                                                              "${state.trucks[index].driver_firstname!} ${state.trucks[index].driver_lastname!}",
                                                              style: TextStyle(
                                                                fontSize:
                                                                    selectedTruck ==
                                                                            index
                                                                        ? 17.sp
                                                                        : 15.sp,
                                                                color: AppColor
                                                                    .deepBlack,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 25.h,
                                                  width: 25.h,
                                                  child: SvgPicture.asset(
                                                    state.trucks[index].isOn!
                                                        ? "assets/icons/delete.svg"
                                                        : "assets/icons/delete.svg",
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                              : NoResultsWidget(
                                  text: AppLocalizations.of(context)!
                                      .translate("no_trucks"),
                                ),
                          SizedBox(
                            height: 4.h,
                          ),
                          CustomButton(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddNewTruckScreen(ownerId: ownerId),
                                ),
                              );
                            },
                            title: SizedBox(
                              height: 50.h,
                              width: MediaQuery.sizeOf(context).width * .9,
                              child: Center(
                                child: SectionBody(
                                  text: AppLocalizations.of(context)!
                                      .translate("create_new_truck"),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: LoadingIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
