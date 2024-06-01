// import 'dart:async';
// import 'dart:math';

// import 'package:camion/Localization/app_localizations.dart';
// import 'package:camion/business_logic/cubit/locale_cubit.dart';
// import 'package:camion/constants/enums.dart';
// import 'package:camion/data/models/co2_report.dart';
// import 'package:camion/data/models/shipment_model.dart';
// import 'package:camion/data/providers/active_shipment_provider.dart';
// import 'package:camion/data/services/co2_service.dart';
// import 'package:camion/helpers/color_constants.dart';
// import 'package:camion/views/widgets/custom_app_bar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart' as loc;
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:provider/provider.dart';
// import 'package:timelines/timelines.dart';
// import 'package:intl/intl.dart' as intel;

// class ActiveShipmentDetailsScreen extends StatefulWidget {
//   final String user_id;
//   final Shipment shipment;
//   final int index;
//   ActiveShipmentDetailsScreen(
//       {Key? key,
//       required this.user_id,
//       required this.shipment,
//       required this.index})
//       : super(key: key);

//   @override
//   State<ActiveShipmentDetailsScreen> createState() =>
//       _ActiveShipmentDetailsScreenState();
// }

// class _ActiveShipmentDetailsScreenState
//     extends State<ActiveShipmentDetailsScreen> with TickerProviderStateMixin {
//   late Timer timer;
//   final loc.Location location = loc.Location();
//   late GoogleMapController _controller;
//   bool _added = false;
//   String _mapStyle = "";
//   PanelState panelState = PanelState.hidden;
//   final panelTransation = const Duration(milliseconds: 500);
//   Co2Report _report = Co2Report();
//   var f = intel.NumberFormat("#,###", "en_US");

//   late final AnimationController _animationController = AnimationController(
//     duration: const Duration(seconds: 2),
//     vsync: this,
//   );
// // _heartbeatAnimation = Tween(begin: 180.0, end: 160.0).animate(
// //   CurvedAnimation(
// //     curve: Curves.easeOutBack,
// //     parent: _animationController,
// //   ),
// // );

//   void calculateCo2Report() {
//     ShippmentDetail detail = ShippmentDetail();
//     detail.legs = [];
//     detail.load = [];
//     Legs leg = Legs();
//     leg.mode = "LTL";
//     print("report!.title!");
//     Origin origin = Origin();
//     leg.origin = origin;
//     Origin destination = Origin();
//     leg.destination = destination;

//     leg.origin!.latitude = widget.shipment!.pickupCityLat!;
//     leg.origin!.longitude = widget.shipment!.pickupCityLang!;
//     leg.destination!.latitude = widget.shipment!.deliveryCityLat!;
//     leg.destination!.longitude = widget.shipment!.deliveryCityLang!;

//     detail.legs!.add(leg);

//     for (var i = 0; i < widget.shipment!.shipmentItems!.length; i++) {
//       Load load = Load();
//       load.unitWeightKg =
//           widget.shipment!.shipmentItems![i].commodityWeight!.toDouble();
//       load.unitType = "pallets";
//       detail.load!.add(load);
//     }

//     Co2Service.getCo2Calculate(
//             detail,
//             LatLng(widget.shipment!.pickupCityLat!,
//                 widget.shipment!.pickupCityLang!),
//             LatLng(widget.shipment!.deliveryCityLat!,
//                 widget.shipment!.deliveryCityLang!))
//         .then((value) {
//       setState(() {
//         _report = value!;
//       });
//     });
//   }

//   late BitmapDescriptor pickupicon;
//   late BitmapDescriptor deliveryicon;
//   late BitmapDescriptor parkicon;
//   late BitmapDescriptor truckicon;
//   late LatLng truckLocation;
//   late bool truckLocationassign;

