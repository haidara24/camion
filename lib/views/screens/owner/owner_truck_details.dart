import 'dart:convert';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/gps_reports/over_speed_bloc.dart';
import 'package:camion/business_logic/bloc/gps_reports/parking_report_bloc.dart';
import 'package:camion/business_logic/bloc/gps_reports/total_milage_day_bloc.dart';
import 'package:camion/business_logic/bloc/gps_reports/total_statistics_bloc.dart';
import 'package:camion/business_logic/bloc/gps_reports/trip_report_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/repositories/gps_repository.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/owner/reports/milage_per_day_report_screen.dart';
import 'package:camion/views/screens/owner/reports/over_speed_report_screen.dart';
import 'package:camion/views/screens/owner/reports/parking_report_screen.dart';
import 'package:camion/views/screens/owner/reports/trip_report_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intel;
import 'package:url_launcher/url_launcher.dart';

class OwnerTruckDetailsScreen extends StatefulWidget {
  final KTruck truck;
  final double distance;
  final double weight;
  const OwnerTruckDetailsScreen({
    Key? key,
    required this.truck,
    this.distance = 0,
    this.weight = 0,
  }) : super(key: key);

  @override
  State<OwnerTruckDetailsScreen> createState() =>
      _OwnerTruckDetailsScreenState();
}

class _OwnerTruckDetailsScreenState extends State<OwnerTruckDetailsScreen> {
  late GoogleMapController _controller;

  final String _mapStyle = "";
  String position_name = "";
  int homeCarouselIndicator = 0;
  double speed = -1;

  String getTruckType(int type) {
    switch (type) {
      case 1:
        return "سطحة";
      case 2:
        return "براد";
      case 3:
        return "حاوية";
      case 4:
        return "شحن";
      case 5:
        return "قاطرة ومقطورة";
      case 6:
        return "tier";
      default:
        return "سطحة";
    }
  }

  String getEnTruckType(int type) {
    switch (type) {
      case 1:
        return "Flatbed";
      case 2:
        return "Refrigerated";
      case 3:
        return "Container";
      case 4:
        return "Semi Trailer";
      case 5:
        return "Jumbo Trailer";
      case 6:
        return "tier";
      default:
        return "FlatBed";
    }
  }

