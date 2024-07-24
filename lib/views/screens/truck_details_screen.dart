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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class TruckDetailsScreen extends StatefulWidget {
  final KTruck truck;
  final int index;
  final String ops;
  final int subshipmentId;
  TruckDetailsScreen({
    Key? key,
    required this.truck,
    required this.index,
    required this.ops,
    required this.subshipmentId,
  }) : super(key: key);

  @override
  State<TruckDetailsScreen> createState() => _TruckDetailsScreenState();
}

class _TruckDetailsScreenState extends State<TruckDetailsScreen> {
  late GoogleMapController _controller;

  String _mapStyle = "";

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              resizeToAvoidBottomInset: false,
              backgroundColor: AppColor.lightGrey200,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.translate('search_result'),
              ),
              body: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 20.h,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10.h,
                      ),
                      Card(
                        elevation: 1,
                        clipBehavior: Clip.antiAlias,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              widget.truck.images![0].image!,
                              height: 250.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 250.h,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Text("error on loading "),
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }

                                return SizedBox(
                                  height: 250.h,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 7.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${AppLocalizations.of(context)!.translate('truck_type')}: ${localeState.value.languageCode == 'en' ? widget.truck.truckType!.name! : widget.truck.truckType!.nameAr!}',
                                    style: TextStyle(
                                        // color: AppColor.lightBlue,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 7.h,
                                  ),
                                  SizedBox(
                                    height: 175.h,
                                    child: GoogleMap(
                                      onMapCreated: (GoogleMapController
                                          controller) async {
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
                                            double.parse(widget
                                                .truck.locationLat!
                                                .split(',')[0]),
                                            double.parse(widget
                                                .truck.locationLat!
                                                .split(',')[1]),
                                          ),
                                          zoom: 14.47),
                                      gestureRecognizers: {},
                                      markers: {
                                        Marker(
                                          markerId: const MarkerId("truck"),
                                          position: LatLng(
                                            double.parse(widget
                                                .truck.locationLat!
                                                .split(',')[0]),
                                            double.parse(widget
                                                .truck.locationLat!
                                                .split(',')[1]),
                                          ),
                                        )
                                      },

                                      // mapType: shipmentProvider.mapType,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 7.h,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        child: Text(
                                          '${AppLocalizations.of(context)!.translate('truck_location')}: ${widget.truck.location!}',
                                          style: TextStyle(
                                            // color: AppColor.lightBlue,
                                            fontSize: 17.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40.h,
                                        child: VerticalDivider(
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        child: Text(
                                          '${AppLocalizations.of(context)!.translate('number_of_axels')}: ${widget.truck.numberOfAxels!}',
                                          style: TextStyle(
                                            // color: AppColor.lightBlue,
                                            fontSize: 17.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        child: Text(
                                          '${AppLocalizations.of(context)!.translate('empty_weight')}: ${widget.truck.emptyWeight!}',
                                          style: TextStyle(
                                            // color: AppColor.lightBlue,
                                            fontSize: 17.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40.h,
                                        child: VerticalDivider(
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        child: Text(
                                          '${AppLocalizations.of(context)!.translate('empty_weight')}: ${widget.truck.emptyWeight!}',
                                          style: TextStyle(
                                            // color: AppColor.lightBlue,
                                            fontSize: 17.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .25,
                                        child: Text(
                                          '${AppLocalizations.of(context)!.translate('long')}: ${widget.truck.long!}',
                                          style: TextStyle(
                                            // color: AppColor.lightBlue,
                                            fontSize: 17.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40.h,
                                        child: VerticalDivider(
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .25,
                                        child: Text(
                                          '${AppLocalizations.of(context)!.translate('height')}: ${widget.truck.height!}',
                                          style: TextStyle(
                                            // color: AppColor.lightBlue,
                                            fontSize: 17.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40.h,
                                        child: VerticalDivider(
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .25,
                                        child: Text(
                                          '${AppLocalizations.of(context)!.translate('width')}: ${widget.truck.width!}',
                                          style: TextStyle(
                                            // color: AppColor.lightBlue,
                                            fontSize: 17.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),

                                  SizedBox(
                                    height: 7.h,
                                  ),

                                  SizedBox(
                                    height: 7.h,
                                  ),
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceAround,
                                  //   children: [

                                  //   ],),
                                  SizedBox(
                                    height: 7.h,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .5,
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
                                  SizedBox(
                                    height: 7.h,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widget.ops == "create_shipment"
                              ? SizedBox(
                                  width: MediaQuery.of(context).size.width * .9,
                                  child: Consumer<AddMultiShipmentProvider>(
                                      builder:
                                          (context, shipmentProvider, child) {
                                    return CustomButton(
                                      title: Text(
                                        AppLocalizations.of(context)!
                                            .translate('order_truck'),
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                        ),
                                      ),
                                      onTap: () {
                                        shipmentProvider.setTruck(
                                            widget.truck, widget.index);
                                        shipmentProvider
                                            .addSelectedTruck(widget.truck.id!);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                    );
                                  }),
                                )
                              : const SizedBox.shrink(),
                          widget.ops == "assign_new_truck"
                              ? SizedBox(
                                  width: MediaQuery.of(context).size.width * .9,
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
                                            AppLocalizations.of(context)!
                                                .translate('order_truck'),
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                            ),
                                          ),
                                          onTap: () {
                                            BlocProvider.of<OrderTruckBloc>(
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
                        height: 5.h,
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
