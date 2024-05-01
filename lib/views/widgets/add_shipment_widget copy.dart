// import 'dart:convert';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:camion/Localization/app_localizations.dart';
// import 'package:camion/business_logic/bloc/core/commodity_category_bloc.dart';
// import 'package:camion/business_logic/bloc/shipments/shipment_multi_create_bloc.dart';
// import 'package:camion/business_logic/bloc/truck/truck_type_bloc.dart';
// import 'package:camion/business_logic/bloc/truck/trucks_list_bloc.dart';
// import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
// import 'package:camion/business_logic/cubit/locale_cubit.dart';
// import 'package:camion/data/models/commodity_category_model.dart';
// import 'package:camion/data/models/shipmentv2_model.dart';
// import 'package:camion/data/providers/add_multi_shipment_provider.dart';
// import 'package:camion/data/services/places_service.dart';
// import 'package:camion/helpers/color_constants.dart';
// import 'package:camion/helpers/formatter.dart';
// import 'package:camion/views/screens/merchant/add_multishipment_map_picker.dart';
// import 'package:camion/views/screens/merchant/select_truck_multi_path_screen.dart';
// import 'package:camion/views/widgets/custom_botton.dart';
// import 'package:camion/views/widgets/loading_indicator.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:ensure_visible_when_focused/ensure_visible_when_focused.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:intl/intl.dart' as intel;
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:flutter/cupertino.dart' as cupertino;

// class AddMultiShipmentScreen extends StatefulWidget {
//   AddMultiShipmentScreen({Key? key}) : super(key: key);

//   @override
//   State<AddMultiShipmentScreen> createState() => _AddMultiShipmentScreenState();
// }

// class _AddMultiShipmentScreenState extends State<AddMultiShipmentScreen> {
//   // final ScrollController _scrollController = ScrollController();
//   final FocusNode _nodeCommodityWeight = FocusNode();

//   final FocusNode _commodity_node = FocusNode();
//   // final FocusNode _truck_node = FocusNode();

//   // List<bool> co2Loading = [false];
//   // List<bool> co2error = [false];

//   var key1 = GlobalKey();
//   var key2 = GlobalKey();

//   int mapIndex = 0;
//   int truckIndex = 0;

//   String _mapStyle = "";
//   String _darkmapStyle = "";

//   late BitmapDescriptor pickupicon;
//   late BitmapDescriptor deliveryicon;
//   final ScrollController _scrollController = ScrollController();

//   createMarkerIcons() async {
//     pickupicon = await BitmapDescriptor.fromAssetImage(
//         const ImageConfiguration(), "assets/icons/location1.png");
//     deliveryicon = await BitmapDescriptor.fromAssetImage(
//         const ImageConfiguration(), "assets/icons/location2.png");
//     setState(() {});
//   }

//   var f = intel.NumberFormat("#,###", "en_US");

//   _showDatePicker(int index) {
//     cupertino.showCupertinoModalPopup(
//       context: context,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//             color: Colors.white,
//             border:
//                 Border(top: BorderSide(color: AppColor.deepYellow, width: 2))),
//         height: MediaQuery.of(context).size.height * .4,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextButton(
//                 onPressed: () {
//                   addShippmentProvider!.setLoadDate(
//                       addShippmentProvider!.loadDate[index], index);

//                   Navigator.pop(context);
//                 },
//                 child: Text(
//                   AppLocalizations.of(context)!.translate('ok'),
//                   style: TextStyle(
//                     color: AppColor.darkGrey,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 )),
//             Expanded(
//               child: Localizations(
//                 locale: const Locale('en', ''),
//                 delegates: const [
//                   GlobalMaterialLocalizations.delegate,
//                   GlobalWidgetsLocalizations.delegate,
//                   GlobalCupertinoLocalizations.delegate,
//                 ],
//                 child: cupertino.CupertinoDatePicker(
//                   backgroundColor: Colors.white10,
//                   initialDateTime: addShippmentProvider!.loadDate[index],
//                   mode: cupertino.CupertinoDatePickerMode.date,
//                   minimumYear: DateTime.now().year,
//                   minimumDate: DateTime.now().subtract(const Duration(days: 1)),
//                   maximumYear: DateTime.now().year + 1,
//                   onDateTimeChanged: (value) {
//                     // loadDate = value;
//                     addShippmentProvider!.setLoadDate(value, index);
//                     // order_brokerProvider!.setProductDate(value);
//                     // order_brokerProvider!.setDateError(false);
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   _showTimePicker(int index) {
//     cupertino.showCupertinoModalPopup(
//       context: context,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//             color: Colors.white,
//             border:
//                 Border(top: BorderSide(color: AppColor.deepYellow, width: 2))),
//         height: MediaQuery.of(context).size.height * .4,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextButton(
//                 onPressed: () {
//                   addShippmentProvider!.setLoadTime(
//                       addShippmentProvider!.loadTime[index], index);

//                   Navigator.pop(context);
//                 },
//                 child: Text(
//                   AppLocalizations.of(context)!.translate('ok'),
//                   style: TextStyle(
//                     color: AppColor.darkGrey,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 )),
//             Expanded(
//               child: Localizations(
//                 locale: const Locale('en', ''),
//                 delegates: const [
//                   GlobalMaterialLocalizations.delegate,
//                   GlobalWidgetsLocalizations.delegate,
//                   GlobalCupertinoLocalizations.delegate,
//                 ],
//                 child: cupertino.CupertinoDatePicker(
//                   backgroundColor: Colors.white10,
//                   initialDateTime: addShippmentProvider!.loadTime[index],
//                   mode: cupertino.CupertinoDatePickerMode.time,
//                   onDateTimeChanged: (value) {
//                     // loadTime = value;
//                     addShippmentProvider!.setLoadTime(value, index);

//                     // order_brokerProvider!.setProductDate(value);
//                     // order_brokerProvider!.setDateError(false);
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       addShippmentProvider =
//           Provider.of<AddMultiShipmentProvider>(context, listen: false);
//       addShippmentProvider!.initShipment();

//       createMarkerIcons();
//     });

//     rootBundle.loadString('assets/style/normal_style.json').then((string) {
//       _mapStyle = string;
//     });
//     rootBundle.loadString('assets/style/map_style.json').then((string) {
//       _darkmapStyle = string;
//     });
//   }

//   AddMultiShipmentProvider? addShippmentProvider;

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LocaleCubit, LocaleState>(
//       builder: (context, localeState) {
//         return Directionality(
//           textDirection: localeState.value.languageCode == 'en'
//               ? TextDirection.ltr
//               : TextDirection.rtl,
//           child: Consumer<AddMultiShipmentProvider>(
//             builder: (context, shipmentProvider, child) {
//               return Scaffold(
//                 backgroundColor: AppColor.lightGrey200,
//                 body: SingleChildScrollView(
//                   // controller: controller,
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                       bottom: 40,
//                     ),
//                     child: Column(
//                       children: [
//                         ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: shipmentProvider.countpath,
//                           itemBuilder: (context, index) {
//                             return Stack(
//                               clipBehavior: Clip.none,
//                               children: [
//                                 Card(
//                                   color: Colors.grey[100],
//                                   margin: const EdgeInsets.all(5),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(2.0),
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 8.0, vertical: 4),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 2.5),
//                                                 child: Card(
//                                                   color: Colors.white,
//                                                   child: Padding(
//                                                     padding: const EdgeInsets
//                                                         .symmetric(
//                                                         horizontal: 10.0,
//                                                         vertical: 7.5),
//                                                     child: Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         InkWell(
//                                                           onTap: () {
//                                                             mapIndex = index;
//                                                             var provider = Provider
//                                                                 .of<AddMultiShipmentProvider>(
//                                                                     context,
//                                                                     listen:
//                                                                         false);
//                                                             showModalBottomSheet(
//                                                               context: context,
//                                                               isScrollControlled:
//                                                                   true,
//                                                               useSafeArea: true,
//                                                               builder: (context) =>
//                                                                   Consumer<
//                                                                       AddMultiShipmentProvider>(
//                                                                 builder: (context,
//                                                                     valueProvider,
//                                                                     child) {
//                                                                   return Container(
//                                                                     padding:
//                                                                         const EdgeInsets
//                                                                             .all(
//                                                                             8.0),
//                                                                     constraints: BoxConstraints(
//                                                                         maxHeight: MediaQuery.of(context)
//                                                                             .size
//                                                                             .height),
//                                                                     width: double
//                                                                         .infinity,
//                                                                     child:
//                                                                         Column(
//                                                                       crossAxisAlignment:
//                                                                           CrossAxisAlignment
//                                                                               .start,
//                                                                       children: [
//                                                                         SizedBox(
//                                                                           height:
//                                                                               15.h,
//                                                                         ),
//                                                                         TypeAheadField(
//                                                                           textFieldConfiguration:
//                                                                               TextFieldConfiguration(
//                                                                             // autofocus: true,
//                                                                             keyboardType:
//                                                                                 TextInputType.multiline,
//                                                                             maxLines:
//                                                                                 null,
//                                                                             controller:
//                                                                                 valueProvider.pickup_controller[index],
//                                                                             scrollPadding:
//                                                                                 EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 150),
//                                                                             onTap:
//                                                                                 () {
//                                                                               valueProvider.pickup_controller[index].selection = TextSelection(baseOffset: 0, extentOffset: valueProvider.pickup_controller[index].value.text.length);
//                                                                             },
//                                                                             style:
//                                                                                 const TextStyle(fontSize: 18),
//                                                                             decoration:
//                                                                                 InputDecoration(
//                                                                               hintText: AppLocalizations.of(context)!.translate('enter_pickup_address'),
//                                                                               contentPadding: const EdgeInsets.symmetric(
//                                                                                 horizontal: 9.0,
//                                                                                 vertical: 11.0,
//                                                                               ),
//                                                                               suffixIcon: InkWell(
//                                                                                 onTap: () {
//                                                                                   Navigator.push(
//                                                                                     context,
//                                                                                     MaterialPageRoute(
//                                                                                       builder: (context) => MultiShippmentPickUpMapScreen(
//                                                                                         type: 0,
//                                                                                         index: index,
//                                                                                         location: valueProvider.pickup_latlng[index],
//                                                                                       ),
//                                                                                     ),
//                                                                                   ).then((value) => FocusManager.instance.primaryFocus?.unfocus());
//                                                                                   Future.delayed(const Duration(milliseconds: 1500)).then((value) {
//                                                                                     // if (evaluateCo2()) {
//                                                                                     //   calculateCo2Report();
//                                                                                     // }
//                                                                                   });
//                                                                                 },
//                                                                                 child: Container(
//                                                                                   margin: const EdgeInsets.all(7),
//                                                                                   width: 55.0,
//                                                                                   height: 15.0,
//                                                                                   child: Icon(
//                                                                                     Icons.map,
//                                                                                     color: AppColor.deepYellow,
//                                                                                   ),
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                             onSubmitted:
//                                                                                 (value) {
//                                                                               // BlocProvider.of<StopScrollCubit>(context)
//                                                                               //     .emitEnable();
//                                                                               FocusManager.instance.primaryFocus?.unfocus();
//                                                                             },
//                                                                           ),
//                                                                           loadingBuilder:
//                                                                               (context) {
//                                                                             return Container(
//                                                                               color: Colors.white,
//                                                                               child: const Center(
//                                                                                 child: LoadingIndicator(),
//                                                                               ),
//                                                                             );
//                                                                           },
//                                                                           errorBuilder:
//                                                                               (context, error) {
//                                                                             return Container(
//                                                                               color: Colors.white,
//                                                                             );
//                                                                           },
//                                                                           noItemsFoundBuilder:
//                                                                               (value) {
//                                                                             var localizedMessage =
//                                                                                 AppLocalizations.of(context)!.translate('no_result_found');
//                                                                             return Container(
//                                                                               width: double.infinity,
//                                                                               color: Colors.white,
//                                                                               child: Center(
//                                                                                 child: Text(
//                                                                                   localizedMessage,
//                                                                                   style: TextStyle(fontSize: 18.sp),
//                                                                                 ),
//                                                                               ),
//                                                                             );
//                                                                           },
//                                                                           suggestionsCallback:
//                                                                               (pattern) async {
//                                                                             // if (pattern.isNotEmpty) {
//                                                                             //   BlocProvider.of<StopScrollCubit>(context)
//                                                                             //       .emitDisable();
//                                                                             // }
//                                                                             return pattern.isEmpty
//                                                                                 ? []
//                                                                                 : await PlaceService.getAutocomplete(pattern);
//                                                                           },
//                                                                           itemBuilder:
//                                                                               (context, suggestion) {
//                                                                             return Container(
//                                                                               color: Colors.white,
//                                                                               child: Column(
//                                                                                 children: [
//                                                                                   ListTile(
//                                                                                     // leading: Icon(Icons.shopping_cart),
//                                                                                     tileColor: Colors.white,
//                                                                                     title: Text(suggestion.description!),
//                                                                                     // subtitle: Text('\$${suggestion['price']}'),
//                                                                                   ),
//                                                                                   Divider(
//                                                                                     color: Colors.grey[300],
//                                                                                     height: 3,
//                                                                                   ),
//                                                                                 ],
//                                                                               ),
//                                                                             );
//                                                                           },
//                                                                           onSuggestionSelected:
//                                                                               (suggestion) async {
//                                                                             valueProvider.setPickupInfo(suggestion,
//                                                                                 index);