  var f = intel.NumberFormat("#,###", "en_US");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAddressForPickupFromLatLng(widget.truck.locationLat!);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void getAddressForPickupFromLatLng(String location) async {
    http
        .get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?language=ar&latlng=${location.split(',')[0]},${location.split(',')[1]}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
    )
        .then((value) {
      var result = jsonDecode(value.body);

      setState(() {
        position_name = getAddressName(result);
      });
    });
    if (widget.truck.gpsId == null ||
        widget.truck.gpsId!.isEmpty ||
        widget.truck.gpsId!.length < 8) {
      var data = await GpsRepository.getCarInfo(widget.truck.gpsId!);
      speed = (data['carStatus']['speed'] as num).toDouble();
    }
  }

  String getAddressName(dynamic result) {
    String str = "";
    List<String> typesToCheck = [
      'route',
      'locality',
      // 'administrative_area_level_2',
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

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  void _openWhatsApp(String phoneNumber, {String? message}) async {
    final String url = message != null
        ? 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}'
        : 'https://wa.me/$phoneNumber';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.grey[100],
                appBar: CustomAppBar(
                  title: AppLocalizations.of(context)!.translate('truck_info'),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 16.0,
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 58.w,
                                    width: 58.w,
                                    decoration: BoxDecoration(
                                      // color: AppColor.lightGoldenYellow,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: CircleAvatar(
                                      radius: 25.h,
                                      // backgroundColor: AppColor.deepBlue,
                                      child: Center(
                                        child: (0 > 1)
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(180),
                                                child: Image.network(
                                                  "asd",
                                                  height: 55.w,
                                                  width: 55.w,
                                                  fit: BoxFit.fill,
                                                ),
                                              )
                                            : Text(
                                                widget.truck.driver_firstname!,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 28.sp,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${widget.truck.driver_firstname!} ${widget.truck.driver_lastname!}",
                                    style: TextStyle(
                                      // color: AppColor.lightBlue,
                                      fontSize: 19.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  InkWell(
                                    onTap: () {
                                      _makePhoneCall(
                                          widget.truck.driver_phone!);
                                    },
                                    child: Icon(
                                      Icons.call,
                                      color: AppColor.deepYellow,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _openWhatsApp(widget.truck.driver_phone!);
                                    },
                                    icon: SizedBox(
                                      height: 45.h,
                                      width: 45.h,
                                      child: SvgPicture.asset(
                                          "assets/icons/whatsapp.svg"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 5.h,
                          horizontal: 16.w,
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: (widget.truck.gpsId == null ||
                                  widget.truck.gpsId!.isEmpty ||
                                  widget.truck.gpsId!.length < 8)
                              ? Center(
                                  child: SectionBody(
                                    text: AppLocalizations.of(context)!
                                        .translate("no_gps_device"),
                                  ),
                                )
                              : CarouselSlider.builder(
                                  itemCount: widget.truck.images!.length,
                                  itemBuilder: (BuildContext context,
                                          int itemIndex, int pageViewIndex) =>
                                      Image.network(
                                    widget.truck.images![itemIndex].image!,
                                    fit: BoxFit.cover,
                                    height: 230.h,
                                    width: double.infinity,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        // setState(() {
                                        //   homeCarouselIndicator = itemIndex;
                                        // });
                                        return child;
                                      }
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                  options: CarouselOptions(
                                    height: 230.h,
                                    viewportFraction: 1,
                                    initialPage: 0,
                                    enableInfiniteScroll: false,
                                    enlargeCenterPage: true,
                                    scrollDirection: Axis.horizontal,
                                  ),
                                ),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 5.h,
                          horizontal: 16.w,
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(8.h),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      color: Colors.grey),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  SectionTitle(
                                    text: position_name,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8)),
                                height: 175.h,
                                child: GoogleMap(
                                  onMapCreated:
                                      (GoogleMapController controller) async {
                                    setState(() {
                                      _controller = controller;
                                      _controller.setMapStyle(_mapStyle);
                                    });
                                  },
                                  myLocationButtonEnabled: false,
                                  zoomGesturesEnabled: false,
                                  scrollGesturesEnabled: false,
                                  tiltGesturesEnabled: false,
                                  rotateGesturesEnabled: false,
                                  zoomControlsEnabled: false,
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                      double.parse(widget.truck.locationLat!
                                          .split(',')[0]),
                                      double.parse(widget.truck.locationLat!
                                          .split(',')[1]),
                                    ),
                                    zoom: 14.47,
                                  ),
                                  gestureRecognizers: const {},
                                  markers: {
                                    Marker(
                                      markerId: const MarkerId("truck"),
                                      position: LatLng(
                                        double.parse(widget.truck.locationLat!
                                            .split(',')[0]),
                                        double.parse(widget.truck.locationLat!
                                            .split(',')[1]),
                                      ),
                                    )
                                  },

                                  // mapType: shipmentProvider.mapType,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 5.h,
                          horizontal: 16.w,
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(8.h),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SectionTitle(
                                    text: AppLocalizations.of(context)!
                                        .translate('reports'),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              (widget.truck.gpsId == null ||
                                      widget.truck.gpsId!.isEmpty ||
                                      widget.truck.gpsId!.length < 8)
                                  ? Center(
                                      child: SectionBody(
                                        text: AppLocalizations.of(context)!
                                            .translate("no_gps_device"),
                                      ),
                                    )
                                  : BlocConsumer<TotalStatisticsBloc,
                                      TotalStatisticsState>(
                                      listener: (context, state) {
                                        print(state);
                                      },
                                      builder: (context, state) {
                                        if (state
                                            is TotalStatisticsLoadingProgress) {
                                          return LoadingIndicator();
                                        } else if (state
                                            is TotalStatisticsLoadedSuccess) {
                                          return Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      final now =
                                                          DateTime.now();
                                                      final startTime =
                                                          now.subtract(
                                                              const Duration(
                                                                  days: 29));
                                                      final dateFormat =
                                                          intel.DateFormat(
                                                              'yyyy-MM-dd HH:mm:ss');

                                                      final formattedStartTime =
                                                          dateFormat.format(
                                                              startTime);
                                                      final formattedEndTime =
                                                          dateFormat
                                                              .format(now);

                                                      BlocProvider.of<
                                                                  OverSpeedBloc>(
                                                              context)
                                                          .add(OverSpeedLoadEvent(
                                                              formattedStartTime,
                                                              formattedEndTime,
                                                              widget.truck
                                                                  .carId!));
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              OverSpeedReportScreen(
                                                                  start:
                                                                      startTime,
                                                                  end: now,
                                                                  carId: widget
                                                                      .truck
                                                                      .carId!),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 115.h,
                                                      width: 155.w,
                                                      padding:
                                                          EdgeInsets.all(4.h),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7),
                                                        border: Border.all(
                                                          color: AppColor
                                                              .deepYellow,
                                                          width: 2.w,
                                                        ),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          SvgPicture.asset(
                                                            "assets/icons/overspeed.svg",
                                                            height: 50.h,
                                                            width: 50.h,
                                                          ),
                                                          SectionBody(
                                                            text: AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .translate(
                                                                    "total_overspeed"),
                                                          ),
                                                          Text(state.result[
                                                                  "overSpeeds"]
                                                              .toString()),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      final now =
                                                          DateTime.now();
                                                      final startTime =
                                                          now.subtract(
                                                              const Duration(
                                                                  days: 29));
                                                      final dateFormat =
                                                          intel.DateFormat(
                                                              'yyyy-MM-dd HH:mm:ss');

                                                      final formattedStartTime =
                                                          dateFormat.format(
                                                              startTime);
                                                      final formattedEndTime =
                                                          dateFormat
                                                              .format(now);

                                                      BlocProvider.of<
                                                                  ParkingReportBloc>(
                                                              context)
                                                          .add(
                                                        ParkingReportLoadEvent(
                                                            formattedStartTime,
                                                            formattedEndTime,
                                                            widget
                                                                .truck.carId!),
                                                      );

                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ParkingReportScreen(
                                                                  start:
                                                                      startTime,
                                                                  end: now,
                                                                  carId: widget
                                                                      .truck
                                                                      .carId!),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 115.h,
                                                      width: 155.w,
                                                      padding:
                                                          EdgeInsets.all(4.h),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7),
                                                        border: Border.all(
                                                          color: AppColor
                                                              .deepYellow,
                                                          width: 2.w,
                                                        ),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          SvgPicture.asset(
                                                            "assets/icons/total_stops.svg",
                                                            height: 50.h,
                                                            width: 50.h,
                                                          ),
                                                          SectionBody(
                                                              text: AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .translate(
                                                                      "total_parking")),
                                                          Text(state
                                                              .result["stops"]
                                                              .toString()),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 8.h,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      final now =
                                                          DateTime.now();
                                                      final startTime =
                                                          now.subtract(
                                                              const Duration(
                                                                  days: 29));
                                                      final dateFormat =
                                                          intel.DateFormat(
                                                              'yyyy-MM-dd HH:mm:ss');

                                                      final formattedStartTime =
                                                          dateFormat.format(
                                                              startTime);
                                                      final formattedEndTime =
                                                          dateFormat
                                                              .format(now);

                                                      BlocProvider.of<
                                                                  TotalMilageDayBloc>(
                                                              context)
                                                          .add(TotalMilageDayLoadEvent(
                                                              formattedStartTime,
                                                              formattedEndTime,
                                                              widget.truck
                                                                  .carId!));

                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                MilagePerDayReportScreen(
                                                                    start:
                                                                        startTime,
                                                                    end: now,
                                                                    carId: widget
                                                                        .truck
                                                                        .carId!),
                                                          ));
                                                    },
                                                    child: Container(
                                                      height: 115.h,
                                                      width: 155.w,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7),
                                                        border: Border.all(
                                                          color: AppColor
                                                              .deepYellow,
                                                          width: 2.w,
                                                        ),
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(4.h),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            height: 50.h,
                                                            width: 50.h,
                                                            child: SvgPicture
                                                                .asset(
                                                              "assets/icons/orange/shipment_path.svg",
                                                              height: 50.h,
                                                              width: 50.h,
                                                            ),
                                                          ),
                                                          SectionBody(
                                                              text: AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .translate(
                                                                      "total_mileage")),
                                                          Text(state.result[
                                                                  "totalMileage"]
                                                              .toString()),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      final now =
                                                          DateTime.now();
                                                      final startTime =
                                                          now.subtract(
                                                              const Duration(
                                                                  days: 29));
                                                      final dateFormat =
                                                          intel.DateFormat(
                                                              'yyyy-MM-dd HH:mm:ss');

                                                      final formattedStartTime =
                                                          dateFormat.format(
                                                              startTime);
                                                      final formattedEndTime =
                                                          dateFormat
                                                              .format(now);

                                                      BlocProvider.of<
                                                                  TripReportBloc>(
                                                              context)
                                                          .add(TripReportLoadEvent(
                                                              formattedStartTime,
                                                              formattedEndTime,
                                                              widget.truck
                                                                  .carId!));
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                TripReportScreen(
                                                                    start:
                                                                        startTime,
                                                                    end: now,
                                                                    carId: widget
                                                                        .truck
                                                                        .carId!),
                                                          ));
                                                    },
                                                    child: Container(
                                                      height: 115.h,
                                                      width: 155.w,
                                                      padding:
                                                          EdgeInsets.all(4.h),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7),
                                                        border: Border.all(
                                                          color: AppColor
                                                              .deepYellow,
                                                          width: 2.w,
                                                        ),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          SvgPicture.asset(
                                                            "assets/icons/total_trips.svg",
                                                            height: 50.h,
                                                            width: 50.h,
                                                          ),
                                                          SectionBody(
                                                              text: AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .translate(
                                                                      "total_trips")),
                                                          const Text(""),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        } else {
                                          return LoadingIndicator();
                                        }
                                      },
                                    ),
                            ],
                          ),
                        ),
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
