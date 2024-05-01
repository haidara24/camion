import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/managment/permissions_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/price_request_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/check_point/permission_details_screen.dart';
import 'package:camion/views/screens/managment/add_new_price_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart' as intel;

class PermissionLogScreen extends StatefulWidget {
  PermissionLogScreen({Key? key}) : super(key: key);

  @override
  State<PermissionLogScreen> createState() => _PermissionLogScreenState();
}

class _PermissionLogScreenState extends State<PermissionLogScreen> {
  var f = intel.NumberFormat("#,###", "en_US");
  String setLoadDate(DateTime date) {
    if (date == null) {
      return "";
    }
    List months = [
      'كانون ثاني',
      'شباط',
      'أذار',
      'نيسان',
      'أيار',
      'حزيران',
      'تموز',
      'آب',
      'أيلول',
      'تشرين أول',
      'تشرين ثاني',
      'كانون أول'
    ];
    var mon = date.month;
    var month = months[mon - 1];

    var result = '${date.day}-$month-${date.year}';
    return result;
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
                  BlocConsumer<PermissionsListBloc, PermissionsListState>(
                    listener: (context, state) {
                      if (state is PermissionsListLoadedFailed) {
                        print(state.error);
                      }
                    },
                    builder: (context, state) {
                      if (state is PermissionsListLoadedSuccess) {
                        return state.permissions.isEmpty
                            ? Center(
                                child: Text(AppLocalizations.of(context)!
                                    .translate('no_shipments')),
                              )
                            : ListView.builder(
                                itemCount: state.permissions.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  // DateTime now = DateTime.now();
                                  // Duration diff = now
                                  //     .difference(state.offers[index].createdDate!);
                                  return InkWell(
                                    onTap: () {
                                      // Navigator.push(context, MaterialPageRoute(builder: (context) => PermissionDetailsScreen(shipment: state.perm),))
                                    },
                                    child: Card(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.permissions[index].shipment!}',
                                              style: TextStyle(
                                                  // color: AppColor.lightBlue,
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'التاريخ: ${setLoadDate(state.permissions[index].passdate!)}',
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
