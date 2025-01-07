import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/gps_reports/total_milage_day_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/no_reaults_widget.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart' as cupertino;

class MilagePerDayReportScreen extends StatefulWidget {
  final DateTime start;
  final DateTime end;
  final int carId;
  const MilagePerDayReportScreen({
    super.key,
    required this.start,
    required this.end,
    required this.carId,
  });

  @override
  State<MilagePerDayReportScreen> createState() =>
      _MilagePerDayReportScreenState();
}

class _MilagePerDayReportScreenState extends State<MilagePerDayReportScreen> {
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();

  TextEditingController startdate_controller = TextEditingController();
  String startdate = "";
  TextEditingController enddate_controller = TextEditingController();
  String enddate = "";

  _showDatePicker(String lang, bool startOrEnd) {
    cupertino.showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border:
                Border(top: BorderSide(color: AppColor.deepYellow, width: 2))),
        height: MediaQuery.of(context).size.height * .4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.translate('ok'),
                  style: TextStyle(
                    color: AppColor.darkGrey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            Expanded(
              child: Localizations(
                locale: const Locale('en', ''),
                delegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                child: cupertino.CupertinoDatePicker(
                  backgroundColor: Colors.white10,
                  initialDateTime: startOrEnd ? startTime : endTime,
                  mode: cupertino.CupertinoDatePickerMode.date,
                  // minimumYear: DateTime.now().year,
                  // minimumDate: DateTime.now().subtract(const Duration(days: 1)),
                  // maximumYear: DateTime.now().year + 1,
                  onDateTimeChanged: (value) {
                    setState(() {
                      if (startOrEnd) {
                        startTime = value;
                        startdate_controller.text =
                            "${startTime.year}-${startTime.month}-${startTime.day} ";
                        startdate =
                            "${startTime.year}-${startTime.month}-${startTime.day} ${startTime.hour}:${startTime.minute}:${startTime.second}";
                      } else {
                        endTime = value;
                        enddate_controller.text =
                            "${endTime.year}-${endTime.month}-${endTime.day} ";
                        enddate =
                            "${endTime.year}-${endTime.month}-${endTime.day} ${endTime.hour}:${endTime.minute}:${endTime.second}";
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    startTime = widget.start;
    startdate_controller.text =
        "${startTime.year}-${startTime.month}-${startTime.day} ";
    startdate =
        "${startTime.year}-${startTime.month}-${startTime.day} ${startTime.hour}:${startTime.minute}:${startTime.second}";

    endTime = widget.end;
    enddate_controller.text =
        "${endTime.year}-${endTime.month}-${endTime.day} ";
    enddate =
        "${endTime.year}-${endTime.month}-${endTime.day} ${endTime.hour}:${endTime.minute}:${endTime.second}";
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
                title: AppLocalizations.of(context)!
                    .translate('total_mileage_report'),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    _showDatePicker(
                                        localeState.value.languageCode, true);
                                  },
                                  child: TextFormField(
                                    controller: startdate_controller,
                                    enabled: false,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .translate('startDate'),
                                      floatingLabelStyle: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 11.0, horizontal: 9.0),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: SvgPicture.asset(
                                          "assets/icons/grey/calendar.svg",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    _showDatePicker(
                                        localeState.value.languageCode, false);
                                  },
                                  child: TextFormField(
                                    controller: enddate_controller,
                                    enabled: false,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .translate('endDate'),
                                      floatingLabelStyle: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 11.0, horizontal: 9.0),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: SvgPicture.asset(
                                          "assets/icons/grey/calendar.svg",
                                          height: 15.h,
                                          width: 15.h,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              CustomButton(
                                title: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                onTap: () {
                                  BlocProvider.of<TotalMilageDayBloc>(context)
                                      .add(
                                    TotalMilageDayLoadEvent(
                                      startdate,
                                      enddate,
                                      widget.carId,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                      BlocBuilder<TotalMilageDayBloc, TotalMilageDayState>(
                        builder: (context, state) {
                          if (state is TotalMilageDayLoadedSuccess) {
                            return state.result.isEmpty
                                ? ListView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    children: [
                                      NoResultsWidget(
                                        text: AppLocalizations.of(context)!
                                            .translate('no_reports'),
                                      )
                                    ],
                                  )
                                : Table(
                                    border: TableBorder.all(
                                      borderRadius: BorderRadius.circular(8),
                                      color: AppColor.deepYellow,
                                      width: 1,
                                    ),
                                    children: [
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColor.lightYellow,
                                              borderRadius: BorderRadius.only(
                                                topLeft: localeState.value
                                                            .languageCode ==
                                                        "en"
                                                    ? const Radius.circular(8)
                                                    : Radius.zero,
                                                topRight: localeState.value
                                                            .languageCode ==
                                                        "en"
                                                    ? Radius.zero
                                                    : const Radius.circular(8),
                                              ),
                                            ),
                                            child: SizedBox(
                                              height:
                                                  50.0, // Set a consistent height
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Center(
                                                    child: SectionBody(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .translate('date'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColor.lightYellow,
                                            ),
                                            child: SizedBox(
                                              height:
                                                  50.0, // Set a consistent height
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Center(
                                                    child: SectionBody(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .translate(
                                                              'overspeed_count'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColor.lightYellow,
                                            ),
                                            child: SizedBox(
                                              height:
                                                  50.0, // Set a consistent height
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Center(
                                                    child: SectionBody(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .translate(
                                                              'parking_count'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColor.lightYellow,
                                              borderRadius: BorderRadius.only(
                                                topRight: localeState.value
                                                            .languageCode ==
                                                        "en"
                                                    ? const Radius.circular(8)
                                                    : Radius.zero,
                                                topLeft: localeState.value
                                                            .languageCode ==
                                                        "en"
                                                    ? Radius.zero
                                                    : const Radius.circular(8),
                                              ),
                                            ),
                                            child: SizedBox(
                                              height:
                                                  50.0, // Set a consistent height
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Center(
                                                    child: SectionBody(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .translate(
                                                              'total_mileage'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                      ...List.generate(
                                        state.result.length,
                                        (index) => TableRow(children: [
                                          TableCell(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: SectionBody(
                                                    text: state.result[index]
                                                        ["day"]),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SectionBody(
                                                  text:
                                                      '${state.result[index]["overSpeedCount"]} '),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SectionBody(
                                                  text:
                                                      '${state.result[index]["stopCount"]} '),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SectionBody(
                                                  text:
                                                      '${(state.result[index]["mileage"] / 1000).toStringAsFixed(2)} ${localeState.value.languageCode == "en" ? 'km' : 'كم'}'),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ],
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
                                      height: 75.h,
                                      width: double.infinity,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                                itemCount: 10,
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
            ),
          ),
        );
      },
    );
  }
}
