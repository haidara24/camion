// // ignore_for_file: non_constant_identifier_names

// import 'package:camion/Localization/app_localizations.dart';
// import 'package:camion/business_logic/bloc/instructions/instruction_create_bloc.dart';
// import 'package:camion/business_logic/bloc/instructions/read_instruction_bloc.dart';
// import 'package:camion/business_logic/bloc/package_type_bloc.dart';
// import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
// import 'package:camion/business_logic/cubit/locale_cubit.dart';
// import 'package:camion/data/models/instruction_model.dart';
// import 'package:camion/data/models/shipmentv2_model.dart';
// import 'package:camion/data/providers/task_num_provider.dart';
// import 'package:camion/helpers/color_constants.dart';
// import 'package:camion/helpers/formatter.dart';
// import 'package:camion/views/widgets/custom_botton.dart';
// import 'package:camion/views/widgets/loading_indicator.dart';
// import 'package:camion/views/widgets/section_title_widget.dart';
// import 'package:camion/views/widgets/shipment_path_widget.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:ensure_visible_when_focused/ensure_visible_when_focused.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';

// class ShipmentInstructionScreen extends StatefulWidget {
//   final SubShipment shipment;
//   final int subshipmentIndex;
//   final bool hasinstruction;
//   ShipmentInstructionScreen({
//     Key? key,
//     required this.shipment,
//     required this.subshipmentIndex,
//     required this.hasinstruction,
//   }) : super(key: key);

//   @override
//   State<ShipmentInstructionScreen> createState() =>
//       _ShipmentInstructionScreenState();
// }

// class _ShipmentInstructionScreenState extends State<ShipmentInstructionScreen> {
//   final FocusNode _orderTypenode = FocusNode();
//   var key1 = GlobalKey();
//   String selectedRadioTile = "M";
//   final GlobalKey<FormState> _shipperDetailsformKey = GlobalKey<FormState>();
//   bool hasinstruction = false;

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

//   TextEditingController charger_name_controller = TextEditingController();
//   TextEditingController charger_address_controller = TextEditingController();
//   TextEditingController charger_phone_controller = TextEditingController();

//   TextEditingController reciever_name_controller = TextEditingController();
//   TextEditingController reciever_address_controller = TextEditingController();
//   TextEditingController reciever_phone_controller = TextEditingController();

//   List<int> count = [];

//   TextEditingController total_weight_controller = TextEditingController();
//   TextEditingController net_weight_controller = TextEditingController();
//   TextEditingController truck_weight_controller = TextEditingController();
//   TextEditingController final_weight_controller = TextEditingController();

//   List<TextEditingController> commodityName_controller = [];
//   List<TextEditingController> commodityWeight_controller = [];
//   List<TextEditingController> commodityQuantity_controller = [];
//   List<TextEditingController> readpackageType_controller = [];
//   List<PackageType?> packageType_controller = [null];
//   final GlobalKey<FormState> _commodityInfoformKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> _weightInfoformKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();

