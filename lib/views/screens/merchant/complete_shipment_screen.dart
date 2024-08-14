import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_complete_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_details_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/merchant/shipment_details_screen.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intel;
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class CompleteShipmentScreen extends StatelessWidget {
  CompleteShipmentScreen({Key? key}) : super(key: key);
  var f = intel.NumberFormat("#,###", "en_US");

  String setLoadDate(DateTime date) {
    List months = [
      'jan',
      'feb',
      'mar',
      'april',
      'may',
      'jun',
      'july',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec'
    ];
    var mon = date.month;
    var month = months[mon - 1];

    var result = '${date.day}-$month-${date.year}';
    return result;
  }

  String getOfferStatus(String offer) {
    switch (offer) {
      case "P":
        return "معلقة";
      case "R":
        return "جارية";
      case "C":
        return "مكتملة";
      case "F":
        return "مرفوضة";
      default:
        return "خطأ";
    }
  }

  String diffText(Duration diff) {
    if (diff.inSeconds < 60) {
      return "منذ ${diff.inSeconds.toString()} ثانية";
    } else if (diff.inMinutes < 60) {
      return "منذ ${diff.inMinutes.toString()} دقيقة";
    } else if (diff.inHours < 24) {
      return "منذ ${diff.inHours.toString()} ساعة";
    } else {
      return "منذ ${diff.inDays.toString()} يوم";
    }
  }

  String diffEnText(Duration diff) {
    if (diff.inSeconds < 60) {
      return "since ${diff.inSeconds.toString()} seconds";
    } else if (diff.inMinutes < 60) {
      return "since ${diff.inMinutes.toString()} minutes";
    } else if (diff.inHours < 24) {
      return "since ${diff.inHours.toString()} hours";
    } else {
      return "since ${diff.inDays.toString()} days";
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
              backgroundColor: Colors.grey[100],
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.translate('shippment_log'),
              ),
              body: SingleChildScrollView(
                // physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BlocBuilder<ShipmentCompleteListBloc,
                          ShipmentCompleteListState>(
                        builder: (context, state) {
                          if (state is ShipmentCompleteListLoadedSuccess) {
                            return state.shipments.isEmpty
                                ? Center(
                                    child: Text(AppLocalizations.of(context)!
                                        .translate('no_shipments')),
                                  )
                                : ListView.builder(
                                    itemCount: state.shipments.length,
                                    // physics:
                                    //     const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      // DateTime now = DateTime.now();
                                      // Duration diff = now
                                      //     .difference(state.offers[index].createdDate!);
                                      return InkWell(
                                        onTap: () {
                                          BlocProvider.of<ShipmentDetailsBloc>(
                                                  context)
                                              .add(ShipmentDetailsLoadEvent(
                                                  state.shipments[index].id!));
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ShipmentDetailsScreen(
                                                  shipment:
                                                      state.shipments[index],
                                                  preview: true,
                                                ),
                                              ));
                                        },
                                        child: AbsorbPointer(
                                          absorbing: false,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4.0,
                                            ),
                                            child: Card(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    height: 48.h,
                                                    color: Colors.grey[300],
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 4,
                                                          ),
                                                          child: SectionTitle(
                                                            text:
                                                                "${AppLocalizations.of(context)!.translate('shipment_number')}: SA-${state.shipments[index].id!}",
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 4,
                                                          ),
                                                          child: SectionTitle(
                                                            text: state
                                                                        .shipments[
                                                                            index]
                                                                        .shipmentStatus! ==
                                                                    'C'
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'completed')
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'cancelled'),
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 45.h,
                                                          width: 45.w,
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 4,
                                                          ),
                                                          child: Center(
                                                            child: state
                                                                        .shipments[
                                                                            index]
                                                                        .shipmentStatus! ==
                                                                    'C'
                                                                ? SvgPicture
                                                                    .asset(
                                                                    "assets/icons/shipment_completed.svg",
                                                                    height:
                                                                        30.h,
                                                                    width: 30.w,
                                                                    fit: BoxFit
                                                                        .fill,
                                                                  )
                                                                : SvgPicture
                                                                    .asset(
                                                                    "assets/icons/shipment_cancellation.svg",
                                                                    height:
                                                                        30.h,
                                                                    width: 30.w,
                                                                    fit: BoxFit
                                                                        .fill,
                                                                  ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  ShipmentPathVerticalWidget(
                                                    pathpoints: state
                                                        .shipments[index]
                                                        .subshipments![0]
                                                        .pathpoints!,
                                                    pickupDate: state
                                                        .shipments[index]
                                                        .subshipments![0]
                                                        .pickupDate!,
                                                    deliveryDate: state
                                                        .shipments[index]
                                                        .subshipments![0]
                                                        .deliveryDate!,
                                                    langCode: localeState
                                                        .value.languageCode,
                                                    mini: true,
                                                  ),
                                                ],
                                              ),
                                            ).animate().slideX(
                                                duration: 350.ms,
                                                delay: 0.ms,
                                                begin: 1,
                                                end: 0,
                                                curve: Curves.easeInOutSine),
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