//                                                                             FocusManager.instance.primaryFocus?.unfocus();
//                                                                             // if (evaluateCo2()) {
//                                                                             //   calculateCo2Report();
//                                                                             // }
//                                                                           },
//                                                                         ),
//                                                                         const SizedBox(
//                                                                           height:
//                                                                               5,
//                                                                         ),
//                                                                         Visibility(
//                                                                           visible:
//                                                                               !valueProvider.deliveryPosition[index],
//                                                                           child: !valueProvider.pickupLoading[index]
//                                                                               ? InkWell(
//                                                                                   onTap: () {
//                                                                                     // _(() {
//                                                                                     //   pickupPosition[index] = true;
//                                                                                     //   pickupLoading[index] = true;
//                                                                                     // });
//                                                                                     valueProvider.setPickupLoading(true, index);
//                                                                                     valueProvider.setPickupPositionClick(true, index);

//                                                                                     valueProvider.getCurrentPositionForPickup(context, index).then(
//                                                                                       (value) {
//                                                                                         valueProvider.setPickupLoading(false, index);
//                                                                                         valueProvider.setPickupPositionClick(false, index);
//                                                                                       },
//                                                                                     );
//                                                                                   },
//                                                                                   child: Row(
//                                                                                     mainAxisAlignment: MainAxisAlignment.start,
//                                                                                     children: [
//                                                                                       Icon(
//                                                                                         Icons.location_on,
//                                                                                         color: AppColor.deepYellow,
//                                                                                       ),
//                                                                                       SizedBox(
//                                                                                         width: 5.w,
//                                                                                       ),
//                                                                                       Text(
//                                                                                         AppLocalizations.of(context)!.translate('pick_my_location'),
//                                                                                       ),
//                                                                                     ],
//                                                                                   ),
//                                                                                 )
//                                                                               : const Row(
//                                                                                   mainAxisAlignment: MainAxisAlignment.start,
//                                                                                   children: [
//                                                                                     SizedBox(
//                                                                                       height: 25,
//                                                                                       width: 25,
//                                                                                       child: LoadingIndicator(),
//                                                                                     ),
//                                                                                   ],
//                                                                                 ),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                           height:
//                                                                               12,
//                                                                         ),
//                                                                         Visibility(
//                                                                           visible:
//                                                                               valueProvider.pickup_controller[index].text.isNotEmpty && valueProvider.delivery_controller[index].text.isNotEmpty,
//                                                                           child: Column(
//                                                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                                                               children: [
//                                                                                 ListView.builder(
//                                                                                   shrinkWrap: true,
//                                                                                   itemCount: valueProvider.stoppoints_controller[index].length,
//                                                                                   itemBuilder: (context, index2) {
//                                                                                     return Column(
//                                                                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                                                                       children: [
//                                                                                         const SizedBox(
//                                                                                           height: 5,
//                                                                                         ),
//                                                                                         Row(
//                                                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                                           children: [
//                                                                                             SizedBox(
//                                                                                               width: MediaQuery.of(context).size.width * .85,
//                                                                                               child: TypeAheadField(
//                                                                                                 textFieldConfiguration: TextFieldConfiguration(
//                                                                                                   // autofocus: true,
//                                                                                                   keyboardType: TextInputType.multiline,
//                                                                                                   maxLines: null,
//                                                                                                   controller: valueProvider.stoppoints_controller[index][index2],
//                                                                                                   scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 150),
//                                                                                                   onTap: () {
//                                                                                                     valueProvider.stoppoints_controller[index][index2].selection = TextSelection(
//                                                                                                       baseOffset: 0,
//                                                                                                       extentOffset: valueProvider.stoppoints_controller[index][index2].value.text.length,
//                                                                                                     );
//                                                                                                   },

//                                                                                                   style: const TextStyle(fontSize: 18),
//                                                                                                   decoration: InputDecoration(
//                                                                                                     hintText: AppLocalizations.of(context)!.translate('enter_load\\unload_address'),
//                                                                                                     contentPadding: const EdgeInsets.symmetric(
//                                                                                                       horizontal: 9.0,
//                                                                                                       vertical: 11.0,
//                                                                                                     ),
//                                                                                                     suffixIcon: InkWell(
//                                                                                                       onTap: () {
//                                                                                                         // Navigator.push(
//                                                                                                         //   context,
//                                                                                                         //   MaterialPageRoute(
//                                                                                                         //     builder: (context) => MultiShippmentPickUpMapScreen(
//                                                                                                         //       type: 1,
//                                                                                                         //       index: index,
//                                                                                                         //       location: valueProvider.delivery_latlng[index],
//                                                                                                         //     ),
//                                                                                                         //   ),
//                                                                                                         // ).then((value) => FocusManager.instance.primaryFocus?.unfocus());

//                                                                                                         print("delivry address co2 evaluation");
//                                                                                                         // Get.to(SearchFilterView());
//                                                                                                         Future.delayed(const Duration(milliseconds: 1500)).then((value) {
//                                                                                                           // if (evaluateCo2()) {
//                                                                                                           //   calculateCo2Report();
//                                                                                                           // }
//                                                                                                         });
//                                                                                                       },
//                                                                                                       child: Container(
//                                                                                                         margin: const EdgeInsets.all(7),
//                                                                                                         width: 55.0,
//                                                                                                         height: 15.0,
//                                                                                                         // decoration: new BoxDecoration(
//                                                                                                         //   borderRadius: BorderRadius.circular(10),
//                                                                                                         //   border: Border.all(
//                                                                                                         //       color: Colors.black87, width: 1),
//                                                                                                         // ),
//                                                                                                         child: Icon(
//                                                                                                           Icons.map,
//                                                                                                           color: AppColor.deepYellow,
//                                                                                                         ),
//                                                                                                       ),
//                                                                                                     ),
//                                                                                                   ),
//                                                                                                   onSubmitted: (value) {
//                                                                                                     // BlocProvider.of<StopScrollCubit>(context)
//                                                                                                     //     .emitEnable();
//                                                                                                     FocusManager.instance.primaryFocus?.unfocus();
//                                                                                                   },
//                                                                                                 ),
//                                                                                                 loadingBuilder: (context) {
//                                                                                                   return Container(
//                                                                                                     color: Colors.white,
//                                                                                                     child: const Center(
//                                                                                                       child: LoadingIndicator(),
//                                                                                                     ),
//                                                                                                   );
//                                                                                                 },
//                                                                                                 errorBuilder: (context, error) {
//                                                                                                   return Container(
//                                                                                                     color: Colors.white,
//                                                                                                   );
//                                                                                                 },
//                                                                                                 noItemsFoundBuilder: (value) {
//                                                                                                   var localizedMessage = AppLocalizations.of(context)!.translate('no_result_found');
//                                                                                                   return Container(
//                                                                                                     width: double.infinity,
//                                                                                                     color: Colors.white,
//                                                                                                     child: Center(
//                                                                                                       child: Text(
//                                                                                                         localizedMessage,
//                                                                                                         style: TextStyle(fontSize: 18.sp),
//                                                                                                       ),
//                                                                                                     ),
//                                                                                                   );
//                                                                                                 },
//                                                                                                 suggestionsCallback: (pattern) async {
//                                                                                                   // if (pattern.isNotEmpty) {
//                                                                                                   //   BlocProvider.of<StopScrollCubit>(context)
//                                                                                                   //       .emitDisable();
//                                                                                                   // }
//                                                                                                   return pattern.isEmpty ? [] : await PlaceService.getAutocomplete(pattern);
//                                                                                                 },
//                                                                                                 itemBuilder: (context, suggestion) {
//                                                                                                   return Container(
//                                                                                                     color: Colors.white,
//                                                                                                     child: Column(
//                                                                                                       children: [
//                                                                                                         ListTile(
//                                                                                                           // leading: Icon(Icons.shopping_cart),
//                                                                                                           tileColor: Colors.white,
//                                                                                                           title: Text(suggestion.description!),
//                                                                                                           // subtitle: Text('\$${suggestion['price']}'),
//                                                                                                         ),
//                                                                                                         Divider(
//                                                                                                           color: Colors.grey[300],
//                                                                                                           height: 3,
//                                                                                                         ),
//                                                                                                       ],
//                                                                                                     ),
//                                                                                                   );
//                                                                                                 },
//                                                                                                 onSuggestionSelected: (suggestion) async {
//                                                                                                   valueProvider.setStopPointInfo(suggestion, index, index2);

