import 'dart:convert';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/order_truck_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/providers/add_multi_shipment_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/control_view.dart';
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
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intel;

class TruckDetailsScreen extends StatefulWidget {
  final KTruck truck;
  final int index;
  final String ops;
  final int subshipmentId;
  final double distance;
  final double weight;
  const TruckDetailsScreen({
    Key? key,
    required this.truck,
    required this.index,
    required this.ops,
    required this.subshipmentId,
    this.distance = 0,
    this.weight = 0,
  }) : super(key: key);

  @override
  State<TruckDetailsScreen> createState() => _TruckDetailsScreenState();
}

class _TruckDetailsScreenState extends State<TruckDetailsScreen> {
  late GoogleMapController _controller;

  final String _mapStyle = "";
  String position_name = "";
  int homeCarouselIndicator = 0;

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

  void getAddressForPickupFromLatLng(String location) {
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

  int calculatePrice(
    double distance,
    double weight,
  ) {
    double result = 0.0;
    result = distance * (weight / 1000) * 550;
    return result.toInt();
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${widget.truck.driver_firstname!} ${widget.truck.driver_lastname!}",
                                        style: TextStyle(
                                          // color: AppColor.lightBlue,
                                          fontSize: 19.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 7.h,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            widget.truck.rating! >= 1
                                                ? Icon(
                                                    Icons.star,
                                                    color: AppColor.deepYellow,
                                                  )
                                                : Icon(
                                                    Icons.star_border,
                                                    color: AppColor.deepYellow,
                                                  ),
                                            widget.truck.rating! >= 2
                                                ? Icon(
                                                    Icons.star,
                                                    color: AppColor.deepYellow,
                                                  )
                                                : Icon(
                                                    Icons.star_border,
                                                    color: AppColor.deepYellow,
                                                  ),
                                            widget.truck.rating! >= 3
                                                ? Icon(
                                                    Icons.star,
                                                    color: AppColor.deepYellow,
                                                  )
                                                : Icon(
                                                    Icons.star_border,
                                                    color: AppColor.deepYellow,
                                                  ),
                                            widget.truck.rating! >= 4
                                                ? Icon(
                                                    Icons.star,
                                                    color: AppColor.deepYellow,
                                                  )
                                                : Icon(
                                                    Icons.star_border,
                                                    color: AppColor.deepYellow,
                                                  ),
                                            widget.truck.rating! == 5
                                                ? Icon(
                                                    Icons.star,
                                                    color: AppColor.deepYellow,
                                                  )
                                                : Icon(
                                                    Icons.star_border,
                                                    color: AppColor.deepYellow,
                                                  ),
                                            // Text(
                                            //   '(${widget.truck.rating!.toString()})',
                                            //   style: TextStyle(
                                            //     color: AppColor.deepYellow,
                                            //     fontSize: 19,
                                            //     fontWeight: FontWeight.bold,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ],
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
                          child: Column(
                            children: [
                              CarouselSlider.builder(
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
                              SizedBox(
                                height: 8.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: SectionBody(
                                      text:
                                          '${AppLocalizations.of(context)!.translate('empty_weight')}: ${f.format(widget.truck.emptyWeight)} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}',
                                    ),
                                  ),
                                  Expanded(
                                    child: SectionBody(
                                      text:
                                          '${AppLocalizations.of(context)!.translate('number_of_axels')}: ${widget.truck.numberOfAxels!}',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: SectionBody(
                                      text:
                                          '${AppLocalizations.of(context)!.translate('long')}: ${widget.truck.long!}${localeState.value.languageCode == 'en' ? "m" : "م"}',
                                    ),
                                  ),
                                  Expanded(
                                    child: SectionBody(
                                      text:
                                          '${AppLocalizations.of(context)!.translate('height')}: ${widget.truck.height!}${localeState.value.languageCode == 'en' ? "m" : "م"}',
                                    ),
                                  ),
                                  Expanded(
                                    child: SectionBody(
                                      text:
                                          '${AppLocalizations.of(context)!.translate('width')}: ${widget.truck.width!}${localeState.value.languageCode == 'en' ? "m" : "م"}',
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
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SectionTitle(
                                    text: AppLocalizations.of(context)!
                                        .translate('price'),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ((widget.truck.private_price != null &&
                                              widget.truck.private_price! >
                                                  0) &&
                                          (widget.truck.private_price! <
                                              calculatePrice(widget.distance,
                                                  widget.weight)))
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SectionTitle(
                                              size: 22,
                                              text:
                                                  '${f.format(widget.truck.private_price)} ${localeState.value.languageCode == "en" ? "S.P" : "ل.س"}',
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              '${f.format(calculatePrice(widget.distance, widget.weight))}  ${localeState.value.languageCode == "en" ? "S.P" : "ل.س"}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        )
                                      : SectionTitle(
                                          text:
                                              '${f.format(calculatePrice(widget.distance, widget.weight))} ${localeState.value.languageCode == "en" ? "S.P" : "ل.س"}',
                                        ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  (widget.ops == "create_shipment")
                                      ? SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .8,
                                          child: Consumer<
                                                  AddMultiShipmentProvider>(
                                              builder: (context,
                                                  shipmentProvider, child) {
                                            return !shipmentProvider
                                                    .selectedTruckId
                                                    .contains(widget.truck.id)
                                                ? CustomButton(
                                                    title: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .translate(
                                                              'add_truck'),
                                                      style: TextStyle(
                                                        fontSize: 20.sp,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      shipmentProvider
                                                          .addSelectedTruck(
                                                        widget.truck,
                                                        widget.truck.truckType!
                                                            .id!,
                                                      );

                                                      Navigator.pop(context);
                                                      // Navigator.pop(context);
                                                    },
                                                  )
                                                : const SizedBox.shrink();
                                          }),
                                        )
                                      : const SizedBox.shrink(),
                                  widget.ops == "assign_new_truck"
                                      ? SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .9,
                                          child: BlocConsumer<OrderTruckBloc,
                                              OrderTruckState>(
                                            listener: (context, updatestate) {
                                              if (updatestate
                                                  is OrderTruckSuccessState) {
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ControlView(),
                                                  ),
                                                  (route) => false,
                                                );
                                              }
                                            },
                                            builder: (context, updatestate) {
                                              if (updatestate
                                                  is OrderTruckLoadingProgressState) {
                                                return CustomButton(
                                                  title: LoadingIndicator(),
                                                  onTap: () {},
                                                );
                                              } else {
                                                return CustomButton(
                                                  title: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'order_truck'),
                                                    style: TextStyle(
                                                      fontSize: 20.sp,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    BlocProvider.of<
                                                                OrderTruckBloc>(
                                                            context)
                                                        .add(
                                                      OrderTruckButtonPressed(
                                                        widget.subshipmentId,
                                                        widget.truck.id!,
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8.h,
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
