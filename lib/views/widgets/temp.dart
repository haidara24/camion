// BlocBuilder<
//                                                                     TruckTypeBloc,
//                                                                     TruckTypeState>(
//                                                                   builder:
//                                                                       (context,
//                                                                           state) {
//                                                                     if (state
//                                                                         is TruckTypeLoadedSuccess) {
//                                                                       return state
//                                                                               .truckTypes
//                                                                               .isEmpty
//                                                                           ? Center(
//                                                                               child: Text(AppLocalizations.of(context)!.translate('no_shipments')),
//                                                                             )
//                                                                           : Expanded(
//                                                                               child: ListView.builder(
//                                                                                   shrinkWrap: true,
//                                                                                   itemBuilder: (context, index3) {
//                                                                                     return Column(
//                                                                                       children: [
//                                                                                         Padding(
//                                                                                           padding: EdgeInsets.symmetric(
//                                                                                             horizontal: 5.w,
//                                                                                           ),
//                                                                                           child: InkWell(
//                                                                                             onTap: () {
//                                                                                               FocusManager.instance.primaryFocus?.unfocus();
//                                                                                               setState(() {
//                                                                                                 truckProvider.truckError[selectedIndex] = false;
//                                                                                                 // truckNumControllers[previousIndex].text = "";
//                                                                                                 // trucknum[previousIndex] = 0;
//                                                                                                 // truckNumControllers[index].text = "1";
//                                                                                                 // trucknum[index][index3] = 1;
//                                                                                                 // truckType[index] = state.truckTypes[index].id!;
//                                                                                                 // // previousIndex = index;
//                                                                                               });
//                                                                                             },
//                                                                                             child: Stack(
//                                                                                               clipBehavior: Clip.none,
//                                                                                               children: [
//                                                                                                 Container(
//                                                                                                   // width: 175.w,
//                                                                                                   // decoration: BoxDecoration(
//                                                                                                   //   borderRadius: BorderRadius.circular(7),
//                                                                                                   //   border: Border.all(
//                                                                                                   //     color: truckType == state.truckTypes[index].id! ? AppColor.deepYellow : AppColor.darkGrey,
//                                                                                                   //     width: 2.w,
//                                                                                                   //   ),
//                                                                                                   // ),
//                                                                                                   child: Row(
//                                                                                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                                                     children: [
//                                                                                                       Checkbox(
//                                                                                                         onChanged: (checked) {
//                                                                                                           if (!(checked ?? false)) {
//                                                                                                             truckProvider.removeTruckType(state.truckTypes[index3].id!, selectedIndex);
//                                                                                                           } else {
//                                                                                                             truckProvider.addTruckType(state.truckTypes[index3].id!, selectedIndex);
//                                                                                                           }
//                                                                                                         },
//                                                                                                         value: truckProvider.selectedTruckType[selectedIndex].contains(state.truckTypes[index3].id),
//                                                                                                       ),
//                                                                                                       Column(
//                                                                                                         children: [
//                                                                                                           SizedBox(
//                                                                                                             height: 50.h,
//                                                                                                             width: 175.w,
//                                                                                                             child: CachedNetworkImage(
//                                                                                                               imageUrl: state.truckTypes[index3].image!,
//                                                                                                               progressIndicatorBuilder: (context, url, downloadProgress) => Shimmer.fromColors(
//                                                                                                                 baseColor: (Colors.grey[300])!,
//                                                                                                                 highlightColor: (Colors.grey[100])!,
//                                                                                                                 enabled: true,
//                                                                                                                 child: Container(
//                                                                                                                   height: 50.h,
//                                                                                                                   width: 175.w,
//                                                                                                                   color: Colors.white,
//                                                                                                                 ),
//                                                                                                               ),
//                                                                                                               errorWidget: (context, url, error) => Container(
//                                                                                                                 height: 50.h,
//                                                                                                                 width: 175.w,
//                                                                                                                 color: Colors.grey[300],
//                                                                                                                 child: Center(
//                                                                                                                   child: Text(AppLocalizations.of(context)!.translate('image_load_error')),
//                                                                                                                 ),
//                                                                                                               ),
//                                                                                                             ),
//                                                                                                           ),
//                                                                                                           SizedBox(
//                                                                                                             height: 7.h,
//                                                                                                           ),
//                                                                                                           Text(
//                                                                                                             localeState.value.languageCode == 'en' ? state.truckTypes[index3].name! : state.truckTypes[index3].nameAr!,
//                                                                                                             style: TextStyle(
//                                                                                                               fontSize: 17.sp,
//                                                                                                               color: AppColor.deepBlack,
//                                                                                                             ),
//                                                                                                           ),
//                                                                                                         ],
//                                                                                                       ),
//                                                                                                       SizedBox(
//                                                                                                         height: 7.h,
//                                                                                                       ),
//                                                                                                       Padding(
//                                                                                                         padding: EdgeInsets.symmetric(horizontal: 5.w),
//                                                                                                         child: Row(
//                                                                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                                                           children: [
//                                                                                                             InkWell(
//                                                                                                               onTap: () {
//                                                                                                                 if (truckProvider.selectedTruckType[selectedIndex].contains(state.truckTypes[index3].id)) {
//                                                                                                                   truckProvider.increaseTruckType(state.truckTypes[index3].id!, selectedIndex);
//                                                                                                                 }
//                                                                                                               },
//                                                                                                               child: Container(
//                                                                                                                 padding: const EdgeInsets.all(3),
//                                                                                                                 decoration: BoxDecoration(
//                                                                                                                   border: Border.all(
//                                                                                                                     color: Colors.grey[600]!,
//                                                                                                                     width: 1,
//                                                                                                                   ),
//                                                                                                                   borderRadius: BorderRadius.circular(45),
//                                                                                                                 ),
//                                                                                                                 child: Icon(Icons.add, size: 25.w, color: Colors.blue[200]!),
//                                                                                                               ),
//                                                                                                             ),
//                                                                                                             SizedBox(
//                                                                                                               width: 7.h,
//                                                                                                             ),
//                                                                                                             SizedBox(
//                                                                                                               width: 70.w,
//                                                                                                               height: 38.h,
//                                                                                                               child: TextField(
//                                                                                                                 controller: truckProvider.selectedTruckType[selectedIndex].contains(state.truckTypes[index3].id) ? truckProvider.truckNumController[selectedIndex][truckProvider.selectedTruckType[selectedIndex].indexWhere((item) => item == state.truckTypes[index3].id)] : null,
//                                                                                                                 enabled: false,
//                                                                                                                 textAlign: TextAlign.center,
//                                                                                                                 style: const TextStyle(fontSize: 18),
//                                                                                                                 textInputAction: TextInputAction.done,
//                                                                                                                 keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
//                                                                                                                 inputFormatters: [
//                                                                                                                   DecimalFormatter(),
//                                                                                                                 ],
//                                                                                                                 decoration: const InputDecoration(
//                                                                                                                   labelText: "",
//                                                                                                                   alignLabelWithHint: true,
//                                                                                                                   contentPadding: EdgeInsets.zero,
//                                                                                                                 ),
//                                                                                                                 scrollPadding: EdgeInsets.only(
//                                                                                                                   bottom: MediaQuery.of(context).viewInsets.bottom + 50,
//                                                                                                                 ),
//                                                                                                               ),
//                                                                                                             ),
//                                                                                                             SizedBox(
//                                                                                                               width: 7.h,
//                                                                                                             ),
//                                                                                                             InkWell(
//                                                                                                               onTap: () {
//                                                                                                                 if (truckProvider.selectedTruckType[selectedIndex].contains(state.truckTypes[index3].id)) {
//                                                                                                                   truckProvider.decreaseTruckType(state.truckTypes[index3].id!, selectedIndex);
//                                                                                                                 }
//                                                                                                               },
//                                                                                                               child: Container(
//                                                                                                                 padding: const EdgeInsets.all(3),
//                                                                                                                 decoration: BoxDecoration(
//                                                                                                                   border: Border.all(
//                                                                                                                     color: Colors.grey[600]!,
//                                                                                                                     width: 1,
//                                                                                                                   ),
//                                                                                                                   borderRadius: BorderRadius.circular(45),
//                                                                                                                 ),
//                                                                                                                 child: Icon(
//                                                                                                                   Icons.remove,
//                                                                                                                   size: 25.w,
//                                                                                                                   color: Colors.grey[600]!,
//                                                                                                                 ),
//                                                                                                               ),
//                                                                                                             ),
//                                                                                                           ],
//                                                                                                         ),
//                                                                                                       ),
//                                                                                                     ],
//                                                                                                   ),
//                                                                                                 ),
//                                                                                               ],
//                                                                                             ),
//                                                                                           ),
//                                                                                         ),
//                                                                                         const Divider(),
//                                                                                       ],
//                                                                                     );
//                                                                                   },
//                                                                                   itemCount: state.truckTypes.length),
//                                                                             );
//                                                                     } else {
//                                                                       return Container();
//                                                                     }
//                                                                   },
//                                                                 )