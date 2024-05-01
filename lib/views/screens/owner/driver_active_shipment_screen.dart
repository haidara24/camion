// import 'package:camion/Localization/app_localizations.dart';
// import 'package:camion/business_logic/bloc/driver_shipments/driver_active_shipment_bloc.dart';
// import 'package:camion/business_logic/bloc/owner_shipments/owner_active_shipments_bloc.dart';
// import 'package:camion/business_logic/bloc/shipments/active_shipment_list_bloc.dart';
// import 'package:camion/business_logic/bloc/truck/owner_trucks_bloc.dart';
// import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
// import 'package:camion/business_logic/cubit/locale_cubit.dart';
// import 'package:camion/data/models/truck_model.dart';
// import 'package:camion/data/providers/active_shipment_provider.dart';
// import 'package:camion/data/providers/truck_provider.dart';
// import 'package:camion/helpers/color_constants.dart';
// import 'package:camion/views/screens/merchant/active_shipment_details_screen.dart';
// import 'package:camion/views/widgets/shipment_path_widget.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:camion/views/screens/driver/tracking_shippment_screen.dart';

// class OwnerActiveShipmentScreen extends StatefulWidget {
//   OwnerActiveShipmentScreen({Key? key}) : super(key: key);

//   @override
//   State<OwnerActiveShipmentScreen> createState() =>
//       _OwnerActiveShipmentScreenState();
// }

// class _OwnerActiveShipmentScreenState extends State<OwnerActiveShipmentScreen> {
//   String _mapStyle = "";
//   Truck? _selectedTruck;

//   BitmapDescriptor pickupicon = BitmapDescriptor.defaultMarker;
//   BitmapDescriptor deliveryicon = BitmapDescriptor.defaultMarker;

//   createMarkerIcons() async {
//     pickupicon = await BitmapDescriptor.fromAssetImage(
//         const ImageConfiguration(), "assets/icons/location1.png");
//     deliveryicon = await BitmapDescriptor.fromAssetImage(
//         const ImageConfiguration(), "assets/icons/location2.png");
//     setState(() {});
//   }

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

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       createMarkerIcons();
//     });
//     rootBundle.loadString('assets/style/map_style.json').then((string) {
//       _mapStyle = string;
//     });
//   }

//   Future<void> onRefresh() async {
//     BlocProvider.of<ActiveShipmentListBloc>(context)
//         .add(ActiveShipmentListLoadEvent());
//   }

