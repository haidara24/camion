import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/managment/price_request_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/managment/add_new_price_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart' as intel;

class PriceRequestLogScreen extends StatefulWidget {
  PriceRequestLogScreen({Key? key}) : super(key: key);

  @override
  State<PriceRequestLogScreen> createState() => _PriceRequestLogScreenState();
}

class _PriceRequestLogScreenState extends State<PriceRequestLogScreen> {
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
                  BlocConsumer<PriceRequestBloc, PriceRequestState>(
                    listener: (context, state) {
                      if (state is PriceRequestLoadedFailed) {
                        print(state.error);
                      }
                    },
                    builder: (context, state) {
                      if (state is PriceRequestLoadedSuccess) {
                        return state.pricerequest.isEmpty
                            ? Center(
                                child: Text(AppLocalizations.of(context)!
                                    .translate('no_shipments')),
                              )
                            : ListView.builder(
                                itemCount: state.pricerequest.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  // DateTime now = DateTime.now();
                                  // Duration diff = now
                                  //     .difference(state.offers[index].createdDate!);
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddNewPriceScreen(
                                                  request: state
                                                      .pricerequest[index]),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5.h),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 11),
                                              child: Text(
                                                'اسم التاجر: ${state.pricerequest[index].merchant!.user!.firstName!} ${state.pricerequest[index].merchant!.user!.lastName!}',
                                                style: TextStyle(
                                                    // color: AppColor.lightBlue,
                                                    fontSize: 18.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 7,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 11),
                                              child: Text(
                                                'نوع البضاعة: ${state.pricerequest[index].categoryName!} ',
                                                style: TextStyle(
                                                    // color: AppColor.lightBlue,
                                                    fontSize: 17.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
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
