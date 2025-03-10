// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:camion/Localization/app_localizations.dart';
// import 'package:camion/business_logic/bloc/truck/trucks_list_bloc.dart';
// import 'package:camion/business_logic/cubit/locale_cubit.dart';
// import 'package:camion/data/models/truck_model.dart';
// import 'package:camion/data/providers/add_multi_shipment_provider.dart';
// import 'package:camion/helpers/color_constants.dart';
// import 'package:camion/views/screens/truck_details_screen.dart';
// import 'package:camion/views/widgets/custom_app_bar.dart';
// import 'package:camion/views/widgets/custom_botton.dart';
// import 'package:camion/views/widgets/section_body_widget.dart';
// import 'package:camion/views/widgets/section_title_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:intl/intl.dart' as intel;
// import 'package:timeline_tile/timeline_tile.dart';

// class AddCommodityScreen extends StatelessWidget {
//   AddCommodityScreen({Key? key}) : super(key: key);
//   int selectedIndex = 0;

//   int calculatePrice(
//     double distance,
//     double weight,
//   ) {
//     double result = 0.0;
//     result = distance * (weight / 1000) * 550;
//     return result.toInt();
//   }

//   var f = intel.NumberFormat("#,###", "en_US");

//   Widget selectedTrucksList(
//       AddMultiShipmentProvider provider, BuildContext context, String lang) {
//     List<KTruck> trucks = [];
//     for (var element in provider.selectedTruck) {
//       for (var element1 in element) {
//         trucks.add(element1);
//       }
//     }