//   bool shipmentsLoaded = false;
//   final TextEditingController _driverController = TextEditingController();
//   int truckId = 0;

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LocaleCubit, LocaleState>(
//       builder: (context, localeState) {
//         return Directionality(
//           textDirection: localeState.value.languageCode == 'en'
//               ? TextDirection.ltr
//               : TextDirection.rtl,
//           child: Scaffold(
//             backgroundColor: AppColor.lightGrey200,
//             body: RefreshIndicator(
//               onRefresh: onRefresh,
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: BlocConsumer<OwnerTrucksBloc, OwnerTrucksState>(
//                         listener: (context, state) {},
//                         builder: (context, state) {
//                           if (state is OwnerTrucksLoadedSuccess) {
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 DropdownButtonHideUnderline(
//                                   child: DropdownButton2<Truck?>(
//                                     isExpanded: true,
//                                     barrierLabel: AppLocalizations.of(context)!
//                                         .translate('select_driver'),
//                                     hint: Text(
//                                       AppLocalizations.of(context)!
//                                           .translate('select_driver'),
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         color: Theme.of(context).hintColor,
//                                       ),
//                                     ),
//                                     items: state.trucks
//                                         .map((Truck item) =>
//                                             DropdownMenuItem<Truck>(
//                                               value: item,
//                                               child: Text(
//                                                 "${item.truckuser!.user!.firstName!} ${item.truckuser!.user!.lastName!}",
//                                                 style: const TextStyle(
//                                                   fontSize: 17,
//                                                 ),
//                                               ),
//                                             ))
//                                         .toList(),
//                                     value: _selectedTruck,
//                                     onChanged: (Truck? value) {
//                                       _selectedTruck = value;
//                                       setState(() {
//                                         truckId = value!.truckuser!.id!;
//                                       });
//                                       if (truckId != 0) {
//                                         BlocProvider.of<
//                                                     DriverActiveShipmentBloc>(
//                                                 context)
//                                             .add(
//                                                 DriverActiveShipmentForOwnerLoadEvent(
//                                                     "A", truckId));
//                                       } else {
//                                         BlocProvider.of<
//                                                     OwnerActiveShipmentsBloc>(
//                                                 context)
//                                             .add(
//                                                 OwnerActiveShipmentsLoadEvent());
//                                       }
//                                     },
//                                     buttonStyleData: ButtonStyleData(
//                                       height: 50,
//                                       width: double.infinity,

//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 9.0,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(12),
//                                         border: Border.all(
//                                           color: Colors.black26,
//                                         ),
//                                         color: Colors.white,
//                                       ),
//                                       // elevation: 2,
//                                     ),
//                                     iconStyleData: IconStyleData(
//                                       icon: const Icon(
//                                         Icons.keyboard_arrow_down_sharp,
//                                       ),
//                                       iconSize: 20,
//                                       iconEnabledColor: AppColor.lightYellow,
//                                       iconDisabledColor: Colors.grey,
//                                     ),
//                                     dropdownSearchData: DropdownSearchData(
//                                       searchController: _driverController,
//                                       searchInnerWidgetHeight: 60,
//                                       searchInnerWidget: Container(
//                                         height: 60,
//                                         padding: const EdgeInsets.only(
//                                           top: 8,
//                                           bottom: 4,
//                                           right: 8,
//                                           left: 8,
//                                         ),
//                                         child: TextFormField(
//                                           expands: true,
//                                           maxLines: null,
//                                           controller: _driverController,
//                                           onTapOutside: (event) {
//                                             BlocProvider.of<BottomNavBarCubit>(
//                                                     context)
//                                                 .emitShow();
//                                           },
//                                           onTap: () {
//                                             BlocProvider.of<BottomNavBarCubit>(
//                                                     context)
//                                                 .emitHide();
//                                             _driverController.selection =
//                                                 TextSelection(
//                                                     baseOffset: 0,
//                                                     extentOffset:
//                                                         _driverController
//                                                             .value.text.length);
//                                           },
//                                           decoration: InputDecoration(
//                                             isDense: true,
//                                             contentPadding:
//                                                 const EdgeInsets.symmetric(
//                                               horizontal: 10,
//                                               vertical: 8,
//                                             ),
//                                             hintText:
//                                                 AppLocalizations.of(context)!
//                                                     .translate('select_driver'),
//                                             hintStyle:
//                                                 const TextStyle(fontSize: 17),
//                                             border: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                           ),
//                                           onFieldSubmitted: (value) {
//                                             BlocProvider.of<BottomNavBarCubit>(
//                                                     context)
//                                                 .emitShow();
//                                           },
//                                         ),
//                                       ),
//                                       searchMatchFn: (item, searchValue) {
//                                         print(searchValue);
//                                         print(item.value!.truckuser!.user!
//                                             .firstName!);
//                                         return item
//                                             .value!.truckuser!.user!.firstName!
//                                             .contains(searchValue);
//                                       },
//                                     ),
//                                     onMenuStateChange: (isOpen) {
//                                       if (!isOpen) {
//                                         _driverController.clear();
//                                       }
//                                     },
//                                     dropdownStyleData: DropdownStyleData(
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(14),
//                                         color: Colors.white,
//                                       ),
//                                       scrollbarTheme: ScrollbarThemeData(
//                                         radius: const Radius.circular(40),
//                                         thickness: MaterialStateProperty.all(6),
//                                         thumbVisibility:
//                                             MaterialStateProperty.all(true),
//                                       ),
//                                     ),
//                                     menuItemStyleData: MenuItemStyleData(
//                                       height: 40.h,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           } else if (state is OwnerTrucksLoadedFailed) {
//                             return Center(
//                               child: InkWell(
//                                 onTap: () {
//                                   // BlocProvider.of<
//                                   //             OwnerTrucksBloc>(
//                                   //         context)
//                                   //     .add(
//                                   //         OwnerTrucksLoadEvent());
//                                 },
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       AppLocalizations.of(context)!
//                                           .translate('list_error'),
//                                       style: const TextStyle(color: Colors.red),
//                                     ),
//                                     const Icon(
//                                       Icons.refresh,
//                                       color: Colors.grey,
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             );
//                           } else {
//                             return const Center(
//                               child: LinearProgressIndicator(),
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                     truckId == 0
//                         ? Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Consumer<ActiveShippmentProvider>(builder:
//                                 (context, activeShipmentProvider, child) {
//                               activeShipmentProvider.init();
//                               return BlocConsumer<OwnerActiveShipmentsBloc,
//                                   OwnerActiveShipmentsState>(
//                                 listener: (context, state) {
//                                   if (state
//                                       is OwnerActiveShipmentsLoadedSuccess) {
//                                     // for (var element in state.shipments) {
//                                     //   _maps.add(value)
//                                     // }
//                                     print("listen");
//                                     activeShipmentProvider
//                                         .getpolylineCoordinates(
//                                             state.shipments);
//                                   }
//                                 },
//                                 builder: (context, state) {
//                                   if (state
//                                       is OwnerActiveShipmentsLoadedSuccess) {
//                                     if (!shipmentsLoaded) {
//                                       BlocProvider.of<OwnerActiveShipmentsBloc>(
//                                               context)
//                                           .add(OwnerActiveShipmentsRefreash());
//                                       shipmentsLoaded = true;
//                                       print("build");
//                                     }
//                                     // activeShipmentProvider
//                                     //     .getpolylineCoordinates(state.shipments);
//                                     return state.shipments.isEmpty
//                                         ? ListView(
//                                             physics:
//                                                 const NeverScrollableScrollPhysics(),
//                                             shrinkWrap: true,
//                                             children: [
//                                               SizedBox(
//                                                 height: MediaQuery.of(context)
//                                                         .size
//                                                         .height *
//                                                     .75,
//                                                 child: Center(
//                                                   child: Text(
//                                                       AppLocalizations.of(
//                                                               context)!
//                                                           .translate(
//                                                               'no_shipments')),
//                                                 ),
//                                               )
//                                             ],
//                                           )
//                                         : ListView.builder(
//                                             itemCount: state.shipments.length,
//                                             physics:
//                                                 const NeverScrollableScrollPhysics(),
//                                             shrinkWrap: true,
//                                             itemBuilder: (context, index) {
//                                               // DateTime now = DateTime.now();
//                                               // Duration diff = now
//                                               //     .difference(state.offers[index].createdDate!);
//                                               return Card(
//                                                 shape:
//                                                     const RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.all(
//                                                     Radius.circular(10),
//                                                   ),
//                                                 ),
//                                                 child: Padding(
//                                                   padding: EdgeInsets.symmetric(
//                                                       vertical: 5.h),
//                                                   child: Column(
//                                                     children: [
//                                                       InkWell(
//                                                         onTap: () {
//                                                           print(
//                                                               'driver${state.shipments[index].driver!.user!.id!}');
//                                                           Navigator.push(
//                                                               context,
//                                                               MaterialPageRoute(
//                                                                 builder:
//                                                                     (context) =>
//                                                                         ActiveShipmentDetailsScreen(
//                                                                   user_id:
//                                                                       'driver${state.shipments[index].driver!.user!.id!}',
//                                                                   shipment: state
//                                                                           .shipments[
//                                                                       index],
//                                                                   index: index,
//                                                                 ),
//                                                               ));
//                                                         },
//                                                         child: Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                                   horizontal:
//                                                                       3.0),
//                                                           child: Column(
//                                                             mainAxisSize:
//                                                                 MainAxisSize
//                                                                     .min,
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .end,
//                                                             children: [
//                                                               Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .all(
//                                                                         3.0),
//                                                                 child: Row(
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .spaceBetween,
//                                                                   children: [
//                                                                     Card(
//                                                                       shape:
//                                                                           RoundedRectangleBorder(
//                                                                         borderRadius:
//                                                                             BorderRadius.circular(45),
//                                                                       ),
//                                                                       child:
//                                                                           Container(
//                                                                         margin: const EdgeInsets
//                                                                             .all(
//                                                                             3),
//                                                                         padding: const EdgeInsets
//                                                                             .all(
//                                                                             1),
//                                                                         decoration: BoxDecoration(
//                                                                             color:
//                                                                                 AppColor.deepYellow,
//                                                                             borderRadius: BorderRadius.circular(45)),
//                                                                         child:
//                                                                             CircleAvatar(
//                                                                           radius:
//                                                                               30.h,
//                                                                           backgroundColor:
//                                                                               Colors.white,
//                                                                           child:
//                                                                               Center(
//                                                                             child:
//                                                                                 Text(
//                                                                               "as",
//                                                                               style: TextStyle(
//                                                                                 fontSize: 28.sp,
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                     Text(
//                                                                       "${AppLocalizations.of(context)!.translate('commodity_name')}: ${state.shipments[index].shipmentItems![0].commodityName!}",
//                                                                       style:
//                                                                           TextStyle(
//                                                                         fontSize:
//                                                                             19.sp,
//                                                                       ),
//                                                                     ),
//                                                                     Text(
//                                                                       "#${state.shipments[index].id!}",
//                                                                       style:
//                                                                           TextStyle(
//                                                                         fontSize:
//                                                                             19.sp,
//                                                                         fontWeight:
//                                                                             FontWeight.bold,
//                                                                       ),
//                                                                     )
//                                                                   ],
//                                                                 ),
//                                                               ),
//                                                               Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .all(
//                                                                         8.0),
//                                                                 child: SizedBox(
//                                                                   height: 200.h,
//                                                                   child:
//                                                                       AbsorbPointer(
//                                                                     absorbing:
//                                                                         true,
//                                                                     child:
//                                                                         GoogleMap(
//                                                                       onMapCreated:
//                                                                           (controller) {
//                                                                         activeShipmentProvider.onMapCreated(
//                                                                             controller,
//                                                                             _mapStyle,
//                                                                             index);
//                                                                         // _maps.add(
//                                                                         //     controller);
//                                                                         // _maps[index]
//                                                                         //     .setMapStyle(
//                                                                         //         _mapStyle);
//                                                                       },
//                                                                       myLocationButtonEnabled:
//                                                                           false,
//                                                                       zoomGesturesEnabled:
//                                                                           false,
//                                                                       scrollGesturesEnabled:
//                                                                           false,
//                                                                       tiltGesturesEnabled:
//                                                                           false,
//                                                                       rotateGesturesEnabled:
//                                                                           false,
//                                                                       zoomControlsEnabled:
//                                                                           false,
//                                                                       initialCameraPosition:
//                                                                           const CameraPosition(
//                                                                         target: LatLng(
//                                                                             35.363149,
//                                                                             35.932120),
//                                                                         zoom:
//                                                                             13,
//                                                                       ),
//                                                                       markers: {
//                                                                         Marker(
//                                                                           markerId:
//                                                                               const MarkerId("pickup"),
//                                                                           position: LatLng(
//                                                                               state.shipments[index].pickupCityLat!,
//                                                                               state.shipments[index].pickupCityLang!),
//                                                                           icon:
//                                                                               pickupicon,
//                                                                         ),
//                                                                         Marker(
//                                                                           markerId:
//                                                                               const MarkerId("delivery"),
//                                                                           position: LatLng(
//                                                                               state.shipments[index].deliveryCityLat!,
//                                                                               state.shipments[index].deliveryCityLang!),
//                                                                           icon:
//                                                                               deliveryicon,
//                                                                         ),
//                                                                       },
//                                                                       polylines: {
//                                                                         Polyline(
//                                                                           polylineId:
//                                                                               const PolylineId("route"),
//                                                                           points: activeShipmentProvider.polylineCoordinates.length > index
//                                                                               ? activeShipmentProvider.polylineCoordinates[index]
//                                                                               : [],
//                                                                           color:
//                                                                               AppColor.deepYellow,
//                                                                           width:
//                                                                               5,
//                                                                         ),
//                                                                       },
//                                                                       mapType:
//                                                                           MapType
//                                                                               .normal,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               ShipmentPathWidget(
//                                                                 loadDate: setLoadDate(state
//                                                                     .shipments[
//                                                                         index]
//                                                                     .pickupDate!),
//                                                                 pickupName: state
//                                                                     .shipments[
//                                                                         index]
//                                                                     .pickupCityLocation!,
//                                                                 deliveryName: state
//                                                                     .shipments[
//                                                                         index]
//                                                                     .deliveryCityLocation!,
//                                                                 width: MediaQuery.of(
//                                                                             context)
//                                                                         .size
//                                                                         .width *
//                                                                     .8,
//                                                                 pathwidth: MediaQuery.of(
//                                                                             context)
//                                                                         .size
//                                                                         .width *
//                                                                     .7,
//                                                               ).animate().slideX(
//                                                                   duration:
//                                                                       300.ms,
//                                                                   delay: 0.ms,
//                                                                   begin: 1,
//                                                                   end: 0,
//                                                                   curve: Curves
//                                                                       .easeInOutSine),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ).animate().slideX(
//                                                   duration: 350.ms,
//                                                   delay: 0.ms,
//                                                   begin: 1,
//                                                   end: 0,
//                                                   curve: Curves.easeInOutSine);
//                                             },
//                                           );
//                                   } else {
//                                     return Shimmer.fromColors(
//                                       baseColor: (Colors.grey[300])!,
//                                       highlightColor: (Colors.grey[100])!,
//                                       enabled: true,
//                                       direction: ShimmerDirection.ttb,
//                                       child: ListView.builder(
//                                         shrinkWrap: true,
//                                         itemBuilder: (_, __) => Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Container(
//                                               margin:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 15,
//                                                       vertical: 5),
//                                               height: 250.h,
//                                               width: double.infinity,
//                                               clipBehavior: Clip.antiAlias,
//                                               decoration: BoxDecoration(
//                                                 color: Colors.white,
//                                                 borderRadius:
//                                                     BorderRadius.circular(10),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         itemCount: 6,
//                                       ),
//                                     );
//                                   }
//                                 },
//                               );
//                             }),
//                           )
//                         : DriverActiveShipmentDetailsScreen(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   List<LatLng> getpolylineCoordinates(double d, double e, double f, double g) {
//     PolylinePoints polylinePoints = PolylinePoints();
//     List<LatLng> _polylineCoordinates = [];

//     polylinePoints
//         .getRouteBetweenCoordinates(
//       "AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w",
//       PointLatLng(d, e),
//       PointLatLng(f, g),
//     )
//         .then((result) {
//       if (result.points.isNotEmpty) {
//         result.points.forEach((element) {
//           _polylineCoordinates.add(
//             LatLng(
//               element.latitude,
//               element.longitude,
//             ),
//           );
//         });
//       }
//     });
//     return _polylineCoordinates;
//   }
// }
