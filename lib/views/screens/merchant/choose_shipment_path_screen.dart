// import 'dart:convert';
// import 'dart:io';

// import 'package:camion/Localization/app_localizations.dart';
// import 'package:camion/business_logic/cubit/locale_cubit.dart';
// import 'package:camion/data/models/place_model.dart';
// import 'package:camion/data/providers/add_shippment_provider.dart';
// import 'package:camion/data/services/places_service.dart';
// import 'package:camion/helpers/color_constants.dart';
// import 'package:camion/views/screens/merchant/add_shippment_pickup_map.dart';
// import 'package:camion/views/widgets/loading_indicator.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/services.dart' show rootBundle;

// class ChooseShippmentPathScreen extends StatefulWidget {
//   ChooseShippmentPathScreen({Key? key}) : super(key: key);
//   @override
//   State<ChooseShippmentPathScreen> createState() =>
//       _ChooseShippmentPathScreenState();
// }

// class _ChooseShippmentPathScreenState extends State<ChooseShippmentPathScreen> {
//   List<PlaceSearch> searchResults = [];

//   bool pickupLoading = false;
//   bool deliveryLoading = false;

//   bool pickupPosition = false;
//   bool deliveryPosition = false;

//   AddShippmentProvider? addShippmentProvider;

//   late BitmapDescriptor pickupicon;
//   late BitmapDescriptor deliveryicon;

//   String _mapStyle = "";

//   createMarkerIcons() async {
//     pickupicon = await BitmapDescriptor.fromAssetImage(
//         const ImageConfiguration(), "assets/icons/location1.png");
//     deliveryicon = await BitmapDescriptor.fromAssetImage(
//         const ImageConfiguration(), "assets/icons/location2.png");
//     setState(() {});
//   }

//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       addShippmentProvider =
//           Provider.of<AddShippmentProvider>(context, listen: false);
//       addShippmentProvider!.initMapbounds();
//       createMarkerIcons();
//     });
//     rootBundle.loadString('assets/style/normal_style.json').then((string) {
//       _mapStyle = string;
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     addShippmentProvider!.dispose();
//     super.dispose();
//   }

//   Future<bool> _handleLocationPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text(
//               'Location services are disabled. Please enable the services')));
//       // setState(() {
//       //   pickupLoading = false;
//       // });
//       // return false;
//     }
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Location permissions are denied')));
//         setState(() {
//           pickupLoading = false;
//         });
//         return false;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text(
//               'Location permissions are permanently denied, we cannot request permissions.')));
//       setState(() {
//         pickupLoading = false;
//       });
//       return false;
//     }
//     return true;
//   }

//   Future<void> _getCurrentPositionForPickup() async {
//     final hasPermission = await _handleLocationPermission();
//     print(hasPermission);
//     if (!hasPermission) return;
//     await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
//         .then((Position position) {
//       print(position);
//       addShippmentProvider!
//           .setPickupLatLang(position.latitude, position.longitude);
//       addShippmentProvider!.setPickUpPosition(position);
//       _getAddressForPickupFromLatLng(position);
//     }).catchError((e) {
//       setState(() {
//         pickupLoading = false;
//       });
//       debugPrint(e);
//     });
//   }

//   Future<void> _getAddressForPickupFromLatLng(Position position) async {
//     var response = await http.get(
//       Uri.parse(
//           "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
//     );
//     print(response.statusCode);
//     if (response.statusCode == 200) {
//       var result = jsonDecode(response.body);
//       addShippmentProvider!.setPickupName(
//           result["results"][0]["address_components"][1]["long_name"]);
//       addShippmentProvider!.pickup_controller.text =
//           result["results"][0]["address_components"][1]["long_name"];
//     }
//     setState(() {
//       pickupLoading = false;
//     });
//   }

//   Future<void> _getCurrentPositionForDelivery() async {
//     final hasPermission = await _handleLocationPermission();
//     if (!hasPermission) return;
//     await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
//         .then((Position position) {
//       addShippmentProvider!
//           .setDeliveryLatLang(position.latitude, position.longitude);
//       addShippmentProvider!.setDeliveryPosition(position);
//       _getAddressForDeliveryFromLatLng(position);
//     }).catchError((e) {
//       setState(() {
//         deliveryLoading = false;
//       });
//       debugPrint(e);
//     });
//   }

