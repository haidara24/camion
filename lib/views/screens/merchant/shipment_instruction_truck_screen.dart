import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/instructions/instruction_create_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/read_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/read_sub_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/sub_instruction_create_bloc.dart';
import 'package:camion/business_logic/bloc/package_type_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/providers/shipment_instructions_provider.dart';
import 'package:camion/data/providers/task_num_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/formatter.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ShipmentInstructionTruckScreen extends StatefulWidget {
  final int? shipmentInstruction;
  final ShipmentTruck? trucks;
  ShipmentInstructionTruckScreen({
    Key? key,
    required this.shipmentInstruction,
    required this.trucks,
  }) : super(key: key);

  @override
  State<ShipmentInstructionTruckScreen> createState() =>
      _ShipmentInstructionTruckScreenState();
}

class _ShipmentInstructionTruckScreenState
    extends State<ShipmentInstructionTruckScreen> {
  int selectedTruck = 0;
  bool widgetLoading = true;

  List<int> count = [];
  ShipmentInstructionsProvider? instructionsProvider;

  TextEditingController total_weight_controller = TextEditingController();
  List<TextEditingController> net_weight_controller = [];
  List<TextEditingController> truck_weight_controller = [
    TextEditingController()
  ];
  List<TextEditingController> final_weight_controller = [
    TextEditingController()
  ];

  List<List<TextEditingController>> commodityName_controller = [];
  List<List<TextEditingController>> commodityWeight_controller = [];
  List<List<TextEditingController>> commodityQuantity_controller = [];
  List<List<TextEditingController>> readpackageType_controller = [];
  List<List<PackageType?>> packageType_controller = [
    [null]
  ];
  final GlobalKey<FormState> _commodityInfoformKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _weightInfoformKey = GlobalKey<FormState>();

  void additem() {
    setState(() {
      commodityName_controller[selectedTruck].add(TextEditingController());
      commodityWeight_controller[selectedTruck].add(TextEditingController());
      commodityQuantity_controller[selectedTruck].add(TextEditingController());
      packageType_controller[selectedTruck].add(null);

      count[selectedTruck]++;
    });
  }

  void removeitem(int index) {
    setState(() {
      commodityName_controller[selectedTruck].removeAt(index);
      commodityWeight_controller[selectedTruck].removeAt(index);
      commodityQuantity_controller[selectedTruck].removeAt(index);
      packageType_controller[selectedTruck].removeAt(index);

      count[selectedTruck]--;
    });
  }

  // Widget truckList() {
  //   return SizedBox(
  //     height: 115.h,
  //     child: ListView.builder(
  //       itemCount: widget.trucks!.length,
  //       shrinkWrap: true,
  //       scrollDirection: Axis.horizontal,
  //       itemBuilder: (context, index) {
  //         return InkWell(
  //           onTap: () async {
  //             setState(() {
  //               selectedTruck = index;
  //             });
  //           },
  //           child: Container(
  //             width: 180.w,
  //             margin: const EdgeInsets.all(5),
  //             padding: const EdgeInsets.all(5),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(11),
  //               border: Border.all(
  //                 color: selectedTruck == index
  //                     ? AppColor.deepYellow
  //                     : Colors.grey[400]!,
  //               ),
  //             ),
  //             child: Column(
  //               children: [
  //                 SizedBox(
  //                   height: 50.h,
  //                   width: 175.w,
  //                   child: CachedNetworkImage(
  //                     imageUrl: widget.trucks![index].truck_type!.image!,
  //                     progressIndicatorBuilder:
  //                         (context, url, downloadProgress) =>
  //                             Shimmer.fromColors(
  //                       baseColor: (Colors.grey[300])!,
  //                       highlightColor: (Colors.grey[100])!,
  //                       enabled: true,
  //                       child: Container(
  //                         height: 50.h,
  //                         width: 175.w,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                     errorWidget: (context, url, error) => Container(
  //                       height: 50.h,
  //                       width: 175.w,
  //                       color: Colors.grey[300],
  //                       child: Center(
  //                         child: Text(AppLocalizations.of(context)!
  //                             .translate('image_load_error')),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   height: 7.h,
  //                 ),
  //                 Text(
  //                   "${widget.trucks![index].truckuser!.user!.firstName!} ${widget.trucks![index].truckuser!.user!.lastName!}",
  //                   style: TextStyle(
  //                     fontSize: 17.sp,
  //                     color: AppColor.deepBlack,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      instructionsProvider =
          Provider.of<ShipmentInstructionsProvider>(context, listen: false);
      print(jsonEncode(
          instructionsProvider!.subShipment!.shipmentinstructionv2!));
      if (instructionsProvider!
              .subShipment!.shipmentinstructionv2!.subinstrucations!
              .singleWhere(
            (element) => element!.truck! == widget.trucks!.id!,
            orElse: () => SubShipmentInstruction(id: 0),
          ) !=
          SubShipmentInstruction(id: 0)) {
        net_weight_controller[selectedTruck].text = instructionsProvider!
            .subShipment!.shipmentinstructionv2!.subinstrucations!
            .singleWhere(
              (element) => element!.truck! == widget.trucks!.id!,
              orElse: () => SubShipmentInstruction(id: 0),
            )!
            .netWeight!
            .toString();
        truck_weight_controller[0].text = instructionsProvider!
            .subShipment!.shipmentinstructionv2!.subinstrucations!
            .singleWhere(
              (element) => element!.truck! == widget.trucks!.id!,
              orElse: () => SubShipmentInstruction(id: 0),
            )!
            .truckWeight!
            .toString();
        final_weight_controller[0].text = instructionsProvider!
            .subShipment!.shipmentinstructionv2!.subinstrucations!
            .singleWhere(
              (element) => element!.truck! == widget.trucks!.id!,
              orElse: () => SubShipmentInstruction(id: 0),
            )!
            .finalWeight!
            .toString();
        for (var i = 0;
            i <
                instructionsProvider!
                    .subShipment!.shipmentinstructionv2!.subinstrucations!
                    .singleWhere(
                      (element) => element!.truck! == widget.trucks!.id!,
                      orElse: () => SubShipmentInstruction(id: 0),
                    )!
                    .commodityItems!
                    .length;
            i++) {
          commodityName_controller[0][i].text = instructionsProvider!
              .subShipment!.shipmentinstructionv2!.subinstrucations!
              .singleWhere(
                (element) => element!.truck! == widget.trucks!.id!,
                orElse: () => SubShipmentInstruction(id: 0),
              )!
              .commodityItems![i]
              .commodityName!;
          commodityWeight_controller[0][i].text = instructionsProvider!
              .subShipment!.shipmentinstructionv2!.subinstrucations!
              .singleWhere(
                (element) => element!.truck! == widget.trucks!.id!,
                orElse: () => SubShipmentInstruction(id: 0),
              )!
              .commodityItems![i]
              .commodityWeight!
              .toString();
          commodityQuantity_controller[0][i].text = instructionsProvider!
              .subShipment!.shipmentinstructionv2!.subinstrucations!
              .singleWhere(
                (element) => element!.truck! == widget.trucks!.id!,
                orElse: () => SubShipmentInstruction(id: 0),
              )!
              .commodityItems![i]
              .commodityQuantity!
              .toString();
          readpackageType_controller[0][i].text = instructionsProvider!
              .subShipment!.shipmentinstructionv2!.subinstrucations!
              .singleWhere(
                (element) => element!.truck! == widget.trucks!.id!,
                orElse: () => SubShipmentInstruction(id: 0),
              )!
              .commodityItems![i]
              .packageType!
              .toString();
        }
      }
    });
    // for (var i = 0; i < widget.trucks!.length; i++) {
    //   net_weight_controller.add(TextEditingController());
    //   truck_weight_controller.add(TextEditingController());
    //   final_weight_controller.add(TextEditingController());

    //   commodityName_controller.add([TextEditingController()]);
    //   commodityWeight_controller.add([TextEditingController()]);
    //   commodityQuantity_controller.add([TextEditingController()]);
    //   packageType_controller.add([null]);
    //   count.add(1);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return SafeArea(
          child: Scaffold(
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.translate('shipment_tasks'),
            ),
            backgroundColor: Colors.grey[200],
            body: SingleChildScrollView(
              child: Consumer<ShipmentInstructionsProvider>(
                  builder: (context, instructionProvider, child) {
                return Column(
                  children: [
                    // truckList(),
                    instructionProvider.subShipment!.shipmentinstructionv2!
                                .subinstrucations!
                                .singleWhere(
                              (element) =>
                                  element!.truck! == widget.trucks!.id!,
                              orElse: () => SubShipmentInstruction(id: 0),
                            ) !=
                            SubShipmentInstruction(id: 0)
                        ? Stack(
                            clipBehavior: Clip.none,
                            children: [
                              SizedBox(
                                // key: key1,
                                child: Form(
                                  key: _commodityInfoformKey,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: count[selectedTruck],
                                      itemBuilder: (context, index2) {
                                        return Stack(
                                          children: [
                                            Card(
                                              color: Colors.white,
                                              margin: const EdgeInsets.all(5),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 7.5),
                                                child: Column(
                                                  children: [
                                                    index2 == 0
                                                        ? Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                                Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .translate(
                                                                          'commodity_info'),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: AppColor
                                                                        .darkGrey,
                                                                  ),
                                                                ),
                                                              ])
                                                        : const SizedBox
                                                            .shrink(),
                                                    index2 != 0
                                                        ? const SizedBox(
                                                            height: 30,
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
                                                    const SizedBox(
                                                      height: 7,
                                                    ),
                                                    BlocBuilder<PackageTypeBloc,
                                                        PackageTypeState>(
                                                      builder:
                                                          (context, state2) {
                                                        if (state2
                                                            is PackageTypeLoadedSuccess) {
                                                          return DropdownButtonHideUnderline(
                                                            child:
                                                                DropdownButton2<
                                                                    PackageType>(
                                                              isExpanded: true,
                                                              hint: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'package_type'),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .hintColor,
                                                                ),
                                                              ),
                                                              items: state2
                                                                  .packageTypes
                                                                  .map((PackageType
                                                                          item) =>
                                                                      DropdownMenuItem<
                                                                          PackageType>(
                                                                        value:
                                                                            item,
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              200,
                                                                          child:
                                                                              Text(
                                                                            item.name!,
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 17,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ))
                                                                  .toList(),
                                                              value:
                                                                  packageType_controller[
                                                                      index2][0],
                                                              onChanged:
                                                                  (PackageType?
                                                                      value) {
                                                                setState(() {
                                                                  packageType_controller[
                                                                          selectedTruck]
                                                                      [
                                                                      index2] = value!;
                                                                });
                                                              },
                                                              buttonStyleData:
                                                                  ButtonStyleData(
                                                                height: 50,
                                                                width: double
                                                                    .infinity,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      9.0,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .black26,
                                                                  ),
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                // elevation: 2,
                                                              ),
                                                              iconStyleData:
                                                                  IconStyleData(
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .keyboard_arrow_down_sharp,
                                                                ),
                                                                iconSize: 20,
                                                                iconEnabledColor:
                                                                    AppColor
                                                                        .deepYellow,
                                                                iconDisabledColor:
                                                                    Colors.grey,
                                                              ),
                                                              dropdownStyleData:
                                                                  DropdownStyleData(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              14),
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                scrollbarTheme:
                                                                    ScrollbarThemeData(
                                                                  radius: const Radius
                                                                      .circular(
                                                                      40),
                                                                  thickness:
                                                                      MaterialStateProperty
                                                                          .all(
                                                                              6),
                                                                  thumbVisibility:
                                                                      MaterialStateProperty
                                                                          .all(
                                                                              true),
                                                                ),
                                                              ),
                                                              menuItemStyleData:
                                                                  const MenuItemStyleData(
                                                                height: 40,
                                                              ),
                                                            ),
                                                          );
                                                        } else if (state2
                                                            is PackageTypeLoadingProgress) {
                                                          return const Center(
                                                            child:
                                                                LinearProgressIndicator(),
                                                          );
                                                        } else if (state2
                                                            is PackageTypeLoadedFailed) {
                                                          return Center(
                                                            child: InkWell(
                                                              onTap: () {
                                                                BlocProvider.of<
                                                                            PackageTypeBloc>(
                                                                        context)
                                                                    .add(
                                                                        PackageTypeLoadEvent());
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .translate(
                                                                            'list_error'),
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                  const Icon(
                                                                    Icons
                                                                        .refresh,
                                                                    color: Colors
                                                                        .grey,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          return Container();
                                                        }
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    TextFormField(
                                                      controller:
                                                          commodityName_controller[
                                                                  selectedTruck]
                                                              [index2],
                                                      onTap: () {
                                                        BlocProvider.of<
                                                                    BottomNavBarCubit>(
                                                                context)
                                                            .emitHide();
                                                        commodityName_controller[
                                                                        selectedTruck]
                                                                    [index2]
                                                                .selection =
                                                            TextSelection(
                                                                baseOffset: 0,
                                                                extentOffset:
                                                                    commodityName_controller[selectedTruck]
                                                                            [
                                                                            index2]
                                                                        .value
                                                                        .text
                                                                        .length);
                                                      },
                                                      // focusNode: _nodeWeight,
                                                      // enabled: !valueEnabled,
                                                      scrollPadding:
                                                          EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                    context)
                                                                .viewInsets
                                                                .bottom +
                                                            50,
                                                      ),
                                                      textInputAction:
                                                          TextInputAction.done,

                                                      style: const TextStyle(
                                                          fontSize: 20),
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: AppLocalizations
                                                                .of(context)!
                                                            .translate(
                                                                'commodity_name'),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 11.0,
                                                                horizontal:
                                                                    9.0),
                                                      ),
                                                      onTapOutside: (event) {},
                                                      onEditingComplete: () {
                                                        // if (evaluateCo2()) {
                                                        //   calculateCo2Report();
                                                        // }
                                                      },
                                                      onChanged: (value) {
                                                        // if (evaluateCo2()) {
                                                        //   calculateCo2Report();
                                                        // }
                                                      },
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
                                                          return AppLocalizations
                                                                  .of(context)!
                                                              .translate(
                                                                  'insert_value_validate');
                                                        }
                                                        return null;
                                                      },
                                                      onSaved: (newValue) {
                                                        commodityName_controller[
                                                                    selectedTruck]
                                                                [index2]
                                                            .text = newValue!;
                                                      },
                                                      onFieldSubmitted:
                                                          (value) {
                                                        // if (evaluateCo2()) {
                                                        //   calculateCo2Report();
                                                        // }
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                        BlocProvider.of<
                                                                    BottomNavBarCubit>(
                                                                context)
                                                            .emitShow();
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    TextFormField(
                                                      controller:
                                                          commodityQuantity_controller[
                                                                  selectedTruck]
                                                              [index2],
                                                      onTap: () {
                                                        BlocProvider.of<
                                                                    BottomNavBarCubit>(
                                                                context)
                                                            .emitHide();
                                                        commodityQuantity_controller[
                                                                        selectedTruck]
                                                                    [index2]
                                                                .selection =
                                                            TextSelection(
                                                                baseOffset: 0,
                                                                extentOffset:
                                                                    commodityQuantity_controller[selectedTruck]
                                                                            [
                                                                            index2]
                                                                        .value
                                                                        .text
                                                                        .length);
                                                      },
                                                      // focusNode: _nodeWeight,
                                                      // enabled: !valueEnabled,
                                                      scrollPadding:
                                                          EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                    context)
                                                                .viewInsets
                                                                .bottom +
                                                            50,
                                                      ),
                                                      textInputAction:
                                                          TextInputAction.done,
                                                      keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                              decimal: true,
                                                              signed: true),
                                                      inputFormatters: [
                                                        DecimalFormatter(),
                                                      ],
                                                      style: const TextStyle(
                                                          fontSize: 20),
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: AppLocalizations
                                                                .of(context)!
                                                            .translate(
                                                                'commodity_quantity'),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 11.0,
                                                                horizontal:
                                                                    9.0),
                                                      ),
                                                      onTapOutside: (event) {},
                                                      onEditingComplete: () {
                                                        // if (evaluateCo2()) {
                                                        //   calculateCo2Report();
                                                        // }
                                                      },
                                                      onChanged: (value) {
                                                        // if (evaluateCo2()) {
                                                        //   calculateCo2Report();
                                                        // }
                                                      },
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
                                                          return AppLocalizations
                                                                  .of(context)!
                                                              .translate(
                                                                  'insert_value_validate');
                                                        }
                                                        return null;
                                                      },
                                                      onSaved: (newValue) {
                                                        commodityQuantity_controller[
                                                                    selectedTruck]
                                                                [index2]
                                                            .text = newValue!;
                                                      },
                                                      onFieldSubmitted:
                                                          (value) {
                                                        // if (evaluateCo2()) {
                                                        //   calculateCo2Report();
                                                        // }
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                        BlocProvider.of<
                                                                    BottomNavBarCubit>(
                                                                context)
                                                            .emitShow();
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    TextFormField(
                                                      controller:
                                                          commodityWeight_controller[
                                                                  selectedTruck]
                                                              [index2],
                                                      onTap: () {
                                                        BlocProvider.of<
                                                                    BottomNavBarCubit>(
                                                                context)
                                                            .emitHide();
                                                        commodityWeight_controller[
                                                                        selectedTruck]
                                                                    [index2]
                                                                .selection =
                                                            TextSelection(
                                                                baseOffset: 0,
                                                                extentOffset:
                                                                    commodityWeight_controller[selectedTruck]
                                                                            [
                                                                            index2]
                                                                        .value
                                                                        .text
                                                                        .length);
                                                      },
                                                      // focusNode: _nodeWeight,
                                                      // enabled: !valueEnabled,
                                                      scrollPadding:
                                                          EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                    context)
                                                                .viewInsets
                                                                .bottom +
                                                            50,
                                                      ),
                                                      textInputAction:
                                                          TextInputAction.done,
                                                      keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                              decimal: true,
                                                              signed: true),
                                                      inputFormatters: [
                                                        DecimalFormatter(),
                                                      ],
                                                      style: const TextStyle(
                                                          fontSize: 20),
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: AppLocalizations
                                                                .of(context)!
                                                            .translate(
                                                                'commodity_weight'),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 11.0,
                                                                horizontal:
                                                                    9.0),
                                                      ),
                                                      onTapOutside: (event) {},
                                                      onEditingComplete: () {
                                                        // if (evaluateCo2()) {
                                                        //   calculateCo2Report();
                                                        // }
                                                      },
                                                      onChanged: (value) {
                                                        // if (evaluateCo2()) {
                                                        //   calculateCo2Report();
                                                        // }
                                                      },
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
                                                          return AppLocalizations
                                                                  .of(context)!
                                                              .translate(
                                                                  'insert_value_validate');
                                                        }
                                                        return null;
                                                      },
                                                      onSaved: (newValue) {
                                                        commodityWeight_controller[
                                                                    selectedTruck]
                                                                [index2]
                                                            .text = newValue!;
                                                      },
                                                      onFieldSubmitted:
                                                          (value) {
                                                        // if (evaluateCo2()) {
                                                        //   calculateCo2Report();
                                                        // }
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                        BlocProvider.of<
                                                                    BottomNavBarCubit>(
                                                                context)
                                                            .emitShow();
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            (count[selectedTruck] > 1)
                                                ? Positioned(
                                                    left: 5,
                                                    // right: localeState
                                                    //             .value
                                                    //             .languageCode ==
                                                    //         'en'
                                                    //     ? null
                                                    //     : 5,
                                                    top: 5,
                                                    child: Container(
                                                      height: 30,
                                                      width: 35,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColor.deepYellow,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topLeft:
                                                              //  localeState
                                                              //             .value
                                                              //             .languageCode ==
                                                              //         'en'
                                                              //     ?
                                                              Radius.circular(
                                                                  12)
                                                          // : const Radius
                                                          //     .circular(
                                                          //     5)
                                                          ,
                                                          topRight:
                                                              // localeState
                                                              //             .value
                                                              //             .languageCode ==
                                                              //         'en'
                                                              //     ?
                                                              Radius.circular(5)
                                                          // :
                                                          // const Radius
                                                          //     .circular(
                                                          //     15)
                                                          ,
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  5),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  5),
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          (index2 + 1)
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                            (count[selectedTruck] > 1) &&
                                                    (index2 != 0)
                                                ? Positioned(
                                                    right: 0,
                                                    // left: localeState
                                                    //             .value
                                                    //             .languageCode ==
                                                    //         'en'
                                                    //     ? null
                                                    //     : 0,
                                                    child: InkWell(
                                                      onTap: () {
                                                        removeitem(index2);
                                                        // _showAlertDialog(index);
                                                      },
                                                      child: Container(
                                                        height: 30,
                                                        width: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(45),
                                                        ),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.close,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ],
                                        );
                                      }),
                                ),
                              ),
                              Positioned(
                                bottom: -18,
                                left: 0,
                                child: InkWell(
                                  onTap: () => additem(),
                                  child: AbsorbPointer(
                                    absorbing: true,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        height: 32.h,
                                        width: 32.w,
                                        child: SvgPicture.asset(
                                            "assets/icons/add.svg"),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : BlocBuilder<ReadSubInstructionBloc,
                            ReadSubInstructionState>(
                            builder: (context, state) {
                              if (state is ReadSubInstructionLoadedSuccess) {
                                return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: instructionProvider
                                        .subShipment!
                                        .shipmentinstructionv2!
                                        .subinstrucations!
                                        .singleWhere(
                                          (element) =>
                                              element!.truck! ==
                                              widget.trucks!.id!,
                                          orElse: () => SubShipmentInstruction(
                                              id: 0, commodityItems: []),
                                        )!
                                        .commodityItems!
                                        .length,
                                    itemBuilder: (context, index2) {
                                      return Stack(
                                        children: [
                                          Card(
                                            color: Colors.white,
                                            margin: const EdgeInsets.all(5),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 7.5),
                                              child: Column(
                                                children: [
                                                  index2 == 0
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                              Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'commodity_info'),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColor
                                                                      .darkGrey,
                                                                ),
                                                              ),
                                                            ])
                                                      : const SizedBox.shrink(),
                                                  index2 != 0
                                                      ? const SizedBox(
                                                          height: 30,
                                                        )
                                                      : const SizedBox.shrink(),
                                                  const SizedBox(
                                                    height: 7,
                                                  ),
                                                  Container(
                                                    child: Text(instructionProvider
                                                        .subShipment!
                                                        .shipmentinstructionv2!
                                                        .subinstrucations!
                                                        .singleWhere(
                                                          (element) =>
                                                              element!.truck! ==
                                                              widget
                                                                  .trucks!.id!,
                                                          orElse: () =>
                                                              SubShipmentInstruction(
                                                                  id: 0,
                                                                  commodityItems: []),
                                                        )!
                                                        .commodityItems![index2]
                                                        .commodityName!),
                                                  ),
                                                  const SizedBox(
                                                    height: 12,
                                                  ),
                                                  Container(
                                                    child: Text(instructionProvider
                                                        .subShipment!
                                                        .shipmentinstructionv2!
                                                        .subinstrucations!
                                                        .singleWhere(
                                                          (element) =>
                                                              element!.truck! ==
                                                              widget
                                                                  .trucks!.id!,
                                                          orElse: () =>
                                                              SubShipmentInstruction(
                                                                  id: 0,
                                                                  commodityItems: []),
                                                        )!
                                                        .commodityItems![index2]
                                                        .commodityQuantity!
                                                        .toString()),
                                                  ),
                                                  const SizedBox(
                                                    height: 12,
                                                  ),
                                                  Container(
                                                    child: Text(instructionProvider
                                                        .subShipment!
                                                        .shipmentinstructionv2!
                                                        .subinstrucations!
                                                        .singleWhere(
                                                          (element) =>
                                                              element!.truck! ==
                                                              widget
                                                                  .trucks!.id!,
                                                          orElse: () =>
                                                              SubShipmentInstruction(
                                                                  id: 0,
                                                                  commodityItems: []),
                                                        )!
                                                        .commodityItems![index2]
                                                        .commodityWeight!
                                                        .toString()),
                                                  ),
                                                  const SizedBox(
                                                    height: 12,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          (count[selectedTruck] > 1)
                                              ? Positioned(
                                                  left: 5,
                                                  top: 5,
                                                  child: Container(
                                                    height: 30,
                                                    width: 35,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColor.deepYellow,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(12),
                                                        topRight:
                                                            Radius.circular(5),
                                                        bottomLeft:
                                                            Radius.circular(5),
                                                        bottomRight:
                                                            Radius.circular(5),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        (index2 + 1).toString(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      );
                                    });
                              } else {
                                return Center(
                                  child: LoadingIndicator(),
                                );
                              }
                            },
                          ),
                    instructionProvider.subShipment!.shipmentinstructionv2!
                                .subinstrucations!
                                .singleWhere(
                              (element) =>
                                  element!.truck! == widget.trucks!.id!,
                              orElse: () => SubShipmentInstruction(id: 0),
                            ) !=
                            SubShipmentInstruction(id: 0)
                        ? Container(
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            color: Colors.white,
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              key: _weightInfoformKey,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .43,
                                        child: TextFormField(
                                          controller: truck_weight_controller[
                                              selectedTruck],
                                          onTap: () {
                                            truck_weight_controller[
                                                        selectedTruck]
                                                    .selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        truck_weight_controller[
                                                                selectedTruck]
                                                            .value
                                                            .text
                                                            .length);
                                          },
                                          // enabled:
                                          //     widget.shipment.shipmentinstruction == null,
                                          scrollPadding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          textInputAction: TextInputAction.done,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                              decimal: true, signed: true),
                                          style: const TextStyle(fontSize: 18),
                                          decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)!
                                                    .translate('total_weight'),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 11.0,
                                                    horizontal: 9.0),
                                          ),
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          onEditingComplete: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();

                                            // evaluatePrice();
                                          },
                                          onChanged: (value) {},
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return AppLocalizations.of(
                                                      context)!
                                                  .translate(
                                                      'insert_value_validate');
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            truck_weight_controller[
                                                    selectedTruck]
                                                .text = newValue!;
                                          },
                                          onFieldSubmitted: (value) {},
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .43,
                                        child: TextFormField(
                                          controller: net_weight_controller[
                                              selectedTruck],
                                          onTap: () {
                                            net_weight_controller[selectedTruck]
                                                    .selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        net_weight_controller[
                                                                selectedTruck]
                                                            .value
                                                            .text
                                                            .length);
                                          },
                                          // enabled:
                                          //     widget.shipment.shipmentinstruction == null,
                                          scrollPadding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          textInputAction: TextInputAction.done,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                              decimal: true, signed: true),
                                          style: const TextStyle(fontSize: 18),
                                          decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)!
                                                    .translate('net_weight'),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 11.0,
                                                    horizontal: 9.0),
                                          ),
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          onEditingComplete: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();

                                            // evaluatePrice();
                                          },
                                          onChanged: (value) {},
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return AppLocalizations.of(
                                                      context)!
                                                  .translate(
                                                      'insert_value_validate');
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            net_weight_controller[selectedTruck]
                                                .text = newValue!;
                                          },
                                          onFieldSubmitted: (value) {},
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .95,
                                        child: TextFormField(
                                          controller: final_weight_controller[
                                              selectedTruck],
                                          onTap: () {
                                            final_weight_controller[
                                                        selectedTruck]
                                                    .selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        final_weight_controller[
                                                                selectedTruck]
                                                            .value
                                                            .text
                                                            .length);
                                          },
                                          // enabled:
                                          //     widget.shipment.shipmentinstruction == null,
                                          scrollPadding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          textInputAction: TextInputAction.done,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                              decimal: true, signed: true),
                                          style: const TextStyle(fontSize: 18),
                                          decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)!
                                                    .translate('final_weight'),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 11.0,
                                                    horizontal: 9.0),
                                          ),
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          onEditingComplete: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();

                                            // evaluatePrice();
                                          },
                                          onChanged: (value) {},
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return AppLocalizations.of(
                                                      context)!
                                                  .translate(
                                                      'insert_value_validate');
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            final_weight_controller[
                                                    selectedTruck]
                                                .text = newValue!;
                                          },
                                          onFieldSubmitted: (value) {},
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : BlocBuilder<ReadSubInstructionBloc,
                            ReadSubInstructionState>(
                            builder: (context, state) {
                              if (state is ReadSubInstructionLoadedSuccess) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .43,
                                            child: Container(
                                              child: Text(state
                                                  .instruction.netWeight!
                                                  .toString()),
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .43,
                                            child: Container(
                                              child: Text(state
                                                  .instruction.truckWeight!
                                                  .toString()),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Container(
                                        child: Text(state
                                            .instruction.finalWeight!
                                            .toString()),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Center(
                                  child: LoadingIndicator(),
                                );
                              }
                            },
                          ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Consumer<TaskNumProvider>(
                        builder: (context, taskProvider, child) {
                          return BlocConsumer<SubInstructionCreateBloc,
                              SubInstructionCreateState>(
                            listener: (context, state) {
                              taskProvider.decreaseTaskNum();

                              if (state is SubInstructionCreateSuccessState) {
                                instructionsProvider!
                                    .addSubInstruction(state.shipment);
                                BlocProvider.of<ReadSubInstructionBloc>(context)
                                    .add(ReadSubInstructionLoadEvent(
                                        instructionsProvider!.subShipment!.id!,
                                        state.shipment.id!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColor.deepGreen,
                                    dismissDirection: DismissDirection.up,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(context).size.height -
                                                150,
                                        left: 10,
                                        right: 10),
                                    content:
                                        localeState.value.languageCode == 'en'
                                            ? const Text(
                                                'shipment instruction has been created successfully.',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              )
                                            : const Text(
                                                'تم اضافة تعليمات الشحن بنجاح..',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                                instructionProvider
                                    .addSubInstruction(state.shipment);
                                // Navigator.pushAndRemoveUntil(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const ControlView(),
                                //   ),
                                //   (route) => false,
                                // );
                              }
                              if (state is SubInstructionCreateFailureState) {
                                print(state.errorMessage);
                              }
                            },
                            builder: (context, state) {
                              if (state
                                  is SubInstructionCreateLoadingProgressState) {
                                return CustomButton(
                                  title: const LoadingIndicator(),
                                  onTap: () {},
                                );
                              } else {
                                return CustomButton(
                                  title: Text(
                                    AppLocalizations.of(context)!
                                        .translate('add_instruction'),
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                  onTap: () {
                                    SubShipmentInstruction subinstruction =
                                        SubShipmentInstruction();
                                    subinstruction.instruction =
                                        widget.shipmentInstruction!;
                                    subinstruction.netWeight = double.parse(
                                            net_weight_controller[selectedTruck]
                                                .text)
                                        .toInt();
                                    subinstruction.truckWeight = double.parse(
                                            truck_weight_controller[
                                                    selectedTruck]
                                                .text)
                                        .toInt();
                                    subinstruction.finalWeight = double.parse(
                                            final_weight_controller[
                                                    selectedTruck]
                                                .text)
                                        .toInt();
                                    subinstruction.truck = widget.trucks!.id!;

                                    List<CommodityItems> items = [];
                                    print(commodityWeight_controller!.length);
                                    for (var i = 0;
                                        i <
                                            commodityWeight_controller![
                                                    selectedTruck]
                                                .length;
                                        i++) {
                                      CommodityItems item = CommodityItems(
                                          commodityName:
                                              commodityName_controller[
                                                      selectedTruck][i]
                                                  .text,
                                          commodityQuantity: int.parse(
                                              commodityQuantity_controller[
                                                      selectedTruck][i]
                                                  .text),
                                          commodityWeight: double.parse(
                                            commodityWeight_controller[
                                                    selectedTruck][i]
                                                .text
                                                .replaceAll(",", ""),
                                          ).toInt(),
                                          packageType: packageType_controller[
                                                  selectedTruck][i]!
                                              .id!);
                                      items.add(item);
                                    }

                                    subinstruction.commodityItems = items;

                                    BlocProvider.of<SubInstructionCreateBloc>(
                                            context)
                                        .add(
                                      SubInstructionCreateButtonPressed(
                                        subinstruction,
                                        widget.shipmentInstruction!,
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
