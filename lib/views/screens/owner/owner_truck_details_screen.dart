import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/truck/truck_details_bloc.dart';
import 'package:camion/business_logic/bloc/truck_fixes/truck_fix_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class OwnerTruckDetailsScreen extends StatefulWidget {
  final int truckId;
  const OwnerTruckDetailsScreen({Key? key, required this.truckId})
      : super(key: key);

  @override
  State<OwnerTruckDetailsScreen> createState() =>
      _OwnerTruckDetailsScreenState();
}

class _OwnerTruckDetailsScreenState extends State<OwnerTruckDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int tabIndex = 0;

  @override
  void initState() {
    BlocProvider.of<TruckDetailsBloc>(context)
        .add(TruckDetailsLoadEvent(widget.truckId));
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark, // Reset to default
        statusBarColor: AppColor.deepBlack,
        systemNavigationBarColor: AppColor.deepBlack,
      ),
    );
    _tabController.dispose();
  }

  Widget showscreenBody(String lang) {
    switch (tabIndex) {
      case 0:
        return Container();
      case 1:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocConsumer<TruckFixListBloc, TruckFixListState>(
            listener: (context, state) {
              print(state);
            },
            builder: (context, state) {
              if (state is TruckFixListLoadedSuccess) {
                return state.fixes.isEmpty
                    ? Center(
                        child: Text(AppLocalizations.of(context)!
                            .translate('no_shipments')),
                      )
                    : ListView.builder(
                        itemCount: state.fixes.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          // DateTime now = DateTime.now();
                          // Duration diff = now
                          //     .difference(state.offers[index].createdDate!);
                          return InkWell(
                            onTap: () {},
                            child: AbsorbPointer(
                              absorbing: false,
                              child: Card(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 25.h,
                                            width: 25.h,
                                            child: SvgPicture.network(state
                                                .fixes[index]
                                                .expenseType!
                                                .image!),
                                          ),
                                          const SizedBox(width: 8),
                                          // SvgPicture.network(state.fixes[index].expenseType!.name!),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 11),
                                            child: Text(
                                              lang == "en"
                                                  ? state.fixes[index]
                                                      .expenseType!.name!
                                                  : state.fixes[index]
                                                      .expenseType!.nameAr!,
                                              style: TextStyle(
                                                  // color: AppColor.lightBlue,
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 11,
                                            ),
                                            child: Text(
                                              'التكلفة: ${state.fixes[index].amount} ${lang == "en" ? 'S.P' : 'ل.س'}',
                                              style: TextStyle(
                                                // color: AppColor.lightBlue,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // SvgPicture.network(state.fixes[index].expenseType!.name!),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 11),
                                            child: Text(
                                              'التاريخ: ${state.fixes[index].dob!.year}/${state.fixes[index].dob!.month}/${state.fixes[index].dob!.day}',
                                              style: TextStyle(
                                                  // color: AppColor.lightBlue,
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // SvgPicture.network(state.fixes[index].expenseType!.name!),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 11),
                                            child: Text(
                                              'ملاحظات: ${state.fixes[index].note}',
                                              style: TextStyle(
                                                  // color: AppColor.lightBlue,
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
        );
      default:
        return Container();
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
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: AppColor.deepBlack, // Make status bar transparent
              statusBarIconBrightness:
                  Brightness.light, // Light icons for dark backgrounds
              systemNavigationBarColor: Colors.grey[200], // Works on Android
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.grey[100],
                body: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: Colors.grey[200],
                        child: TabBar(
                          indicatorColor: AppColor.deepYellow,
                          controller: _tabController,
                          onTap: (value) {
                            switch (value) {
                              case 0:
                                BlocProvider.of<TruckDetailsBloc>(context)
                                    .add(TruckDetailsLoadEvent(widget.truckId));
                                break;
                              case 1:
                                BlocProvider.of<TruckFixListBloc>(context)
                                    .add(TruckFixListLoad(widget.truckId));
                                break;
                              default:
                            }
                            setState(() {
                              tabIndex = value;
                            });
                          },
                          tabs: const [
                            // first tab [you can add an icon using the icon property]
                            Tab(
                              child: Center(child: Text("معلومات المركبة")),
                            ),
                            Tab(
                              child: Center(child: Text("المصاريف")),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: showscreenBody(localeState.value.languageCode),
                      ),
                      const SizedBox(
                        height: 4,
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
