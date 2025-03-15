import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/read_instruction_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ShipmentInstructionDetailsScreen extends StatefulWidget {
  final int shipment;

  const ShipmentInstructionDetailsScreen({
    Key? key,
    required this.shipment,
  }) : super(key: key);

  @override
  State<ShipmentInstructionDetailsScreen> createState() =>
      _ShipmentInstructionDetailsScreenState();
}

class _ShipmentInstructionDetailsScreenState
    extends State<ShipmentInstructionDetailsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<SubShipmentDetailsBloc>(context).add(
      SubShipmentDetailsLoadEvent(widget.shipment),
    );
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark, // Reset to default
        statusBarColor: AppColor.deepBlack,
        systemNavigationBarColor: AppColor.deepBlack,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: AppColor.deepBlack, // Make status bar transparent
              statusBarIconBrightness:
                  Brightness.light, // Light icons for dark backgrounds
              systemNavigationBarColor: Colors.grey[200], // Works on Android
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: SafeArea(
              child: Scaffold(
                appBar: CustomAppBar(
                  title: AppLocalizations.of(context)!
                      .translate("shipment_instruction"),
                ),
                backgroundColor: Colors.grey[100],
                body: SingleChildScrollView(
                  child: BlocConsumer<SubShipmentDetailsBloc,
                      SubShipmentDetailsState>(
                    listener: (context, shipmentstate) {
                      if (shipmentstate is SubShipmentDetailsLoadedSuccess) {
                        BlocProvider.of<ReadInstructionBloc>(context).add(
                          ReadInstructionLoadEvent(
                              shipmentstate.shipment.shipmentinstructionv2!),
                        );
                      }
                    },
                    builder: (context, shipmentstate) {
                      if (shipmentstate is SubShipmentDetailsLoadedSuccess) {
                        return BlocBuilder<ReadInstructionBloc,
                            ReadInstructionState>(
                          builder: (context, state) {
                            if (state is ReadInstructionLoadedSuccess) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Card(
                                      elevation: 2,
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .translate(
                                                          'shipment_path_info'),
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
                                            ShipmentPathVerticalWidget(
                                              pathpoints: shipmentstate
                                                  .shipment.pathpoints!,
                                              pickupDate: shipmentstate
                                                  .shipment.pickupDate!,
                                              deliveryDate: shipmentstate
                                                  .shipment.deliveryDate!,
                                              langCode: localeState
                                                  .value.languageCode,
                                              mini: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Card(
                                        elevation: 2,
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Visibility(
                                                visible: state.instruction
                                                    .chargerName!.isNotEmpty,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SectionTitle(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .translate(
                                                                  'charger_info'),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(state.instruction
                                                        .chargerName!),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(state.instruction
                                                        .chargerAddress!),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(state.instruction
                                                        .chargerPhone!),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    const Divider(),
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                visible: state.instruction
                                                    .recieverName!.isNotEmpty,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SectionTitle(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .translate(
                                                                  'reciever_info'),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    SectionBody(
                                                        text:
                                                            '${AppLocalizations.of(context)!.translate('charger_name')}: ${state.instruction.recieverName!}'),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    SectionBody(
                                                        text:
                                                            '${AppLocalizations.of(context)!.translate('charger_address')}: ${state.instruction.recieverAddress!}'),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    SectionBody(
                                                        text:
                                                            '${AppLocalizations.of(context)!.translate('charger_phone')}: ${state.instruction.recieverPhone!}'),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SectionTitle(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'commodity_info'),
                                                  ),
                                                ]),
                                            ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: shipmentstate
                                                    .shipment
                                                    .shipmentItems!
                                                    .length,
                                                itemBuilder: (context, index2) {
                                                  return Stack(
                                                    children: [
                                                      Card(
                                                        color: Colors.grey[50],
                                                        margin: const EdgeInsets
                                                            .all(5),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10.0,
                                                                  vertical:
                                                                      7.5),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                height: 7,
                                                              ),
                                                              SectionBody(
                                                                  text:
                                                                      '${AppLocalizations.of(context)!.translate('commodity_name')}: ${state.instruction.commodityItems![index2].commodityName!}'),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              SectionBody(
                                                                  text:
                                                                      '${AppLocalizations.of(context)!.translate('commodity_quantity')}: ${state.instruction.commodityItems![index2].commodityQuantity!.toString()}'),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              SectionBody(
                                                                  text:
                                                                      '${AppLocalizations.of(context)!.translate('commodity_weight')}: ${shipmentstate.shipment.shipmentItems![index2].commodityWeight!.toString()} كغ'),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      (shipmentstate
                                                                  .shipment
                                                                  .shipmentItems!
                                                                  .length >
                                                              1)
                                                          ? Positioned(
                                                              left: localeState
                                                                          .value
                                                                          .languageCode ==
                                                                      "en"
                                                                  ? null
                                                                  : 5,
                                                              right: localeState
                                                                          .value
                                                                          .languageCode ==
                                                                      "en"
                                                                  ? 5
                                                                  : null,
                                                              top: 5,
                                                              child: Container(
                                                                height: 30,
                                                                width: 35,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    topLeft: localeState.value.languageCode ==
                                                                            "en"
                                                                        ? const Radius
                                                                            .circular(
                                                                            5)
                                                                        : const Radius
                                                                            .circular(
                                                                            12),
                                                                    topRight: localeState.value.languageCode ==
                                                                            "en"
                                                                        ? const Radius
                                                                            .circular(
                                                                            12)
                                                                        : const Radius
                                                                            .circular(
                                                                            5),
                                                                    bottomLeft:
                                                                        const Radius
                                                                            .circular(
                                                                            5),
                                                                    bottomRight:
                                                                        const Radius
                                                                            .circular(
                                                                            5),
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    (index2 + 1)
                                                                        .toString(),
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox
                                                              .shrink(),
                                                    ],
                                                  );
                                                }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      color: Colors.white,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SectionTitle(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'weight_info'),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              SectionBody(
                                                  text:
                                                      '${AppLocalizations.of(context)!.translate('first_weight')}: ${state.instruction.netWeight!.toString()}'),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              SectionBody(
                                                  text:
                                                      '${AppLocalizations.of(context)!.translate('second_weight')}: ${state.instruction.truckWeight!.toString()}'),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              SectionBody(
                                                  text:
                                                      '${AppLocalizations.of(context)!.translate('commodity_gross_weight')}: ${state.instruction.finalWeight!.toString()}'),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox.shrink(),
                                  ],
                                ),
                              );
                            } else {
                              return Shimmer.fromColors(
                                baseColor: (Colors.grey[300])!,
                                highlightColor: (Colors.grey[100])!,
                                enabled: true,
                                direction: ShimmerDirection.ttb,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemBuilder: (_, __) => Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 5),
                                        height: 150.h,
                                        width: double.infinity,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  itemCount: 4,
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        return Shimmer.fromColors(
                          baseColor: (Colors.grey[300])!,
                          highlightColor: (Colors.grey[100])!,
                          enabled: true,
                          direction: ShimmerDirection.ttb,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemBuilder: (_, __) => Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  height: 150.h,
                                  width: double.infinity,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                            itemCount: 4,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
