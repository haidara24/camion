// ignore_for_file: non_constant_identifier_names

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/instructions/instruction_create_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/read_instruction_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/providers/shipment_instructions_provider.dart';
import 'package:camion/data/providers/task_num_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/screens/merchant/shipment_instruction_truck_screen.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/shipment_path_widget.dart';
import 'package:ensure_visible_when_focused/ensure_visible_when_focused.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ShipmentInstructionScreen extends StatefulWidget {
  final SubShipment shipment;
  final int subshipmentIndex;
  // final bool hasinstruction;
  ShipmentInstructionScreen({
    Key? key,
    required this.shipment,
    required this.subshipmentIndex,
    // required this.hasinstruction,
  }) : super(key: key);

  @override
  State<ShipmentInstructionScreen> createState() =>
      _ShipmentInstructionScreenState();
}

class _ShipmentInstructionScreenState extends State<ShipmentInstructionScreen> {
  final FocusNode _orderTypenode = FocusNode();
  var key1 = GlobalKey();
  String selectedRadioTile = "M";
  final GlobalKey<FormState> _shipperDetailsformKey = GlobalKey<FormState>();

  String setLoadDate(DateTime date) {
    List months = [
      'jan',
      'feb',
      'mar',
      'april',
      'may',
      'jun',
      'july',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec'
    ];
    var mon = date.month;
    var month = months[mon - 1];

    var result = '${date.day}-$month-${date.year}';
    return result;
  }

  TextEditingController charger_name_controller = TextEditingController();
  TextEditingController charger_address_controller = TextEditingController();
  TextEditingController charger_phone_controller = TextEditingController();