//   createMarkerIcons() async {
//     pickupicon = await BitmapDescriptor.fromAssetImage(
//         const ImageConfiguration(), "assets/icons/location1.png");
//     deliveryicon = await BitmapDescriptor.fromAssetImage(
//         const ImageConfiguration(), "assets/icons/location2.png");
//     parkicon = await BitmapDescriptor.fromAssetImage(
//         const ImageConfiguration(), "assets/icons/locationP.png");
//     truckicon = await BitmapDescriptor.fromAssetImage(
//         const ImageConfiguration(), "assets/icons/truck.png");
//     setState(() {});
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       createMarkerIcons();
//       setState(() {});
//     });
//     rootBundle.loadString('assets/style/map_style.json').then((string) {
//       _mapStyle = string;
//     });
//     calculateCo2Report();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     timer.cancel();
//     super.dispose();
//   }

//   void _onVerticalGesture(DragUpdateDetails details) {
//     if (details.primaryDelta! < -7 && panelState == PanelState.hidden) {
//       changeToOpen();
//     } else if (details.primaryDelta! > 7 && panelState == PanelState.open) {
//       changeToHidden();
//     }
//   }

//   void changeToOpen() {
//     setState(() {
//       panelState = PanelState.open;
//     });
//   }

//   void changeToHidden() {
//     setState(() {
//       panelState = PanelState.hidden;
//     });
//   }

//   double? _getSizeForPanel(PanelState state, Size size) {
//     if (state == PanelState.open) {
//       return size.height;
//     } else if (state == PanelState.hidden) {
//       return (size.height * 0.5);
//     }
//   }

//   List<LatLng> _truckpolyline = [];
//   bool _printed = false;

//   String setLoadDate(DateTime date) {
//     List months = [
//       'jan',
//       'feb',
//       'mar',
//       'april',
//       'may',
//       'jun',
//       'july',
//       'aug',
//       'sep',
//       'oct',
//       'nov',
//       'dec'
//     ];
//     var mon = date.month;
//     var month = months[mon - 1];

//     var result = '${date.day}-$month-${date.year}';
//     return result;
//   }

