import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/truck_fixes/truck_fix_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/driver/create_fix_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/driver_appbar.dart';
import 'package:camion/views/widgets/no_reaults_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class FixesListScreen extends StatelessWidget {
  const FixesListScreen({Key? key}) : super(key: key);

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
              backgroundColor: Colors.grey[100],
              appBar: DriverAppBar(
                title: AppLocalizations.of(context)!.translate('my_fixes'),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateFixScreen(),
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                backgroundColor: AppColor.darkGrey,
              ),
              body: SingleChildScrollView(
                // physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 5.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BlocConsumer<TruckFixListBloc, TruckFixListState>(
                        listener: (context, state) {
                          print(state);
                        },
                        builder: (context, state) {
                          if (state is TruckFixListLoadedSuccess) {
                            return state.fixes.isEmpty
                                ? NoResultsWidget(
                                    text: AppLocalizations.of(context)!
                                        .translate("no_spending"),
                                  )
                                : ListView.builder(
                                    itemCount: state.fixes.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        height: 25.h,
                                                        width: 25.h,
                                                        child: SvgPicture
                                                            .network(state
                                                                .fixes[index]
                                                                .expenseType!
                                                                .image!),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      // SvgPicture.network(state.fixes[index].expenseType!.name!),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 11),
                                                        child: Text(
                                                          localeState.value
                                                                      .languageCode ==
                                                                  "en"
                                                              ? state
                                                                  .fixes[index]
                                                                  .expenseType!
                                                                  .name!
                                                              : state
                                                                  .fixes[index]
                                                                  .expenseType!
                                                                  .nameAr!,
                                                          style: TextStyle(
                                                              // color: AppColor.lightBlue,
                                                              fontSize: 18.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 11,
                                                        ),
                                                        child: Text(
                                                          '${AppLocalizations.of(context)!.translate('costs')}: ${state.fixes[index].amount} ${localeState.value.languageCode == "en" ? 'S.P' : 'ل.س'}',
                                                          style: TextStyle(
                                                            // color: AppColor.lightBlue,
                                                            fontSize: 18.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Divider(),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // SvgPicture.network(state.fixes[index].expenseType!.name!),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 11),
                                                        child: Text(
                                                          '${AppLocalizations.of(context)!.translate('date')}: ${state.fixes[index].dob!.year}/${state.fixes[index].dob!.month}/${state.fixes[index].dob!.day}',
                                                          style: TextStyle(
                                                              // color: AppColor.lightBlue,
                                                              fontSize: 18.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Divider(),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // SvgPicture.network(state.fixes[index].expenseType!.name!),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 11),
                                                        child: Text(
                                                          '${AppLocalizations.of(context)!.translate('note')}: ${state.fixes[index].note}',
                                                          style: TextStyle(
                                                              // color: AppColor.lightBlue,
                                                              fontSize: 18.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
