import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_details_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/merchant/shipment_instruction_screen.dart';
import 'package:camion/views/screens/merchant/shipment_payment_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

class ShipmentTaskDetailsFromNotificationScreen extends StatefulWidget {
  ShipmentTaskDetailsFromNotificationScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ShipmentTaskDetailsFromNotificationScreen> createState() =>
      _ShipmentTaskDetailsFromNotificationScreenState();
}

class _ShipmentTaskDetailsFromNotificationScreenState
    extends State<ShipmentTaskDetailsFromNotificationScreen>
    with SingleTickerProviderStateMixin {
  bool hasinstruction = false;
  late TabController _tabController;
  int tabIndex = 0;

  bool instructionSelect = true;

  final FocusNode _orderTypenode = FocusNode();
  var key1 = GlobalKey();
  String selectedRadioTile = "";

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
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
                child: BlocConsumer<ShipmentDetailsBloc, ShipmentDetailsState>(
                  listener: (context, state) {
                    if (state is ShipmentDetailsLoadedSuccess) {
                      hasinstruction = state.shipment.subshipments![0]
                              .shipmentinstructionv2 !=
                          null;
                    }
                  },
                  builder: (context, state) {
                    if (state is ShipmentDetailsLoadedSuccess) {
                      return Column(
                        children: [
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
                                    width:
                                        MediaQuery.of(context).size.width * .47,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                state.shipment.subshipments![0]
                                                            .shipmentinstructionv2 ==
                                                        null
                                                    ? const Icon(
                                                        Icons
                                                            .warning_amber_rounded,
                                                        color: Colors.red,
                                                      )
                                                    : Icon(
                                                        Icons.check_circle,
                                                        color:
                                                            AppColor.deepYellow,
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
                                                    AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'shipment_instruction'),
                                                    style: TextStyle(
                                                        // color: AppColor.lightBlue,
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 7.h,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .4,
                                            child: state
                                                        .shipment
                                                        .subshipments![0]
                                                        .shipmentinstructionv2 ==
                                                    null
                                                ? Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'instruction_not_complete'),
                                                    maxLines: 2,
                                                  )
                                                : Text(
                                                    AppLocalizations.of(
                                                            context)!
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
                                    // BlocProvider.of<TruckDetailsBloc>(context)
                                    //     .add(TruckDetailsLoadEvent(
                                    //         state.shipment.driver!.truck!));
                                    setState(() {
                                      instructionSelect = false;
                                    });
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .47,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                state.shipment.subshipments![0]
                                                            .shipmentpaymentv2 ==
                                                        null
                                                    ? const Icon(
                                                        Icons
                                                            .warning_amber_rounded,
                                                        color: Colors.red,
                                                      )
                                                    : Icon(
                                                        Icons.check_circle,
                                                        color:
                                                            AppColor.deepYellow,
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
                                                    AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'payment_instruction'),
                                                    style: TextStyle(
                                                        // color: AppColor.lightBlue,
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 7.h,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .4,
                                            child: state
                                                        .shipment
                                                        .subshipments![0]
                                                        .shipmentpaymentv2 ==
                                                    null
                                                ? Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'payment_not_complete'),
                                                    maxLines: 2,
                                                  )
                                                : Text(
                                                    AppLocalizations.of(
                                                            context)!
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
                                  shipment: state.shipment.subshipments![0],
                                  subshipmentIndex: 0,
                                  // hasinstruction: hasinstruction,
                                )
                              : ShipmentPaymentScreen(
                                  shipment: state.shipment.subshipments![0],
                                  subshipmentIndex: 0,
                                ),
                        ],
                      );
                    } else {
                      return Shimmer.fromColors(
                        baseColor: (Colors.grey[300])!,
                        highlightColor: (Colors.grey[100])!,
                        enabled: true,
                        direction: ShimmerDirection.ttb,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (_, __) => Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 30.h,
                                  width: 100.w,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  height: 30.h,
                                  width: 150.w,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  height: 30.h,
                                  width: 150.w,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          itemCount: 6,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
