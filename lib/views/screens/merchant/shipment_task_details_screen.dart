import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/instructions/read_instruction_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/providers/shipment_instructions_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/merchant/shipment_instruction_screen.dart';
import 'package:camion/views/screens/merchant/shipment_payment_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ShipmentTaskDetailsScreen extends StatefulWidget {
  final Shipmentv2 shipment;
  // final bool hasinstruction;
  ShipmentTaskDetailsScreen({
    Key? key,
    required this.shipment,
    // required this.hasinstruction,
  }) : super(key: key);

  @override
  State<ShipmentTaskDetailsScreen> createState() =>
      _ShipmentTaskDetailsScreenState();
}

class _ShipmentTaskDetailsScreenState extends State<ShipmentTaskDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int tabIndex = 0;
  int selectedIndex = 0;
  bool instructionSelect = true;

  var key1 = GlobalKey();
  String selectedRadioTile = "";
  ShipmentInstructionsProvider? instructionsProvider;

  Widget pathList() {
    return SizedBox(
      height: 60.h,
      child: ListView.builder(
        itemCount: widget.shipment.subshipments!.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });

              instructionsProvider!
                  .setSubShipment(widget.shipment.subshipments![index], index);
            },
            child: Container(
              width: 130.w,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: selectedIndex == index
                    ? AppColor.lightYellow
                    : Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: selectedIndex == index
                      ? AppColor.deepYellow
                      : Colors.grey[400]!,
                ),
              ),
              child: Center(
                child: Text(
                  "المسار رقم ${index + 1}",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: selectedIndex == index
                        ? AppColor.deepYellow
                        : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      instructionsProvider =
          Provider.of<ShipmentInstructionsProvider>(context, listen: false);
      instructionsProvider!.setSubShipment(widget.shipment.subshipments![0], 0);
      if (instructionsProvider!.subShipment!.shipmentinstructionv2 != null) {
        BlocProvider.of<ReadInstructionBloc>(context).add(
            ReadInstructionLoadEvent(
                instructionsProvider!.subShipment!.shipmentinstructionv2!.id!));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: SafeArea(
            child: Scaffold(
              appBar: CustomAppBar(
                title:
                    AppLocalizations.of(context)!.translate('shipment_tasks'),
              ),
              backgroundColor: Colors.grey[200],
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.h,
                    ),
                    pathList(),
                    SizedBox(
                      height: 5.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                instructionSelect = true;
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * .47,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                color: Colors.white,
                                border: Border.all(
                                  color: instructionSelect
                                      ? AppColor.deepYellow
                                      : Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          widget
                                                      .shipment
                                                      .subshipments![
                                                          selectedIndex]
                                                      .shipmentinstructionv2 ==
                                                  null
                                              ? const Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: Colors.red,
                                                )
                                              : Icon(
                                                  Icons.check_circle,
                                                  color: AppColor.deepYellow,
                                                )
                                        ]),
                                    Row(
                                      children: [
                                        SizedBox(
                                            height: 25.h,
                                            width: 25.w,
                                            child: SvgPicture.asset(
                                                "assets/icons/instruction.svg")),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .35,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      'shipment_instruction'),
                                              style: TextStyle(
                                                  // color: AppColor.lightBlue,
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 7.h,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .4,
                                      child: widget
                                                  .shipment
                                                  .subshipments![selectedIndex]
                                                  .shipmentinstructionv2 ==
                                              null
                                          ? Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      'instruction_not_complete'),
                                              maxLines: 2,
                                            )
                                          : Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      'instruction_complete'),
                                              maxLines: 2,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              // BlocProvider.of<TruckDetailsBloc>(context).add(
                              //     TruckDetailsLoadEvent(
                              //         widget.shipment.driver!.truck!));
                              setState(() {
                                instructionSelect = false;
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * .47,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                color: Colors.white,
                                border: Border.all(
                                  color: !instructionSelect
                                      ? AppColor.deepYellow
                                      : Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          widget
                                                      .shipment
                                                      .subshipments![
                                                          selectedIndex]
                                                      .shipmentpaymentv2 ==
                                                  null
                                              ? const Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: Colors.red,
                                                )
                                              : Icon(
                                                  Icons.check_circle,
                                                  color: AppColor.deepYellow,
                                                )
                                        ]),
                                    Row(
                                      children: [
                                        SizedBox(
                                            height: 25.h,
                                            width: 25.w,
                                            child: SvgPicture.asset(
                                                "assets/icons/payment.svg")),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .35,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      'payment_instruction'),
                                              style: TextStyle(
                                                  // color: AppColor.lightBlue,
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 7.h,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .4,
                                      child: widget
                                                  .shipment
                                                  .subshipments![selectedIndex]
                                                  .shipmentpaymentv2 ==
                                              null
                                          ? Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      'payment_not_complete'),
                                              maxLines: 2,
                                            )
                                          : Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      'payment_complete'),
                                              maxLines: 2,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    instructionSelect
                        ? ShipmentInstructionScreen(
                            shipment:
                                widget.shipment.subshipments![selectedIndex],
                            subshipmentIndex: selectedIndex,
                            // hasinstruction: widget.hasinstruction,
                          )
                        : ShipmentPaymentScreen(
                            shipment:
                                widget.shipment.subshipments![selectedIndex],
                            subshipmentIndex: selectedIndex,
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