//   Future<void> _getAddressForDeliveryFromLatLng(Position position) async {
//     var response = await http.get(
//       Uri.parse(
//           "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyADOoc8dgS4K4_qk9Hyp441jWtDSumfU7w"),
//     );
//     if (response.statusCode == 200) {
//       var result = jsonDecode(response.body);
//       addShippmentProvider!.setDeliveryName(
//           result["results"][0]["address_components"][1]["long_name"]);
//       addShippmentProvider!.delivery_controller.text =
//           result["results"][0]["address_components"][1]["long_name"];
//     }
//     setState(() {
//       deliveryLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LocaleCubit, LocaleState>(
//       builder: (context, localeState) {
//         return Directionality(
//           textDirection: localeState.value.languageCode == 'en'
//               ? TextDirection.ltr
//               : TextDirection.rtl,
//           child: SafeArea(
//             child: Scaffold(
//               appBar: AppBar(
//                 title: Text(
//                   AppLocalizations.of(context)!
//                       .translate('choose_shippment_path'),
//                   style: TextStyle(
//                     // color: AppColor.lightBlue,
//                     fontSize: 19.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               backgroundColor: Colors.white,
//               body: SingleChildScrollView(
//                 child: Consumer<AddShippmentProvider>(
//                     builder: (context, addshipmentprovider, child) {
//                   addshipmentprovider.initMapbounds();

//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           height: 20.h,
//                         ),
//                         TypeAheadField(
//                           textFieldConfiguration: TextFieldConfiguration(
//                             // autofocus: true,
//                             keyboardType: TextInputType.multiline,
//                             maxLines: null,
//                             controller: addshipmentprovider!.pickup_controller,
//                             scrollPadding: EdgeInsets.only(
//                                 bottom:
//                                     MediaQuery.of(context).viewInsets.bottom +
//                                         150),
//                             onTap: () {
//                               addshipmentprovider!
//                                       .pickup_controller!.selection =
//                                   TextSelection(
//                                       baseOffset: 0,
//                                       extentOffset: addshipmentprovider!
//                                           .pickup_controller!
//                                           .value
//                                           .text
//                                           .length);
//                             },