//                                                                                                   FocusManager.instance.primaryFocus?.unfocus();
//                                                                                                   // if (evaluateCo2()) {
//                                                                                                   //   calculateCo2Report();
//                                                                                                   // }
//                                                                                                 },
//                                                                                               ),
//                                                                                             ),
//                                                                                             InkWell(
//                                                                                               onTap: () {
//                                                                                                 valueProvider.removestoppoint(index, index2);
//                                                                                                 // _showAlertDialog(index);
//                                                                                               },
//                                                                                               child: Container(
//                                                                                                 height: 30,
//                                                                                                 width: 30,
//                                                                                                 decoration: BoxDecoration(
//                                                                                                   color: Colors.red,
//                                                                                                   borderRadius: BorderRadius.circular(45),
//                                                                                                 ),
//                                                                                                 child: const Center(
//                                                                                                   child: Icon(
//                                                                                                     Icons.close,
//                                                                                                     color: Colors.white,
//                                                                                                   ),
//                                                                                                 ),
//                                                                                               ),
//                                                                                             ),
//                                                                                           ],
//                                                                                         ),
//                                                                                         const SizedBox(
//                                                                                           height: 5,
//                                                                                         ),
//                                                                                         InkWell(
//                                                                                           onTap: () {
//                                                                                             valueProvider.setStopPointLoading(true, index, index2);
//                                                                                             valueProvider.setStopPointPositionClick(true, index, index2);

//                                                                                             valueProvider.getCurrentPositionForStop(context, index, index2);

//                                                                                             // _getCurrentPositionForDelivery();
//                                                                                           },
//                                                                                           child: Row(
//                                                                                             mainAxisAlignment: MainAxisAlignment.start,
//                                                                                             children: [
//                                                                                               Icon(
//                                                                                                 Icons.location_on,
//                                                                                                 color: AppColor.deepYellow,
//                                                                                               ),
//                                                                                               SizedBox(
//                                                                                                 width: 5.w,
//                                                                                               ),
//                                                                                               Text(
//                                                                                                 AppLocalizations.of(context)!.translate('pick_my_location'),
//                                                                                               ),
//                                                                                             ],
//                                                                                           ),
//                                                                                         ),
//                                                                                         // const SizedBox(
//                                                                                         //   height: 12,
//                                                                                         // ),
//                                                                                       ],
//                                                                                     );
//                                                                                   },
//                                                                                 ),
//                                                                                 InkWell(
//                                                                                   onTap: () {
//                                                                                     valueProvider.addstoppoint(index);
//                                                                                   },
//                                                                                   child: AbsorbPointer(
//                                                                                     absorbing: true,
//                                                                                     child: Row(
//                                                                                       mainAxisAlignment: MainAxisAlignment.start,
//                                                                                       children: [
//                                                                                         Padding(
//                                                                                           padding: const EdgeInsets.all(8.0),
//                                                                                           child: SizedBox(
//                                                                                             height: 32.h,
//                                                                                             width: 32.w,
//                                                                                             child: SvgPicture.asset("assets/icons/add.svg"),
//                                                                                           ),
//                                                                                         ),
//                                                                                         const SizedBox(
//                                                                                           width: 7,
//                                                                                         ),
//                                                                                         Text("add check point")
//                                                                                       ],
//                                                                                     ),
//                                                                                   ),
//                                                                                 ),
//                                                                               ]),
//                                                                         ),
//                                                                         Visibility(
//                                                                           visible: valueProvider
//                                                                               .pickup_controller[index]
//                                                                               .text
//                                                                               .isNotEmpty,
//                                                                           child:
//                                                                               Column(
//                                                                             crossAxisAlignment:
//                                                                                 CrossAxisAlignment.start,
//                                                                             children: [
//                                                                               const SizedBox(
//                                                                                 height: 5,
//                                                                               ),
//                                                                               TypeAheadField(
//                                                                                 textFieldConfiguration: TextFieldConfiguration(
//                                                                                   // autofocus: true,
//                                                                                   keyboardType: TextInputType.multiline,
//                                                                                   maxLines: null,
//                                                                                   controller: valueProvider.delivery_controller[index],
//                                                                                   scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 150),
//                                                                                   onTap: () {
//                                                                                     valueProvider.delivery_controller[index].selection = TextSelection(
//                                                                                       baseOffset: 0,
//                                                                                       extentOffset: valueProvider.delivery_controller[index].value.text.length,
//                                                                                     );
//                                                                                   },

//                                                                                   style: const TextStyle(fontSize: 18),
//                                                                                   decoration: InputDecoration(
//                                                                                     hintText: AppLocalizations.of(context)!.translate('enter_delivery_address'),
//                                                                                     contentPadding: const EdgeInsets.symmetric(
//                                                                                       horizontal: 9.0,
//                                                                                       vertical: 11.0,
//                                                                                     ),
//                                                                                     suffixIcon: InkWell(
//                                                                                       onTap: () {
//                                                                                         Navigator.push(
//                                                                                           context,
//                                                                                           MaterialPageRoute(
//                                                                                             builder: (context) => MultiShippmentPickUpMapScreen(
//                                                                                               type: 1,
//                                                                                               index: index,
//                                                                                               location: valueProvider.delivery_latlng[index],
//                                                                                             ),
//                                                                                           ),
//                                                                                         ).then((value) => FocusManager.instance.primaryFocus?.unfocus());

//                                                                                         print("delivry address co2 evaluation");
//                                                                                         // Get.to(SearchFilterView());
//                                                                                         Future.delayed(const Duration(milliseconds: 1500)).then((value) {
//                                                                                           // if (evaluateCo2()) {
//                                                                                           //   calculateCo2Report();
//                                                                                           // }
//                                                                                         });
//                                                                                       },
//                                                                                       child: Container(
//                                                                                         margin: const EdgeInsets.all(7),
//                                                                                         width: 55.0,
//                                                                                         height: 15.0,
//                                                                                         // decoration: new BoxDecoration(
//                                                                                         //   borderRadius: BorderRadius.circular(10),
//                                                                                         //   border: Border.all(
//                                                                                         //       color: Colors.black87, width: 1),
//                                                                                         // ),
//                                                                                         child: Icon(
//                                                                                           Icons.map,
//                                                                                           color: AppColor.deepYellow,
//                                                                                         ),
//                                                                                       ),
//                                                                                     ),
//                                                                                   ),
//                                                                                   onSubmitted: (value) {
//                                                                                     // BlocProvider.of<StopScrollCubit>(context)
//                                                                                     //     .emitEnable();
//                                                                                     FocusManager.instance.primaryFocus?.unfocus();
//                                                                                   },
//                                                                                 ),
//                                                                                 loadingBuilder: (context) {
//                                                                                   return Container(
//                                                                                     color: Colors.white,
//                                                                                     child: const Center(
//                                                                                       child: LoadingIndicator(),
//                                                                                     ),
//                                                                                   );
//                                                                                 },
//                                                                                 errorBuilder: (context, error) {
//                                                                                   return Container(
//                                                                                     color: Colors.white,
//                                                                                   );
//                                                                                 },
//                                                                                 noItemsFoundBuilder: (value) {
//                                                                                   var localizedMessage = AppLocalizations.of(context)!.translate('no_result_found');
//                                                                                   return Container(
//                                                                                     width: double.infinity,
//                                                                                     color: Colors.white,
//                                                                                     child: Center(
//                                                                                       child: Text(
//                                                                                         localizedMessage,
//                                                                                         style: TextStyle(fontSize: 18.sp),
//                                                                                       ),
//                                                                                     ),
//                                                                                   );
//                                                                                 },
//                                                                                 suggestionsCallback: (pattern) async {
//                                                                                   // if (pattern.isNotEmpty) {
//                                                                                   //   BlocProvider.of<StopScrollCubit>(context)
//                                                                                   //       .emitDisable();
//                                                                                   // }
//                                                                                   return pattern.isEmpty ? [] : await PlaceService.getAutocomplete(pattern);
//                                                                                 },
//                                                                                 itemBuilder: (context, suggestion) {
//                                                                                   return Container(
//                                                                                     color: Colors.white,
//                                                                                     child: Column(
//                                                                                       children: [
//                                                                                         ListTile(
//                                                                                           // leading: Icon(Icons.shopping_cart),
//                                                                                           tileColor: Colors.white,
//                                                                                           title: Text(suggestion.description!),
//                                                                                           // subtitle: Text('\$${suggestion['price']}'),
//                                                                                         ),
//                                                                                         Divider(
//                                                                                           color: Colors.grey[300],
//                                                                                           height: 3,
//                                                                                         ),
//                                                                                       ],
//                                                                                     ),
//                                                                                   );
//                                                                                 },
//                                                                                 onSuggestionSelected: (suggestion) async {
//                                                                                   valueProvider.setDeliveryInfo(suggestion, index);

