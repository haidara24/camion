import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/shipments_widgets/shimmer_card.dart';
import 'package:camion/views/widgets/shipments_widgets/subshipment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/unassigned_shipment_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/driver/search_shipment_details_screen.dart';
import 'package:intl/intl.dart' as intl;

class SearchShippmentScreen extends StatefulWidget {
  SearchShippmentScreen({Key? key}) : super(key: key);

  @override
  State<SearchShippmentScreen> createState() => _SearchShippmentScreenState();
}

class _SearchShippmentScreenState extends State<SearchShippmentScreen> {
  final f = intl.NumberFormat("#,###", "en_US");

  String setLoadDate(DateTime date) {
    const months = [
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
    final month = months[date.month - 1];
    return '${date.day}-$month-${date.year}';
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
      return "منذ ${diff.inSeconds} ثانية";
    } else if (diff.inMinutes < 60) {
      return "منذ ${diff.inMinutes} دقيقة";
    } else if (diff.inHours < 24) {
      return "منذ ${diff.inHours} ساعة";
    } else {
      return "منذ ${diff.inDays} يوم";
    }
  }

  String diffEnText(Duration diff) {
    if (diff.inSeconds < 60) {
      return "since ${diff.inSeconds} seconds";
    } else if (diff.inMinutes < 60) {
      return "since ${diff.inMinutes} minutes";
    } else if (diff.inHours < 24) {
      return "since ${diff.inHours} hours";
    } else {
      return "since ${diff.inDays} days";
    }
  }

  Future<void> onRefresh() async {
    BlocProvider.of<UnassignedShipmentListBloc>(context)
        .add(UnassignedShipmentListLoadEvent());
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
            body: RefreshIndicator(
              onRefresh: onRefresh,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: BlocConsumer<UnassignedShipmentListBloc,
                    UnassignedShipmentListState>(
                  listener: (context, state) {
                    print(state);
                  },
                  builder: (context, state) {
                    if (state is UnassignedShipmentListLoadedSuccess) {
                      return state.shipments.isEmpty
                          ? Center(
                              child: SectionTitle(
                                  text: AppLocalizations.of(context)!
                                      .translate('no_shipments')),
                            )
                          : ListView.builder(
                              itemCount: state.shipments.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return SubShipmentCardWidget(
                                  shipment: state.shipments[index],
                                  languageCode: localeState.value.languageCode,
                                  onTap: () {
                                    BlocProvider.of<SubShipmentDetailsBloc>(
                                            context)
                                        .add(SubShipmentDetailsLoadEvent(
                                            state.shipments[index].id!));
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SearchShipmentDetailsScreen(
                                          shipment: state.shipments[index],
                                          userType: "Driver",
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                    } else {
                      return const ShimmerLoadingWidget();
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