//   var count = 25;
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return SafeArea(
//       child: Scaffold(
//         appBar: CustomAppBar(
//           title: AppLocalizations.of(context)!.translate('shipment_details'),
//         ),
//         body: Consumer<ActiveShippmentProvider>(
//             builder: (context, shipmentProvider, child) {
//           return StreamBuilder(
//             stream:
//                 FirebaseFirestore.instance.collection('location').snapshots(),
//             builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//               if (_added && !_printed) {
//                 _printed =
//                     true; // Set the flag to true to prevent starting multiple timers
//                 timer = Timer.periodic(const Duration(seconds: 10), (timer) {
//                   print("asd");
//                 });

//                 mymap(snapshot);
//               }
//               if (!snapshot.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               return AnimatedBuilder(
//                 animation: _animationController,
//                 builder: (context, child) {
//                   return Stack(
//                     children: [
//                       GoogleMap(
//                         mapType: MapType.normal,
//                         zoomControlsEnabled: false,
//                         markers: {
//                           // Marker(
//                           //   position: truckLocation,
//                           //   markerId: const MarkerId('parking'),
//                           //   icon: parkicon,
//                           // ),
//                           Marker(
//                             position: LatLng(
//                               snapshot.data!.docs.singleWhere((element) =>
//                                   element.id == widget.user_id)['latitude'],
//                               snapshot.data!.docs.singleWhere((element) =>
//                                   element.id == widget.user_id)['longitude'],
//                             ),
//                             markerId: const MarkerId('truck'),
//                             icon: truckicon,
//                           ),
//                           Marker(
//                             markerId: const MarkerId("pickup"),
//                             position: LatLng(widget.shipment!.pickupCityLat!,
//                                 widget.shipment!.pickupCityLang!),
//                             icon: pickupicon,
//                           ),
//                           Marker(
//                             markerId: const MarkerId("delivery"),
//                             position: LatLng(widget.shipment!.deliveryCityLat!,
//                                 widget.shipment!.deliveryCityLang!),
//                             icon: deliveryicon,
//                           ),
//                         },
//                         initialCameraPosition: CameraPosition(
//                             target: LatLng(
//                               snapshot.data!.docs.singleWhere((element) =>
//                                   element.id == widget.user_id)['latitude'],
//                               snapshot.data!.docs.singleWhere((element) =>
//                                   element.id == widget.user_id)['longitude'],
//                             ),
//                             zoom: 14.47),
//                         onMapCreated: (GoogleMapController controller) async {
//                           setState(() {
//                             _controller = controller;
//                             _controller.setMapStyle(_mapStyle);
//                             _added = true;
//                           });
//                         },
//                         polylines: {
//                           Polyline(
//                             polylineId: const PolylineId("route"),
//                             points:
//                                 shipmentProvider.polylineCoordinates.length >
//                                         widget.index
//                                     ? shipmentProvider
//                                         .polylineCoordinates[widget.index]
//                                     : [],
//                             color: AppColor.deepYellow,
//                             width: 7,
//                           ),
//                         },
//                       ),
//                       AnimatedPositioned(
//                         duration: panelTransation,
//                         curve: Curves.decelerate,
//                         left: 0,
//                         right: 0,
//                         bottom: _getTopForPanel(),
//                         child: GestureDetector(
//                           onVerticalDragUpdate: _onVerticalGesture,
//                           child: _buildExpandedPanelWidget(context),
//                           // child: AnimatedSwitcher(
//                           //   duration: panelTransation,
//                           //   child: _buildPanelOption(context),
//                           // ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//           );
//         }),
//       ),
//     );
//   }

//   getpolylineCoordinates(Shipment shipment) async {
//     print("asd");
//     List<Marker> markers = [];
//     markers.add(
//       Marker(
//         markerId: const MarkerId("pickup"),
//         position: LatLng(shipment!.pickupCityLat!, shipment!.pickupCityLang!),
//       ),
//     );
//     markers.add(
//       Marker(
//         markerId: const MarkerId("delivery"),
//         position:
//             LatLng(shipment!.deliveryCityLat!, shipment!.deliveryCityLang!),
//       ),
//     );
//     calculateCo2Report();
//     print("asd2");

//     getBounds(markers, _controller);
//     // setState(() {});
//   }

//   void getBounds(List<Marker> markers, GoogleMapController mapcontroller) {
//     var lngs = markers.map<double>((m) => m.position.longitude).toList();
//     var lats = markers.map<double>((m) => m.position.latitude).toList();

//     double topMost = lngs.reduce(max);
//     double leftMost = lats.reduce(min);
//     double rightMost = lats.reduce(max);
//     double bottomMost = lngs.reduce(min);

//     LatLngBounds _bounds = LatLngBounds(
//       northeast: LatLng(rightMost, topMost),
//       southwest: LatLng(leftMost, bottomMost),
//     );
//     var cameraUpdate = CameraUpdate.newLatLngBounds(_bounds, 50.0);
//     mapcontroller.animateCamera(cameraUpdate);
//     print("asd3");

//     // setState(() {});
//   }

//   double? _getTopForPanel() {
//     if (panelState == PanelState.hidden) {
//       return 90.h - 420.h;
//     } else if (panelState == PanelState.open) {
//       return 0;
//     }
//   }

//   Widget _buildPanelOption(BuildContext context) {
//     if (panelState == PanelState.hidden) {
//       return _buildPanelWidget(context);
//     } else if (panelState == PanelState.open) {
//       return _buildExpandedPanelWidget(context);
//     } else {
//       return const SizedBox.shrink();
//     }
//   }

//   Widget _buildExpandedPanelWidget(BuildContext context) {
//     return BlocBuilder<LocaleCubit, LocaleState>(
//       builder: (context, localeState) {
//         return Stack(
//           clipBehavior: Clip.none,
//           children: [
//             Container(
//               height: 435.h,
//               width: MediaQuery.of(context).size.width,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(13),
//                   topRight: Radius.circular(13),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       changeToHidden();
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(13.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const SizedBox(
//                             width: 50,
//                             height: 50,
//                           ),
//                           Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "${AppLocalizations.of(context)!.translate('truck_type')}: \n${localeState.value.languageCode == 'en' ? widget.shipment.truckType!.name! : widget.shipment.truckType!.nameAr!}",
//                                 style: TextStyle(
//                                   fontSize: 19.sp,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               // Text(
//                               //   "commodity name: ${widget.shipment.shipmentItems![0].commodityName!}",
//                               //   style: TextStyle(
//                               //     fontSize: 19.sp,
//                               //   ),
//                               // ),
//                             ],
//                           ),
//                           Text(
//                             "${AppLocalizations.of(context)!.translate('shipment_number')} \n${widget.shipment.id!}",
//                             style: TextStyle(
//                               fontSize: 19.sp,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   const Divider(),
//                   SizedBox(
//                     height: 100.h,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         TimelineTile(
//                           direction: Axis.horizontal,
//                           oppositeContents: Text(
//                             "",
//                           ),
//                           contents: SizedBox(
//                             width: MediaQuery.of(context).size.width * .18,
//                             child: Text(
//                               'Pickup: ${widget.shipment!.pickupCityLocation!}',
//                               style: const TextStyle(),
//                               maxLines: 2,
//                             ),
//                           ),
//                           node: SizedBox(
//                             width: MediaQuery.of(context).size.width * .3,
//                             child: TimelineNode(
//                               indicator:
//                                   DotIndicator(color: AppColor.deepYellow),
//                               // startConnector: SolidLineConnector(),
//                               endConnector: DashedLineConnector(
//                                   color: AppColor.deepYellow),
//                             ),
//                           ),
//                         ),
//                         TimelineTile(
//                           direction: Axis.horizontal,
//                           oppositeContents: const SizedBox.shrink(),
//                           contents: const SizedBox.shrink(),
//                           node: SizedBox(
//                             width: MediaQuery.of(context).size.width * .35,
//                             child:
//                                 DashedLineConnector(color: AppColor.deepYellow),
//                           ),
//                         ),
//                         TimelineTile(
//                           direction: Axis.horizontal,
//                           oppositeContents: Text(
//                             "",
//                           ),
//                           contents: SizedBox(
//                             width: MediaQuery.of(context).size.width * .18,
//                             child: Text(
//                               'Delivery:${widget.shipment!.pickupCityLocation!}',
//                               style: const TextStyle(),
//                               maxLines: 2,
//                             ),
//                           ),
//                           node: SizedBox(
//                             width: MediaQuery.of(context).size.width * .3,
//                             child: TimelineNode(
//                               indicator:
//                                   DotIndicator(color: AppColor.deepYellow),
//                               startConnector: DashedLineConnector(
//                                   color: AppColor.deepYellow),
//                               // endConnector: SolidLineConnector(),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                   const Divider(),
//                   _buildCommodityWidget(widget.shipment.shipmentItems),
//                   const Divider(),
//                   _buildCo2Report(),
//                 ],
//               ),
//             ),
//             Positioned(
//               top: -45,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     Card(
//                       color: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(45),
//                       ),
//                       child: Container(
//                         margin: const EdgeInsets.all(3),
//                         padding: const EdgeInsets.all(1),
//                         decoration: BoxDecoration(
//                             color: AppColor.deepYellow,
//                             borderRadius: BorderRadius.circular(45)),
//                         child: CircleAvatar(
//                           radius: 30.h,
//                           backgroundColor: Colors.white,
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(180),
//                             child: SvgPicture.asset(
//                               "assets/images/person_orange.svg",
//                               fit: BoxFit.fill,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Text(
//                       AppLocalizations.of(context)!.translate('driver_name'),
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         // color: AppColor.deepYellow,
//                       ),
//                     ),
//                     // Text(
//                     //   "${widget.shipment.truck!.truckuser!.firstName!} ${widget.shipment.truck!.truckuser!.lastName!}",
//                     //   style: TextStyle(
//                     //     fontWeight: FontWeight.bold,
//                     //     color: AppColor.deepYellow,
//                     //     fontSize: 16,
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
//             ),
//             BlocBuilder<LocaleCubit, LocaleState>(
//               builder: (context, localeState) {
//                 return Positioned(
//                   top: -20,
//                   right: MediaQuery.of(context).size.width * .45,
//                   child: panelState == PanelState.hidden
//                       ? InkWell(
//                           onTap: () {
//                             changeToOpen();
//                           },
//                           child: AbsorbPointer(
//                             absorbing: true,
//                             child: Container(
//                               height: 45.h,
//                               width: 45.w,
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: Colors.grey[300]!,
//                                   width: 1,
//                                 ),
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(45),
//                               ),
//                               child: Center(
//                                 child: SizedBox(
//                                   height: 25.h,
//                                   width: 25.w,
//                                   child: SvgPicture.asset(
//                                     "assets/icons/arrow_up.svg",
//                                     fit: BoxFit.contain,
//                                     height: 25.h,
//                                     width: 25.w,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         )
//                       : InkWell(
//                           onTap: () {
//                             changeToHidden();
//                           },
//                           child: AbsorbPointer(
//                             absorbing: true,
//                             child: Container(
//                               height: 45.h,
//                               width: 45.w,
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: Colors.grey[300]!,
//                                   width: 1,
//                                 ),
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(45),
//                               ),
//                               child: Center(
//                                 child: SizedBox(
//                                   height: 25.h,
//                                   width: 25.w,
//                                   child: SvgPicture.asset(
//                                     "assets/icons/arrow_down.svg",
//                                     fit: BoxFit.contain,
//                                     height: 25.h,
//                                     width: 25.w,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildPanelWidget(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         changeToOpen();
//       },
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Container(
//             height: 100.h,
//             width: MediaQuery.of(context).size.width,
//             decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(13),
//                   topRight: Radius.circular(13),
//                 )),
//             child: Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Column(
//                 children: [
//                   const SizedBox(
//                     height: 8,
//                   ),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const SizedBox(
//                         width: 50,
//                         height: 50,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Text(
//                             "${AppLocalizations.of(context)!.translate('truck_type')}: ${widget.shipment.truckType!.name!}",
//                             style: TextStyle(
//                               fontSize: 19.sp,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           Text(
//                             "${AppLocalizations.of(context)!.translate('commodity_name')}: ${widget.shipment.shipmentItems![0].commodityName!}",
//                             style: TextStyle(
//                               fontSize: 18.sp,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         "${widget.shipment.id!}",
//                         style: TextStyle(
//                           fontSize: 23.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             top: -45,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   Card(
//                     color: Colors.white,
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(45),
//                     ),
//                     child: Container(
//                       margin: const EdgeInsets.all(3),
//                       padding: const EdgeInsets.all(1),
//                       decoration: BoxDecoration(
//                           color: AppColor.deepYellow,
//                           borderRadius: BorderRadius.circular(45)),
//                       child: CircleAvatar(
//                         radius: 30.h,
//                         backgroundColor: Colors.white,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(180),
//                           child: SvgPicture.asset(
//                             "assets/images/person_orange.svg",
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const Text(
//                     "Driver Name",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       // color: AppColor.deepYellow,
//                     ),
//                   ),
//                   Text(
//                     "${widget.shipment.driver!.user!.firstName!} ${widget.shipment.driver!.user!.lastName!}",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: AppColor.deepYellow,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           BlocBuilder<LocaleCubit, LocaleState>(
//             builder: (context, localeState) {
//               return Positioned(
//                 top: -20,
//                 right: MediaQuery.of(context).size.width * .45,
//                 child: InkWell(
//                   onTap: () {
//                     changeToOpen();
//                   },
//                   child: AbsorbPointer(
//                     absorbing: true,
//                     child: Container(
//                       height: 45.h,
//                       width: 45.w,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Colors.grey[300]!,
//                           width: 1,
//                         ),
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(45),
//                       ),
//                       child: Center(
//                         child: SizedBox(
//                           height: 25.h,
//                           width: 25.w,
//                           child: SvgPicture.asset(
//                             "assets/icons/arrow_up.svg",
//                             fit: BoxFit.contain,
//                             height: 25.h,
//                             width: 25.w,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   int getunfinishedTasks(Shipment shipment) {
//     var count = 0;
//     // if (shipment.shipmentinstruction == null) {
//     //   count++;
//     // }
//     // if (shipment.shipmentpayment == null) {
//     //   count++;
//     // }
//     return count;
//   }

//   Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
//     getpolylineCoordinates(widget.shipment);
//   }

//   final ScrollController _scrollController = ScrollController();

//   gettruckpolylineCoordinates(LatLng driver, LatLng distination) async {
//     _truckpolyline = [];
//     PolylinePoints polylinePoints = PolylinePoints();
//     print("werwer");
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       "AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w",
//       PointLatLng(driver.latitude!, driver.longitude!),
//       PointLatLng(distination.latitude!, distination.longitude!),
//     );
//     _truckpolyline = [];
//     if (result.points.isNotEmpty) {
//       result.points.forEach((element) {
//         _truckpolyline.add(
//           LatLng(
//             element.latitude,
//             element.longitude,
//           ),
//         );
//       });
//     }
//     setState(() {});
//   }

//   _buildCommodityWidget(List<ShipmentItems>? shipmentItems) {
//     return SizedBox(
//       height: 135.h,
//       width: MediaQuery.of(context).size.width,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               const SizedBox(
//                 width: 10,
//               ),
//               SizedBox(
//                 height: 25.h,
//                 width: 25.w,
//                 child: SvgPicture.asset("assets/icons/commodity_icon.svg"),
//               ),
//               const SizedBox(
//                 width: 5,
//               ),
//               Text(
//                 AppLocalizations.of(context)!.translate('commodity_info'),
//                 style: TextStyle(
//                   fontSize: 17.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 5,
//           ),
//           SizedBox(
//             height: 95.h,
//             child: Scrollbar(
//               controller: _scrollController,
//               thumbVisibility: true,
//               thickness: 3.0,
//               child: Padding(
//                 padding: const EdgeInsets.all(2.0),
//                 child: ListView.builder(
//                   controller: _scrollController,
//                   shrinkWrap: true,
//                   scrollDirection: Axis.horizontal,
//                   itemCount: widget.shipment.shipmentItems!.length,
//                   itemBuilder: (context, index) {
//                     return Card(
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(5)),
//                       child: Padding(
//                         padding: const EdgeInsets.all(5.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Text(
//                               "${AppLocalizations.of(context)!.translate('commodity_name')}: ${widget.shipment.shipmentItems![index].commodityName!}",
//                               style: TextStyle(
//                                 fontSize: 17.sp,
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Text(
//                               "${AppLocalizations.of(context)!.translate('commodity_weight')}: ${widget.shipment.shipmentItems![index].commodityWeight!}",
//                               style: TextStyle(
//                                 fontSize: 17.sp,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   _buildCo2Report() {
//     return SizedBox(
//       height: 50.h,
//       width: MediaQuery.of(context).size.width,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 30,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             SizedBox(
//               height: 35,
//               width: 35,
//               child: SvgPicture.asset("assets/icons/co2fingerprint.svg"),
//             ),
//             const SizedBox(
//               width: 5,
//             ),
//             BlocBuilder<LocaleCubit, LocaleState>(
//               builder: (context, localeState) {
//                 return SizedBox(
//                   width: MediaQuery.of(context).size.width * .7,
//                   child: Text(
//                     "${AppLocalizations.of(context)!.translate('total_co2')}: ${f.format(_report!.et!.toInt())} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}",
//                     style: const TextStyle(
//                       // color: Colors.white,
//                       fontSize: 17,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
