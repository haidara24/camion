import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/managment/passcharges_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/permissions_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart' as intel;

class ChargesLogScreen extends StatefulWidget {
  ChargesLogScreen({Key? key}) : super(key: key);

  @override
  State<ChargesLogScreen> createState() => _ChargesLogScreenState();
}

class _ChargesLogScreenState extends State<ChargesLogScreen> {
  var f = intel.NumberFormat("#,###", "en_US");

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColor.lightGrey200,
            body: SingleChildScrollView(
              // physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  BlocConsumer<PasschargesListBloc, PasschargesListState>(
                    listener: (context, state) {
                      if (state is PasschargesListLoadedFailed) {
                        print(state.error);
                      }
                    },
                    builder: (context, state) {
                      if (state is PasschargesListLoadedSuccess) {
                        return state.charges.isEmpty
                            ? Center(
                                child: Text(AppLocalizations.of(context)!
                                    .translate('no_shipments')),
                              )
                            : ListView.builder(
                                itemCount: state.charges.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  // DateTime now = DateTime.now();
                                  // Duration diff = now
                                  //     .difference(state.offers[index].createdDate!);
                                  return InkWell(
                                    onTap: () {},
                                    child: Card(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5.h),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.charges[index].shipment!}',
                                              style: TextStyle(
                                                  // color: AppColor.lightBlue,
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
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
                                  height: 100.h,
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
        );
      },
    );
  }
}
