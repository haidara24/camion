import 'dart:convert';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/gps_reports/over_speed_bloc.dart';
import 'package:camion/business_logic/bloc/gps_reports/parking_report_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/methods_helper.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/no_reaults_widget.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:http/http.dart' as http;

class ParkingReportScreen extends StatefulWidget {
  final DateTime start;
  final DateTime end;
  final int carId;
  const ParkingReportScreen({
    super.key,
    required this.start,
    required this.end,
    required this.carId,
  });

  @override
  State<ParkingReportScreen> createState() => _ParkingReportScreenState();
}

class _ParkingReportScreenState extends State<ParkingReportScreen> {
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();

  TextEditingController startdate_controller = TextEditingController();
  String startdate = "";
  TextEditingController enddate_controller = TextEditingController();
  String enddate = "";
  bool showOverlay = false;
  String positionName = "Loading address...";
  LatLng location = const LatLng(37.7749, -122.4194);

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

  void getAddressForPickupFromLatLng(LatLng location) {
    String latLng = "${location.latitude},${location.longitude}";
    print(latLng);

    http
        .get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=$latLng&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    )
        .then((value) {
      print(value.body);

      var result = jsonDecode(value.body);
      setState(() {
        positionName = getAddressName(result);
      });
    }).catchError((e) {
      setState(() {
        positionName = "Failed to fetch address.";
      });
    });
  }

  String getAddressName(dynamic result) {
    String str = "";
    List<String> typesToCheck = [
      'route',
      'locality',
      'administrative_area_level_2',
      'administrative_area_level_1'
    ];
    for (var element in result["results"]) {
      if (element['address_components'][0]['types'].contains('route')) {
        for (int i = element['address_components'].length - 1; i >= 0; i--) {
          var element1 = element['address_components'][i];
          if (typesToCheck.any((type) => element1['types'].contains(type)) &&
              element1["long_name"] != null &&
              element1["long_name"] != "طريق بدون اسم") {
            str = str + ('${element1["long_name"]},');
          }
        }
        break;
      }
    }
    if (str.isEmpty) {
      for (int i = result["results"]['address_components'].length - 1;
          i >= 0;
          i--) {
        var element1 = result["results"]['address_components'][i];
        if (typesToCheck.any((type) => element1['types'].contains(type))) {
          str = str + ('${element1["long_name"] ?? ""},');
        }
      }
    }
    return str.replaceRange(str.length - 1, null, ".");
  }

  showLocationModalSheet(BuildContext context, String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      builder: (context) => Container(
        color: Colors.grey[200],
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
        width: double.infinity,
        child: ListView(
          // shrinkWrap: true,
          // physics: NeverScrollableScrollPhysics(),
          children: [
            AbsorbPointer(
              absorbing: false,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Spacer(),
                    // SectionTitle(
                    //   text: AppLocalizations.of(context)!
                    //       .translate('choose_shippment_path'),
                    //   size: 20,
                    // ),
                    // const Spacer(),
                    // const SizedBox(
                    //   width: 25,
                    // ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .9,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: location,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('location'),
                    position: location,
                  ),
                },
              ),
            ),
            const SizedBox(height: 16),
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(15),
            //   ),
            //   child: Text(
            //     positionName,
            //     style: const TextStyle(fontSize: 16),
            //   ),
            // ),
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
                title:
                    AppLocalizations.of(context)!.translate('parking_report'),
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
                                  BlocProvider.of<ParkingReportBloc>(context)
                                      .add(
                                    ParkingReportLoadEvent(
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
                      BlocBuilder<ParkingReportBloc, ParkingReportState>(
                        builder: (context, state) {
                          if (state is ParkingReportLoadedSuccess) {
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
                                                        ? const Radius.circular(
                                                            8)
                                                        : Radius.zero,
                                                    topRight: localeState.value
                                                                .languageCode ==
                                                            "en"
                                                        ? Radius.zero
                                                        : const Radius.circular(
                                                            8))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: SectionBody(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'startDate')),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColor.lightYellow,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: SectionBody(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .translate('endDate')),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColor.lightYellow,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: SectionBody(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .translate('stopTime')),
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
                                                        ? const Radius.circular(
                                                            8)
                                                        : Radius.zero,
                                                    topLeft: localeState.value
                                                                .languageCode ==
                                                            "en"
                                                        ? Radius.zero
                                                        : const Radius.circular(
                                                            8))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: SectionBody(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .translate('location')),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                      ...List.generate(
                                        state.result.length,
                                        (index) => TableRow(children: [
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SectionBody(
                                                  text: state.result[index]
                                                      ["startTime"]),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SectionBody(
                                                  text: state.result[index]
                                                      ["endTime"]),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SectionBody(
                                                  text:
                                                      '${MethodHelper.formatDuration(state.result[index]["stopTime"])} '),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: IconButton(
                                                onPressed: () {
                                                  location = LatLng(
                                                      state.result[index]
                                                          ["lat"],
                                                      state.result[index]
                                                          ["lon"]);

                                                  showLocationModalSheet(
                                                      context,
                                                      localeState
                                                          .value.languageCode);
                                                  getAddressForPickupFromLatLng(
                                                      location);
                                                },
                                                icon: Icon(
                                                  Icons.location_on,
                                                  color: AppColor.deepYellow,
                                                ),
                                              ),
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
