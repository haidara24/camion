import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/truck/owner_trucks_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/owner/add_new_truck_screen.dart';
import 'package:camion/views/screens/owner/owner_truck_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class OwnerTruckListScreen extends StatefulWidget {
  const OwnerTruckListScreen({Key? key}) : super(key: key);

  @override
  State<OwnerTruckListScreen> createState() => _OwnerTruckListScreenState();
}

class _OwnerTruckListScreenState extends State<OwnerTruckListScreen> {
  int ownerId = 0;
  late SharedPreferences prefs;

  void getOwnerId() async {
    prefs = await SharedPreferences.getInstance();
    ownerId = prefs.getInt("truckowner") ?? 0;
  }

  @override
  void initState() {
    super.initState();
    getOwnerId();
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
              backgroundColor: AppColor.lightGrey200,
              floatingActionButton: FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNewTruckScreen(ownerId: ownerId),
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
              body: SingleChildScrollView(
                // physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BlocConsumer<OwnerTrucksBloc, OwnerTrucksState>(
                    listener: (context, state) {
                      print(state);
                    },
                    builder: (context, state) {
                      if (state is OwnerTrucksLoadedSuccess) {
                        return state.trucks.isEmpty
                            ? Center(
                                child: Text(AppLocalizations.of(context)!
                                    .translate('no_trucks')),
                              )
                            : ListView.builder(
                                itemCount: state.trucks.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  // DateTime now = DateTime.now();
                                  // Duration diff = now
                                  //     .difference(state.offers[index].createdDate!);
                                  return index == 0
                                      ? const SizedBox.shrink()
                                      : InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    OwnerTruckDetailsScreen(
                                                        truckId: state
                                                            .trucks[index].id!),
                                              ),
                                            );
                                          },
                                          child: AbsorbPointer(
                                            absorbing: false,
                                            child: Card(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  child: Container(
                                                    // height: selectedTruck == index ? 88.h : 80.h,
                                                    width: 180.w,
                                                    margin:
                                                        const EdgeInsets.all(5),
                                                    padding:
                                                        const EdgeInsets.all(5),

                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            SizedBox(
                                                              height: 25.h,
                                                              width: 120.w,
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
                                                                        25.h,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Container(
                                                                  height: 25.h,
                                                                  width: 120.w,
                                                                  color: Colors
                                                                          .grey[
                                                                      300],
                                                                  child: Center(
                                                                    child: Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .translate(
                                                                              'image_load_error'),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 4.h,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              "${state.trucks[index].driver_firstname!} ${state.trucks[index].driver_lastname!}",
                                                              style: TextStyle(
                                                                fontSize: 17.sp,
                                                                color: AppColor
                                                                    .deepBlack,
                                                              ),
                                                            ),
                                                            Text(
                                                              "${state.trucks[index].truckNumber!} ",
                                                              style: TextStyle(
                                                                fontSize: 15.sp,
                                                                color: AppColor
                                                                    .deepBlack,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )),
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
              ),
            ),
          ),
        );
      },
    );
  }
}