//                             style: const TextStyle(fontSize: 18),
//                             decoration: InputDecoration(
//                               labelText: AppLocalizations.of(context)!
//                                   .translate('pickup_address'),
//                               hintText: AppLocalizations.of(context)!
//                                   .translate('enter_pickup_address'),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 9.0,
//                                 vertical: 11.0,
//                               ),
//                               suffixIcon: InkWell(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           ShippmentPickUpMapScreen(
//                                               type: 0,
//                                               location: addshipmentprovider
//                                                       .pickup_latlng ??
//                                                   null),
//                                     ),
//                                   ).then((value) => FocusManager
//                                       .instance.primaryFocus
//                                       ?.unfocus());
//                                   // Get.to(SearchFilterView());
//                                 },
//                                 child: Container(
//                                   margin: const EdgeInsets.all(7),
//                                   width: 55.0,
//                                   height: 15.0,
//                                   child: Icon(
//                                     Icons.map,
//                                     color: AppColor.deepYellow,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             onSubmitted: (value) {
//                               // BlocProvider.of<StopScrollCubit>(context)
//                               //     .emitEnable();
//                               FocusManager.instance.primaryFocus?.unfocus();
//                             },
//                           ),
//                           loadingBuilder: (context) {
//                             return Container(
//                               color: Colors.white,
//                               child: const Center(
//                                 child: LoadingIndicator(),
//                               ),
//                             );
//                           },
//                           errorBuilder: (context, error) {
//                             return Container(
//                               color: Colors.white,
//                             );
//                           },
//                           noItemsFoundBuilder: (value) {
//                             var localizedMessage = AppLocalizations.of(context)!
//                                 .translate('no_result_found');
//                             return Container(
//                               width: double.infinity,
//                               color: Colors.white,
//                               child: Center(
//                                 child: Text(
//                                   localizedMessage,
//                                   style: TextStyle(fontSize: 18.sp),
//                                 ),
//                               ),
//                             );
//                           },
//                           suggestionsCallback: (pattern) async {
//                             // if (pattern.isNotEmpty) {
//                             //   BlocProvider.of<StopScrollCubit>(context)
//                             //       .emitDisable();
//                             // }
//                             return pattern.isEmpty
//                                 ? []
//                                 : await PlaceService.getAutocomplete(pattern);
//                           },
//                           itemBuilder: (context, suggestion) {
//                             return Container(
//                               color: Colors.white,
//                               child: Column(
//                                 children: [
//                                   ListTile(
//                                     // leading: Icon(Icons.shopping_cart),
//                                     tileColor: Colors.white,
//                                     title: Text(suggestion.description!),
//                                     // subtitle: Text('\$${suggestion['price']}'),
//                                   ),
//                                   Divider(
//                                     color: Colors.grey[300],
//                                     height: 3,
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                           onSuggestionSelected: (suggestion) async {
//                             var sLocation =
//                                 await PlaceService.getPlace(suggestion.placeId);
//                             setState(() {
//                               addshipmentprovider.setPickUpPlace(sLocation);
//                               addshipmentprovider.setPickupLatLang(
//                                   sLocation.geometry.location.lat,
//                                   sLocation.geometry.location.lng);
//                               addshipmentprovider
//                                   .setPickupName(suggestion.description);
//                               addshipmentprovider!.pickup_controller!.text =
//                                   suggestion.description;
//                             });
//                             FocusManager.instance.primaryFocus?.unfocus();
//                           },
//                         ),
//                         const SizedBox(
//                           height: 5,
//                         ),
//                         Visibility(
//                           visible: !deliveryPosition,
//                           child: !pickupLoading
//                               ? InkWell(
//                                   onTap: () {
//                                     setState(() {
//                                       pickupLoading = true;
//                                       pickupPosition = true;
//                                     });
//                                     _getCurrentPositionForPickup();
//                                   },
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       Icon(
//                                         Icons.location_on,
//                                         color: AppColor.deepYellow,
//                                       ),
//                                       SizedBox(
//                                         width: 5.w,
//                                       ),
//                                       Text(
//                                         AppLocalizations.of(context)!
//                                             .translate('pick_my_location'),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               : const Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     SizedBox(
//                                       height: 25,
//                                       width: 25,
//                                       child: LoadingIndicator(),
//                                     ),
//                                   ],
//                                 ),
//                         ),
//                         const SizedBox(
//                           height: 12,
//                         ),
//                         Visibility(
//                           visible: addshipmentprovider
//                               .pickup_controller!.text.isNotEmpty,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(
//                                 height: 5,
//                               ),
//                               TypeAheadField(
//                                 textFieldConfiguration: TextFieldConfiguration(
//                                   // autofocus: true,
//                                   keyboardType: TextInputType.multiline,
//                                   maxLines: null,
//                                   controller:
//                                       addshipmentprovider!.delivery_controller,
//                                   scrollPadding: EdgeInsets.only(
//                                       bottom: MediaQuery.of(context)
//                                               .viewInsets
//                                               .bottom +
//                                           150),
//                                   onTap: () {
//                                     addshipmentprovider!
//                                             .delivery_controller!.selection =
//                                         TextSelection(
//                                             baseOffset: 0,
//                                             extentOffset: addshipmentprovider!
//                                                 .delivery_controller!
//                                                 .value
//                                                 .text
//                                                 .length);
//                                   },

//                                   style: const TextStyle(fontSize: 18),
//                                   decoration: InputDecoration(
//                                     labelText: AppLocalizations.of(context)!
//                                         .translate('delivery_address'),
//                                     hintText: AppLocalizations.of(context)!
//                                         .translate('enter_delivery_address'),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 9.0,
//                                       vertical: 11.0,
//                                     ),
//                                     suffixIcon: InkWell(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 ShippmentPickUpMapScreen(
//                                                     type: 1,
//                                                     location: addshipmentprovider
//                                                             .delivery_latlng ??
//                                                         null),
//                                           ),
//                                         ).then((value) => FocusManager
//                                             .instance.primaryFocus
//                                             ?.unfocus());
//                                         // Get.to(SearchFilterView());
//                                       },
//                                       child: Container(
//                                         margin: const EdgeInsets.all(7),
//                                         width: 55.0,
//                                         height: 15.0,
//                                         // decoration: new BoxDecoration(
//                                         //   borderRadius: BorderRadius.circular(10),
//                                         //   border: Border.all(
//                                         //       color: Colors.black87, width: 1),
//                                         // ),
//                                         child: Icon(
//                                           Icons.map,
//                                           color: AppColor.deepYellow,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   onSubmitted: (value) {
//                                     // BlocProvider.of<StopScrollCubit>(context)
//                                     //     .emitEnable();
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                   },
//                                 ),
//                                 loadingBuilder: (context) {
//                                   return Container(
//                                     color: Colors.white,
//                                     child: const Center(
//                                       child: LoadingIndicator(),
//                                     ),
//                                   );
//                                 },
//                                 errorBuilder: (context, error) {
//                                   return Container(
//                                     color: Colors.white,
//                                   );
//                                 },
//                                 noItemsFoundBuilder: (value) {
//                                   var localizedMessage =
//                                       AppLocalizations.of(context)!
//                                           .translate('no_result_found');
//                                   return Container(
//                                     width: double.infinity,
//                                     color: Colors.white,
//                                     child: Center(
//                                       child: Text(
//                                         localizedMessage,
//                                         style: TextStyle(fontSize: 18.sp),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 suggestionsCallback: (pattern) async {
//                                   // if (pattern.isNotEmpty) {
//                                   //   BlocProvider.of<StopScrollCubit>(context)
//                                   //       .emitDisable();
//                                   // }
//                                   return pattern.isEmpty
//                                       ? []
//                                       : await PlaceService.getAutocomplete(
//                                           pattern);
//                                 },
//                                 itemBuilder: (context, suggestion) {
//                                   return Container(
//                                     color: Colors.white,
//                                     child: Column(
//                                       children: [
//                                         ListTile(
//                                           // leading: Icon(Icons.shopping_cart),
//                                           tileColor: Colors.white,
//                                           title: Text(suggestion.description!),
//                                           // subtitle: Text('\$${suggestion['price']}'),
//                                         ),
//                                         Divider(
//                                           color: Colors.grey[300],
//                                           height: 3,
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                                 onSuggestionSelected: (suggestion) async {
//                                   var sLocation = await PlaceService.getPlace(
//                                       suggestion.placeId);
//                                   setState(() {
//                                     addshipmentprovider
//                                         .setDeliveryPlace(sLocation);
//                                     addshipmentprovider.setDeliveryLatLang(
//                                         sLocation.geometry.location.lat,
//                                         sLocation.geometry.location.lng);
//                                     addshipmentprovider.setDeliveryName(
//                                         suggestion.description);
//                                     addshipmentprovider!.delivery_controller!
//                                         .text = suggestion.description;
//                                   });

//                                   FocusManager.instance.primaryFocus?.unfocus();
//                                 },
//                               ),
//                               const SizedBox(
//                                 height: 5,
//                               ),
//                               Visibility(
//                                 visible: !pickupPosition,
//                                 child: !deliveryLoading
//                                     ? InkWell(
//                                         onTap: () {
//                                           setState(() {
//                                             deliveryLoading = true;
//                                             deliveryPosition = true;
//                                           });
//                                           _getCurrentPositionForDelivery();
//                                         },
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: [
//                                             Icon(
//                                               Icons.location_on,
//                                               color: AppColor.deepYellow,
//                                             ),
//                                             SizedBox(
//                                               width: 5.w,
//                                             ),
//                                             Text(
//                                               AppLocalizations.of(context)!
//                                                   .translate(
//                                                       'pick_my_location'),
//                                             ),
//                                           ],
//                                         ),
//                                       )
//                                     : const Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         children: [
//                                           SizedBox(
//                                             height: 25,
//                                             width: 25,
//                                             child: LoadingIndicator(),
//                                           ),
//                                         ],
//                                       ),
//                               ),
//                               const SizedBox(
//                                 height: 12,
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(
//                           height: 25,
//                         ),
//                         Visibility(
//                           visible: addshipmentprovider
//                                   .pickup_controller!.text.isNotEmpty ||
//                               addshipmentprovider
//                                   .delivery_controller!.text.isNotEmpty,
//                           child: SizedBox(
//                             height: 300.h,
//                             child: AbsorbPointer(
//                               absorbing: false,
//                               child: GoogleMap(
//                                 onMapCreated: (controller) {
//                                   addshipmentprovider.onMapCreated(
//                                       controller, _mapStyle);
//                                   addshipmentprovider.updateMap(
//                                       addshipmentprovider.pickup_latlng!);
//                                 },
//                                 myLocationButtonEnabled: false,
//                                 zoomGesturesEnabled: false,
//                                 scrollGesturesEnabled: false,
//                                 tiltGesturesEnabled: false,
//                                 rotateGesturesEnabled: false,
//                                 // zoomControlsEnabled: false,
//                                 initialCameraPosition: CameraPosition(
//                                   target: addshipmentprovider.center,
//                                   zoom: addshipmentprovider.zoom,
//                                 ),
//                                 gestureRecognizers: {},
//                                 markers: (addshipmentprovider.pickup_latlng !=
//                                             null ||
//                                         addshipmentprovider.delivery_latlng !=
//                                             null)
//                                     ? {
//                                         addshipmentprovider.pickup_latlng !=
//                                                 null
//                                             ? Marker(
//                                                 markerId:
//                                                     const MarkerId("pickup"),
//                                                 position: LatLng(
//                                                     addshipmentprovider
//                                                         .pickup_lat,
//                                                     addshipmentprovider
//                                                         .pickup_lang),
//                                                 icon: pickupicon,
//                                               )
//                                             : const Marker(
//                                                 markerId: MarkerId("pickup"),
//                                               ),
//                                         addshipmentprovider.delivery_latlng !=
//                                                 null
//                                             ? Marker(
//                                                 markerId:
//                                                     const MarkerId("delivery"),
//                                                 position: LatLng(
//                                                     addshipmentprovider
//                                                         .delivery_lat,
//                                                     addshipmentprovider
//                                                         .delivery_lang),
//                                                 icon: deliveryicon,
//                                               )
//                                             : const Marker(
//                                                 markerId: MarkerId("delivery"),
//                                               ),
//                                       }
//                                     : {},
//                                 polylines: addshipmentprovider
//                                         .polylineCoordinates.isNotEmpty
//                                     ? {
//                                         Polyline(
//                                           polylineId: const PolylineId("route"),
//                                           points: addshipmentprovider
//                                               .polylineCoordinates,
//                                           color: AppColor.deepYellow,
//                                           width: 5,
//                                         ),
//                                       }
//                                     : {},
//                                 mapType: addshipmentprovider.mapType,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void setPickupLocation(String placeId) async {
//     var sLocation = await PlaceService.getPlace(placeId);
//     setState(() {
//       searchResults = [];
//     });
//     // _selectedLocation = Rxn(sLocation);
//     // _selectedLocationStatic = Rxn(sLocation);
//     // if (selectedLocation.value != null) {
//     //   _goToPlace(selectedLocation.value!);
//     // }
//   }
//   // Future<void> _goToPlace(Place place) async {
//   //   _googleMapController.animateCamera(
//   //     CameraUpdate.newCameraPosition(
//   //       CameraPosition(
//   //           target: LatLng(
//   //               place.geometry.location.lat, place.geometry.location.lng),
//   //           zoom: 14.0),
//   //     ),
//   //   );
//   // }
// }