//                                                                                   FocusManager.instance.primaryFocus?.unfocus();
//                                                                                   // if (evaluateCo2()) {
//                                                                                   //   calculateCo2Report();
//                                                                                   // }
//                                                                                 },
//                                                                               ),
//                                                                               const SizedBox(
//                                                                                 height: 5,
//                                                                               ),
//                                                                               Visibility(
//                                                                                 visible: !valueProvider.pickupPosition[index],
//                                                                                 child: !valueProvider.deliveryLoading[index]
//                                                                                     ? InkWell(
//                                                                                         onTap: () {
//                                                                                           valueProvider.setDeliveryLoading(true, index);
//                                                                                           valueProvider.setDeliveryPositionClick(true, index);

//                                                                                           valueProvider.getCurrentPositionForDelivery(context, index);

//                                                                                           // _getCurrentPositionForDelivery();
//                                                                                         },
//                                                                                         child: Row(
//                                                                                           mainAxisAlignment: MainAxisAlignment.start,
//                                                                                           children: [
//                                                                                             Icon(
//                                                                                               Icons.location_on,
//                                                                                               color: AppColor.deepYellow,
//                                                                                             ),
//                                                                                             SizedBox(
//                                                                                               width: 5.w,
//                                                                                             ),
//                                                                                             Text(
//                                                                                               AppLocalizations.of(context)!.translate('pick_my_location'),
//                                                                                             ),
//                                                                                           ],
//                                                                                         ),
//                                                                                       )
//                                                                                     : const Row(
//                                                                                         mainAxisAlignment: MainAxisAlignment.start,
//                                                                                         children: [
//                                                                                           SizedBox(
//                                                                                             height: 25,
//                                                                                             width: 25,
//                                                                                             child: LoadingIndicator(),
//                                                                                           ),
//                                                                                         ],
//                                                                                       ),
//                                                                               ),
//                                                                               // const SizedBox(
//                                                                               //   height: 12,
//                                                                               // ),
//                                                                             ],
//                                                                           ),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   );
//                                                                 },
//                                                               ),
//                                                             );
//                                                           },
//                                                           child: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Text(
//                                                                 AppLocalizations.of(
//                                                                         context)!
//                                                                     .translate(
//                                                                         'choose_shippment_path'),
//                                                                 style:
//                                                                     TextStyle(
//                                                                   // color: AppColor.lightBlue,
//                                                                   fontSize:
//                                                                       19.sp,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                           height: 7.h,
//                                                         ),
//                                                         Visibility(
//                                                           visible: shipmentProvider
//                                                                   .pickup_controller[
//                                                                       index]
//                                                                   .text
//                                                                   .isNotEmpty &&
//                                                               shipmentProvider
//                                                                   .delivery_controller[
//                                                                       index]
//                                                                   .text
//                                                                   .isNotEmpty,
//                                                           child: Column(
//                                                             children: [
//                                                               const SizedBox(
//                                                                 height: 5,
//                                                               ),
//                                                               TextFormField(
//                                                                 controller:
//                                                                     shipmentProvider
//                                                                             .pickup_controller[
//                                                                         index],
//                                                                 enabled: false,
//                                                                 maxLines: null,
//                                                                 style:
//                                                                     const TextStyle(
//                                                                         fontSize:
//                                                                             18),
//                                                                 decoration:
//                                                                     InputDecoration(
//                                                                   labelText: AppLocalizations.of(
//                                                                           context)!
//                                                                       .translate(
//                                                                           'pickup_address'),
//                                                                   contentPadding:
//                                                                       const EdgeInsets
//                                                                           .symmetric(
//                                                                     horizontal:
//                                                                         9.0,
//                                                                     vertical:
//                                                                         11.0,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               const SizedBox(
//                                                                 height: 15,
//                                                               ),
//                                                               ListView.builder(
//                                                                 shrinkWrap:
//                                                                     true,
//                                                                 itemCount:
//                                                                     shipmentProvider
//                                                                         .stoppoints_controller[
//                                                                             index]
//                                                                         .length,
//                                                                 itemBuilder:
//                                                                     (context,
//                                                                         index2) {
//                                                                   return Column(
//                                                                     crossAxisAlignment:
//                                                                         CrossAxisAlignment
//                                                                             .start,
//                                                                     children: [
//                                                                       TextFormField(
//                                                                         controller:
//                                                                             shipmentProvider.stoppoints_controller[index][index2],
//                                                                         enabled:
//                                                                             false,
//                                                                         maxLines:
//                                                                             null,
//                                                                         style: const TextStyle(
//                                                                             fontSize:
//                                                                                 18),
//                                                                         decoration:
//                                                                             InputDecoration(
//                                                                           labelText:
//                                                                               AppLocalizations.of(context)!.translate('load\\unload_address') + (index2 + 1).toString(),
//                                                                           contentPadding:
//                                                                               const EdgeInsets.symmetric(
//                                                                             horizontal:
//                                                                                 9.0,
//                                                                             vertical:
//                                                                                 11.0,
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                       const SizedBox(
//                                                                         height:
//                                                                             12,
//                                                                       ),
//                                                                     ],
//                                                                   );
//                                                                 },
//                                                               ),
//                                                               TextFormField(
//                                                                 controller:
//                                                                     shipmentProvider
//                                                                             .delivery_controller[
//                                                                         index],
//                                                                 enabled: false,
//                                                                 maxLines: null,
//                                                                 style:
//                                                                     const TextStyle(
//                                                                         fontSize:
//                                                                             18),
//                                                                 decoration:
//                                                                     InputDecoration(
//                                                                   labelText: AppLocalizations.of(
//                                                                           context)!
//                                                                       .translate(
//                                                                           'delivery_address'),
//                                                                   contentPadding:
//                                                                       const EdgeInsets
//                                                                           .symmetric(
//                                                                     horizontal:
//                                                                         9.0,
//                                                                     vertical:
//                                                                         11.0,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               const SizedBox(
//                                                                 height: 5,
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         const SizedBox(
//                                                           height: 10,
//                                                         ),
//                                                         Visibility(
//                                                           visible:
//                                                               shipmentProvider
//                                                                       .pathError[
//                                                                   index],
//                                                           child: Column(
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .all(
//                                                                         8.0),
//                                                                 child: Text(
//                                                                   AppLocalizations.of(
//                                                                           context)!
//                                                                       .translate(
//                                                                           'choose_path_error'),
//                                                                   style:
//                                                                       const TextStyle(
//                                                                     color: Colors
//                                                                         .red,
//                                                                     fontSize:
//                                                                         17,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 2.5),
//                                                 child: Card(
//                                                   color: Colors.white,
//                                                   child: Padding(
//                                                     padding: const EdgeInsets
//                                                         .symmetric(
//                                                         horizontal: 10.0,
//                                                         vertical: 7.5),
//                                                     child: Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         InkWell(
//                                                           onTap: () {
//                                                             showModalBottomSheet(
//                                                               context: context,
//                                                               isScrollControlled:
//                                                                   true,
//                                                               useSafeArea: true,
//                                                               builder: (context) => Consumer<
//                                                                       AddMultiShipmentProvider>(
//                                                                   builder: (context,
//                                                                       truckProvider,
//                                                                       child) {
//                                                                 return Container(
//                                                                   padding:
//                                                                       const EdgeInsets
//                                                                           .all(
//                                                                           8.0),
//                                                                   constraints: BoxConstraints(
//                                                                       maxHeight: MediaQuery.of(
//                                                                               context)
//                                                                           .size
//                                                                           .height),
//                                                                   width: double
//                                                                       .infinity,
//                                                                   child: Column(
//                                                                     children: [
//                                                                       Padding(
//                                                                         padding: const EdgeInsets
//                                                                             .all(
//                                                                             8.0),
//                                                                         child:
//                                                                             Row(
//                                                                           mainAxisAlignment:
//                                                                               MainAxisAlignment.spaceBetween,
//                                                                           children: [
//                                                                             InkWell(
//                                                                               onTap: () {
//                                                                                 Navigator.pop(context);
//                                                                               },
//                                                                               child: AbsorbPointer(
//                                                                                 absorbing: false,
//                                                                                 child: Padding(
//                                                                                   padding: const EdgeInsets.all(8.0),
//                                                                                   child: localeState.value.countryCode == 'en' ? const Icon(Icons.arrow_forward) : const Icon(Icons.arrow_back),
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                             Text(
//                                                                               AppLocalizations.of(context)!.translate('select_truck_type'),
//                                                                               style: TextStyle(
//                                                                                 fontSize: 18.sp,
//                                                                                 fontWeight: FontWeight.bold,
//                                                                               ),
//                                                                             ),
//                                                                           ],
//                                                                         ),
//                                                                       ),
//                                                                       SizedBox(
//                                                                         height:
//                                                                             5.h,
//                                                                       ),
//                                                                       BlocBuilder<
//                                                                           TruckTypeBloc,
//                                                                           TruckTypeState>(
//                                                                         builder:
//                                                                             (context,
//                                                                                 state) {
//                                                                           if (state
//                                                                               is TruckTypeLoadedSuccess) {
//                                                                             return state.truckTypes.isEmpty
//                                                                                 ? Center(
//                                                                                     child: Text(AppLocalizations.of(context)!.translate('no_shipments')),
//                                                                                   )
//                                                                                 : Expanded(
//                                                                                     child: ListView.builder(
//                                                                                         shrinkWrap: true,
//                                                                                         itemBuilder: (context, index3) {
//                                                                                           return Column(
//                                                                                             children: [
//                                                                                               Padding(
//                                                                                                 padding: EdgeInsets.symmetric(
//                                                                                                   horizontal: 5.w,
//                                                                                                 ),
//                                                                                                 child: InkWell(
//                                                                                                   onTap: () {
//                                                                                                     FocusManager.instance.primaryFocus?.unfocus();
//                                                                                                     setState(() {
//                                                                                                       truckProvider.truckError[index] = false;
//                                                                                                       // truckNumControllers[previousIndex].text = "";
//                                                                                                       // trucknum[previousIndex] = 0;
//                                                                                                       // truckNumControllers[index].text = "1";
//                                                                                                       // trucknum[index][index3] = 1;
//                                                                                                       // truckType[index] = state.truckTypes[index].id!;
//                                                                                                       // // previousIndex = index;
//                                                                                                     });
//                                                                                                   },
//                                                                                                   child: Stack(
//                                                                                                     clipBehavior: Clip.none,
//                                                                                                     children: [
//                                                                                                       Container(
//                                                                                                         // width: 175.w,
//                                                                                                         // decoration: BoxDecoration(
//                                                                                                         //   borderRadius: BorderRadius.circular(7),
//                                                                                                         //   border: Border.all(
//                                                                                                         //     color: truckType == state.truckTypes[index].id! ? AppColor.deepYellow : AppColor.darkGrey,
//                                                                                                         //     width: 2.w,
//                                                                                                         //   ),
//                                                                                                         // ),
//                                                                                                         child: Row(
//                                                                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                                                           children: [
//                                                                                                             Checkbox(
//                                                                                                               onChanged: (checked) {
//                                                                                                                 if (!(checked ?? false)) {
//                                                                                                                   truckProvider.removeTruckType(state.truckTypes[index3].id!, index);
//                                                                                                                 } else {
//                                                                                                                   truckProvider.addTruckType(state.truckTypes[index3].id!, index);
//                                                                                                                 }
//                                                                                                               },
//                                                                                                               value: truckProvider.selectedTruckType[index].contains(state.truckTypes[index3].id),
//                                                                                                             ),
//                                                                                                             Column(
//                                                                                                               children: [
//                                                                                                                 SizedBox(
//                                                                                                                   height: 50.h,
//                                                                                                                   width: 175.w,
//                                                                                                                   child: CachedNetworkImage(
//                                                                                                                     imageUrl: state.truckTypes[index3].image!,
//                                                                                                                     progressIndicatorBuilder: (context, url, downloadProgress) => Shimmer.fromColors(
//                                                                                                                       baseColor: (Colors.grey[300])!,
//                                                                                                                       highlightColor: (Colors.grey[100])!,
//                                                                                                                       enabled: true,
//                                                                                                                       child: Container(
//                                                                                                                         height: 50.h,
//                                                                                                                         width: 175.w,
//                                                                                                                         color: Colors.white,
//                                                                                                                       ),
//                                                                                                                     ),
//                                                                                                                     errorWidget: (context, url, error) => Container(
//                                                                                                                       height: 50.h,
//                                                                                                                       width: 175.w,
//                                                                                                                       color: Colors.grey[300],
//                                                                                                                       child: Center(
//                                                                                                                         child: Text(AppLocalizations.of(context)!.translate('image_load_error')),
//                                                                                                                       ),
//                                                                                                                     ),
//                                                                                                                   ),
//                                                                                                                 ),
//                                                                                                                 SizedBox(
//                                                                                                                   height: 7.h,
//                                                                                                                 ),
//                                                                                                                 Text(
//                                                                                                                   localeState.value.languageCode == 'en' ? state.truckTypes[index3].name! : state.truckTypes[index3].nameAr!,
//                                                                                                                   style: TextStyle(
//                                                                                                                     fontSize: 17.sp,
//                                                                                                                     color: AppColor.deepBlack,
//                                                                                                                   ),
//                                                                                                                 ),
//                                                                                                               ],
//                                                                                                             ),
//                                                                                                             SizedBox(
//                                                                                                               height: 7.h,
//                                                                                                             ),
//                                                                                                             Padding(
//                                                                                                               padding: EdgeInsets.symmetric(horizontal: 5.w),
//                                                                                                               child: Row(
//                                                                                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                                                                 children: [
//                                                                                                                   InkWell(
//                                                                                                                     onTap: () {
//                                                                                                                       if (truckProvider.selectedTruckType[index].contains(state.truckTypes[index3].id)) {
//                                                                                                                         truckProvider.increaseTruckType(state.truckTypes[index3].id!, index);
//                                                                                                                       }
//                                                                                                                     },
//                                                                                                                     child: Container(
//                                                                                                                       padding: const EdgeInsets.all(3),
//                                                                                                                       decoration: BoxDecoration(
//                                                                                                                         border: Border.all(
//                                                                                                                           color: Colors.grey[600]!,
//                                                                                                                           width: 1,
//                                                                                                                         ),
//                                                                                                                         borderRadius: BorderRadius.circular(45),
//                                                                                                                       ),
//                                                                                                                       child: Icon(Icons.add, size: 25.w, color: Colors.blue[200]!),
//                                                                                                                     ),
//                                                                                                                   ),
//                                                                                                                   SizedBox(
//                                                                                                                     width: 7.h,
//                                                                                                                   ),
//                                                                                                                   SizedBox(
//                                                                                                                     width: 70.w,
//                                                                                                                     height: 38.h,
//                                                                                                                     child: TextField(
//                                                                                                                       controller: truckProvider.selectedTruckType[index].contains(state.truckTypes[index3].id) ? truckProvider.truckNumController[index][truckProvider.selectedTruckType[index].indexWhere((item) => item == state.truckTypes[index3].id)] : null,
//                                                                                                                       enabled: false,
//                                                                                                                       textAlign: TextAlign.center,
//                                                                                                                       style: const TextStyle(fontSize: 18),
//                                                                                                                       textInputAction: TextInputAction.done,
//                                                                                                                       keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
//                                                                                                                       inputFormatters: [
//                                                                                                                         DecimalFormatter(),
//                                                                                                                       ],
//                                                                                                                       decoration: const InputDecoration(
//                                                                                                                         labelText: "",
//                                                                                                                         alignLabelWithHint: true,
//                                                                                                                         contentPadding: EdgeInsets.zero,
//                                                                                                                       ),
//                                                                                                                       scrollPadding: EdgeInsets.only(
//                                                                                                                         bottom: MediaQuery.of(context).viewInsets.bottom + 50,
//                                                                                                                       ),
//                                                                                                                     ),
//                                                                                                                   ),
//                                                                                                                   SizedBox(
//                                                                                                                     width: 7.h,
//                                                                                                                   ),
//                                                                                                                   InkWell(
//                                                                                                                     onTap: () {
//                                                                                                                       if (truckProvider.selectedTruckType[index].contains(state.truckTypes[index3].id)) {
//                                                                                                                         truckProvider.decreaseTruckType(state.truckTypes[index3].id!, index);
//                                                                                                                       }
//                                                                                                                     },
//                                                                                                                     child: Container(
//                                                                                                                       padding: const EdgeInsets.all(3),
//                                                                                                                       decoration: BoxDecoration(
//                                                                                                                         border: Border.all(
//                                                                                                                           color: Colors.grey[600]!,
//                                                                                                                           width: 1,
//                                                                                                                         ),
//                                                                                                                         borderRadius: BorderRadius.circular(45),
//                                                                                                                       ),
//                                                                                                                       child: Icon(
//                                                                                                                         Icons.remove,
//                                                                                                                         size: 25.w,
//                                                                                                                         color: Colors.grey[600]!,
//                                                                                                                       ),
//                                                                                                                     ),
//                                                                                                                   ),
//                                                                                                                 ],
//                                                                                                               ),
//                                                                                                             ),
//                                                                                                           ],
//                                                                                                         ),
//                                                                                                       ),
//                                                                                                     ],
//                                                                                                   ),
//                                                                                                 ),
//                                                                                               ),
//                                                                                               const Divider(),
//                                                                                             ],
//                                                                                           );
//                                                                                         },
//                                                                                         itemCount: state.truckTypes.length),
//                                                                                   );
//                                                                           } else {
//                                                                             return Container();
//                                                                           }
//                                                                         },
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 );
//                                                               }),
//                                                             );
//                                                           },
//                                                           child: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Text(
//                                                                 AppLocalizations.of(
//                                                                         context)!
//                                                                     .translate(
//                                                                         'select_truck_type'),
//                                                                 style:
//                                                                     TextStyle(
//                                                                   // color: AppColor.lightBlue,
//                                                                   fontSize:
//                                                                       19.sp,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         Visibility(
//                                                           visible: shipmentProvider
//                                                               .selectedTruckType[
//                                                                   index]
//                                                               .isNotEmpty,
//                                                           child: SizedBox(
//                                                             height: 185.h,
//                                                             child: BlocBuilder<
//                                                                 TruckTypeBloc,
//                                                                 TruckTypeState>(
//                                                               builder: (context,
//                                                                   state) {
//                                                                 if (state
//                                                                     is TruckTypeLoadedSuccess) {
//                                                                   return Scrollbar(
//                                                                     controller:
//                                                                         shipmentProvider
//                                                                             .scrollController[index],
//                                                                     thumbVisibility:
//                                                                         true,
//                                                                     thickness:
//                                                                         3.0,
//                                                                     child:
//                                                                         Padding(
//                                                                       padding: EdgeInsets
//                                                                           .all(2
//                                                                               .h),
//                                                                       child: ListView
//                                                                           .builder(
//                                                                         controller:
//                                                                             shipmentProvider.scrollController[index],
//                                                                         itemCount: shipmentProvider
//                                                                             .selectedTruckType[index]
//                                                                             .length,
//                                                                         scrollDirection:
//                                                                             Axis.horizontal,
//                                                                         shrinkWrap:
//                                                                             true,
//                                                                         itemBuilder:
//                                                                             (context,
//                                                                                 truckindex) {
//                                                                           return Padding(
//                                                                             padding:
//                                                                                 EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
//                                                                             child:
//                                                                                 InkWell(
//                                                                               onTap: () {},
//                                                                               child: Stack(
//                                                                                 clipBehavior: Clip.none,
//                                                                                 children: [
//                                                                                   Container(
//                                                                                     width: 190.w,
//                                                                                     decoration: BoxDecoration(
//                                                                                       borderRadius: BorderRadius.circular(7),
//                                                                                       border: Border.all(
//                                                                                         color: AppColor.darkGrey,
//                                                                                         width: 2.w,
//                                                                                       ),
//                                                                                     ),
//                                                                                     child: Column(
//                                                                                       mainAxisAlignment: MainAxisAlignment.center,
//                                                                                       children: [
//                                                                                         CachedNetworkImage(
//                                                                                           imageUrl: state.truckTypes[state.truckTypes.indexWhere((element) => element.id == shipmentProvider.selectedTruckType[index][truckindex])].image!,
//                                                                                           progressIndicatorBuilder: (context, url, downloadProgress) => Shimmer.fromColors(
//                                                                                             baseColor: (Colors.grey[300])!,
//                                                                                             highlightColor: (Colors.grey[100])!,
//                                                                                             enabled: true,
//                                                                                             child: Container(
//                                                                                               height: 50.h,
//                                                                                               width: 190.w,
//                                                                                               color: Colors.white,
//                                                                                             ),
//                                                                                           ),
//                                                                                           errorWidget: (context, url, error) => Container(
//                                                                                             height: 50.h,
//                                                                                             width: 190.w,
//                                                                                             color: Colors.grey[300],
//                                                                                             child: Center(
//                                                                                               child: Text(AppLocalizations.of(context)!.translate('image_load_error')),
//                                                                                             ),
//                                                                                           ),
//                                                                                         ),
//                                                                                         SizedBox(
//                                                                                           height: 7.h,
//                                                                                         ),
//                                                                                         Text(
//                                                                                           localeState.value.languageCode == 'en' ? state.truckTypes[index].name! : state.truckTypes[index].nameAr!,
//                                                                                           style: TextStyle(
//                                                                                             fontSize: 17.sp,
//                                                                                             color: AppColor.deepBlack,
//                                                                                           ),
//                                                                                         ),
//                                                                                         SizedBox(
//                                                                                           height: 7.h,
//                                                                                         ),
//                                                                                         Padding(
//                                                                                           padding: EdgeInsets.symmetric(horizontal: 5.w),
//                                                                                           child: Row(
//                                                                                             mainAxisAlignment: MainAxisAlignment.center,
//                                                                                             children: [
//                                                                                               SizedBox(
//                                                                                                 width: 70.w,
//                                                                                                 height: 38.h,
//                                                                                                 child: TextField(
//                                                                                                   controller: shipmentProvider.truckNumController[index][truckindex],
//                                                                                                   // focusNode:
//                                                                                                   //     _nodeTabaleh,
//                                                                                                   enabled: false,

//                                                                                                   textAlign: TextAlign.center,
//                                                                                                   style: const TextStyle(fontSize: 18),
//                                                                                                   textInputAction: TextInputAction.done,
//                                                                                                   keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
//                                                                                                   inputFormatters: [
//                                                                                                     DecimalFormatter(),
//                                                                                                   ],

//                                                                                                   decoration: const InputDecoration(
//                                                                                                     labelText: "",
//                                                                                                     alignLabelWithHint: true,
//                                                                                                     contentPadding: EdgeInsets.zero,
//                                                                                                   ),
//                                                                                                   scrollPadding: EdgeInsets.only(
//                                                                                                     bottom: MediaQuery.of(context).viewInsets.bottom + 50,
//                                                                                                   ),
//                                                                                                 ),
//                                                                                               ),
//                                                                                               // Text(
//                                                                                               //   tabalehNum.toString(),
//                                                                                               //   style: const TextStyle(fontSize: 30),
//                                                                                               // ),
//                                                                                             ],
//                                                                                           ),
//                                                                                         ),
//                                                                                       ],
//                                                                                     ),
//                                                                                   ),
//                                                                                 ],
//                                                                               ),
//                                                                             ),
//                                                                           );
//                                                                         },
//                                                                       ),
//                                                                     ),
//                                                                   );
//                                                                 } else {
//                                                                   return Shimmer
//                                                                       .fromColors(
//                                                                     baseColor:
//                                                                         (Colors.grey[
//                                                                             300])!,
//                                                                     highlightColor:
//                                                                         (Colors.grey[
//                                                                             100])!,
//                                                                     enabled:
//                                                                         true,
//                                                                     direction:
//                                                                         ShimmerDirection
//                                                                             .rtl,
//                                                                     child: ListView
//                                                                         .builder(
//                                                                       shrinkWrap:
//                                                                           true,
//                                                                       scrollDirection:
//                                                                           Axis.horizontal,
//                                                                       itemBuilder:
//                                                                           (_, __) =>
//                                                                               Padding(
//                                                                         padding: EdgeInsets.symmetric(
//                                                                             horizontal:
//                                                                                 5.w,
//                                                                             vertical: 15.h),
//                                                                         child:
//                                                                             Container(
//                                                                           clipBehavior:
//                                                                               Clip.antiAlias,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             color:
//                                                                                 Colors.white,
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10),
//                                                                           ),
//                                                                           child:
//                                                                               SizedBox(
//                                                                             width:
//                                                                                 175.w,
//                                                                             height:
//                                                                                 70.h,
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                       itemCount:
//                                                                           6,
//                                                                     ),
//                                                                   );
//                                                                 }
//                                                               },
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                           height: 5.h,
//                                                         ),
//                                                         Visibility(
//                                                           visible:
//                                                               shipmentProvider
//                                                                       .truckError[
//                                                                   index],
//                                                           child: Column(
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .all(
//                                                                         8.0),
//                                                                 child: Text(
//                                                                   AppLocalizations.of(
//                                                                           context)!
//                                                                       .translate(
//                                                                           'select_truck_type_error'),
//                                                                   style:
//                                                                       const TextStyle(
//                                                                     color: Colors
//                                                                         .red,
//                                                                     fontSize:
//                                                                         17,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                           height: 7.h,
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               EnsureVisibleWhenFocused(
//                                                 focusNode: _commodity_node,
//                                                 child: Stack(
//                                                   clipBehavior: Clip.none,
//                                                   children: [
//                                                     Container(
//                                                       // key: key1,
//                                                       child: Form(
//                                                         key: shipmentProvider
//                                                                 .addShipmentformKey[
//                                                             index],
//                                                         child: ListView.builder(
//                                                             shrinkWrap: true,
//                                                             physics:
//                                                                 const NeverScrollableScrollPhysics(),
//                                                             itemCount:
//                                                                 shipmentProvider
//                                                                         .count[
//                                                                     index],
//                                                             itemBuilder:
//                                                                 (context,
//                                                                     index2) {
//                                                               return Stack(
//                                                                 children: [
//                                                                   Card(
//                                                                     color: Colors
//                                                                         .white,
//                                                                     margin:
//                                                                         const EdgeInsets
//                                                                             .all(
//                                                                             5),
//                                                                     child:
//                                                                         Padding(
//                                                                       padding: const EdgeInsets
//                                                                           .symmetric(
//                                                                           horizontal:
//                                                                               10.0,
//                                                                           vertical:
//                                                                               7.5),
//                                                                       child:
//                                                                           Column(
//                                                                         children: [
//                                                                           index2 == 0
//                                                                               ? Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//                                                                                   shipmentProvider.count[index] > 1
//                                                                                       ? SizedBox(
//                                                                                           width: 35.w,
//                                                                                         )
//                                                                                       : const SizedBox.shrink(),
//                                                                                   Text(
//                                                                                     AppLocalizations.of(context)!.translate('commodity_info'),
//                                                                                     overflow: TextOverflow.ellipsis,
//                                                                                     style: TextStyle(
//                                                                                       fontSize: 17,
//                                                                                       fontWeight: FontWeight.bold,
//                                                                                       color: AppColor.darkGrey,
//                                                                                     ),
//                                                                                   ),
//                                                                                 ])
//                                                                               : const SizedBox.shrink(),
//                                                                           index != 0
//                                                                               ? const SizedBox(
//                                                                                   height: 30,
//                                                                                 )
//                                                                               : const SizedBox.shrink(),
//                                                                           const SizedBox(
//                                                                             height:
//                                                                                 7,
//                                                                           ),
//                                                                           BlocBuilder<
//                                                                               CommodityCategoryBloc,
//                                                                               CommodityCategoryState>(
//                                                                             builder:
//                                                                                 (context, state2) {
//                                                                               if (state2 is CommodityCategoryLoadedSuccess) {
//                                                                                 return DropdownButtonHideUnderline(
//                                                                                   child: DropdownButton2<CommodityCategory>(
//                                                                                     isExpanded: true,
//                                                                                     hint: Text(
//                                                                                       AppLocalizations.of(context)!.translate('package_type'),
//                                                                                       style: TextStyle(
//                                                                                         fontSize: 18,
//                                                                                         color: Theme.of(context).hintColor,
//                                                                                       ),
//                                                                                     ),
//                                                                                     items: state2.commodityCategories
//                                                                                         .map((CommodityCategory item) => DropdownMenuItem<CommodityCategory>(
//                                                                                               value: item,
//                                                                                               child: SizedBox(
//                                                                                                 width: 200,
//                                                                                                 child: Text(
//                                                                                                   item.name!,
//                                                                                                   style: const TextStyle(
//                                                                                                     fontSize: 17,
//                                                                                                   ),
//                                                                                                 ),
//                                                                                               ),
//                                                                                             ))
//                                                                                         .toList(),
//                                                                                     value: shipmentProvider.commodityCategory_controller[index][index2],
//                                                                                     onChanged: (CommodityCategory? value) {
//                                                                                       setState(() {
//                                                                                         shipmentProvider.commodityCategory_controller[index][index2] = value!;
//                                                                                       });
//                                                                                     },
//                                                                                     buttonStyleData: ButtonStyleData(
//                                                                                       height: 50,
//                                                                                       width: double.infinity,
//                                                                                       padding: const EdgeInsets.symmetric(
//                                                                                         horizontal: 9.0,
//                                                                                       ),
//                                                                                       decoration: BoxDecoration(
//                                                                                         borderRadius: BorderRadius.circular(12),
//                                                                                         border: Border.all(
//                                                                                           color: Colors.black26,
//                                                                                         ),
//                                                                                         color: Colors.white,
//                                                                                       ),
//                                                                                       // elevation: 2,
//                                                                                     ),
//                                                                                     iconStyleData: IconStyleData(
//                                                                                       icon: const Icon(
//                                                                                         Icons.keyboard_arrow_down_sharp,
//                                                                                       ),
//                                                                                       iconSize: 20,
//                                                                                       iconEnabledColor: AppColor.deepYellow,
//                                                                                       iconDisabledColor: Colors.grey,
//                                                                                     ),
//                                                                                     dropdownStyleData: DropdownStyleData(
//                                                                                       decoration: BoxDecoration(
//                                                                                         borderRadius: BorderRadius.circular(14),
//                                                                                         color: Colors.white,
//                                                                                       ),
//                                                                                       scrollbarTheme: ScrollbarThemeData(
//                                                                                         radius: const Radius.circular(40),
//                                                                                         thickness: MaterialStateProperty.all(6),
//                                                                                         thumbVisibility: MaterialStateProperty.all(true),
//                                                                                       ),
//                                                                                     ),
//                                                                                     menuItemStyleData: const MenuItemStyleData(
//                                                                                       height: 40,
//                                                                                     ),
//                                                                                   ),
//                                                                                 );
//                                                                               } else if (state2 is CommodityCategoryLoadingProgress) {
//                                                                                 return const Center(
//                                                                                   child: LinearProgressIndicator(),
//                                                                                 );
//                                                                               } else if (state2 is CommodityCategoryLoadedFailed) {
//                                                                                 return Center(
//                                                                                   child: InkWell(
//                                                                                     onTap: () {
//                                                                                       BlocProvider.of<CommodityCategoryBloc>(context).add(CommodityCategoryLoadEvent());
//                                                                                     },
//                                                                                     child: Row(
//                                                                                       mainAxisAlignment: MainAxisAlignment.center,
//                                                                                       children: [
//                                                                                         Text(
//                                                                                           AppLocalizations.of(context)!.translate('list_error'),
//                                                                                           style: const TextStyle(color: Colors.red),
//                                                                                         ),
//                                                                                         const Icon(
//                                                                                           Icons.refresh,
//                                                                                           color: Colors.grey,
//                                                                                         )
//                                                                                       ],
//                                                                                     ),
//                                                                                   ),
//                                                                                 );
//                                                                               } else {
//                                                                                 return Container();
//                                                                               }
//                                                                             },
//                                                                           ),
//                                                                           const SizedBox(
//                                                                             height:
//                                                                                 12,
//                                                                           ),
//                                                                           Focus(
//                                                                             focusNode:
//                                                                                 _nodeCommodityWeight,
//                                                                             onFocusChange:
//                                                                                 (bool focus) {
//                                                                               if (!focus) {
//                                                                                 FocusManager.instance.primaryFocus?.unfocus();
//                                                                                 BlocProvider.of<BottomNavBarCubit>(context).emitShow();
//                                                                               }
//                                                                             },
//                                                                             child:
//                                                                                 TextFormField(
//                                                                               controller: shipmentProvider.commodityWeight_controllers[index][index2],
//                                                                               onTap: () {
//                                                                                 BlocProvider.of<BottomNavBarCubit>(context).emitHide();
//                                                                                 shipmentProvider.commodityWeight_controllers[index][index2].selection = TextSelection(baseOffset: 0, extentOffset: shipmentProvider.commodityWeight_controllers[index][index2].value.text.length);
//                                                                               },
//                                                                               // focusNode: _nodeWeight,
//                                                                               // enabled: !valueEnabled,
//                                                                               scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 50),
//                                                                               textInputAction: TextInputAction.done,
//                                                                               keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
//                                                                               inputFormatters: [
//                                                                                 DecimalFormatter(),
//                                                                               ],
//                                                                               style: const TextStyle(fontSize: 20),
//                                                                               decoration: InputDecoration(
//                                                                                 labelText: AppLocalizations.of(context)!.translate('commodity_weight'),
//                                                                                 contentPadding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 9.0),
//                                                                               ),
//                                                                               onTapOutside: (event) {},
//                                                                               onEditingComplete: () {
//                                                                                 // if (evaluateCo2()) {
//                                                                                 //   calculateCo2Report();
//                                                                                 // }
//                                                                               },
//                                                                               onChanged: (value) {
//                                                                                 // if (evaluateCo2()) {
//                                                                                 //   calculateCo2Report();
//                                                                                 // }
//                                                                               },
//                                                                               autovalidateMode: AutovalidateMode.onUserInteraction,
//                                                                               validator: (value) {
//                                                                                 if (value!.isEmpty) {
//                                                                                   return AppLocalizations.of(context)!.translate('insert_value_validate');
//                                                                                 }
//                                                                                 return null;
//                                                                               },
//                                                                               onSaved: (newValue) {
//                                                                                 shipmentProvider.commodityWeight_controllers[index][index2].text = newValue!;
//                                                                               },
//                                                                               onFieldSubmitted: (value) {
//                                                                                 // if (evaluateCo2()) {
//                                                                                 //   calculateCo2Report();
//                                                                                 // }
//                                                                                 FocusManager.instance.primaryFocus?.unfocus();
//                                                                                 BlocProvider.of<BottomNavBarCubit>(context).emitShow();
//                                                                               },
//                                                                             ),
//                                                                           ),
//                                                                           const SizedBox(
//                                                                             height:
//                                                                                 12,
//                                                                           ),
//                                                                         ],
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                   (shipmentProvider.count[
//                                                                               index] >
//                                                                           1)
//                                                                       ? Positioned(
//                                                                           left:
//                                                                               5,
//                                                                           // right: localeState
//                                                                           //             .value
//                                                                           //             .languageCode ==
//                                                                           //         'en'
//                                                                           //     ? null
//                                                                           //     : 5,
//                                                                           top:
//                                                                               5,
//                                                                           child:
//                                                                               Container(
//                                                                             height:
//                                                                                 30,
//                                                                             width:
//                                                                                 35,
//                                                                             decoration:
//                                                                                 BoxDecoration(
//                                                                               color: AppColor.deepYellow,
//                                                                               borderRadius: const BorderRadius.only(
//                                                                                 topLeft:
//                                                                                     //  localeState
//                                                                                     //             .value
//                                                                                     //             .languageCode ==
//                                                                                     //         'en'
//                                                                                     //     ?
//                                                                                     Radius.circular(12)
//                                                                                 // : const Radius
//                                                                                 //     .circular(
//                                                                                 //     5)
//                                                                                 ,
//                                                                                 topRight:
//                                                                                     // localeState
//                                                                                     //             .value
//                                                                                     //             .languageCode ==
//                                                                                     //         'en'
//                                                                                     //     ?
//                                                                                     Radius.circular(5)
//                                                                                 // :
//                                                                                 // const Radius
//                                                                                 //     .circular(
//                                                                                 //     15)
//                                                                                 ,
//                                                                                 bottomLeft: Radius.circular(5),
//                                                                                 bottomRight: Radius.circular(5),
//                                                                               ),
//                                                                             ),
//                                                                             child:
//                                                                                 Center(
//                                                                               child: Text(
//                                                                                 (index2 + 1).toString(),
//                                                                                 style: const TextStyle(
//                                                                                   color: Colors.white,
//                                                                                   fontWeight: FontWeight.bold,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         )
//                                                                       : const SizedBox
//                                                                           .shrink(),
//                                                                   (shipmentProvider.count[index] >
//                                                                               1) &&
//                                                                           (index2 !=
//                                                                               0)
//                                                                       ? Positioned(
//                                                                           right:
//                                                                               0,
//                                                                           // left: localeState
//                                                                           //             .value
//                                                                           //             .languageCode ==
//                                                                           //         'en'
//                                                                           //     ? null
//                                                                           //     : 0,
//                                                                           child:
//                                                                               InkWell(
//                                                                             onTap:
//                                                                                 () {
//                                                                               shipmentProvider.removeitem(index, index2);
//                                                                               // _showAlertDialog(index);
//                                                                             },
//                                                                             child:
//                                                                                 Container(
//                                                                               height: 30,
//                                                                               width: 30,
//                                                                               decoration: BoxDecoration(
//                                                                                 color: Colors.red,
//                                                                                 borderRadius: BorderRadius.circular(45),
//                                                                               ),
//                                                                               child: const Center(
//                                                                                 child: Icon(
//                                                                                   Icons.close,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         )
//                                                                       : const SizedBox
//                                                                           .shrink(),
//                                                                 ],
//                                                               );
//                                                             }),
//                                                       ),
//                                                     ),
//                                                     Positioned(
//                                                       bottom: -18,
//                                                       left: 0,
//                                                       child: InkWell(
//                                                         onTap: () =>
//                                                             shipmentProvider
//                                                                 .additem(index),
//                                                         child: AbsorbPointer(
//                                                           absorbing: true,
//                                                           child: Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: SizedBox(
//                                                               height: 32.h,
//                                                               width: 32.w,
//                                                               child: SvgPicture
//                                                                   .asset(
//                                                                       "assets/icons/add.svg"),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     )
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           height: 7,
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 8.0, vertical: 2.5),
//                                           child: Card(
//                                             color: Colors.white,
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 10.0,
//                                                       vertical: 7.5),
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     AppLocalizations.of(
//                                                             context)!
//                                                         .translate(
//                                                             'loading_time'),
//                                                     style: TextStyle(
//                                                       // color: AppColor.lightBlue,
//                                                       fontSize: 19.sp,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(
//                                                     height: 10,
//                                                   ),
//                                                   Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                     children: [
//                                                       SizedBox(
//                                                         width: MediaQuery.of(
//                                                                     context)
//                                                                 .size
//                                                                 .width *
//                                                             .42,
//                                                         child: InkWell(
//                                                           onTap: () {
//                                                             _showDatePicker(
//                                                                 index);
//                                                           },
//                                                           child: TextFormField(
//                                                             controller:
//                                                                 shipmentProvider
//                                                                         .date_controller[
//                                                                     index],
//                                                             enabled: false,
//                                                             style:
//                                                                 const TextStyle(
//                                                                     fontSize:
//                                                                         18),
//                                                             decoration:
//                                                                 InputDecoration(
//                                                               labelText:
//                                                                   AppLocalizations.of(
//                                                                           context)!
//                                                                       .translate(
//                                                                           'date'),
//                                                               contentPadding:
//                                                                   const EdgeInsets
//                                                                       .symmetric(
//                                                                       vertical:
//                                                                           11.0,
//                                                                       horizontal:
//                                                                           9.0),
//                                                               suffixIcon:
//                                                                   const Icon(Icons
//                                                                       .calendar_month),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       SizedBox(
//                                                         width: MediaQuery.of(
//                                                                     context)
//                                                                 .size
//                                                                 .width *
//                                                             .42,
//                                                         child: InkWell(
//                                                           onTap: () {
//                                                             _showTimePicker(
//                                                                 index);
//                                                           },
//                                                           child: TextFormField(
//                                                             controller:
//                                                                 shipmentProvider
//                                                                         .time_controller[
//                                                                     index],
//                                                             enabled: false,
//                                                             style:
//                                                                 const TextStyle(
//                                                                     fontSize:
//                                                                         18),
//                                                             decoration:
//                                                                 InputDecoration(
//                                                               labelText:
//                                                                   AppLocalizations.of(
//                                                                           context)!
//                                                                       .translate(
//                                                                           'time'),
//                                                               contentPadding:
//                                                                   const EdgeInsets
//                                                                       .symmetric(
//                                                                       vertical:
//                                                                           11.0,
//                                                                       horizontal:
//                                                                           9.0),
//                                                               suffixIcon:
//                                                                   const Icon(Icons
//                                                                       .timer_outlined),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   const SizedBox(
//                                                     height: 5,
//                                                   ),
//                                                   Visibility(
//                                                     visible: shipmentProvider
//                                                         .dateError[index],
//                                                     child: Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(8.0),
//                                                           child: Text(
//                                                             AppLocalizations.of(
//                                                                     context)!
//                                                                 .translate(
//                                                                     'pick_date_error'),
//                                                             style:
//                                                                 const TextStyle(
//                                                               color: Colors.red,
//                                                               fontSize: 17,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   Visibility(
//                                                     visible: false,
//                                                     child: const Column(
//                                                       children: [
//                                                         SizedBox(
//                                                           height: 5,
//                                                         ),
//                                                         Column(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             Padding(
//                                                               padding:
//                                                                   EdgeInsets
//                                                                       .all(8.0),
//                                                               child: Text(
//                                                                 "there is no available route change destination.",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   color: Colors
//                                                                       .red,
//                                                                   fontSize: 17,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           height: 20,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 (shipmentProvider.countpath > 1) && (index != 0)
//                                     ? Positioned(
//                                         right: 0,
//                                         child: InkWell(
//                                           onTap: () {
//                                             shipmentProvider.removePath(
//                                               index,
//                                             );
//                                             // _showAlertDialog(index);
//                                           },
//                                           child: Container(
//                                             height: 30,
//                                             width: 30,
//                                             decoration: BoxDecoration(
//                                               color: Colors.red,
//                                               borderRadius:
//                                                   BorderRadius.circular(45),
//                                             ),
//                                             child: const Center(
//                                               child: Icon(
//                                                 Icons.close,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                     : const SizedBox.shrink(),
//                                 index == (shipmentProvider.countpath - 1)
//                                     ? Positioned(
//                                         bottom: -18,
//                                         left: 0,
//                                         child: InkWell(
//                                           onTap: () =>
//                                               shipmentProvider.addpath(),
//                                           child: AbsorbPointer(
//                                             absorbing: true,
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: SizedBox(
//                                                 height: 32.h,
//                                                 width: 32.w,
//                                                 child: SvgPicture.asset(
//                                                     "assets/icons/add.svg"),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                     : const SizedBox.shrink()
//                               ],
//                             );
//                           },
//                         ),
//                         const SizedBox(height: 20),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8.0, vertical: 2.5),
//                           child: BlocConsumer<ShipmentMultiCreateBloc,
//                               ShipmentMultiCreateState>(
//                             listener: (context, state) {
//                               print(state);
//                               if (state is ShipmentMultiCreateSuccessState) {
//                                 ScaffoldMessenger.of(context)
//                                     .showSnackBar(SnackBar(
//                                   content: Text(AppLocalizations.of(context)!
//                                       .translate('shipment_created_success')),
//                                   duration: const Duration(seconds: 3),
//                                 ));

//                                 BlocProvider.of<TrucksListBloc>(context).add(
//                                     TrucksListLoadEvent(
//                                         shipmentProvider.selectedTruckType[0]));

//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           SelectTruckMultiPathScreen(
//                                               shipment: state.shipment),
//                                     ));
//                               }
//                               if (state is ShipmentMultiCreateFailureState) {
//                                 print(state.errorMessage);
//                               }
//                             },
//                             builder: (context, state) {
//                               if (state is ShippmentLoadingProgressState) {
//                                 return CustomButton(
//                                   title: const LoadingIndicator(),
//                                   onTap: () {},
//                                 );
//                               } else {
//                                 return CustomButton(
//                                   title: Text(
//                                     AppLocalizations.of(context)!
//                                         .translate('create_shipment'),
//                                     style: TextStyle(
//                                       fontSize: 20.sp,
//                                     ),
//                                   ),
//                                   onTap: () {
//                                     print("asd");
//                                     for (var element in shipmentProvider
//                                         .addShipmentformKey) {
//                                       element.currentState?.save();
//                                     }

//                                     List<SubShipment> subshipmentsitems = [];

//                                     for (var i = 0;
//                                         i <
//                                             shipmentProvider
//                                                 .pickup_controller.length;
//                                         i++) {
//                                       List<ShipmentItems> shipmentitems = [];

//                                       int totalWeight = 0;
//                                       for (var j = 0;
//                                           j <
//                                               shipmentProvider
//                                                   .commodityWeight_controllers[
//                                                       i]
//                                                   .length;
//                                           j++) {
//                                         print(shipmentProvider
//                                             .commodityCategories[i][j]);
//                                         ShipmentItems shipmentitem =
//                                             ShipmentItems(
//                                           commodityCategory: shipmentProvider
//                                               .commodityCategory_controller[i]
//                                                   [j]!
//                                               .id!,
//                                           commodityWeight: double.parse(
//                                                   shipmentProvider
//                                                       .commodityWeight_controllers[
//                                                           i][j]
//                                                       .text
//                                                       .replaceAll(",", ""))
//                                               .toInt(),
//                                         );
//                                         shipmentitems.add(shipmentitem);
//                                         totalWeight += double.parse(
//                                                 shipmentProvider
//                                                     .commodityWeight_controllers[
//                                                         i][j]
//                                                     .text
//                                                     .replaceAll(",", ""))
//                                             .toInt();
//                                       }

//                                       List<PathPoint> points = [];
//                                       points.add(PathPoint(
//                                         pointType: "P",
//                                         location:
//                                             "${shipmentProvider.pickup_latlng[i]!.latitude},${shipmentProvider.pickup_latlng[i]!.longitude}",
//                                         name: shipmentProvider
//                                             .pickup_controller[i].text,
//                                         number: 0,
//                                         city: 1,
//                                       ));
//                                       points.add(PathPoint(
//                                         pointType: "D",
//                                         location:
//                                             "${shipmentProvider.delivery_latlng[i]!.latitude},${shipmentProvider.delivery_latlng[i]!.longitude}",
//                                         name: shipmentProvider
//                                             .delivery_controller[i].text,
//                                         number: 0,
//                                         city: 1,
//                                       ));

//                                       for (var s = 0;
//                                           s <
//                                               shipmentProvider
//                                                   .stoppoints_controller[i]
//                                                   .length;
//                                           s++) {
//                                         points.add(PathPoint(
//                                           pointType: "S",
//                                           location:
//                                               "${shipmentProvider.stoppoints_latlng[i][s]!.latitude},${shipmentProvider.stoppoints_latlng[i][s]!.longitude}",
//                                           name: shipmentProvider
//                                               .stoppoints_controller[i][s].text,
//                                           number: s,
//                                           city: 1,
//                                         ));
//                                       }

//                                       List<SelectedTruckType> truckTypes = [];
//                                       for (var element in shipmentProvider
//                                           .selectedTruckType) {
//                                         for (var element1 in element) {
//                                           SelectedTruckType truck =
//                                               SelectedTruckType(
//                                             truckType: element1,
//                                             is_assigned: false,
//                                           );
//                                           truckTypes.add(truck);
//                                         }
//                                       }

//                                       print("shipmentProvider.pathes[i]");
//                                       print(shipmentProvider.pathes[i]);
//                                       SubShipment subshipment = SubShipment(
//                                         shipmentStatus: "P",
//                                         paths: jsonEncode(
//                                             shipmentProvider.pathes[i]),
//                                         shipmentItems: shipmentitems,
//                                         totalWeight: totalWeight,
//                                         pathpoints: points,
//                                         truckTypes: truckTypes,
//                                         pickupDate: DateTime(
//                                           shipmentProvider.loadDate[i].year,
//                                           shipmentProvider.loadDate[i].month,
//                                           shipmentProvider.loadDate[i].day,
//                                           shipmentProvider.loadTime[i].hour,
//                                           shipmentProvider.loadTime[i].day,
//                                         ),
//                                         deliveryDate: DateTime.now(),
//                                       );
//                                       subshipmentsitems.add(subshipment);
//                                     }

//                                     Shipmentv2 shipment = Shipmentv2(
//                                       subshipments: subshipmentsitems,
//                                     );
//                                     print("asd1");

//                                     BlocProvider.of<ShipmentMultiCreateBloc>(
//                                             context)
//                                         .add(
//                                       ShipmentMultiCreateButtonPressed(
//                                         shipment,
//                                       ),
//                                     );
//                                   },
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                         SizedBox(
//                           height: 7.h,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
