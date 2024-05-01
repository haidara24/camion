// Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 8.0, vertical: 2.5),
//                                       child: EnsureVisibleWhenFocused(
//                                         focusNode: _truck_node,
//                                         child: Card(
//                                           key: key2,
//                                           color: Colors.white,
//                                           child: Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 1.0, vertical: 7.5),
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 InkWell(
//                                                   onTap: () {
//                                                     showModalBottomSheet(
//                                                       context: context,
//                                                       isScrollControlled: true,
//                                                       useSafeArea: true,
//                                                       builder: (context) =>
//                                                           Container(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(8.0),
//                                                         constraints: BoxConstraints(
//                                                             maxHeight:
//                                                                 MediaQuery.of(
//                                                                         context)
//                                                                     .size
//                                                                     .height),
//                                                         width: double.infinity,
//                                                         child: Column(
//                                                           children: [
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(8.0),
//                                                               child: Row(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .spaceBetween,
//                                                                 children: [
//                                                                   InkWell(
//                                                                     onTap: () {
//                                                                       Navigator.pop(
//                                                                           context);
//                                                                     },
//                                                                     child:
//                                                                         AbsorbPointer(
//                                                                       absorbing:
//                                                                           false,
//                                                                       child:
//                                                                           Padding(
//                                                                         padding: const EdgeInsets
//                                                                             .all(
//                                                                             8.0),
//                                                                         child: localeState.value.countryCode ==
//                                                                                 'en'
//                                                                             ? const Icon(Icons.arrow_forward)
//                                                                             : const Icon(Icons.arrow_back),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                   Text(
//                                                                     AppLocalizations.of(
//                                                                             context)!
//                                                                         .translate(
//                                                                             'select_truck_type'),
//                                                                     style:
//                                                                         TextStyle(
//                                                                       fontSize:
//                                                                           18.sp,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold,
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                             SizedBox(
//                                                               height: 5.h,
//                                                             ),
//                                                             BlocBuilder<
//                                                                 TruckTypeBloc,
//                                                                 TruckTypeState>(
//                                                               builder: (context,
//                                                                   state) {
//                                                                 if (state
//                                                                     is TruckTypeLoadedSuccess) {
//                                                                   return state
//                                                                           .truckTypes
//                                                                           .isEmpty
//                                                                       ? Center(
//                                                                           child:
//                                                                               Text(AppLocalizations.of(context)!.translate('no_shipments')),
//                                                                         )
//                                                                       : Expanded(
//                                                                           child: ListView.builder(
//                                                                               shrinkWrap: true,
//                                                                               itemBuilder: (context, index3) {
//                                                                                 return Column(
//                                                                                   children: [
//                                                                                     Padding(
//                                                                                       padding: EdgeInsets.symmetric(
//                                                                                         horizontal: 5.w,
//                                                                                       ),
//                                                                                       child: InkWell(
//                                                                                         onTap: () {
//                                                                                           FocusManager.instance.primaryFocus?.unfocus();
//                                                                                           setState(() {
//                                                                                             truckError[index] = false;
//                                                                                             // truckNumControllers[previousIndex].text = "";
//                                                                                             // trucknum[previousIndex] = 0;
//                                                                                             // truckNumControllers[index].text = "1";
//                                                                                             // trucknum[index][index3] = 1;
//                                                                                             // truckType[index] = state.truckTypes[index].id!;
//                                                                                             // // previousIndex = index;
//                                                                                           });
//                                                                                         },
//                                                                                         child: Stack(
//                                                                                           clipBehavior: Clip.none,
//                                                                                           children: [
//                                                                                             Container(
//                                                                                               // width: 175.w,
//                                                                                               // decoration: BoxDecoration(
//                                                                                               //   borderRadius: BorderRadius.circular(7),
//                                                                                               //   border: Border.all(
//                                                                                               //     color: truckType == state.truckTypes[index].id! ? AppColor.deepYellow : AppColor.darkGrey,
//                                                                                               //     width: 2.w,
//                                                                                               //   ),
//                                                                                               // ),
//                                                                                               child: Row(
//                                                                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                                                 children: [
//                                                                                                   Column(
//                                                                                                     children: [
//                                                                                                       SizedBox(
//                                                                                                         height: 50.h,
//                                                                                                         width: 175.w,
//                                                                                                         child: CachedNetworkImage(
//                                                                                                           imageUrl: state.truckTypes[index].image!,
//                                                                                                           progressIndicatorBuilder: (context, url, downloadProgress) => Shimmer.fromColors(
//                                                                                                             baseColor: (Colors.grey[300])!,
//                                                                                                             highlightColor: (Colors.grey[100])!,
//                                                                                                             enabled: true,
//                                                                                                             child: Container(
//                                                                                                               height: 50.h,
//                                                                                                               width: 175.w,
//                                                                                                               color: Colors.white,
//                                                                                                             ),
//                                                                                                           ),
//                                                                                                           errorWidget: (context, url, error) => Container(
//                                                                                                             height: 50.h,
//                                                                                                             width: 175.w,
//                                                                                                             color: Colors.grey[300],
//                                                                                                             child: Center(
//                                                                                                               child: Text(AppLocalizations.of(context)!.translate('image_load_error')),
//                                                                                                             ),
//                                                                                                           ),
//                                                                                                         ),
//                                                                                                       ),
//                                                                                                       SizedBox(
//                                                                                                         height: 7.h,
//                                                                                                       ),
//                                                                                                       Text(
//                                                                                                         localeState.value.languageCode == 'en' ? state.truckTypes[index].name! : state.truckTypes[index].nameAr!,
//                                                                                                         style: TextStyle(
//                                                                                                           fontSize: 17.sp,
//                                                                                                           color: AppColor.deepBlack,
//                                                                                                         ),
//                                                                                                       ),
//                                                                                                     ],
//                                                                                                   ),
//                                                                                                   SizedBox(
//                                                                                                     height: 7.h,
//                                                                                                   ),
//                                                                                                   Padding(
//                                                                                                     padding: EdgeInsets.symmetric(horizontal: 5.w),
//                                                                                                     child: Row(
//                                                                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                                                       children: [
//                                                                                                         InkWell(
//                                                                                                           onTap: () {
//                                                                                                             if (truckType == state.truckTypes[index].id!) {
//                                                                                                               setState(() {
//                                                                                                                 trucknum[index][index3]++;
//                                                                                                                 truckNumControllers[index][index3].text = trucknum[index].toString();
//                                                                                                               });
//                                                                                                             } else {
//                                                                                                               setState(() {
//                                                                                                                 truckError[index] = false;
//                                                                                                                 // truckNumControllers[previousIndex].text = "";
//                                                                                                                 // trucknum[previousIndex] = 0;
//                                                                                                                 // truckNumControllers[index].text = "1";
//                                                                                                                 // trucknum[index][index3] = 1;
//                                                                                                                 // truckType[index] = state.truckTypes[index].id!;
//                                                                                                                 // previousIndex = index;
//                                                                                                               });
//                                                                                                             }
//                                                                                                           },
//                                                                                                           child: Container(
//                                                                                                             padding: const EdgeInsets.all(3),
//                                                                                                             decoration: BoxDecoration(
//                                                                                                               border: Border.all(
//                                                                                                                 color: Colors.grey[600]!,
//                                                                                                                 width: 1,
//                                                                                                               ),
//                                                                                                               borderRadius: BorderRadius.circular(45),
//                                                                                                             ),
//                                                                                                             child: Icon(Icons.add, size: 25.w, color: Colors.blue[200]!),
//                                                                                                           ),
//                                                                                                         ),
//                                                                                                         SizedBox(
//                                                                                                           width: 7.h,
//                                                                                                         ),
//                                                                                                         SizedBox(
//                                                                                                           width: 70.w,
//                                                                                                           height: 38.h,
//                                                                                                           child: TextField(
//                                                                                                             controller: truckNumControllers[index][index3],
//                                                                                                             // focusNode:
//                                                                                                             //     _nodeTabaleh,
//                                                                                                             enabled: false,

//                                                                                                             textAlign: TextAlign.center,
//                                                                                                             style: const TextStyle(fontSize: 18),
//                                                                                                             textInputAction: TextInputAction.done,
//                                                                                                             keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
//                                                                                                             inputFormatters: [
//                                                                                                               DecimalFormatter(),
//                                                                                                             ],

//                                                                                                             decoration: const InputDecoration(
//                                                                                                               labelText: "",
//                                                                                                               alignLabelWithHint: true,
//                                                                                                               contentPadding: EdgeInsets.zero,
//                                                                                                             ),
//                                                                                                             scrollPadding: EdgeInsets.only(
//                                                                                                               bottom: MediaQuery.of(context).viewInsets.bottom + 50,
//                                                                                                             ),
//                                                                                                           ),
//                                                                                                         ),
//                                                                                                         // Text(
//                                                                                                         //   tabalehNum.toString(),
//                                                                                                         //   style: const TextStyle(fontSize: 30),
//                                                                                                         // ),
//                                                                                                         SizedBox(
//                                                                                                           width: 7.h,
//                                                                                                         ),
//                                                                                                         InkWell(
//                                                                                                           onTap: () {
//                                                                                                             // if (truckType == state.truckTypes[index].id!) {
//                                                                                                             //   setState(() {
//                                                                                                             //     if (trucknum[index] > 0) {
//                                                                                                             //       trucknum[index]--;
//                                                                                                             //       truckNumControllers[index].text = trucknum[index].toString();
//                                                                                                             //     }
//                                                                                                             //   });
//                                                                                                             // }
//                                                                                                           },
//                                                                                                           child: Container(
//                                                                                                             padding: const EdgeInsets.all(3),
//                                                                                                             decoration: BoxDecoration(
//                                                                                                               border: Border.all(
//                                                                                                                 color: Colors.grey[600]!,
//                                                                                                                 width: 1,
//                                                                                                               ),
//                                                                                                               borderRadius: BorderRadius.circular(45),
//                                                                                                             ),
//                                                                                                             child: trucknum[index][index3] > 1
//                                                                                                                 ? Icon(
//                                                                                                                     Icons.remove,
//                                                                                                                     size: 25.w,
//                                                                                                                     color: Colors.blue[200]!,
//                                                                                                                   )
//                                                                                                                 : Icon(
//                                                                                                                     Icons.remove,
//                                                                                                                     size: 25.w,
//                                                                                                                     color: Colors.grey[600]!,
//                                                                                                                   ),
//                                                                                                           ),
//                                                                                                         ),
//                                                                                                       ],
//                                                                                                     ),
//                                                                                                   ),
//                                                                                                 ],
//                                                                                               ),
//                                                                                             ),
//                                                                                             truckType == state.truckTypes[index].id!
//                                                                                                 ? Positioned(
//                                                                                                     right: -7.w,
//                                                                                                     top: -10.h,
//                                                                                                     child: Container(
//                                                                                                       padding: const EdgeInsets.all(2),
//                                                                                                       decoration: BoxDecoration(
//                                                                                                         color: AppColor.deepYellow,
//                                                                                                         borderRadius: BorderRadius.circular(45),
//                                                                                                       ),
//                                                                                                       child: Icon(Icons.check, size: 16.w, color: Colors.white),
//                                                                                                     ),
//                                                                                                   )
//                                                                                                 : const SizedBox.shrink()
//                                                                                           ],
//                                                                                         ),
//                                                                                       ),
//                                                                                     ),
//                                                                                     const Divider(),
//                                                                                   ],
//                                                                                 );
//                                                                               },
//                                                                               itemCount: state.truckTypes.length),
//                                                                         );
//                                                                 } else {
//                                                                   return Container();
//                                                                 }
//                                                               },
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     );
//                                                   },
//                                                   child: Padding(
//                                                     padding:
//                                                         const EdgeInsets.all(
//                                                             4.0),
//                                                     child: Text(
//                                                       AppLocalizations.of(
//                                                               context)!
//                                                           .translate(
//                                                               'select_truck_type'),
//                                                       style: TextStyle(
//                                                         // color: AppColor.lightBlue,
//                                                         fontSize: 19.sp,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 SizedBox(
//                                                   height: 5.h,
//                                                 ),
//                                                 SizedBox(
//                                                   height: 185.h,
//                                                   child: BlocBuilder<
//                                                       TruckTypeBloc,
//                                                       TruckTypeState>(
//                                                     builder: (context, state) {
//                                                       if (state
//                                                           is TruckTypeLoadedSuccess) {
//                                                         truckTypes = [];
//                                                         // truckTypes = state.truckTypes[truckindex];
//                                                         for (var element
//                                                             in truckTypes) {
//                                                           trucknum.add([0]);
//                                                           truckNumControllers
//                                                               .add([
//                                                             TextEditingController()
//                                                           ]);
//                                                         }
//                                                         return Scrollbar(
//                                                           controller:
//                                                               _scrollController,
//                                                           thumbVisibility: true,
//                                                           thickness: 2.0,
//                                                           child: Padding(
//                                                             padding:
//                                                                 EdgeInsets.all(
//                                                                     2.h),
//                                                             child: ListView
//                                                                 .builder(
//                                                               controller:
//                                                                   _scrollController,
//                                                               itemCount: state
//                                                                   .truckTypes
//                                                                   .length,
//                                                               scrollDirection:
//                                                                   Axis.horizontal,
//                                                               shrinkWrap: true,
//                                                               itemBuilder:
//                                                                   (context,
//                                                                       truckindex) {
//                                                                 return Padding(
//                                                                   padding: EdgeInsets.symmetric(
//                                                                       horizontal:
//                                                                           5.w,
//                                                                       vertical:
//                                                                           15.h),
//                                                                   child:
//                                                                       InkWell(
//                                                                     onTap: () {
//                                                                       FocusManager
//                                                                           .instance
//                                                                           .primaryFocus
//                                                                           ?.unfocus();
//                                                                       setState(
//                                                                           () {
//                                                                         truckError[index] =
//                                                                             false;
//                                                                         // truckNumControllers[
//                                                                         //         previousIndex]
//                                                                         //     .text = "";
//                                                                         // trucknum[
//                                                                         //     previousIndex] = 0;
//                                                                         // truckNumControllers[
//                                                                         //         index]
//                                                                         //     .text = "1";
//                                                                         // trucknum[index] = 1;
//                                                                         // truckType = state
//                                                                         //     .truckTypes[
//                                                                         //         index]
//                                                                         //     .id!;
//                                                                         // previousIndex =
//                                                                         //     index;
//                                                                       });
//                                                                     },
//                                                                     child:
//                                                                         Stack(
//                                                                       clipBehavior:
//                                                                           Clip.none,
//                                                                       children: [
//                                                                         Container(
//                                                                           width:
//                                                                               175.w,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(7),
//                                                                             border:
//                                                                                 Border.all(
//                                                                               color: truckType == state.truckTypes[index].id! ? AppColor.deepYellow : AppColor.darkGrey,
//                                                                               width: 2.w,
//                                                                             ),
//                                                                           ),
//                                                                           child:
//                                                                               Column(
//                                                                             mainAxisAlignment:
//                                                                                 MainAxisAlignment.center,
//                                                                             children: [
//                                                                               CachedNetworkImage(
//                                                                                 imageUrl: state.truckTypes[index].image!,
//                                                                                 progressIndicatorBuilder: (context, url, downloadProgress) => Shimmer.fromColors(
//                                                                                   baseColor: (Colors.grey[300])!,
//                                                                                   highlightColor: (Colors.grey[100])!,
//                                                                                   enabled: true,
//                                                                                   child: Container(
//                                                                                     height: 50.h,
//                                                                                     width: 175.w,
//                                                                                     color: Colors.white,
//                                                                                   ),
//                                                                                 ),
//                                                                                 errorWidget: (context, url, error) => Container(
//                                                                                   height: 50.h,
//                                                                                   width: 175.w,
//                                                                                   color: Colors.grey[300],
//                                                                                   child: Center(
//                                                                                     child: Text(AppLocalizations.of(context)!.translate('image_load_error')),
//                                                                                   ),
//                                                                                 ),
//                                                                               ),
//                                                                               SizedBox(
//                                                                                 height: 7.h,
//                                                                               ),
//                                                                               Text(
//                                                                                 localeState.value.languageCode == 'en' ? state.truckTypes[index].name! : state.truckTypes[index].nameAr!,
//                                                                                 style: TextStyle(
//                                                                                   fontSize: 17.sp,
//                                                                                   color: AppColor.deepBlack,
//                                                                                 ),
//                                                                               ),
//                                                                               SizedBox(
//                                                                                 height: 7.h,
//                                                                               ),
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.symmetric(horizontal: 5.w),
//                                                                                 child: Row(
//                                                                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                                   children: [
//                                                                                     InkWell(
//                                                                                       onTap: () {
//                                                                                         if (truckType == state.truckTypes[index].id!) {
//                                                                                           setState(() {
//                                                                                             trucknum[index][truckindex]++;
//                                                                                             truckNumControllers[index][truckindex].text = trucknum[index][truckindex].toString();
//                                                                                           });
//                                                                                         } else {
//                                                                                           setState(() {
//                                                                                             truckError[index] = false;
//                                                                                             // truckNumControllers[previousIndex].text = "";
//                                                                                             // trucknum[previousIndex] = 0;
//                                                                                             // truckNumControllers[index].text = "1";
//                                                                                             // trucknum[index] = 1;
//                                                                                             // truckType = state.truckTypes[index].id!;
//                                                                                             // previousIndex = index;
//                                                                                           });
//                                                                                         }
//                                                                                       },
//                                                                                       child: Container(
//                                                                                         padding: const EdgeInsets.all(3),
//                                                                                         decoration: BoxDecoration(
//                                                                                           border: Border.all(
//                                                                                             color: Colors.grey[600]!,
//                                                                                             width: 1,
//                                                                                           ),
//                                                                                           borderRadius: BorderRadius.circular(45),
//                                                                                         ),
//                                                                                         child: Icon(Icons.add, size: 25.w, color: Colors.blue[200]!),
//                                                                                       ),
//                                                                                     ),
//                                                                                     SizedBox(
//                                                                                       width: 70.w,
//                                                                                       height: 38.h,
//                                                                                       child: TextField(
//                                                                                         controller: truckNumControllers[index][truckindex],
//                                                                                         // focusNode:
//                                                                                         //     _nodeTabaleh,
//                                                                                         enabled: false,

//                                                                                         textAlign: TextAlign.center,
//                                                                                         style: const TextStyle(fontSize: 18),
//                                                                                         textInputAction: TextInputAction.done,
//                                                                                         keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
//                                                                                         inputFormatters: [
//                                                                                           DecimalFormatter(),
//                                                                                         ],

//                                                                                         decoration: const InputDecoration(
//                                                                                           labelText: "",
//                                                                                           alignLabelWithHint: true,
//                                                                                           contentPadding: EdgeInsets.zero,
//                                                                                         ),
//                                                                                         scrollPadding: EdgeInsets.only(
//                                                                                           bottom: MediaQuery.of(context).viewInsets.bottom + 50,
//                                                                                         ),
//                                                                                       ),
//                                                                                     ),
//                                                                                     // Text(
//                                                                                     //   tabalehNum.toString(),
//                                                                                     //   style: const TextStyle(fontSize: 30),
//                                                                                     // ),
//                                                                                     InkWell(
//                                                                                       onTap: () {
//                                                                                         if (truckType == state.truckTypes[index].id!) {
//                                                                                           setState(() {
//                                                                                             if (trucknum[index][truckindex] > 0) {
//                                                                                               trucknum[index][truckindex]--;
//                                                                                               truckNumControllers[index][truckindex].text = trucknum[index][truckindex].toString();
//                                                                                             }
//                                                                                           });
//                                                                                         }
//                                                                                       },
//                                                                                       child: Container(
//                                                                                         padding: const EdgeInsets.all(3),
//                                                                                         decoration: BoxDecoration(
//                                                                                           border: Border.all(
//                                                                                             color: Colors.grey[600]!,
//                                                                                             width: 1,
//                                                                                           ),
//                                                                                           borderRadius: BorderRadius.circular(45),
//                                                                                         ),
//                                                                                         child: trucknum[index][index] > 1
//                                                                                             ? Icon(
//                                                                                                 Icons.remove,
//                                                                                                 size: 25.w,
//                                                                                                 color: Colors.blue[200]!,
//                                                                                               )
//                                                                                             : Icon(
//                                                                                                 Icons.remove,
//                                                                                                 size: 25.w,
//                                                                                                 color: Colors.grey[600]!,
//                                                                                               ),
//                                                                                       ),
//                                                                                     ),
//                                                                                   ],
//                                                                                 ),
//                                                                               ),
//                                                                             ],
//                                                                           ),
//                                                                         ),
//                                                                         truckType ==
//                                                                                 state.truckTypes[index].id!
//                                                                             ? Positioned(
//                                                                                 right: -7.w,
//                                                                                 top: -10.h,
//                                                                                 child: Container(
//                                                                                   padding: const EdgeInsets.all(2),
//                                                                                   decoration: BoxDecoration(
//                                                                                     color: AppColor.deepYellow,
//                                                                                     borderRadius: BorderRadius.circular(45),
//                                                                                   ),
//                                                                                   child: Icon(Icons.check, size: 16.w, color: Colors.white),
//                                                                                 ),
//                                                                               )
//                                                                             : const SizedBox.shrink()
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                 );
//                                                               },
//                                                             ),
//                                                           ),
//                                                         );
//                                                       } else {
//                                                         return Shimmer
//                                                             .fromColors(
//                                                           baseColor: (Colors
//                                                               .grey[300])!,
//                                                           highlightColor:
//                                                               (Colors
//                                                                   .grey[100])!,
//                                                           enabled: true,
//                                                           direction:
//                                                               ShimmerDirection
//                                                                   .rtl,
//                                                           child:
//                                                               ListView.builder(
//                                                             shrinkWrap: true,
//                                                             scrollDirection:
//                                                                 Axis.horizontal,
//                                                             itemBuilder:
//                                                                 (_, __) =>
//                                                                     Padding(
//                                                               padding: EdgeInsets
//                                                                   .symmetric(
//                                                                       horizontal:
//                                                                           5.w,
//                                                                       vertical:
//                                                                           15.h),
//                                                               child: Container(
//                                                                 clipBehavior: Clip
//                                                                     .antiAlias,
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   color: Colors
//                                                                       .white,
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               10),
//                                                                 ),
//                                                                 child: SizedBox(
//                                                                   width: 175.w,
//                                                                   height: 70.h,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             itemCount: 6,
//                                                           ),
//                                                         );
//                                                       }
//                                                     },
//                                                   ),
//                                                 ),
//                                                 Visibility(
//                                                   visible: truckError[index],
//                                                   child: Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(8.0),
//                                                         child: Text(
//                                                           AppLocalizations.of(
//                                                                   context)!
//                                                               .translate(
//                                                                   'select_truck_type_error'),
//                                                           style:
//                                                               const TextStyle(
//                                                             color: Colors.red,
//                                                             fontSize: 17,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 SizedBox(
//                                                   height: 7.h,
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),