//     if (widget.shipment.shipmentinstructionv2 != null) {
//       setState(() {
//         selectedRadioTile = "K";
//         hasinstruction = true;
//       });
//     } else {
//       for (var i = 0; i < widget.shipment.shipmentItems!.length; i++) {
//         commodityName_controller.add(TextEditingController());
//         commodityQuantity_controller.add(TextEditingController());
//         commodityWeight_controller.add(TextEditingController());
//         packageType_controller.add(null);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LocaleCubit, LocaleState>(
//       builder: (context, localeState) {
//         return Column(
//           children: [
//             Container(
//               color: Colors.white,
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Text(
//                         AppLocalizations.of(context)!
//                             .translate('shipment_path_info'),
//                         style: TextStyle(
//                           fontSize: 17,
//                           fontWeight: FontWeight.bold,
//                           color: AppColor.darkGrey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   ShipmentPathWidget(
//                     loadDate: setLoadDate(widget.shipment.pickupDate!),
//                     pickupName: widget.shipment.pathpoints!
//                         .singleWhere((element) => element.pointType == "P")
//                         .name!,
//                     deliveryName: widget.shipment.pathpoints!
//                         .singleWhere((element) => element.pointType == "D")
//                         .name!,
//                     width: MediaQuery.of(context).size.width * .8,
//                     pathwidth: MediaQuery.of(context).size.width * .7,
//                   ).animate().slideX(
//                       duration: 300.ms,
//                       delay: 0.ms,
//                       begin: 1,
//                       end: 0,
//                       curve: Curves.easeInOutSine),
//                 ],
//               ),
//             ),
//             Visibility(
//               visible: !hasinstruction,
//               child: EnsureVisibleWhenFocused(
//                 focusNode: _orderTypenode,
//                 child: Container(
//                   key: key1,
//                   margin: const EdgeInsets.symmetric(vertical: 7),
//                   color: Colors.white,
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Text(
//                               AppLocalizations.of(context)!
//                                   .translate('select_your_identity'),
//                               style: TextStyle(
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColor.darkGrey,
//                               )),
//                         ],
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * .3,
//                             child: RadioListTile(
//                               contentPadding: EdgeInsets.zero,
//                               value: "C",
//                               groupValue: selectedRadioTile,
//                               title: FittedBox(
//                                 fit: BoxFit.scaleDown,
//                                 child: Text(
//                                   AppLocalizations.of(context)!
//                                       .translate('charger'),
//                                   overflow: TextOverflow.fade,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ),
//                               // subtitle: Text("Radio 1 Subtitle"),
//                               onChanged: (val) {
//                                 // print("Radio Tile pressed $val");
//                                 setState(() {
//                                   selectedRadioTile = val!;
//                                 });
//                               },
//                               activeColor: AppColor.deepYellow,
//                               selected: selectedRadioTile == "C",
//                             ),
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * .3,
//                             child: RadioListTile(
//                               contentPadding: EdgeInsets.zero,
//                               value: "M",
//                               groupValue: selectedRadioTile,
//                               title: FittedBox(
//                                 fit: BoxFit.scaleDown,
//                                 child: Text(
//                                   AppLocalizations.of(context)!
//                                       .translate('mediator'),
//                                   overflow: TextOverflow.fade,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ),
//                               // subtitle: Text("Radio 1 Subtitle"),
//                               onChanged: (val) {
//                                 // print("Radio Tile pressed $val");
//                                 setState(() {
//                                   selectedRadioTile = val!;
//                                 });
//                               },
//                               activeColor: AppColor.deepYellow,
//                               selected: selectedRadioTile == "M",
//                             ),
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * .3,
//                             child: RadioListTile(
//                               contentPadding: EdgeInsets.zero,

//                               value: "R",
//                               groupValue: selectedRadioTile,
//                               title: FittedBox(
//                                 fit: BoxFit.scaleDown,
//                                 child: Text(
//                                   AppLocalizations.of(context)!
//                                       .translate('reciever'),
//                                   overflow: TextOverflow.fade,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ),
//                               // subtitle: Text("Radio 2 Subtitle"),
//                               onChanged: (val) {
//                                 // print("Radio Tile pressed $val");
//                                 setState(() {
//                                   selectedRadioTile = val!;
//                                 });
//                               },
//                               activeColor: AppColor.deepYellow,

//                               selected: selectedRadioTile == "R",
//                             ),
//                           ),
//                         ],
//                       ),
//                       // Visibility(
//                       //   visible: showtypeError,
//                       //   child: Text(
//                       //     AppLocalizations.of(context)!
//                       //         .translate('select_operation_type_error'),
//                       //     style: const TextStyle(color: Colors.red),
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             !hasinstruction
//                 ? Container(
//                     margin: const EdgeInsets.symmetric(vertical: 7),
//                     color: Colors.white,
//                     padding: const EdgeInsets.all(8.0),
//                     child: Form(
//                       key: _shipperDetailsformKey,
//                       child: Column(
//                         children: [
//                           Visibility(
//                             visible: (selectedRadioTile.isEmpty ||
//                                 selectedRadioTile == "M" ||
//                                 selectedRadioTile == "R"),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                         AppLocalizations.of(context)!
//                                             .translate('charger_info'),
//                                         style: TextStyle(
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.bold,
//                                           color: AppColor.darkGrey,
//                                         )),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 TextFormField(
//                                   controller: charger_name_controller,
//                                   onTap: () {
//                                     charger_name_controller.selection =
//                                         TextSelection(
//                                             baseOffset: 0,
//                                             extentOffset:
//                                                 charger_name_controller
//                                                     .value.text.length);
//                                   },
//                                   scrollPadding: EdgeInsets.only(
//                                       bottom: MediaQuery.of(context)
//                                           .viewInsets
//                                           .bottom),
//                                   // enabled: instructionProvider.subShipment!
//                                   //         .shipmentinstructionv2 ==
//                                   //     null,
//                                   textInputAction: TextInputAction.done,
//                                   style: const TextStyle(fontSize: 18),
//                                   decoration: InputDecoration(
//                                     labelText: AppLocalizations.of(context)!
//                                         .translate('charger_name'),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         vertical: 11.0, horizontal: 9.0),
//                                   ),
//                                   onTapOutside: (event) {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                   },
//                                   onEditingComplete: () {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();

//                                     // evaluatePrice();
//                                   },
//                                   onChanged: (value) {},
//                                   autovalidateMode:
//                                       AutovalidateMode.onUserInteraction,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return AppLocalizations.of(context)!
//                                           .translate('insert_value_validate');
//                                     }
//                                     return null;
//                                   },
//                                   onSaved: (newValue) {
//                                     charger_name_controller.text = newValue!;
//                                   },
//                                   onFieldSubmitted: (value) {},
//                                 ),
//                                 const SizedBox(
//                                   height: 12,
//                                 ),
//                                 TextFormField(
//                                   controller: charger_address_controller,
//                                   onTap: () {
//                                     charger_address_controller.selection =
//                                         TextSelection(
//                                             baseOffset: 0,
//                                             extentOffset:
//                                                 charger_address_controller
//                                                     .value.text.length);
//                                   },
//                                   // enabled: instructionProvider.subShipment!
//                                   //         .shipmentinstructionv2 ==
//                                   //     null,
//                                   scrollPadding: EdgeInsets.only(
//                                       bottom: MediaQuery.of(context)
//                                           .viewInsets
//                                           .bottom),
//                                   textInputAction: TextInputAction.done,
//                                   style: const TextStyle(fontSize: 18),
//                                   decoration: InputDecoration(
//                                     labelText: AppLocalizations.of(context)!
//                                         .translate('charger_address'),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         vertical: 11.0, horizontal: 9.0),
//                                   ),
//                                   onTapOutside: (event) {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                     // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
//                                   },
//                                   onEditingComplete: () {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();

//                                     // evaluatePrice();
//                                   },
//                                   onChanged: (value) {},
//                                   autovalidateMode:
//                                       AutovalidateMode.onUserInteraction,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return AppLocalizations.of(context)!
//                                           .translate('insert_value_validate');
//                                     }
//                                     return null;
//                                   },
//                                   onSaved: (newValue) {
//                                     // commodityWeight_controller.text = newValue!;
//                                   },
//                                   onFieldSubmitted: (value) {
//                                     // FocusManager.instance.primaryFocus?.unfocus();
//                                     // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
//                                   },
//                                 ),
//                                 const SizedBox(
//                                   height: 12,
//                                 ),
//                                 TextFormField(
//                                   controller: charger_phone_controller,
//                                   onTap: () {
//                                     charger_phone_controller.selection =
//                                         TextSelection(
//                                             baseOffset: 0,
//                                             extentOffset:
//                                                 charger_phone_controller
//                                                     .value.text.length);
//                                   },
//                                   // enabled: instructionProvider.subShipment!
//                                   //         .shipmentinstructionv2 ==
//                                   //     null,
//                                   scrollPadding: EdgeInsets.only(
//                                       bottom: MediaQuery.of(context)
//                                           .viewInsets
//                                           .bottom),
//                                   textInputAction: TextInputAction.done,
//                                   keyboardType: TextInputType.phone,
//                                   style: const TextStyle(fontSize: 18),
//                                   decoration: InputDecoration(
//                                     labelText: AppLocalizations.of(context)!
//                                         .translate('charger_phone'),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         vertical: 11.0, horizontal: 9.0),
//                                   ),
//                                   onTapOutside: (event) {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                     // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
//                                   },
//                                   onEditingComplete: () {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();

//                                     // evaluatePrice();
//                                   },
//                                   onChanged: (value) {},
//                                   autovalidateMode:
//                                       AutovalidateMode.onUserInteraction,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return AppLocalizations.of(context)!
//                                           .translate('insert_value_validate');
//                                     }
//                                     return null;
//                                   },
//                                   onSaved: (newValue) {
//                                     // commodityWeight_controller.text = newValue!;
//                                   },
//                                   onFieldSubmitted: (value) {
//                                     // FocusManager.instance.primaryFocus?.unfocus();
//                                     // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
//                                   },
//                                 ),
//                                 const SizedBox(
//                                   height: 8,
//                                 ),
//                                 const Divider(),
//                               ],
//                             ),
//                           ),
//                           Visibility(
//                             visible: (selectedRadioTile.isEmpty ||
//                                 selectedRadioTile == "M" ||
//                                 selectedRadioTile == "C"),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                         AppLocalizations.of(context)!
//                                             .translate('reciever_info'),
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: AppColor.darkGrey,
//                                         )),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 TextFormField(
//                                   controller: reciever_name_controller,
//                                   onTap: () {
//                                     reciever_name_controller.selection =
//                                         TextSelection(
//                                             baseOffset: 0,
//                                             extentOffset:
//                                                 reciever_name_controller
//                                                     .value.text.length);
//                                   },
//                                   // enabled: instructionProvider.subShipment!
//                                   //         .shipmentinstructionv2 ==
//                                   //     null,
//                                   scrollPadding: EdgeInsets.only(
//                                       bottom: MediaQuery.of(context)
//                                           .viewInsets
//                                           .bottom),
//                                   textInputAction: TextInputAction.done,
//                                   style: const TextStyle(fontSize: 18),
//                                   decoration: InputDecoration(
//                                     labelText: AppLocalizations.of(context)!
//                                         .translate('reciever_name'),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         vertical: 11.0, horizontal: 9.0),
//                                   ),
//                                   onTapOutside: (event) {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                   },
//                                   onEditingComplete: () {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();

//                                     // evaluatePrice();
//                                   },
//                                   onChanged: (value) {},
//                                   autovalidateMode:
//                                       AutovalidateMode.onUserInteraction,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return AppLocalizations.of(context)!
//                                           .translate('insert_value_validate');
//                                     }
//                                     return null;
//                                   },
//                                   onSaved: (newValue) {
//                                     reciever_name_controller.text = newValue!;
//                                   },
//                                   // onFieldSubmitted: (value) {},
//                                 ),
//                                 const SizedBox(
//                                   height: 12,
//                                 ),
//                                 TextFormField(
//                                   controller: reciever_address_controller,
//                                   onTap: () {
//                                     reciever_address_controller.selection =
//                                         TextSelection(
//                                             baseOffset: 0,
//                                             extentOffset:
//                                                 reciever_address_controller
//                                                     .value.text.length);
//                                   },
//                                   // enabled: instructionProvider.subShipment!
//                                   //         .shipmentinstructionv2 ==
//                                   //     null,
//                                   scrollPadding: EdgeInsets.only(
//                                       bottom: MediaQuery.of(context)
//                                           .viewInsets
//                                           .bottom),
//                                   textInputAction: TextInputAction.done,
//                                   style: const TextStyle(fontSize: 18),
//                                   decoration: InputDecoration(
//                                     labelText: AppLocalizations.of(context)!
//                                         .translate('reciever_address'),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         vertical: 11.0, horizontal: 9.0),
//                                   ),
//                                   onTapOutside: (event) {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                     // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
//                                   },
//                                   onEditingComplete: () {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();

//                                     // evaluatePrice();
//                                   },
//                                   onChanged: (value) {},
//                                   autovalidateMode:
//                                       AutovalidateMode.onUserInteraction,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return AppLocalizations.of(context)!
//                                           .translate('insert_value_validate');
//                                     }
//                                     return null;
//                                   },
//                                   onSaved: (newValue) {
//                                     reciever_address_controller.text =
//                                         newValue!;
//                                   },
//                                   // onFieldSubmitted: (value) {
//                                   //   // FocusManager.instance.primaryFocus?.unfocus();
//                                   //   // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
//                                   // },
//                                 ),
//                                 const SizedBox(
//                                   height: 12,
//                                 ),
//                                 TextFormField(
//                                   controller: reciever_phone_controller,
//                                   onTap: () {
//                                     reciever_phone_controller.selection =
//                                         TextSelection(
//                                             baseOffset: 0,
//                                             extentOffset:
//                                                 reciever_phone_controller
//                                                     .value.text.length);
//                                   },
//                                   // enabled: instructionProvider.subShipment!
//                                   //         .shipmentinstructionv2 ==
//                                   //     null,
//                                   scrollPadding: EdgeInsets.only(
//                                       bottom: MediaQuery.of(context)
//                                           .viewInsets
//                                           .bottom),
//                                   textInputAction: TextInputAction.done,
//                                   keyboardType: TextInputType.phone,
//                                   style: const TextStyle(fontSize: 18),
//                                   decoration: InputDecoration(
//                                     labelText: AppLocalizations.of(context)!
//                                         .translate('reciever_phone'),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         vertical: 11.0, horizontal: 9.0),
//                                   ),
//                                   onTapOutside: (event) {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                     // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
//                                   },
//                                   onEditingComplete: () {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();

//                                     // evaluatePrice();
//                                   },
//                                   onChanged: (value) {},
//                                   autovalidateMode:
//                                       AutovalidateMode.onUserInteraction,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return AppLocalizations.of(context)!
//                                           .translate('insert_value_validate');
//                                     }
//                                     return null;
//                                   },
//                                   onSaved: (newValue) {
//                                     reciever_phone_controller.text = newValue!;
//                                   },
//                                   // onFieldSubmitted: (value) {
//                                   //   // FocusManager.instance.primaryFocus?.unfocus();
//                                   //   // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
//                                   // },
//                                 ),
//                                 const SizedBox(
//                                   height: 12,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 : BlocBuilder<ReadInstructionBloc, ReadInstructionState>(
//                     builder: (context, state) {
//                       if (state is ReadInstructionLoadedSuccess) {
//                         return Container(
//                           margin: const EdgeInsets.symmetric(vertical: 7),
//                           color: Colors.white,
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             children: [
//                               Visibility(
//                                 visible:
//                                     state.instruction.chargerName!.isNotEmpty,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         SectionTitle(
//                                           text: AppLocalizations.of(context)!
//                                               .translate('charger_info'),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(
//                                       height: 10,
//                                     ),
//                                     Container(
//                                       child:
//                                           Text(state.instruction.chargerName!),
//                                     ),
//                                     const SizedBox(
//                                       height: 12,
//                                     ),
//                                     Container(
//                                       child: Text(
//                                           state.instruction.chargerAddress!),
//                                     ),
//                                     const SizedBox(
//                                       height: 12,
//                                     ),
//                                     Container(
//                                       child:
//                                           Text(state.instruction.chargerPhone!),
//                                     ),
//                                     const SizedBox(
//                                       height: 12,
//                                     ),
//                                     const SizedBox(
//                                       height: 8,
//                                     ),
//                                     const Divider(),
//                                   ],
//                                 ),
//                               ),
//                               Visibility(
//                                 visible:
//                                     state.instruction.recieverName!.isNotEmpty,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         SectionTitle(
//                                           text: AppLocalizations.of(context)!
//                                               .translate('reciever_info'),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(
//                                       height: 10,
//                                     ),
//                                     Container(
//                                       child: Text(
//                                           '${AppLocalizations.of(context)!.translate('charger_name')}: ${state.instruction.recieverName!}'),
//                                     ),
//                                     const SizedBox(
//                                       height: 8,
//                                     ),
//                                     Container(
//                                       child: Text(
//                                           '${AppLocalizations.of(context)!.translate('charger_address')}: ${state.instruction.recieverAddress!}'),
//                                     ),
//                                     const SizedBox(
//                                       height: 8,
//                                     ),
//                                     Container(
//                                       child: Text(
//                                           '${AppLocalizations.of(context)!.translate('charger_phone')}: ${state.instruction.recieverPhone!}'),
//                                     ),
//                                     const SizedBox(
//                                       height: 8,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       } else {
//                         return Center(child: LoadingIndicator());
//                       }
//                     },
//                   ),
//             !hasinstruction
//                 ? SizedBox(
//                     // key: key1,
//                     child: Form(
//                       key: _commodityInfoformKey,
//                       child: ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: widget.shipment.shipmentItems!.length,
//                           itemBuilder: (context, index2) {
//                             return Stack(
//                               children: [
//                                 Card(
//                                   color: Colors.white,
//                                   margin: const EdgeInsets.all(5),
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 10.0, vertical: 7.5),
//                                     child: Column(
//                                       children: [
//                                         index2 == 0
//                                             ? Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.start,
//                                                 children: [
//                                                     Text(
//                                                       AppLocalizations.of(
//                                                               context)!
//                                                           .translate(
//                                                               'commodity_info'),
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: TextStyle(
//                                                         fontSize: 17,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color:
//                                                             AppColor.darkGrey,
//                                                       ),
//                                                     ),
//                                                   ])
//                                             : const SizedBox.shrink(),
//                                         index2 != 0
//                                             ? const SizedBox(
//                                                 height: 30,
//                                               )
//                                             : const SizedBox.shrink(),
//                                         const SizedBox(
//                                           height: 7,
//                                         ),
//                                         BlocBuilder<PackageTypeBloc,
//                                             PackageTypeState>(
//                                           builder: (context, state2) {
//                                             if (state2
//                                                 is PackageTypeLoadedSuccess) {
//                                               return DropdownButtonHideUnderline(
//                                                 child: DropdownButton2<
//                                                     PackageType>(
//                                                   isExpanded: true,
//                                                   hint: Text(
//                                                     AppLocalizations.of(
//                                                             context)!
//                                                         .translate(
//                                                             'package_type'),
//                                                     style: TextStyle(
//                                                       fontSize: 18,
//                                                       color: Theme.of(context)
//                                                           .hintColor,
//                                                     ),
//                                                   ),
//                                                   items: state2.packageTypes
//                                                       .map((PackageType item) =>
//                                                           DropdownMenuItem<
//                                                               PackageType>(
//                                                             value: item,
//                                                             child: SizedBox(
//                                                               width: 200,
//                                                               child: Text(
//                                                                 item.name!,
//                                                                 style:
//                                                                     const TextStyle(
//                                                                   fontSize: 17,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ))
//                                                       .toList(),
//                                                   value: packageType_controller[
//                                                       index2],
//                                                   onChanged:
//                                                       (PackageType? value) {
//                                                     setState(() {
//                                                       packageType_controller[
//                                                           index2] = value!;
//                                                     });
//                                                   },
//                                                   buttonStyleData:
//                                                       ButtonStyleData(
//                                                     height: 50,
//                                                     width: double.infinity,
//                                                     padding: const EdgeInsets
//                                                         .symmetric(
//                                                       horizontal: 9.0,
//                                                     ),
//                                                     decoration: BoxDecoration(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               12),
//                                                       border: Border.all(
//                                                         color: Colors.black26,
//                                                       ),
//                                                       color: Colors.white,
//                                                     ),
//                                                     // elevation: 2,
//                                                   ),
//                                                   iconStyleData: IconStyleData(
//                                                     icon: const Icon(
//                                                       Icons
//                                                           .keyboard_arrow_down_sharp,
//                                                     ),
//                                                     iconSize: 20,
//                                                     iconEnabledColor:
//                                                         AppColor.deepYellow,
//                                                     iconDisabledColor:
//                                                         Colors.grey,
//                                                   ),
//                                                   dropdownStyleData:
//                                                       DropdownStyleData(
//                                                     decoration: BoxDecoration(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               14),
//                                                       color: Colors.white,
//                                                     ),
//                                                     scrollbarTheme:
//                                                         ScrollbarThemeData(
//                                                       radius:
//                                                           const Radius.circular(
//                                                               40),
//                                                       thickness:
//                                                           MaterialStateProperty
//                                                               .all(6),
//                                                       thumbVisibility:
//                                                           MaterialStateProperty
//                                                               .all(true),
//                                                     ),
//                                                   ),
//                                                   menuItemStyleData:
//                                                       const MenuItemStyleData(
//                                                     height: 40,
//                                                   ),
//                                                 ),
//                                               );
//                                             } else if (state2
//                                                 is PackageTypeLoadingProgress) {
//                                               return const Center(
//                                                 child:
//                                                     LinearProgressIndicator(),
//                                               );
//                                             } else if (state2
//                                                 is PackageTypeLoadedFailed) {
//                                               return Center(
//                                                 child: InkWell(
//                                                   onTap: () {
//                                                     BlocProvider.of<
//                                                                 PackageTypeBloc>(
//                                                             context)
//                                                         .add(
//                                                             PackageTypeLoadEvent());
//                                                   },
//                                                   child: Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .center,
//                                                     children: [
//                                                       Text(
//                                                         AppLocalizations.of(
//                                                                 context)!
//                                                             .translate(
//                                                                 'list_error'),
//                                                         style: const TextStyle(
//                                                             color: Colors.red),
//                                                       ),
//                                                       const Icon(
//                                                         Icons.refresh,
//                                                         color: Colors.grey,
//                                                       )
//                                                     ],
//                                                   ),
//                                                 ),
//                                               );
//                                             } else {
//                                               return Container();
//                                             }
//                                           },
//                                         ),
//                                         const SizedBox(
//                                           height: 12,
//                                         ),
//                                         TextFormField(
//                                           controller:
//                                               commodityName_controller[index2],
//                                           onTap: () {
//                                             BlocProvider.of<BottomNavBarCubit>(
//                                                     context)
//                                                 .emitHide();
//                                             commodityName_controller[index2]
//                                                     .selection =
//                                                 TextSelection(
//                                                     baseOffset: 0,
//                                                     extentOffset:
//                                                         commodityName_controller[
//                                                                 index2]
//                                                             .value
//                                                             .text
//                                                             .length);
//                                           },
//                                           // focusNode: _nodeWeight,
//                                           // enabled: !valueEnabled,
//                                           scrollPadding: EdgeInsets.only(
//                                             bottom: MediaQuery.of(context)
//                                                     .viewInsets
//                                                     .bottom +
//                                                 50,
//                                           ),
//                                           textInputAction: TextInputAction.done,

//                                           style: const TextStyle(fontSize: 20),
//                                           decoration: InputDecoration(
//                                             labelText: AppLocalizations.of(
//                                                     context)!
//                                                 .translate('commodity_name'),
//                                             contentPadding:
//                                                 const EdgeInsets.symmetric(
//                                                     vertical: 11.0,
//                                                     horizontal: 9.0),
//                                           ),
//                                           onTapOutside: (event) {},
//                                           onEditingComplete: () {
//                                             // if (evaluateCo2()) {
//                                             //   calculateCo2Report();
//                                             // }
//                                           },
//                                           onChanged: (value) {
//                                             // if (evaluateCo2()) {
//                                             //   calculateCo2Report();
//                                             // }
//                                           },
//                                           autovalidateMode: AutovalidateMode
//                                               .onUserInteraction,
//                                           validator: (value) {
//                                             if (value!.isEmpty) {
//                                               return AppLocalizations.of(
//                                                       context)!
//                                                   .translate(
//                                                       'insert_value_validate');
//                                             }
//                                             return null;
//                                           },
//                                           onSaved: (newValue) {
//                                             commodityName_controller[index2]
//                                                 .text = newValue!;
//                                           },
//                                           onFieldSubmitted: (value) {
//                                             // if (evaluateCo2()) {
//                                             //   calculateCo2Report();
//                                             // }
//                                             FocusManager.instance.primaryFocus
//                                                 ?.unfocus();
//                                             BlocProvider.of<BottomNavBarCubit>(
//                                                     context)
//                                                 .emitShow();
//                                           },
//                                         ),
//                                         const SizedBox(
//                                           height: 12,
//                                         ),
//                                         const SizedBox(
//                                           height: 12,
//                                         ),
//                                         TextFormField(
//                                           controller:
//                                               commodityQuantity_controller[
//                                                   index2],
//                                           onTap: () {
//                                             BlocProvider.of<BottomNavBarCubit>(
//                                                     context)
//                                                 .emitHide();
//                                             commodityQuantity_controller[index2]
//                                                     .selection =
//                                                 TextSelection(
//                                                     baseOffset: 0,
//                                                     extentOffset:
//                                                         commodityQuantity_controller[
//                                                                 index2]
//                                                             .value
//                                                             .text
//                                                             .length);
//                                           },
//                                           // focusNode: _nodeWeight,
//                                           // enabled: !valueEnabled,
//                                           scrollPadding: EdgeInsets.only(
//                                             bottom: MediaQuery.of(context)
//                                                     .viewInsets
//                                                     .bottom +
//                                                 50,
//                                           ),
//                                           textInputAction: TextInputAction.done,
//                                           keyboardType: const TextInputType
//                                               .numberWithOptions(
//                                               decimal: true, signed: true),
//                                           inputFormatters: [
//                                             DecimalFormatter(),
//                                           ],
//                                           style: const TextStyle(fontSize: 20),
//                                           decoration: InputDecoration(
//                                             labelText:
//                                                 AppLocalizations.of(context)!
//                                                     .translate(
//                                                         'commodity_quantity'),
//                                             contentPadding:
//                                                 const EdgeInsets.symmetric(
//                                                     vertical: 11.0,
//                                                     horizontal: 9.0),
//                                           ),
//                                           onTapOutside: (event) {},
//                                           onEditingComplete: () {
//                                             // if (evaluateCo2()) {
//                                             //   calculateCo2Report();
//                                             // }
//                                           },
//                                           onChanged: (value) {
//                                             // if (evaluateCo2()) {
//                                             //   calculateCo2Report();
//                                             // }
//                                           },
//                                           autovalidateMode: AutovalidateMode
//                                               .onUserInteraction,
//                                           validator: (value) {
//                                             if (value!.isEmpty) {
//                                               return AppLocalizations.of(
//                                                       context)!
//                                                   .translate(
//                                                       'insert_value_validate');
//                                             }
//                                             return null;
//                                           },
//                                           onSaved: (newValue) {
//                                             commodityQuantity_controller[index2]
//                                                 .text = newValue!;
//                                           },
//                                           onFieldSubmitted: (value) {
//                                             // if (evaluateCo2()) {
//                                             //   calculateCo2Report();
//                                             // }
//                                             FocusManager.instance.primaryFocus
//                                                 ?.unfocus();
//                                             BlocProvider.of<BottomNavBarCubit>(
//                                                     context)
//                                                 .emitShow();
//                                           },
//                                         ),
//                                         const SizedBox(
//                                           height: 12,
//                                         ),
//                                         TextFormField(
//                                           controller:
//                                               commodityWeight_controller[
//                                                   index2],
//                                           onTap: () {
//                                             BlocProvider.of<BottomNavBarCubit>(
//                                                     context)
//                                                 .emitHide();
//                                             commodityWeight_controller[index2]
//                                                     .selection =
//                                                 TextSelection(
//                                                     baseOffset: 0,
//                                                     extentOffset:
//                                                         commodityWeight_controller[
//                                                                 index2]
//                                                             .value
//                                                             .text
//                                                             .length);
//                                           },
//                                           // focusNode: _nodeWeight,
//                                           // enabled: !valueEnabled,
//                                           scrollPadding: EdgeInsets.only(
//                                             bottom: MediaQuery.of(context)
//                                                     .viewInsets
//                                                     .bottom +
//                                                 50,
//                                           ),
//                                           textInputAction: TextInputAction.done,
//                                           keyboardType: const TextInputType
//                                               .numberWithOptions(
//                                               decimal: true, signed: true),
//                                           inputFormatters: [
//                                             DecimalFormatter(),
//                                           ],
//                                           style: const TextStyle(fontSize: 20),
//                                           decoration: InputDecoration(
//                                             labelText: AppLocalizations.of(
//                                                     context)!
//                                                 .translate('commodity_weight'),
//                                             contentPadding:
//                                                 const EdgeInsets.symmetric(
//                                                     vertical: 11.0,
//                                                     horizontal: 9.0),
//                                           ),
//                                           onTapOutside: (event) {},
//                                           onEditingComplete: () {
//                                             // if (evaluateCo2()) {
//                                             //   calculateCo2Report();
//                                             // }
//                                           },
//                                           onChanged: (value) {
//                                             // if (evaluateCo2()) {
//                                             //   calculateCo2Report();
//                                             // }
//                                           },
//                                           autovalidateMode: AutovalidateMode
//                                               .onUserInteraction,
//                                           validator: (value) {
//                                             if (value!.isEmpty) {
//                                               return AppLocalizations.of(
//                                                       context)!
//                                                   .translate(
//                                                       'insert_value_validate');
//                                             }
//                                             return null;
//                                           },
//                                           onSaved: (newValue) {
//                                             commodityWeight_controller[index2]
//                                                 .text = newValue!;
//                                           },
//                                           onFieldSubmitted: (value) {
//                                             // if (evaluateCo2()) {
//                                             //   calculateCo2Report();
//                                             // }
//                                             FocusManager.instance.primaryFocus
//                                                 ?.unfocus();
//                                             BlocProvider.of<BottomNavBarCubit>(
//                                                     context)
//                                                 .emitShow();
//                                           },
//                                         ),
//                                         const SizedBox(
//                                           height: 12,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 (widget.shipment.shipmentItems!.length > 1)
//                                     ? Positioned(
//                                         left: 5,
//                                         // right: localeState
//                                         //             .value
//                                         //             .languageCode ==
//                                         //         'en'
//                                         //     ? null
//                                         //     : 5,
//                                         top: 5,
//                                         child: Container(
//                                           height: 30,
//                                           width: 35,
//                                           decoration: BoxDecoration(
//                                             color: AppColor.deepYellow,
//                                             borderRadius:
//                                                 const BorderRadius.only(
//                                               topLeft:
//                                                   //  localeState
//                                                   //             .value
//                                                   //             .languageCode ==
//                                                   //         'en'
//                                                   //     ?
//                                                   Radius.circular(12)
//                                               // : const Radius
//                                               //     .circular(
//                                               //     5)
//                                               ,
//                                               topRight:
//                                                   // localeState
//                                                   //             .value
//                                                   //             .languageCode ==
//                                                   //         'en'
//                                                   //     ?
//                                                   Radius.circular(5)
//                                               // :
//                                               // const Radius
//                                               //     .circular(
//                                               //     15)
//                                               ,
//                                               bottomLeft: Radius.circular(5),
//                                               bottomRight: Radius.circular(5),
//                                             ),
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               (index2 + 1).toString(),
//                                               style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                     : const SizedBox.shrink(),
//                               ],
//                             );
//                           }),
//                     ),
//                   )
//                 : BlocBuilder<ReadInstructionBloc, ReadInstructionState>(
//                     builder: (context, state) {
//                       if (state is ReadInstructionLoadedSuccess) {
//                         return Container(
//                           margin: const EdgeInsets.symmetric(vertical: 7),
//                           color: Colors.white,
//                           padding: const EdgeInsets.all(8.0),
//                           child: ListView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemCount: widget.shipment.shipmentItems!.length,
//                               itemBuilder: (context, index2) {
//                                 return Stack(
//                                   children: [
//                                     Card(
//                                       color: Colors.white,
//                                       margin: const EdgeInsets.all(5),
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 10.0, vertical: 7.5),
//                                         child: Column(
//                                           children: [
//                                             index2 == 0
//                                                 ? Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.start,
//                                                     children: [
//                                                         SectionTitle(
//                                                           text: AppLocalizations
//                                                                   .of(context)!
//                                                               .translate(
//                                                                   'commodity_info'),
//                                                         ),
//                                                       ])
//                                                 : const SizedBox.shrink(),
//                                             index2 != 0
//                                                 ? const SizedBox(
//                                                     height: 30,
//                                                   )
//                                                 : const SizedBox.shrink(),
//                                             const SizedBox(
//                                               height: 7,
//                                             ),
//                                             Container(
//                                               child: Text(state
//                                                   .instruction
//                                                   .commodityItems![index2]
//                                                   .commodityName!),
//                                             ),
//                                             const SizedBox(
//                                               height: 12,
//                                             ),
//                                             Container(
//                                               child: Text(state
//                                                   .instruction
//                                                   .commodityItems![index2]
//                                                   .commodityQuantity!
//                                                   .toString()),
//                                             ),
//                                             const SizedBox(
//                                               height: 12,
//                                             ),
//                                             Container(
//                                               child: Text(widget
//                                                   .shipment
//                                                   .shipmentItems![index2]
//                                                   .commodityWeight!
//                                                   .toString()),
//                                             ),
//                                             const SizedBox(
//                                               height: 12,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     (widget.shipment.shipmentItems!.length > 1)
//                                         ? Positioned(
//                                             left: 5,
//                                             top: 5,
//                                             child: Container(
//                                               height: 30,
//                                               width: 35,
//                                               decoration: BoxDecoration(
//                                                 color: AppColor.deepYellow,
//                                                 borderRadius:
//                                                     const BorderRadius.only(
//                                                   topLeft: Radius.circular(12),
//                                                   topRight: Radius.circular(5),
//                                                   bottomLeft:
//                                                       Radius.circular(5),
//                                                   bottomRight:
//                                                       Radius.circular(5),
//                                                 ),
//                                               ),
//                                               child: Center(
//                                                 child: Text(
//                                                   (index2 + 1).toString(),
//                                                   style: const TextStyle(
//                                                     color: Colors.white,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                         : const SizedBox.shrink(),
//                                   ],
//                                 );
//                               }),
//                         );
//                       } else {
//                         return Center(child: LoadingIndicator());
//                       }
//                     },
//                   ),
//             !hasinstruction
//                 ? Container(
//                     margin: const EdgeInsets.symmetric(vertical: 15),
//                     color: Colors.white,
//                     padding: const EdgeInsets.all(8.0),
//                     child: Form(
//                       key: _weightInfoformKey,
//                       child: Column(
//                         children: [
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               SizedBox(
//                                 width: MediaQuery.of(context).size.width * .43,
//                                 child: TextFormField(
//                                   controller: truck_weight_controller,
//                                   onTap: () {
//                                     truck_weight_controller.selection =
//                                         TextSelection(
//                                             baseOffset: 0,
//                                             extentOffset:
//                                                 truck_weight_controller
//                                                     .value.text.length);
//                                   },
//                                   // enabled:
//                                   //     widget.shipment.shipmentinstruction == null,
//                                   scrollPadding: EdgeInsets.only(
//                                       bottom: MediaQuery.of(context)
//                                           .viewInsets
//                                           .bottom),
//                                   textInputAction: TextInputAction.done,
//                                   keyboardType:
//                                       const TextInputType.numberWithOptions(
//                                           decimal: true, signed: true),
//                                   style: const TextStyle(fontSize: 18),
//                                   decoration: InputDecoration(
//                                     labelText: AppLocalizations.of(context)!
//                                         .translate('total_weight'),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         vertical: 11.0, horizontal: 9.0),
//                                   ),
//                                   onTapOutside: (event) {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                   },
//                                   onEditingComplete: () {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();

//                                     // evaluatePrice();
//                                   },
//                                   onChanged: (value) {},
//                                   autovalidateMode:
//                                       AutovalidateMode.onUserInteraction,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return AppLocalizations.of(context)!
//                                           .translate('insert_value_validate');
//                                     }
//                                     return null;
//                                   },
//                                   onSaved: (newValue) {
//                                     truck_weight_controller.text = newValue!;
//                                   },
//                                   onFieldSubmitted: (value) {},
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: MediaQuery.of(context).size.width * .43,
//                                 child: TextFormField(
//                                   controller: net_weight_controller,
//                                   onTap: () {
//                                     net_weight_controller.selection =
//                                         TextSelection(
//                                             baseOffset: 0,
//                                             extentOffset: net_weight_controller
//                                                 .value.text.length);
//                                   },
//                                   // enabled:
//                                   //     widget.shipment.shipmentinstruction == null,
//                                   scrollPadding: EdgeInsets.only(
//                                       bottom: MediaQuery.of(context)
//                                           .viewInsets
//                                           .bottom),
//                                   textInputAction: TextInputAction.done,
//                                   keyboardType:
//                                       const TextInputType.numberWithOptions(
//                                           decimal: true, signed: true),
//                                   style: const TextStyle(fontSize: 18),
//                                   decoration: InputDecoration(
//                                     labelText: AppLocalizations.of(context)!
//                                         .translate('net_weight'),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         vertical: 11.0, horizontal: 9.0),
//                                   ),
//                                   onTapOutside: (event) {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                   },
//                                   onEditingComplete: () {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();

//                                     // evaluatePrice();
//                                   },
//                                   onChanged: (value) {},
//                                   autovalidateMode:
//                                       AutovalidateMode.onUserInteraction,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return AppLocalizations.of(context)!
//                                           .translate('insert_value_validate');
//                                     }
//                                     return null;
//                                   },
//                                   onSaved: (newValue) {
//                                     net_weight_controller.text = newValue!;
//                                   },
//                                   onFieldSubmitted: (value) {},
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 12,
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SizedBox(
//                                 width: MediaQuery.of(context).size.width * .95,
//                                 child: TextFormField(
//                                   controller: final_weight_controller,
//                                   onTap: () {
//                                     final_weight_controller.selection =
//                                         TextSelection(
//                                             baseOffset: 0,
//                                             extentOffset:
//                                                 final_weight_controller
//                                                     .value.text.length);
//                                   },
//                                   // enabled:
//                                   //     widget.shipment.shipmentinstruction == null,
//                                   scrollPadding: EdgeInsets.only(
//                                       bottom: MediaQuery.of(context)
//                                           .viewInsets
//                                           .bottom),
//                                   textInputAction: TextInputAction.done,
//                                   keyboardType:
//                                       const TextInputType.numberWithOptions(
//                                           decimal: true, signed: true),
//                                   style: const TextStyle(fontSize: 18),
//                                   decoration: InputDecoration(
//                                     labelText: AppLocalizations.of(context)!
//                                         .translate('final_weight'),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         vertical: 11.0, horizontal: 9.0),
//                                   ),
//                                   onTapOutside: (event) {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                   },
//                                   onEditingComplete: () {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();

//                                     // evaluatePrice();
//                                   },
//                                   onChanged: (value) {},
//                                   autovalidateMode:
//                                       AutovalidateMode.onUserInteraction,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return AppLocalizations.of(context)!
//                                           .translate('insert_value_validate');
//                                     }
//                                     return null;
//                                   },
//                                   onSaved: (newValue) {
//                                     final_weight_controller.text = newValue!;
//                                   },
//                                   onFieldSubmitted: (value) {},
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 12,
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 : BlocBuilder<ReadInstructionBloc, ReadInstructionState>(
//                     builder: (context, state) {
//                       if (state is ReadInstructionLoadedSuccess) {
//                         return Container(
//                           margin: const EdgeInsets.symmetric(vertical: 15),
//                           color: Colors.white,
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             children: [
//                               const SizedBox(
//                                 height: 10,
//                               ),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   SizedBox(
//                                     width:
//                                         MediaQuery.of(context).size.width * .43,
//                                     child: Container(
//                                       child: Text(state.instruction.netWeight!
//                                           .toString()),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width:
//                                         MediaQuery.of(context).size.width * .43,
//                                     child: Container(
//                                       child: Text(state.instruction.truckWeight!
//                                           .toString()),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(
//                                 height: 12,
//                               ),
//                               Container(
//                                 child: Text(
//                                     state.instruction.finalWeight!.toString()),
//                               ),
//                               const SizedBox(
//                                 height: 12,
//                               ),
//                             ],
//                           ),
//                         );
//                       } else {
//                         return Center(child: LoadingIndicator());
//                       }
//                     },
//                   ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Consumer<TaskNumProvider>(
//                   builder: (context, taskProvider, child) {
//                 return BlocConsumer<InstructionCreateBloc,
//                     InstructionCreateState>(
//                   listener: (context, state) {
//                     taskProvider.decreaseTaskNum();

//                     if (state is InstructionCreateSuccessState) {
//                       print(state.shipment);
//                       // instructionProvider.addInstruction(state.shipment);
//                       BlocProvider.of<ReadInstructionBloc>(context)
//                           .add(ReadInstructionLoadEvent(state.shipment.id!));
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         backgroundColor: AppColor.deepGreen,
//                         dismissDirection: DismissDirection.up,
//                         behavior: SnackBarBehavior.floating,
//                         margin: EdgeInsets.only(
//                             bottom: MediaQuery.of(context).size.height - 150,
//                             left: 10,
//                             right: 10),
//                         content: localeState.value.languageCode == 'en'
//                             ? const Text(
//                                 'shipment instruction has been created successfully.',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                 ),
//                               )
//                             : const Text(
//                                 'تم اضافة تعليمات الشحن بنجاح..',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                 ),
//                               ),
//                         duration: const Duration(seconds: 3),
//                       ));

//                       BlocProvider.of<ReadInstructionBloc>(context)
//                           .add(ReadInstructionLoadEvent(state.shipment.id!));
//                       setState(() {
//                         hasinstruction = true;
//                       });
//                     }
//                     if (state is InstructionCreateFailureState) {
//                       print(state.errorMessage);
//                     }
//                   },
//                   builder: (context, state) {
//                     if (state is InstructionLoadingProgressState) {
//                       return CustomButton(
//                         title: const LoadingIndicator(),
//                         onTap: () {},
//                       );
//                     } else {
//                       return CustomButton(
//                         title: Text(
//                           AppLocalizations.of(context)!
//                               .translate('add_instruction'),
//                           style: TextStyle(
//                             fontSize: 20.sp,
//                           ),
//                         ),
//                         onTap: () {
//                           if (!hasinstruction) {
//                             FocusManager.instance.primaryFocus?.unfocus();

//                             _shipperDetailsformKey.currentState?.save();
//                             if (_shipperDetailsformKey.currentState!
//                                 .validate()) {
//                               Shipmentinstruction shipmentInstruction =
//                                   Shipmentinstruction();
//                               shipmentInstruction.shipment =
//                                   widget.shipment.id!;
//                               shipmentInstruction.userType = selectedRadioTile;
//                               shipmentInstruction.chargerName =
//                                   charger_name_controller.text;
//                               shipmentInstruction.chargerAddress =
//                                   charger_address_controller.text;
//                               shipmentInstruction.chargerPhone =
//                                   charger_phone_controller.text;
//                               shipmentInstruction.recieverName =
//                                   reciever_name_controller.text;
//                               shipmentInstruction.recieverAddress =
//                                   reciever_address_controller.text;
//                               shipmentInstruction.recieverPhone =
//                                   reciever_phone_controller.text;
//                               shipmentInstruction.netWeight =
//                                   double.parse(net_weight_controller.text)
//                                       .toInt();
//                               shipmentInstruction.truckWeight =
//                                   double.parse(truck_weight_controller.text)
//                                       .toInt();
//                               shipmentInstruction.finalWeight =
//                                   double.parse(final_weight_controller.text)
//                                       .toInt();

//                               List<CommodityItems> items = [];
//                               for (var i = 0;
//                                   i < commodityWeight_controller.length;
//                                   i++) {
//                                 CommodityItems item = CommodityItems(
//                                     commodityName:
//                                         commodityName_controller[i].text,
//                                     commodityQuantity: int.parse(
//                                         commodityQuantity_controller[i].text),
//                                     commodityWeight: double.parse(
//                                       commodityWeight_controller[i]
//                                           .text
//                                           .replaceAll(",", ""),
//                                     ).toInt(),
//                                     packageType:
//                                         packageType_controller[i]!.id!);
//                                 items.add(item);
//                               }
//                               print("asd");
//                               shipmentInstruction.commodityItems = items;

//                               BlocProvider.of<InstructionCreateBloc>(context)
//                                   .add(InstructionCreateButtonPressed(
//                                       shipmentInstruction));
//                             } else {
//                               Scrollable.ensureVisible(
//                                 key1.currentContext!,
//                                 duration: const Duration(
//                                   milliseconds: 500,
//                                 ),
//                               );
//                             }

//                             FocusManager.instance.primaryFocus?.unfocus();
//                           } else {
//                             // Navigator.push(
//                             //     context,
//                             //     MaterialPageRoute(
//                             //       builder: (context) =>
//                             //           ShipmentInstructionTruckScreen(
//                             //               shipmentInstruction: widget.shipment
//                             //                   .shipmentinstructionv2!.id!,
//                             //               trucks: widget.shipment.truck!),
//                             //     ));
//                           }
//                         },
//                       );
//                     }
//                   },
//                 );
//               }),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