  TextEditingController reciever_name_controller = TextEditingController();
  TextEditingController reciever_address_controller = TextEditingController();
  TextEditingController reciever_phone_controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.shipment.shipmentinstructionv2 != null) {
      setState(() {
        selectedRadioTile = "K";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Consumer<ShipmentInstructionsProvider>(
            builder: (context, instructionProvider, child) {
          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .translate('shipment_path_info'),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColor.darkGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ShipmentPathWidget(
                      loadDate: setLoadDate(widget.shipment.pickupDate!),
                      pickupName: widget.shipment.pathpoints!
                          .singleWhere((element) => element.pointType == "P")
                          .name!,
                      deliveryName: widget.shipment.pathpoints!
                          .singleWhere((element) => element.pointType == "D")
                          .name!,
                      width: MediaQuery.of(context).size.width * .8,
                      pathwidth: MediaQuery.of(context).size.width * .7,
                    ).animate().slideX(
                        duration: 300.ms,
                        delay: 0.ms,
                        begin: 1,
                        end: 0,
                        curve: Curves.easeInOutSine),
                  ],
                ),
              ),
              Visibility(
                visible:
                    instructionProvider.subShipment!.shipmentinstructionv2 ==
                        null,
                child: EnsureVisibleWhenFocused(
                  focusNode: _orderTypenode,
                  child: Container(
                    key: key1,
                    margin: const EdgeInsets.symmetric(vertical: 7),
                    color: Colors.white,
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                AppLocalizations.of(context)!
                                    .translate('select_your_identity'),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkGrey,
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .3,
                              child: RadioListTile(
                                contentPadding: EdgeInsets.zero,
                                value: "C",
                                groupValue: selectedRadioTile,
                                title: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('charger'),
                                    overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                // subtitle: Text("Radio 1 Subtitle"),
                                onChanged: (val) {
                                  // print("Radio Tile pressed $val");
                                  setState(() {
                                    selectedRadioTile = val!;
                                  });
                                },
                                activeColor: AppColor.deepYellow,
                                selected: selectedRadioTile == "C",
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .3,
                              child: RadioListTile(
                                contentPadding: EdgeInsets.zero,
                                value: "M",
                                groupValue: selectedRadioTile,
                                title: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('mediator'),
                                    overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                // subtitle: Text("Radio 1 Subtitle"),
                                onChanged: (val) {
                                  // print("Radio Tile pressed $val");
                                  setState(() {
                                    selectedRadioTile = val!;
                                  });
                                },
                                activeColor: AppColor.deepYellow,
                                selected: selectedRadioTile == "M",
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .3,
                              child: RadioListTile(
                                contentPadding: EdgeInsets.zero,

                                value: "R",
                                groupValue: selectedRadioTile,
                                title: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('reciever'),
                                    overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                // subtitle: Text("Radio 2 Subtitle"),
                                onChanged: (val) {
                                  // print("Radio Tile pressed $val");
                                  setState(() {
                                    selectedRadioTile = val!;
                                  });
                                },
                                activeColor: AppColor.deepYellow,

                                selected: selectedRadioTile == "R",
                              ),
                            ),
                          ],
                        ),
                        // Visibility(
                        //   visible: showtypeError,
                        //   child: Text(
                        //     AppLocalizations.of(context)!
                        //         .translate('select_operation_type_error'),
                        //     style: const TextStyle(color: Colors.red),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              instructionProvider.subShipment!.shipmentinstructionv2 == null
                  ? Container(
                      margin: const EdgeInsets.symmetric(vertical: 7),
                      color: Colors.white,
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _shipperDetailsformKey,
                        child: Column(
                          children: [
                            Visibility(
                              visible: (selectedRadioTile.isEmpty ||
                                      selectedRadioTile == "M" ||
                                      selectedRadioTile == "R") ||
                                  (instructionProvider.subShipment!
                                              .shipmentinstructionv2 !=
                                          null
                                      ? (instructionProvider
                                                  .subShipment!
                                                  .shipmentinstructionv2!
                                                  .userType ==
                                              "M") ||
                                          (instructionProvider
                                                  .subShipment!
                                                  .shipmentinstructionv2!
                                                  .userType ==
                                              "R")
                                      : false),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          AppLocalizations.of(context)!
                                              .translate('charger_info'),
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.darkGrey,
                                          )),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: charger_name_controller,
                                    onTap: () {
                                      charger_name_controller.selection =
                                          TextSelection(
                                              baseOffset: 0,
                                              extentOffset:
                                                  charger_name_controller
                                                      .value.text.length);
                                    },
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom),
                                    enabled: instructionProvider.subShipment!
                                            .shipmentinstructionv2 ==
                                        null,
                                    textInputAction: TextInputAction.done,
                                    style: const TextStyle(fontSize: 18),
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .translate('charger_name'),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 11.0, horizontal: 9.0),
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
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .translate('insert_value_validate');
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      charger_name_controller.text = newValue!;
                                    },
                                    onFieldSubmitted: (value) {},
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  TextFormField(
                                    controller: charger_address_controller,
                                    onTap: () {
                                      charger_address_controller.selection =
                                          TextSelection(
                                              baseOffset: 0,
                                              extentOffset:
                                                  charger_address_controller
                                                      .value.text.length);
                                    },
                                    enabled: instructionProvider.subShipment!
                                            .shipmentinstructionv2 ==
                                        null,
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom),
                                    textInputAction: TextInputAction.done,
                                    style: const TextStyle(fontSize: 18),
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .translate('charger_address'),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 11.0, horizontal: 9.0),
                                    ),
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                                    },
                                    onEditingComplete: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      // evaluatePrice();
                                    },
                                    onChanged: (value) {},
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .translate('insert_value_validate');
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      // commodityWeight_controller.text = newValue!;
                                    },
                                    onFieldSubmitted: (value) {
                                      // FocusManager.instance.primaryFocus?.unfocus();
                                      // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                                    },
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  TextFormField(
                                    controller: charger_phone_controller,
                                    onTap: () {
                                      charger_phone_controller.selection =
                                          TextSelection(
                                              baseOffset: 0,
                                              extentOffset:
                                                  charger_phone_controller
                                                      .value.text.length);
                                    },
                                    enabled: instructionProvider.subShipment!
                                            .shipmentinstructionv2 ==
                                        null,
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom),
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(fontSize: 18),
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .translate('charger_phone'),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 11.0, horizontal: 9.0),
                                    ),
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                                    },
                                    onEditingComplete: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      // evaluatePrice();
                                    },
                                    onChanged: (value) {},
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .translate('insert_value_validate');
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      // commodityWeight_controller.text = newValue!;
                                    },
                                    onFieldSubmitted: (value) {
                                      // FocusManager.instance.primaryFocus?.unfocus();
                                      // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                                    },
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: (selectedRadioTile.isEmpty ||
                                      selectedRadioTile == "M" ||
                                      selectedRadioTile == "C") ||
                                  (instructionProvider.subShipment!
                                              .shipmentinstructionv2 !=
                                          null
                                      ? (instructionProvider
                                                  .subShipment!
                                                  .shipmentinstructionv2!
                                                  .userType ==
                                              "M") ||
                                          (instructionProvider
                                                  .subShipment!
                                                  .shipmentinstructionv2!
                                                  .userType ==
                                              "C")
                                      : false),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          AppLocalizations.of(context)!
                                              .translate('reciever_info'),
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.darkGrey,
                                          )),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: reciever_name_controller,
                                    onTap: () {
                                      reciever_name_controller.selection =
                                          TextSelection(
                                              baseOffset: 0,
                                              extentOffset:
                                                  reciever_name_controller
                                                      .value.text.length);
                                    },
                                    enabled: instructionProvider.subShipment!
                                            .shipmentinstructionv2 ==
                                        null,
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom),
                                    textInputAction: TextInputAction.done,
                                    style: const TextStyle(fontSize: 18),
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .translate('reciever_name'),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 11.0, horizontal: 9.0),
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
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .translate('insert_value_validate');
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      reciever_name_controller.text = newValue!;
                                    },
                                    // onFieldSubmitted: (value) {},
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  TextFormField(
                                    controller: reciever_address_controller,
                                    onTap: () {
                                      reciever_address_controller.selection =
                                          TextSelection(
                                              baseOffset: 0,
                                              extentOffset:
                                                  reciever_address_controller
                                                      .value.text.length);
                                    },
                                    enabled: instructionProvider.subShipment!
                                            .shipmentinstructionv2 ==
                                        null,
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom),
                                    textInputAction: TextInputAction.done,
                                    style: const TextStyle(fontSize: 18),
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .translate('reciever_address'),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 11.0, horizontal: 9.0),
                                    ),
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                                    },
                                    onEditingComplete: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      // evaluatePrice();
                                    },
                                    onChanged: (value) {},
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .translate('insert_value_validate');
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      reciever_address_controller.text =
                                          newValue!;
                                    },
                                    // onFieldSubmitted: (value) {
                                    //   // FocusManager.instance.primaryFocus?.unfocus();
                                    //   // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                                    // },
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  TextFormField(
                                    controller: reciever_phone_controller,
                                    onTap: () {
                                      reciever_phone_controller.selection =
                                          TextSelection(
                                              baseOffset: 0,
                                              extentOffset:
                                                  reciever_phone_controller
                                                      .value.text.length);
                                    },
                                    enabled: instructionProvider.subShipment!
                                            .shipmentinstructionv2 ==
                                        null,
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom),
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(fontSize: 18),
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .translate('reciever_phone'),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 11.0, horizontal: 9.0),
                                    ),
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                                    },
                                    onEditingComplete: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      // evaluatePrice();
                                    },
                                    onChanged: (value) {},
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .translate('insert_value_validate');
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      reciever_phone_controller.text =
                                          newValue!;
                                    },
                                    // onFieldSubmitted: (value) {
                                    //   // FocusManager.instance.primaryFocus?.unfocus();
                                    //   // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                                    // },
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : BlocBuilder<ReadInstructionBloc, ReadInstructionState>(
                      builder: (context, state) {
                        if (state is ReadInstructionLoadedSuccess) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 7),
                            color: Colors.white,
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Visibility(
                                  visible:
                                      state.instruction.chargerName!.isNotEmpty,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                              AppLocalizations.of(context)!
                                                  .translate('charger_info'),
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: AppColor.darkGrey,
                                              )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        child: Text(
                                            state.instruction.chargerName!),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Container(
                                        child: Text(
                                            state.instruction.chargerAddress!),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Container(
                                        child: Text(
                                            state.instruction.chargerPhone!),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      const Divider(),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: state
                                      .instruction.recieverName!.isNotEmpty,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                              AppLocalizations.of(context)!
                                                  .translate('reciever_info'),
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: AppColor.darkGrey,
                                              )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        child: Text(
                                            state.instruction.recieverName!),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Container(
                                        child: Text(
                                            state.instruction.recieverAddress!),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Container(
                                        child: Text(
                                            state.instruction.recieverPhone!),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Center(child: LoadingIndicator());
                        }
                      },
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<TaskNumProvider>(
                    builder: (context, taskProvider, child) {
                  return BlocConsumer<InstructionCreateBloc,
                      InstructionCreateState>(
                    listener: (context, state) {
                      taskProvider.decreaseTaskNum();

                      if (state is InstructionCreateSuccessState) {
                        print(state.shipment);
                        instructionProvider.addInstruction(state.shipment);
                        BlocProvider.of<ReadInstructionBloc>(context)
                            .add(ReadInstructionLoadEvent(state.shipment.id!));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: AppColor.deepGreen,
                          dismissDirection: DismissDirection.up,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height - 150,
                              left: 10,
                              right: 10),
                          content: localeState.value.languageCode == 'en'
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
                        ));
                      }
                      if (state is InstructionCreateFailureState) {
                        print(state.errorMessage);
                      }
                    },
                    builder: (context, state) {
                      if (state is InstructionLoadingProgressState) {
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
                            if (widget.shipment.shipmentinstructionv2 == null) {
                              FocusManager.instance.primaryFocus?.unfocus();

                              _shipperDetailsformKey.currentState?.save();
                              if (_shipperDetailsformKey.currentState!
                                  .validate()) {
                                Shipmentinstruction shipmentInstruction =
                                    Shipmentinstruction();
                                shipmentInstruction.shipment =
                                    widget.shipment.id!;
                                shipmentInstruction.userType =
                                    selectedRadioTile;
                                shipmentInstruction.chargerName =
                                    charger_name_controller.text;
                                shipmentInstruction.chargerAddress =
                                    charger_address_controller.text;
                                shipmentInstruction.chargerPhone =
                                    charger_phone_controller.text;
                                shipmentInstruction.recieverName =
                                    reciever_name_controller.text;
                                shipmentInstruction.recieverAddress =
                                    reciever_address_controller.text;
                                shipmentInstruction.recieverPhone =
                                    reciever_phone_controller.text;

                                BlocProvider.of<InstructionCreateBloc>(context)
                                    .add(InstructionCreateButtonPressed(
                                        shipmentInstruction));
                              } else {
                                Scrollable.ensureVisible(
                                  key1.currentContext!,
                                  duration: const Duration(
                                    milliseconds: 500,
                                  ),
                                );
                              }

                              FocusManager.instance.primaryFocus?.unfocus();
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ShipmentInstructionTruckScreen(
                                            shipmentInstruction: widget.shipment
                                                .shipmentinstructionv2!.id!,
                                            trucks: widget.shipment.truck!),
                                  ));
                            }
                          },
                        );
                      }
                    },
                  );
                }),
              ),
            ],
          );
        });
      },
    );
  }
}