//     return trucks.isEmpty
//         ? Expanded(
//             child: Center(
//               child: Column(
//                 children: [
//                   const SizedBox(
//                     height: 100,
//                   ),
//                   SizedBox(
//                     height: 100,
//                     width: 100,
//                     child: SvgPicture.asset(
//                         "assets/icons/grey/search_for_truck.svg"),
//                   ),
//                   Text(
//                     AppLocalizations.of(context)!.translate('search_for_truck'),
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         : Expanded(
//             child: ListView.builder(
//               itemCount: trucks.length,
//               // physics: const NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemBuilder: (context, index) {
//                 return StatefulBuilder(builder: (context, menuSetState) {
//                   return Column(
//                     children: [
//                       Container(
//                         clipBehavior: Clip.antiAlias,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(
//                             8,
//                           ),
//                           color: Colors.white,
//                           border: Border.all(
//                             color: Colors.grey[350]!,
//                             width: 1,
//                           ),
//                         ),
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 5,
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Expanded(
//                                         child: SectionTitle(
//                                           text:
//                                               ' ${trucks[index].driver_firstname} ${trucks[index].driver_lastname}',
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: Row(
//                                           children: [
//                                             SectionTitle(
//                                               text:
//                                                   ' ${trucks[index].distance} ${lang == "en" ? "km" : "كم"}',
//                                             ),
//                                             SizedBox(
//                                               height: 20.h,
//                                               width: 25.h,
//                                               child: SvgPicture.asset(
//                                                   "assets/icons/grey/location.svg"),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: SectionTitle(
//                                           text:
//                                               ' ${lang == "en" ? trucks[index].truckType!.name : trucks[index].truckType!.nameAr} ',
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Divider(
//                                     color: Colors.grey[400],
//                                   ),
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                         child: SectionBody(
//                                           text:
//                                               '${AppLocalizations.of(context)!.translate('truck_number')}: ${trucks[index].truckNumber}',
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: SectionBody(
//                                           text:
//                                               '${AppLocalizations.of(context)!.translate('gross_weight')}: ${f.format(trucks[index].grossWeight)} ${lang == "en" ? "kg" : "كغ"}',
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(
//                                     height: 8.h,
//                                   ),
//                                   Row(
//                                     children: [
//                                       SectionTitle(
//                                         text:
//                                             '${AppLocalizations.of(context)!.translate('price')}: ',
//                                       ),
//                                       Spacer(),
//                                       ((calculatePrice(provider.distance,
//                                                       provider.totalWeight[0]) >
//                                                   trucks[index]
//                                                       .private_price!) &&
//                                               trucks[index].private_price == 0)
//                                           ? SectionTitle(
//                                               text:
//                                                   '${f.format(calculatePrice(provider.distance, provider.totalWeight[0]))} ${lang == "en" ? "S.P" : "ل.س"} ${(calculatePrice(provider.distance, provider.totalWeight[0]) > trucks[index].private_price!)}',
//                                             )
//                                           : Row(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.end,
//                                               children: [
//                                                 SectionTitle(
//                                                   text:
//                                                       '${f.format(trucks[index].private_price)} ${lang == "en" ? "S.P" : "ل.س"}',
//                                                 ),
//                                                 const SizedBox(
//                                                   width: 8,
//                                                 ),
//                                                 Text(
//                                                   f.format(calculatePrice(
//                                                       provider.distance,
//                                                       provider.totalWeight[0])),
//                                                   style: const TextStyle(
//                                                     color: Colors.grey,
//                                                     fontSize: 17,
//                                                     decoration: TextDecoration
//                                                         .lineThrough,
//                                                   ),
//                                                 )
//                                               ],
//                                             ),
//                                       Spacer(),
//                                       IconButton(
//                                         onPressed: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   TruckDetailsScreen(
//                                                 truck: trucks[index],
//                                                 index: 0,
//                                                 ops: 'create_shipment',
//                                                 subshipmentId: 0,
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                         icon: Icon(Icons.arrow_forward_ios,
//                                             color: AppColor.deepYellow),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       index == provider.selectedTruck.length - 1
//                           ? SizedBox(
//                               height: 80.h,
//                             )
//                           : const SizedBox.shrink(),
//                     ],
//                   );
//                 });
//               },
//             ),
//           );
//   }

//   Widget selectedTruckTypesList(AddMultiShipmentProvider provider,
//       BuildContext pathcontext, String lang) {
//     // List<int> selectedToShow=provider.selectedTruckType
//     return provider.selectedTruckType.isEmpty
//         ? const SizedBox.shrink()
//         : SizedBox(
//             height: 105.h,
//             child: ListView.builder(
//               itemCount: provider.selectedTruckType.length,
//               shrinkWrap: true,
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (context, index) {
//                 return Container(
//                   // width: 130.w,
//                   margin: const EdgeInsets.all(5),
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 5,
//                     horizontal: 10,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border.all(
//                       color: AppColor.deepYellow,
//                       width: 1,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: 45.h,
//                         width: 155.w,
//                         child: CachedNetworkImage(
//                           imageUrl: provider.selectedTruckType[index].image!,
//                           progressIndicatorBuilder:
//                               (context, url, downloadProgress) =>
//                                   Shimmer.fromColors(
//                             baseColor: (Colors.grey[300])!,
//                             highlightColor: (Colors.grey[100])!,
//                             enabled: true,
//                             child: Container(
//                               height: 45.h,
//                               width: 155.w,
//                               color: Colors.white,
//                             ),
//                           ),
//                           errorWidget: (context, url, error) => Container(
//                             height: 45.h,
//                             width: 155.w,
//                             color: Colors.grey[300],
//                             child: Center(
//                               child: Text(AppLocalizations.of(context)!
//                                   .translate('image_load_error')),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 4.h,
//                       ),
//                       Center(
//                         child: SectionBody(
//                           text: lang == "en"
//                               ? provider.selectedTruckType[index].name!
//                               : provider.selectedTruckType[index].nameAr!,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           );
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
//             child: Consumer<AddMultiShipmentProvider>(
//               builder: (context, shipmentProvider, child) {
//                 return Scaffold(
//                   backgroundColor: Colors.grey[100],
//                   appBar: CustomAppBar(
//                     title: AppLocalizations.of(context)!
//                         .translate('search_for_truck'),
//                   ),
//                   body: Stack(
//                     children: [
//                       Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           SizedBox(
//                             height: 8.h,
//                           ),
//                           selectedTruckTypesList(shipmentProvider, context,
//                               localeState.value.languageCode),
//                           const Divider(),
//                           selectedTrucksList(shipmentProvider, context,
//                               localeState.value.languageCode),
//                         ],
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         child: Container(
//                           height: 80.h,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border(
//                               top: BorderSide(
//                                   color: AppColor.darkGrey200, width: 2),
//                             ),
//                           ),
//                           width: MediaQuery.of(context).size.width,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 2.5),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceAround,
//                               children: [
//                                 // BlocConsumer<ShipmentMultiCreateBloc,
//                                 //     ShipmentMultiCreateState>(
//                                 //   listener: (context, state) {
//                                 //     if (state
//                                 //         is ShipmentMultiCreateSuccessState) {
//                                 //       ScaffoldMessenger.of(context)
//                                 //           .showSnackBar(SnackBar(
//                                 //         content: Text(AppLocalizations.of(
//                                 //                 context)!
//                                 //             .translate(
//                                 //                 'shipment_created_success')),
//                                 //         duration: const Duration(seconds: 3),
//                                 //       ));
//                                 //       shipmentProvider.initForm();
//                                 //       Navigator.pushAndRemoveUntil(
//                                 //         context,
//                                 //         MaterialPageRoute(
//                                 //           builder: (context) =>
//                                 //               const ControlView(),
//                                 //         ),
//                                 //         (route) => false,
//                                 //       );
//                                 //     }
//                                 //     if (state
//                                 //         is ShipmentMultiCreateFailureState) {
//                                 //       print(state.errorMessage);
//                                 //     }
//                                 //   },
//                                 //   builder: (context, state) {
//                                 //     if (state
//                                 //         is ShippmentLoadingProgressState) {
//                                 //       return SizedBox(
//                                 //         width:
//                                 //             MediaQuery.of(context).size.width *
//                                 //                 .92,
//                                 //         child: CustomButton(
//                                 //           title: LoadingIndicator(),
//                                 //           onTap: () {},
//                                 //         ),
//                                 //       );
//                                 //     } else {
//                                 //       return SizedBox(
//                                 //         width:
//                                 //             MediaQuery.of(context).size.width *
//                                 //                 .92,
//                                 //         child: CustomButton(
//                                 //           title: Text(
//                                 //             AppLocalizations.of(context)!
//                                 //                 .translate('create_shipment'),
//                                 //             style: TextStyle(
//                                 //               fontSize: 20.sp,
//                                 //             ),
//                                 //           ),
//                                 //           onTap: () {
//                                 //             if (shipmentProvider
//                                 //                 .selectedTruck.isNotEmpty) {
//                                 //               List<SubShipment>
//                                 //                   subshipmentsitems = [];
//                                 //               List<ShipmentItems>
//                                 //                   shipmentitems = [];
//                                 //               int totalWeight = 0;
//                                 //               for (var j = 0;
//                                 //                   j <
//                                 //                       shipmentProvider
//                                 //                           .commodityWeight_controllers
//                                 //                           .length;
//                                 //                   j++) {
//                                 //                 ShipmentItems shipmentitem =
//                                 //                     ShipmentItems(
//                                 //                   commodityName: shipmentProvider
//                                 //                       .commodityName_controllers[
//                                 //                           j]
//                                 //                       .text,
//                                 //                   commodityWeight: double.parse(
//                                 //                           shipmentProvider
//                                 //                               .commodityWeight_controllers[
//                                 //                                   j]
//                                 //                               .text
//                                 //                               .replaceAll(
//                                 //                                   ",", ""))
//                                 //                       .toInt(),
//                                 //                 );
//                                 //                 shipmentitems.add(shipmentitem);
//                                 //                 totalWeight += double.parse(
//                                 //                         shipmentProvider
//                                 //                             .commodityWeight_controllers[
//                                 //                                 j]
//                                 //                             .text
//                                 //                             .replaceAll(
//                                 //                                 ",", ""))
//                                 //                     .toInt();
//                                 //               }
//                                 //               List<PathPoint> points = [];
//                                 //               points.add(
//                                 //                 PathPoint(
//                                 //                   pointType: "P",
//                                 //                   location:
//                                 //                       "${shipmentProvider.pickup_latlng!.latitude},${shipmentProvider.pickup_latlng!.longitude}",
//                                 //                   name: shipmentProvider
//                                 //                       .pickup_controller.text,
//                                 //                   nameEn: "",
//                                 //                   number: 0,
//                                 //                   city: 1,
//                                 //                 ),
//                                 //               );
//                                 //               points.add(
//                                 //                 PathPoint(
//                                 //                   pointType: "D",
//                                 //                   location:
//                                 //                       "${shipmentProvider.delivery_latlng!.latitude},${shipmentProvider.delivery_latlng!.longitude}",
//                                 //                   name: shipmentProvider
//                                 //                       .delivery_controller.text,
//                                 //                   nameEn: "",
//                                 //                   number: 0,
//                                 //                   city: 1,
//                                 //                 ),
//                                 //               );
//                                 //               for (var s = 0;
//                                 //                   s <
//                                 //                       shipmentProvider
//                                 //                           .stoppoints_controller
//                                 //                           .length;
//                                 //                   s++) {
//                                 //                 points.add(
//                                 //                   PathPoint(
//                                 //                     pointType: "S",
//                                 //                     location:
//                                 //                         "${shipmentProvider.stoppoints_latlng[s]!.latitude},${shipmentProvider.stoppoints_latlng[s]!.longitude}",
//                                 //                     name: shipmentProvider
//                                 //                         .stoppoints_controller[
//                                 //                             s]
//                                 //                         .text,
//                                 //                     nameEn: "",
//                                 //                     number: s,
//                                 //                     city: 1,
//                                 //                   ),
//                                 //                 );
//                                 //               }
//                                 //               int truckQuantity = 0;
//                                 //               for (var element
//                                 //                   in shipmentProvider
//                                 //                       .selectedTruckTypeNum) {
//                                 //                 truckQuantity += element;
//                                 //               }
//                                 //               for (var i = 0;
//                                 //                   i <
//                                 //                       shipmentProvider
//                                 //                           .selectedTruck.length;
//                                 //                   i++) {
//                                 //                 SubShipment subshipment =
//                                 //                     SubShipment(
//                                 //                   shipmentStatus: "P",
//                                 //                   paths: jsonEncode(
//                                 //                       shipmentProvider.pathes),
//                                 //                   shipmentItems: shipmentitems,
//                                 //                   totalWeight: totalWeight,
//                                 //                   distance:
//                                 //                       shipmentProvider.distance,
//                                 //                   price: calculatePrice(
//                                 //                     shipmentProvider.distance,
//                                 //                     shipmentProvider
//                                 //                         .totalWeight,
//                                 //                   ),
//                                 //                   period:
//                                 //                       shipmentProvider.period,
//                                 //                   pathpoints: points,
//                                 //                   truck: ShipmentTruck(
//                                 //                       id: shipmentProvider
//                                 //                           .selectedTruck[i]!
//                                 //                           .id!),
//                                 //                   // truckTypes: truckTypes,
//                                 //                   pickupDate: DateTime(
//                                 //                     shipmentProvider
//                                 //                         .loadDate.year,
//                                 //                     shipmentProvider
//                                 //                         .loadDate.month,
//                                 //                     shipmentProvider
//                                 //                         .loadDate.day,
//                                 //                     shipmentProvider
//                                 //                         .loadTime.hour,
//                                 //                     shipmentProvider
//                                 //                         .loadTime.day,
//                                 //                   ),
//                                 //                   deliveryDate: DateTime(
//                                 //                     shipmentProvider
//                                 //                         .loadDate.year,
//                                 //                     shipmentProvider
//                                 //                         .loadDate.month,
//                                 //                     shipmentProvider
//                                 //                         .loadDate.day,
//                                 //                     shipmentProvider
//                                 //                         .loadTime.hour,
//                                 //                     shipmentProvider
//                                 //                         .loadTime.day,
//                                 //                   ),
//                                 //                 );
//                                 //                 subshipmentsitems
//                                 //                     .add(subshipment);
//                                 //                 truckQuantity--;
//                                 //               }
//                                 //               for (var i = 0;
//                                 //                   i < truckQuantity;
//                                 //                   i++) {
//                                 //                 SubShipment subshipment =
//                                 //                     SubShipment(
//                                 //                   shipmentStatus: "P",
//                                 //                   paths: jsonEncode(
//                                 //                       shipmentProvider.pathes),
//                                 //                   shipmentItems: shipmentitems,
//                                 //                   totalWeight: totalWeight,
//                                 //                   distance:
//                                 //                       shipmentProvider.distance,
//                                 //                   price: calculatePrice(
//                                 //                     shipmentProvider.distance,
//                                 //                     shipmentProvider
//                                 //                         .totalWeight,
//                                 //                   ),
//                                 //                   period:
//                                 //                       shipmentProvider.period,
//                                 //                   pathpoints: points,
//                                 //                   // truckTypes: truckTypes,
//                                 //                   pickupDate: DateTime(
//                                 //                     shipmentProvider
//                                 //                         .loadDate.year,
//                                 //                     shipmentProvider
//                                 //                         .loadDate.month,
//                                 //                     shipmentProvider
//                                 //                         .loadDate.day,
//                                 //                     shipmentProvider
//                                 //                         .loadTime.hour,
//                                 //                     shipmentProvider
//                                 //                         .loadTime.day,
//                                 //                   ),
//                                 //                   deliveryDate: DateTime(
//                                 //                     shipmentProvider
//                                 //                         .loadDate.year,
//                                 //                     shipmentProvider
//                                 //                         .loadDate.month,
//                                 //                     shipmentProvider
//                                 //                         .loadDate.day,
//                                 //                     shipmentProvider
//                                 //                         .loadTime.hour,
//                                 //                     shipmentProvider
//                                 //                         .loadTime.day,
//                                 //                   ),
//                                 //                 );
//                                 //                 subshipmentsitems
//                                 //                     .add(subshipment);
//                                 //               }
//                                 //               Shipmentv2 shipment = Shipmentv2(
//                                 //                 subshipments: subshipmentsitems,
//                                 //               );
//                                 //               BlocProvider.of<
//                                 //                           ShipmentMultiCreateBloc>(
//                                 //                       context)
//                                 //                   .add(
//                                 //                 ShipmentMultiCreateButtonPressed(
//                                 //                   shipment,
//                                 //                 ),
//                                 //               );
//                                 //             }
//                                 //           },
//                                 //         ),
//                                 //       );
//                                 //     }
//                                 //   },
//                                 // ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
