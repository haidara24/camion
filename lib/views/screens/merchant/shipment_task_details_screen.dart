// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/instructions/instruction_create_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/read_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_task_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/providers/shipment_instructions_provider.dart';
import 'package:camion/data/providers/task_num_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/formatter.dart';
import 'package:camion/views/screens/merchant/shipment_payment_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/shipment_path_vertical_widget.dart';
import 'package:camion/views/widgets/snackbar_widget.dart';
import 'package:ensure_visible_when_focused/ensure_visible_when_focused.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ShipmentTaskDetailsScreen extends StatefulWidget {
  final SubShipment shipment;
  // final bool hasinstruction;
  const ShipmentTaskDetailsScreen({
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
  var key2 = GlobalKey();
  var key3 = GlobalKey();
  String selectedRadioTile = "";
  bool selectedRadioTileError = false;
  ShipmentInstructionsProvider? instructionsProvider;

  final FocusNode _orderTypenode = FocusNode();
  // var key1 = GlobalKey();
  // String selectedRadioTile = "M";
  final GlobalKey<FormState> _shipperDetailsformKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _commodityInfoformKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _weightInfoformKey = GlobalKey<FormState>();
  bool hasinstruction = false;

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
  // TextEditingController charger_address_controller = TextEditingController();
  TextEditingController charger_phone_controller = TextEditingController();

  TextEditingController reciever_name_controller = TextEditingController();
  // TextEditingController reciever_address_controller = TextEditingController();
  TextEditingController reciever_phone_controller = TextEditingController();

  int count = 0;

  TextEditingController total_weight_controller = TextEditingController();
  TextEditingController net_weight_controller = TextEditingController();
  TextEditingController truck_weight_controller = TextEditingController();
  TextEditingController final_weight_controller = TextEditingController();

  List<TextEditingController> commodityName_controller = [];
  List<TextEditingController> commodityWeight_controller = [];
  List<TextEditingController> commodityQuantity_controller = [];

  // List<TextEditingController> readpackageType_controller = [];
  // List<PackageType?> packageType_controller = [null];

  final List<File> _files = [];
  final ImagePicker _picker = ImagePicker();

  List<Widget> _buildFilesImages(List<Docs> list) {
    List<Widget> widlist = [];
    if (list.isNotEmpty) {
      for (var i = 0; i < list.length; i++) {
        var elem = GestureDetector(
          onTap: () {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Dialog(
                  insetPadding: EdgeInsets.zero, // Remove default padding
                  backgroundColor: Colors.white,
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * .9,
                    height: MediaQuery.of(context).size.height *
                        .9, // Optional: full height
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: CachedNetworkImage(
                            // height: MediaQuery.of(context).size.width * .23,
                            // width: 110.h,
                            fit: BoxFit.fill,
                            imageUrl: list[i].file!,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    Shimmer.fromColors(
                              baseColor: (Colors.grey[300])!,
                              highlightColor: (Colors.grey[100])!,
                              enabled: true,
                              child: SizedBox(
                                height: 45.h,
                                width: 155.w,
                                child: SvgPicture.asset(
                                    "assets/images/camion_loading.svg"),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 45.h,
                              width: 155.w,
                              color: Colors.grey[300],
                              child: Center(
                                child: Text(AppLocalizations.of(context)!
                                    .translate('image_load_error')),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
            width: MediaQuery.of(context).size.width * .23,
            height: 110.h,
            child: CachedNetworkImage(
              height: MediaQuery.of(context).size.width * .23,
              width: 110.h,
              fit: BoxFit.fill,
              imageUrl: list[i].file!,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Shimmer.fromColors(
                baseColor: (Colors.grey[300])!,
                highlightColor: (Colors.grey[100])!,
                enabled: true,
                child: SizedBox(
                  height: 45.h,
                  width: 155.w,
                  child: SvgPicture.asset("assets/images/camion_loading.svg"),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 45.h,
                width: 155.w,
                color: Colors.grey[300],
                child: Center(
                  child: Text(AppLocalizations.of(context)!
                      .translate('image_load_error')),
                ),
              ),
            ),
          ),
        );
        widlist.add(elem);
      }
    }
    return widlist;
  }

  List<Widget> _buildAttachmentImages() {
    List<Widget> list = [];
    if (_files.isNotEmpty) {
      for (var i = 0; i < _files.length; i++) {
        var elem = Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topLeft,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              width: MediaQuery.of(context).size.width * .23,
              height: 110.h,
              child: Image(
                height: MediaQuery.of(context).size.width * .23,
                width: 110.h,
                fit: BoxFit.fill,
                image: FileImage(_files[i]),
              ),
            ),
            Positioned(
              top: -16,
              left: -16,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _files.removeAt(i);
                  });
                },
                icon: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200]!,
                    borderRadius: BorderRadius.circular(45),
                  ),
                  child: SizedBox(
                    height: 25.w,
                    width: 25.w,
                    child: SvgPicture.asset(
                        "assets/icons/grey/notification_shipment_cancelation.svg"),
                  ),
                ),
              ),
            ),
          ],
        );
        list.add(elem);
      }
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.shipment.shipmentinstructionv2 != null) {
      setState(() {
        selectedRadioTile = "C";
        hasinstruction = true;
      });
    } else {
      count = widget.shipment.shipmentItems!.length;
      for (var i = 0; i < count; i++) {
        commodityName_controller.add(TextEditingController(
            text: widget.shipment.shipmentItems![i].commodityName!));
        commodityQuantity_controller.add(TextEditingController());
        commodityWeight_controller.add(TextEditingController());
        // packageType_controller.add(null);
      }
    }
  }

  void additem() {
    setState(() {
      TextEditingController commodity_weight_controller =
          TextEditingController();
      TextEditingController commodity_name_controller = TextEditingController();
      TextEditingController commodity_quantity_controller =
          TextEditingController();

      commodityName_controller.add(commodity_name_controller);
      commodityWeight_controller.add(commodity_weight_controller);
      commodityQuantity_controller.add(commodity_quantity_controller);

      count++;
    });
  }

  void removeitem(int index) {
    setState(() {
      commodityName_controller.removeAt(index);
      commodityWeight_controller.removeAt(index);
      commodityQuantity_controller.removeAt(index);
      count--;
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark, // Reset to default
        statusBarColor: AppColor.deepBlack,
        systemNavigationBarColor: AppColor.deepBlack,
      ),
    );

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
                  title:
                      AppLocalizations.of(context)!.translate('shipment_tasks'),
                ),
                backgroundColor: Colors.grey[100],
                body: SingleChildScrollView(
                  child: Column(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            widget.shipment
                                                        .shipmentinstructionv2 ==
                                                    null
                                                ? Icon(
                                                    Icons.warning_amber_rounded,
                                                    color: AppColor.deepYellow,
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        child: widget.shipment
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          widget.shipment.shipmentpaymentv2 ==
                                                  null
                                              ? Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: AppColor.deepYellow,
                                                )
                                              : Icon(
                                                  Icons.check_circle,
                                                  color: AppColor.deepYellow,
                                                )
                                        ],
                                      ),
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        child: widget.shipment
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
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
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
                                            pathpoints:
                                                widget.shipment.pathpoints!,
                                            pickupDate:
                                                widget.shipment.pickupDate!,
                                            deliveryDate:
                                                widget.shipment.deliveryDate!,
                                            langCode:
                                                localeState.value.languageCode,
                                            mini: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  widget.shipment.shipmentinstructionv2 == null
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 3,
                                          ),
                                          child: SizedBox(
                                            key: key2,
                                            child: Form(
                                              key: _commodityInfoformKey,
                                              child: Column(
                                                children: [
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount: count,
                                                    itemBuilder:
                                                        (context, index2) {
                                                      return Stack(
                                                        clipBehavior: Clip.none,
                                                        children: [
                                                          Card(
                                                            elevation: 1,
                                                            color: Colors.white,
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              vertical: 5,
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                              child: Column(
                                                                children: [
                                                                  index2 == 0
                                                                      ? Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            SectionTitle(
                                                                              text: AppLocalizations.of(context)!.translate('commodity_info'),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : const SizedBox
                                                                          .shrink(),
                                                                  index2 != 0
                                                                      ? const SizedBox(
                                                                          height:
                                                                              30,
                                                                        )
                                                                      : const SizedBox
                                                                          .shrink(),
                                                                  const SizedBox(
                                                                    height: 16,
                                                                  ),
                                                                  TextFormField(
                                                                    controller:
                                                                        commodityName_controller[
                                                                            index2],
                                                                    onTap: () {
                                                                      commodityName_controller[index2].selection = TextSelection(
                                                                          baseOffset:
                                                                              0,
                                                                          extentOffset: commodityName_controller[index2]
                                                                              .value
                                                                              .text
                                                                              .length);
                                                                    },
                                                                    scrollPadding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      bottom: MediaQuery.of(context)
                                                                              .viewInsets
                                                                              .bottom +
                                                                          20,
                                                                    ),
                                                                    textInputAction:
                                                                        TextInputAction
                                                                            .done,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText: AppLocalizations.of(
                                                                              context)!
                                                                          .translate(
                                                                              'commodity_name'),
                                                                      contentPadding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              11.0,
                                                                          horizontal:
                                                                              9.0),
                                                                    ),
                                                                    onTapOutside:
                                                                        (event) {
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus!
                                                                          .unfocus();
                                                                    },
                                                                    onEditingComplete:
                                                                        () {
                                                                      // if (evaluateCo2()) {
                                                                      //   calculateCo2Report();
                                                                      // }
                                                                    },
                                                                    onChanged:
                                                                        (value) {
                                                                      // if (evaluateCo2()) {
                                                                      //   calculateCo2Report();
                                                                      // }
                                                                    },
                                                                    autovalidateMode:
                                                                        AutovalidateMode
                                                                            .onUserInteraction,
                                                                    validator:
                                                                        (value) {
                                                                      if (value!
                                                                          .isEmpty) {
                                                                        return AppLocalizations.of(context)!
                                                                            .translate('insert_value_validate');
                                                                      }
                                                                      return null;
                                                                    },
                                                                    onSaved:
                                                                        (newValue) {
                                                                      commodityName_controller[index2]
                                                                              .text =
                                                                          newValue!;
                                                                    },
                                                                    onFieldSubmitted:
                                                                        (value) {
                                                                      // if (evaluateCo2()) {
                                                                      //   calculateCo2Report();
                                                                      // }
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();
                                                                      // BlocProvider.of<
                                                                      //             BottomNavBarCubit>(
                                                                      //         context)
                                                                      //     .emitShow();
                                                                    },
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 16,
                                                                  ),
                                                                  // BlocBuilder<
                                                                  //     PackageTypeBloc,
                                                                  //     PackageTypeState>(
                                                                  //   builder:
                                                                  //       (context,
                                                                  //           state2) {
                                                                  //     if (state2
                                                                  //         is PackageTypeLoadedSuccess) {
                                                                  //       return DropdownButtonHideUnderline(
                                                                  //         child:
                                                                  //             DropdownButton2<PackageType>(
                                                                  //           isExpanded:
                                                                  //               true,
                                                                  //           hint:
                                                                  //               Text(
                                                                  //             AppLocalizations.of(context)!.translate('package_type'),
                                                                  //             style: TextStyle(
                                                                  //               fontSize: 18,
                                                                  //               color: Theme.of(context).hintColor,
                                                                  //             ),
                                                                  //           ),
                                                                  //           items: state2.packageTypes
                                                                  //               .map((PackageType item) => DropdownMenuItem<PackageType>(
                                                                  //                     value: item,
                                                                  //                     child: SizedBox(
                                                                  //                       width: 200,
                                                                  //                       child: Text(
                                                                  //                         localeState.value.languageCode == "en" ? item.name! : item.nameAr!,
                                                                  //                         style: const TextStyle(
                                                                  //                           fontSize: 17,
                                                                  //                         ),
                                                                  //                       ),
                                                                  //                     ),
                                                                  //                   ))
                                                                  //               .toList(),
                                                                  //           value:
                                                                  //               packageType_controller[index2],
                                                                  //           onChanged:
                                                                  //               (PackageType? value) {
                                                                  //             setState(() {
                                                                  //               packageType_controller[index2] = value!;
                                                                  //             });
                                                                  //           },
                                                                  //           buttonStyleData:
                                                                  //               ButtonStyleData(
                                                                  //             height: 50,
                                                                  //             width: double.infinity,
                                                                  //             padding: const EdgeInsets.symmetric(
                                                                  //               horizontal: 9.0,
                                                                  //             ),
                                                                  //             decoration: BoxDecoration(
                                                                  //               borderRadius: BorderRadius.circular(12),
                                                                  //               border: Border.all(
                                                                  //                 color: Colors.black26,
                                                                  //               ),
                                                                  //               // color:
                                                                  //               //     Colors.white,
                                                                  //             ),
                                                                  //             // elevation: 2,
                                                                  //           ),
                                                                  //           iconStyleData:
                                                                  //               IconStyleData(
                                                                  //             icon: const Icon(
                                                                  //               Icons.keyboard_arrow_down_sharp,
                                                                  //             ),
                                                                  //             iconSize: 20,
                                                                  //             iconEnabledColor: AppColor.deepYellow,
                                                                  //             iconDisabledColor: Colors.grey,
                                                                  //           ),
                                                                  //           dropdownStyleData:
                                                                  //               DropdownStyleData(
                                                                  //             decoration: BoxDecoration(
                                                                  //               borderRadius: BorderRadius.circular(14),
                                                                  //               color: Colors.white,
                                                                  //             ),
                                                                  //             scrollbarTheme: ScrollbarThemeData(
                                                                  //               radius: const Radius.circular(40),
                                                                  //               thickness: WidgetStateProperty.all(6),
                                                                  //               thumbVisibility: WidgetStateProperty.all(true),
                                                                  //             ),
                                                                  //           ),
                                                                  //           menuItemStyleData:
                                                                  //               const MenuItemStyleData(
                                                                  //             height: 40,
                                                                  //           ),
                                                                  //         ),
                                                                  //       );
                                                                  //     } else if (state2
                                                                  //         is PackageTypeLoadingProgress) {
                                                                  //       return const Center(
                                                                  //         child:
                                                                  //             LinearProgressIndicator(),
                                                                  //       );
                                                                  //     } else if (state2
                                                                  //         is PackageTypeLoadedFailed) {
                                                                  //       return Center(
                                                                  //         child:
                                                                  //             InkWell(
                                                                  //           onTap:
                                                                  //               () {
                                                                  //             BlocProvider.of<PackageTypeBloc>(context).add(PackageTypeLoadEvent());
                                                                  //           },
                                                                  //           child:
                                                                  //               Row(
                                                                  //             mainAxisAlignment: MainAxisAlignment.center,
                                                                  //             children: [
                                                                  //               Text(
                                                                  //                 AppLocalizations.of(context)!.translate('list_error'),
                                                                  //                 style: const TextStyle(color: Colors.red),
                                                                  //               ),
                                                                  //               const Icon(
                                                                  //                 Icons.refresh,
                                                                  //                 color: Colors.grey,
                                                                  //               )
                                                                  //             ],
                                                                  //           ),
                                                                  //         ),
                                                                  //       );
                                                                  //     } else {
                                                                  //       return Container();
                                                                  //     }
                                                                  //   },
                                                                  // ),
                                                                  // const SizedBox(
                                                                  //   height: 16,
                                                                  // ),

                                                                  TextFormField(
                                                                    controller:
                                                                        commodityWeight_controller[
                                                                            index2],
                                                                    onTap: () {
                                                                      // BlocProvider.of<
                                                                      //             BottomNavBarCubit>(
                                                                      //         context)
                                                                      //     .emitHide();
                                                                      commodityWeight_controller[index2].selection = TextSelection(
                                                                          baseOffset:
                                                                              0,
                                                                          extentOffset: commodityWeight_controller[index2]
                                                                              .value
                                                                              .text
                                                                              .length);
                                                                    },
                                                                    // focusNode: _nodeWeight,
                                                                    // enabled: !valueEnabled,
                                                                    scrollPadding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      bottom: MediaQuery.of(context)
                                                                              .viewInsets
                                                                              .bottom +
                                                                          20,
                                                                    ),
                                                                    textInputAction:
                                                                        TextInputAction
                                                                            .done,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    inputFormatters: [
                                                                      DecimalFormatter(),
                                                                    ],
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            20),
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText: AppLocalizations.of(
                                                                              context)!
                                                                          .translate(
                                                                              'commodity_weight'),
                                                                      contentPadding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              11.0,
                                                                          horizontal:
                                                                              9.0),
                                                                      suffix:
                                                                          Text(
                                                                        localeState.value.languageCode ==
                                                                                "en"
                                                                            ? "kg"
                                                                            : "كغ",
                                                                      ),
                                                                      suffixStyle:
                                                                          const TextStyle(
                                                                              fontSize: 15),
                                                                    ),
                                                                    onTapOutside:
                                                                        (event) {
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus!
                                                                          .unfocus();
                                                                    },
                                                                    onEditingComplete:
                                                                        () {
                                                                      // if (evaluateCo2()) {
                                                                      //   calculateCo2Report();
                                                                      // }
                                                                    },
                                                                    onChanged:
                                                                        (value) {},
                                                                    autovalidateMode:
                                                                        AutovalidateMode
                                                                            .onUserInteraction,
                                                                    validator:
                                                                        (value) {
                                                                      if (value!
                                                                          .isEmpty) {
                                                                        return AppLocalizations.of(context)!
                                                                            .translate('insert_value_validate');
                                                                      }
                                                                      return null;
                                                                    },
                                                                    onSaved:
                                                                        (newValue) {
                                                                      commodityWeight_controller[index2]
                                                                              .text =
                                                                          newValue!;
                                                                    },
                                                                    onFieldSubmitted:
                                                                        (value) {
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();
                                                                    },
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 16,
                                                                  ),
                                                                  TextFormField(
                                                                    controller:
                                                                        commodityQuantity_controller[
                                                                            index2],
                                                                    onTap: () {
                                                                      commodityQuantity_controller[index2].selection = TextSelection(
                                                                          baseOffset:
                                                                              0,
                                                                          extentOffset: commodityQuantity_controller[index2]
                                                                              .value
                                                                              .text
                                                                              .length);
                                                                    },
                                                                    // focusNode: _nodeWeight,
                                                                    // enabled: !valueEnabled,
                                                                    scrollPadding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      bottom: MediaQuery.of(context)
                                                                              .viewInsets
                                                                              .bottom +
                                                                          20,
                                                                    ),
                                                                    textInputAction:
                                                                        TextInputAction
                                                                            .done,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    inputFormatters: [
                                                                      DecimalFormatter(),
                                                                    ],
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText: AppLocalizations.of(
                                                                              context)!
                                                                          .translate(
                                                                              'commodity_quantity'),
                                                                      contentPadding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              11.0,
                                                                          horizontal:
                                                                              9.0),
                                                                    ),
                                                                    onTapOutside:
                                                                        (event) {
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();
                                                                    },
                                                                    onEditingComplete:
                                                                        () {
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();
                                                                      // if (evaluateCo2()) {
                                                                      //   calculateCo2Report();
                                                                      // }
                                                                    },
                                                                    onChanged:
                                                                        (value) {
                                                                      // if (evaluateCo2()) {
                                                                      //   calculateCo2Report();
                                                                      // }
                                                                    },
                                                                    autovalidateMode:
                                                                        AutovalidateMode
                                                                            .onUserInteraction,
                                                                    validator:
                                                                        (value) {
                                                                      if (value!
                                                                          .isEmpty) {
                                                                        return AppLocalizations.of(context)!
                                                                            .translate('insert_value_validate');
                                                                      }
                                                                      return null;
                                                                    },
                                                                    onSaved:
                                                                        (newValue) {
                                                                      commodityQuantity_controller[index2]
                                                                              .text =
                                                                          newValue!;
                                                                    },
                                                                    onFieldSubmitted:
                                                                        (value) {
                                                                      // if (evaluateCo2()) {
                                                                      //   calculateCo2Report();
                                                                      // }
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();
                                                                      // BlocProvider.of<
                                                                      //             BottomNavBarCubit>(
                                                                      //         context)
                                                                      //     .emitShow();
                                                                    },
                                                                  ),

                                                                  (count ==
                                                                          (index2 +
                                                                              1))
                                                                      ? Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            InkWell(
                                                                              onTap: () {
                                                                                additem();
                                                                              },
                                                                              child: Text(
                                                                                AppLocalizations.of(context)!.translate('add_commodity'),
                                                                                style: TextStyle(
                                                                                  // fontSize: 16,
                                                                                  // fontWeight:
                                                                                  //     FontWeight
                                                                                  //         .bold,
                                                                                  color: AppColor.deepYellow,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () => additem(),
                                                                              child: AbsorbPointer(
                                                                                absorbing: true,
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: Icon(
                                                                                    Icons.add_circle_outline_outlined,
                                                                                    color: AppColor.deepYellow,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : const SizedBox
                                                                          .shrink(),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          (count > 1)
                                                              ? Positioned(
                                                                  left: 0,
                                                                  // right: localeState
                                                                  //             .value
                                                                  //             .languageCode ==
                                                                  //         'en'
                                                                  //     ? null
                                                                  //     : 5,
                                                                  top: 5,
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: AppColor
                                                                          .deepYellow,
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .only(
                                                                        topLeft:
                                                                            //  localeState
                                                                            //             .value
                                                                            //             .languageCode ==
                                                                            //         'en'
                                                                            //     ?
                                                                            Radius.circular(12)
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
                                                                            Radius.circular(5),
                                                                        bottomRight:
                                                                            Radius.circular(5),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        (index2 +
                                                                                1)
                                                                            .toString(),
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : const SizedBox
                                                                  .shrink(),
                                                          (count > 1) &&
                                                                  (index2 != 0)
                                                              ? Positioned(
                                                                  right: -5,
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      removeitem(
                                                                        index2,
                                                                      );
                                                                      // _showAlertDialog(index);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          30,
                                                                      width: 30,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .red,
                                                                        borderRadius:
                                                                            BorderRadius.circular(45),
                                                                      ),
                                                                      child:
                                                                          const Center(
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .close,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : const SizedBox
                                                                  .shrink(),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : BlocBuilder<ReadInstructionBloc,
                                          ReadInstructionState>(
                                          builder: (context, state) {
                                            if (state
                                                is ReadInstructionLoadedSuccess) {
                                              return Card(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 4,
                                                ),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          SectionTitle(
                                                            text: AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .translate(
                                                                    'commodity_info'),
                                                          ),
                                                        ],
                                                      ),
                                                      ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        itemCount: widget
                                                            .shipment
                                                            .shipmentItems!
                                                            .length,
                                                        itemBuilder:
                                                            (context, index2) {
                                                          return Stack(
                                                            children: [
                                                              Card(
                                                                color: Colors
                                                                    .grey[50],
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        10.0,
                                                                    vertical:
                                                                        7.5,
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const SizedBox(
                                                                        height:
                                                                            7,
                                                                      ),
                                                                      SectionBody(
                                                                          text:
                                                                              '${AppLocalizations.of(context)!.translate('commodity_name')}: ${state.instruction.commodityItems![index2].commodityName!}'),
                                                                      const SizedBox(
                                                                        height:
                                                                            12,
                                                                      ),
                                                                      // SectionBody(
                                                                      //     text:
                                                                      //         '${AppLocalizations.of(context)!.translate('commodity_package')}: ${localeState.value.languageCode == "en" ? state.instruction.commodityItems![index2].packageName! : state.instruction.commodityItems![index2].packageNameAr!}'),
                                                                      // const SizedBox(
                                                                      //   height:
                                                                      //       12,
                                                                      // ),
                                                                      SectionBody(
                                                                        text:
                                                                            '${AppLocalizations.of(context)!.translate('commodity_weight')}: ${widget.shipment.shipmentItems![index2].commodityWeight!.toString()} ${localeState.value.languageCode == "en" ? "kg" : "كغ"}',
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            12,
                                                                      ),

                                                                      SectionBody(
                                                                        text:
                                                                            '${AppLocalizations.of(context)!.translate('commodity_quantity')}: ${state.instruction.commodityItems![index2].commodityQuantity!.toString()}',
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            12,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              (widget
                                                                          .shipment
                                                                          .shipmentItems!
                                                                          .length >
                                                                      1)
                                                                  ? Positioned(
                                                                      left: localeState.value.languageCode ==
                                                                              "en"
                                                                          ? null
                                                                          : 5,
                                                                      right: localeState.value.languageCode ==
                                                                              "en"
                                                                          ? 5
                                                                          : null,
                                                                      top: 5,
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            30,
                                                                        width:
                                                                            35,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              AppColor.deepYellow,
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            topLeft: localeState.value.languageCode == "en"
                                                                                ? const Radius.circular(5)
                                                                                : const Radius.circular(12),
                                                                            topRight: localeState.value.languageCode == "en"
                                                                                ? const Radius.circular(12)
                                                                                : const Radius.circular(5),
                                                                            bottomLeft:
                                                                                const Radius.circular(5),
                                                                            bottomRight:
                                                                                const Radius.circular(5),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            (index2 + 1).toString(),
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : const SizedBox
                                                                      .shrink(),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Shimmer.fromColors(
                                                baseColor: (Colors.grey[300])!,
                                                highlightColor:
                                                    (Colors.grey[100])!,
                                                enabled: true,
                                                direction: ShimmerDirection.ttb,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemBuilder: (_, __) =>
                                                      Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 15,
                                                            vertical: 5),
                                                        height: 150.h,
                                                        width: double.infinity,
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  itemCount: 1,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                  widget.shipment.shipmentinstructionv2 == null
                                      ? EnsureVisibleWhenFocused(
                                          focusNode: _orderTypenode,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3),
                                            child: Card(
                                              color: Colors.white,
                                              elevation: 2,
                                              child: Padding(
                                                key: key1,
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .translate(
                                                                    'select_your_identity'),
                                                            style: TextStyle(
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: AppColor
                                                                  .darkGrey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Expanded(
                                                          child: Theme(
                                                            data: Theme.of(
                                                                    context)
                                                                .copyWith(
                                                              listTileTheme:
                                                                  const ListTileThemeData(
                                                                horizontalTitleGap:
                                                                    0,
                                                              ),
                                                            ),
                                                            child:
                                                                RadioListTile(
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,

                                                              value: "C",
                                                              groupValue:
                                                                  selectedRadioTile,
                                                              title: FittedBox(
                                                                fit: BoxFit
                                                                    .scaleDown,
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .translate(
                                                                          'charger'),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .fade,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                              ),
                                                              // subtitle: Text("Radio 1 Subtitle"),
                                                              onChanged: (val) {
                                                                // print("Radio Tile pressed $val");
                                                                setState(() {
                                                                  selectedRadioTileError =
                                                                      false;
                                                                  selectedRadioTile =
                                                                      val!;
                                                                });
                                                              },
                                                              activeColor:
                                                                  AppColor
                                                                      .deepYellow,
                                                              selected:
                                                                  selectedRadioTile ==
                                                                      "C",
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: RadioListTile(
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            value: "M",
                                                            groupValue:
                                                                selectedRadioTile,
                                                            title: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'mediator'),
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                            // subtitle: Text("Radio 1 Subtitle"),
                                                            onChanged: (val) {
                                                              // print("Radio Tile pressed $val");
                                                              setState(() {
                                                                selectedRadioTileError =
                                                                    false;
                                                                selectedRadioTile =
                                                                    val!;
                                                              });
                                                            },
                                                            activeColor:
                                                                AppColor
                                                                    .deepYellow,
                                                            selected:
                                                                selectedRadioTile ==
                                                                    "M",
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: RadioListTile(
                                                            contentPadding:
                                                                EdgeInsets.zero,

                                                            value: "R",
                                                            groupValue:
                                                                selectedRadioTile,
                                                            title: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'reciever'),
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                            // subtitle: Text("Radio 2 Subtitle"),
                                                            onChanged: (val) {
                                                              // print("Radio Tile pressed $val");
                                                              setState(() {
                                                                selectedRadioTileError =
                                                                    false;
                                                                selectedRadioTile =
                                                                    val!;
                                                              });
                                                            },
                                                            activeColor:
                                                                AppColor
                                                                    .deepYellow,

                                                            selected:
                                                                selectedRadioTile ==
                                                                    "R",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    selectedRadioTileError
                                                        ? SectionBody(
                                                            text: AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .translate(
                                                                    "select_your_identity_error"),
                                                            color: Colors.red,
                                                          )
                                                        : const SizedBox
                                                            .shrink()
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  widget.shipment.shipmentinstructionv2 == null
                                      ? Visibility(
                                          visible: selectedRadioTile.isNotEmpty,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3),
                                            child: Card(
                                              // key: key1,
                                              color: Colors.white,
                                              elevation: 2,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Form(
                                                  key: _shipperDetailsformKey,
                                                  child: Column(
                                                    children: [
                                                      Visibility(
                                                        visible: (selectedRadioTile
                                                                .isEmpty ||
                                                            selectedRadioTile ==
                                                                "M" ||
                                                            selectedRadioTile ==
                                                                "R"),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .translate(
                                                                          'charger_info'),
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
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 16,
                                                            ),
                                                            TextFormField(
                                                              controller:
                                                                  charger_name_controller,
                                                              onTap: () {
                                                                charger_name_controller
                                                                        .selection =
                                                                    TextSelection(
                                                                        baseOffset:
                                                                            0,
                                                                        extentOffset: charger_name_controller
                                                                            .value
                                                                            .text
                                                                            .length);
                                                              },
                                                              // scrollPadding:
                                                              //     EdgeInsets.only(
                                                              //   bottom: MediaQuery.of(
                                                              //           context)
                                                              //       .viewInsets
                                                              //       .bottom,
                                                              // ),
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .done,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          20),
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText: AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'charger_name'),
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            11.0,
                                                                        horizontal:
                                                                            9.0),
                                                              ),
                                                              onTapOutside:
                                                                  (event) {
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();
                                                              },
                                                              onEditingComplete:
                                                                  () {
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();

                                                                // evaluatePrice();
                                                              },
                                                              onChanged:
                                                                  (value) {},
                                                              autovalidateMode:
                                                                  AutovalidateMode
                                                                      .onUserInteraction,
                                                              validator:
                                                                  (value) {
                                                                if (value!
                                                                    .isEmpty) {
                                                                  return AppLocalizations.of(
                                                                          context)!
                                                                      .translate(
                                                                          'insert_value_validate');
                                                                }
                                                                return null;
                                                              },
                                                              onSaved:
                                                                  (newValue) {
                                                                charger_name_controller
                                                                        .text =
                                                                    newValue!;
                                                              },
                                                              onFieldSubmitted:
                                                                  (value) {},
                                                            ),
                                                            const SizedBox(
                                                              height: 16,
                                                            ),
                                                            // TextFormField(
                                                            //   controller:
                                                            //       charger_address_controller,
                                                            //   onTap: () {
                                                            //     charger_address_controller
                                                            //             .selection =
                                                            //         TextSelection(
                                                            //             baseOffset:
                                                            //                 0,
                                                            //             extentOffset: charger_address_controller
                                                            //                 .value
                                                            //                 .text
                                                            //                 .length);
                                                            //   },
                                                            //   textInputAction:
                                                            //       TextInputAction
                                                            //           .done,
                                                            //   style:
                                                            //       const TextStyle(
                                                            //           fontSize:
                                                            //               18),
                                                            //   decoration:
                                                            //       InputDecoration(
                                                            //     labelText: AppLocalizations.of(
                                                            //             context)!
                                                            //         .translate(
                                                            //             'charger_address'),
                                                            //     contentPadding:
                                                            //         const EdgeInsets
                                                            //             .symmetric(
                                                            //             vertical:
                                                            //                 11.0,
                                                            //             horizontal:
                                                            //                 9.0),
                                                            //   ),
                                                            //   onTapOutside:
                                                            //       (event) {
                                                            //     FocusManager
                                                            //         .instance
                                                            //         .primaryFocus
                                                            //         ?.unfocus();
                                                            //     // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                                                            //   },
                                                            //   onEditingComplete:
                                                            //       () {
                                                            //     FocusManager
                                                            //         .instance
                                                            //         .primaryFocus
                                                            //         ?.unfocus();

                                                            //     // evaluatePrice();
                                                            //   },
                                                            //   onChanged:
                                                            //       (value) {},
                                                            //   autovalidateMode:
                                                            //       AutovalidateMode
                                                            //           .onUserInteraction,
                                                            //   validator:
                                                            //       (value) {
                                                            //     if (value!
                                                            //         .isEmpty) {
                                                            //       return AppLocalizations.of(
                                                            //               context)!
                                                            //           .translate(
                                                            //               'insert_value_validate');
                                                            //     }
                                                            //     return null;
                                                            //   },
                                                            //   onSaved:
                                                            //       (newValue) {
                                                            //     // commodityWeight_controller.text = newValue!;
                                                            //   },
                                                            //   onFieldSubmitted:
                                                            //       (value) {
                                                            //     // FocusManager.instance.primaryFocus?.unfocus();
                                                            //     // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                                                            //   },
                                                            // ),
                                                            // const SizedBox(
                                                            //   height: 16,
                                                            // ),
                                                            TextFormField(
                                                              controller:
                                                                  charger_phone_controller,
                                                              onTap: () {
                                                                charger_phone_controller
                                                                        .selection =
                                                                    TextSelection(
                                                                        baseOffset:
                                                                            0,
                                                                        extentOffset: charger_phone_controller
                                                                            .value
                                                                            .text
                                                                            .length);
                                                              },
                                                              // enabled: instructionProvider.subShipment!
                                                              //         .shipmentinstructionv2 ==
                                                              //     null,
                                                              // scrollPadding: EdgeInsets.only(
                                                              //     bottom: MediaQuery.of(
                                                              //                 context)
                                                              //             .viewInsets
                                                              //             .bottom +
                                                              //         20),
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .done,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .phone,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          18),
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText: AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'charger_phone'),
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            11.0,
                                                                        horizontal:
                                                                            9.0),
                                                              ),
                                                              onTapOutside:
                                                                  (event) {
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();
                                                                // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                                                              },
                                                              onEditingComplete:
                                                                  () {
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();

                                                                // evaluatePrice();
                                                              },
                                                              onChanged:
                                                                  (value) {},
                                                              autovalidateMode:
                                                                  AutovalidateMode
                                                                      .onUserInteraction,
                                                              validator:
                                                                  (value) {
                                                                if (value!
                                                                    .isEmpty) {
                                                                  return AppLocalizations.of(
                                                                          context)!
                                                                      .translate(
                                                                          'insert_value_validate');
                                                                }
                                                                return null;
                                                              },
                                                              onSaved:
                                                                  (newValue) {
                                                                // commodityWeight_controller.text = newValue!;
                                                              },
                                                              onFieldSubmitted:
                                                                  (value) {
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
                                                        visible: (selectedRadioTile
                                                                .isEmpty ||
                                                            selectedRadioTile ==
                                                                "M" ||
                                                            selectedRadioTile ==
                                                                "C"),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .translate(
                                                                            'reciever_info'),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: AppColor
                                                                          .darkGrey,
                                                                    )),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 16,
                                                            ),
                                                            TextFormField(
                                                              controller:
                                                                  reciever_name_controller,
                                                              onTap: () {
                                                                reciever_name_controller
                                                                        .selection =
                                                                    TextSelection(
                                                                        baseOffset:
                                                                            0,
                                                                        extentOffset: reciever_name_controller
                                                                            .value
                                                                            .text
                                                                            .length);
                                                              },
                                                              // enabled: instructionProvider.subShipment!
                                                              //         .shipmentinstructionv2 ==
                                                              //     null,
                                                              // scrollPadding: EdgeInsets.only(
                                                              //     bottom: MediaQuery.of(
                                                              //                 context)
                                                              //             .viewInsets
                                                              //             .bottom +
                                                              //         20),
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .done,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          18),
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText: AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'reciever_name'),
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            11.0,
                                                                        horizontal:
                                                                            9.0),
                                                              ),
                                                              onTapOutside:
                                                                  (event) {
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();
                                                              },
                                                              onEditingComplete:
                                                                  () {
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();

                                                                // evaluatePrice();
                                                              },
                                                              onChanged:
                                                                  (value) {},
                                                              autovalidateMode:
                                                                  AutovalidateMode
                                                                      .onUserInteraction,
                                                              validator:
                                                                  (value) {
                                                                if (value!
                                                                    .isEmpty) {
                                                                  return AppLocalizations.of(
                                                                          context)!
                                                                      .translate(
                                                                          'insert_value_validate');
                                                                }
                                                                return null;
                                                              },
                                                              onSaved:
                                                                  (newValue) {
                                                                reciever_name_controller
                                                                        .text =
                                                                    newValue!;
                                                              },
                                                              // onFieldSubmitted: (value) {},
                                                            ),
                                                            const SizedBox(
                                                              height: 16,
                                                            ),
                                                            TextFormField(
                                                              controller:
                                                                  reciever_phone_controller,
                                                              onTap: () {
                                                                reciever_phone_controller
                                                                        .selection =
                                                                    TextSelection(
                                                                        baseOffset:
                                                                            0,
                                                                        extentOffset: reciever_phone_controller
                                                                            .value
                                                                            .text
                                                                            .length);
                                                              },

                                                              textInputAction:
                                                                  TextInputAction
                                                                      .done,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .phone,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          18),
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText: AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'reciever_phone'),
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            11.0,
                                                                        horizontal:
                                                                            9.0),
                                                              ),
                                                              onTapOutside:
                                                                  (event) {
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();
                                                                // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                                                              },
                                                              onEditingComplete:
                                                                  () {
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();

                                                                // evaluatePrice();
                                                              },
                                                              onChanged:
                                                                  (value) {},
                                                              autovalidateMode:
                                                                  AutovalidateMode
                                                                      .onUserInteraction,
                                                              validator:
                                                                  (value) {
                                                                if (value!
                                                                    .isEmpty) {
                                                                  return AppLocalizations.of(
                                                                          context)!
                                                                      .translate(
                                                                          'insert_value_validate');
                                                                }
                                                                return null;
                                                              },
                                                              onSaved:
                                                                  (newValue) {
                                                                reciever_phone_controller
                                                                        .text =
                                                                    newValue!;
                                                              },
                                                              // onFieldSubmitted: (value) {
                                                              //   // FocusManager.instance.primaryFocus?.unfocus();
                                                              //   // BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                                                              // },
                                                            ),
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
                                          ),
                                        )
                                      : BlocBuilder<ReadInstructionBloc,
                                          ReadInstructionState>(
                                          builder: (context, state) {
                                            if (state
                                                is ReadInstructionLoadedSuccess) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 4,
                                                ),
                                                child: Card(
                                                  elevation: 2,
                                                  color: Colors.white,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Column(
                                                      children: [
                                                        Visibility(
                                                          visible: state
                                                              .instruction
                                                              .chargerName!
                                                              .isNotEmpty,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SectionTitle(
                                                                    text: AppLocalizations.of(
                                                                            context)!
                                                                        .translate(
                                                                            'charger_info'),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              SectionBody(
                                                                text:
                                                                    '${AppLocalizations.of(context)!.translate('charger_name')}: ${state.instruction.chargerName!}',
                                                              ),
                                                              const SizedBox(
                                                                height: 8,
                                                              ),
                                                              // SectionBody(
                                                              //   text:
                                                              //       '${AppLocalizations.of(context)!.translate('charger_address')}: ${state.instruction.chargerAddress!}',
                                                              // ),
                                                              // const SizedBox(
                                                              //   height: 8,
                                                              // ),
                                                              SectionBody(
                                                                text:
                                                                    '${AppLocalizations.of(context)!.translate('charger_phone')}: ${state.instruction.chargerPhone!}',
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
                                                              .instruction
                                                              .recieverName!
                                                              .isNotEmpty,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SectionTitle(
                                                                    text: AppLocalizations.of(
                                                                            context)!
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
                                                                    '${AppLocalizations.of(context)!.translate('reciever_name')}: ${state.instruction.recieverName!}',
                                                              ),
                                                              const SizedBox(
                                                                height: 8,
                                                              ),
                                                              // SectionBody(
                                                              //   text:
                                                              //       '${AppLocalizations.of(context)!.translate('reciever_address')}: ${state.instruction.recieverAddress!}',
                                                              // ),
                                                              // const SizedBox(
                                                              //   height: 8,
                                                              // ),
                                                              SectionBody(
                                                                text:
                                                                    '${AppLocalizations.of(context)!.translate('reciever_phone')}: ${state.instruction.recieverPhone!}',
                                                              ),
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
                                              );
                                            } else {
                                              return Shimmer.fromColors(
                                                baseColor: (Colors.grey[300])!,
                                                highlightColor:
                                                    (Colors.grey[100])!,
                                                enabled: true,
                                                direction: ShimmerDirection.ttb,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemBuilder: (_, __) =>
                                                      Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 15,
                                                            vertical: 5),
                                                        height: 150.h,
                                                        width: double.infinity,
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  itemCount: 1,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                  widget.shipment.shipmentinstructionv2 == null
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3),
                                          child: Card(
                                            key: key3,
                                            color: Colors.white,
                                            elevation: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Form(
                                                key: _weightInfoformKey,
                                                child: Column(
                                                  children: [
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          SectionTitle(
                                                            text: AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .translate(
                                                                    'weight_info'),
                                                          ),
                                                        ]),
                                                    const SizedBox(height: 16),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: TextFormField(
                                                            controller:
                                                                truck_weight_controller,
                                                            onTap: () {
                                                              truck_weight_controller
                                                                      .selection =
                                                                  TextSelection(
                                                                      baseOffset:
                                                                          0,
                                                                      extentOffset: truck_weight_controller
                                                                          .value
                                                                          .text
                                                                          .length);
                                                            },
                                                            textInputAction:
                                                                TextInputAction
                                                                    .done,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: [
                                                              DecimalFormatter(),
                                                            ],
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        18),
                                                            decoration:
                                                                InputDecoration(
                                                              labelText: AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .translate(
                                                                      'first_weight'),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          11.0,
                                                                      horizontal:
                                                                          9.0),
                                                              suffix: Text(
                                                                localeState.value
                                                                            .languageCode ==
                                                                        "en"
                                                                    ? "kg"
                                                                    : "كغ",
                                                              ),
                                                              suffixStyle:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                            onTapOutside:
                                                                (event) {
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                            },
                                                            onEditingComplete:
                                                                () {
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();

                                                              // evaluatePrice();
                                                            },
                                                            onChanged: (value) {
                                                              if (net_weight_controller
                                                                  .text
                                                                  .isNotEmpty) {
                                                                final_weight_controller
                                                                    .text = (double.parse(net_weight_controller.text.replaceAll(
                                                                            ",",
                                                                            "")) -
                                                                        double.parse(truck_weight_controller.text.replaceAll(
                                                                            ",",
                                                                            "")))
                                                                    .abs()
                                                                    .toString();
                                                              }
                                                            },
                                                            autovalidateMode:
                                                                AutovalidateMode
                                                                    .onUserInteraction,
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'insert_value_validate');
                                                              }
                                                              return null;
                                                            },
                                                            onSaved:
                                                                (newValue) {
                                                              truck_weight_controller
                                                                      .text =
                                                                  newValue!;
                                                            },
                                                            onFieldSubmitted:
                                                                (value) {},
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                          child: TextFormField(
                                                            controller:
                                                                net_weight_controller,
                                                            onTap: () {
                                                              net_weight_controller
                                                                      .selection =
                                                                  TextSelection(
                                                                baseOffset: 0,
                                                                extentOffset:
                                                                    net_weight_controller
                                                                        .value
                                                                        .text
                                                                        .length,
                                                              );
                                                            },
                                                            textInputAction:
                                                                TextInputAction
                                                                    .done,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: [
                                                              DecimalFormatter(),
                                                            ],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                            ),
                                                            decoration:
                                                                InputDecoration(
                                                              labelText: AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .translate(
                                                                      'second_weight'),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          11.0,
                                                                      horizontal:
                                                                          9.0),
                                                              suffix: Text(
                                                                localeState.value
                                                                            .languageCode ==
                                                                        "en"
                                                                    ? "kg"
                                                                    : "كغ",
                                                              ),
                                                              suffixStyle:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                            onTapOutside:
                                                                (event) {
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                            },
                                                            onEditingComplete:
                                                                () {
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();

                                                              // evaluatePrice();
                                                            },
                                                            onChanged: (value) {
                                                              if (truck_weight_controller
                                                                  .text
                                                                  .isNotEmpty) {
                                                                final_weight_controller
                                                                    .text = (double.parse(net_weight_controller.text.replaceAll(
                                                                            ",",
                                                                            "")) -
                                                                        double.parse(truck_weight_controller.text.replaceAll(
                                                                            ",",
                                                                            "")))
                                                                    .abs()
                                                                    .toString();
                                                              }
                                                            },
                                                            autovalidateMode:
                                                                AutovalidateMode
                                                                    .onUserInteraction,
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'insert_value_validate');
                                                              }
                                                              return null;
                                                            },
                                                            onSaved:
                                                                (newValue) {
                                                              net_weight_controller
                                                                      .text =
                                                                  newValue!;
                                                            },
                                                            onFieldSubmitted:
                                                                (value) {},
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 16,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SectionTitle(
                                                            text:
                                                                '${AppLocalizations.of(context)!.translate('commodity_gross_weight')}: ${final_weight_controller.text.isEmpty ? '----' : final_weight_controller.text} ${localeState.value.languageCode == "en" ? "kg" : "كغ"}'),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : BlocBuilder<ReadInstructionBloc,
                                          ReadInstructionState>(
                                          builder: (context, state) {
                                            if (state
                                                is ReadInstructionLoadedSuccess) {
                                              return Card(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                color: Colors.white,
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SectionTitle(
                                                              text: AppLocalizations
                                                                      .of(
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
                                                                '${AppLocalizations.of(context)!.translate('first_weight')}: ${state.instruction.truckWeight!.toString()} ${localeState.value.languageCode == "en" ? "kg" : "كغ"}'),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        SectionBody(
                                                            text:
                                                                '${AppLocalizations.of(context)!.translate('second_weight')}: ${state.instruction.netWeight!.toString()} ${localeState.value.languageCode == "en" ? "kg" : "كغ"}'),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        SectionBody(
                                                            text:
                                                                '${AppLocalizations.of(context)!.translate('commodity_gross_weight')}: ${state.instruction.finalWeight!.toString()} ${localeState.value.languageCode == "en" ? "kg" : "كغ"}'),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Shimmer.fromColors(
                                                baseColor: (Colors.grey[300])!,
                                                highlightColor:
                                                    (Colors.grey[100])!,
                                                enabled: true,
                                                direction: ShimmerDirection.ttb,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemBuilder: (_, __) =>
                                                      Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 15,
                                                            vertical: 5),
                                                        height: 150.h,
                                                        width: double.infinity,
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  itemCount: 1,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                  widget.shipment.shipmentinstructionv2 == null
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3),
                                          child: Card(
                                            color: Colors.white,
                                            elevation: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SectionTitle(
                                                        text: AppLocalizations
                                                                .of(context)!
                                                            .translate(
                                                                'upload_files'),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 16),
                                                  CustomButton(
                                                    title: const Icon(
                                                      Icons
                                                          .cloud_upload_outlined,
                                                      size: 35,
                                                    ),
                                                    onTap: () async {
                                                      var pickedImages =
                                                          await _picker
                                                              .pickMultiImage();
                                                      for (var element
                                                          in pickedImages) {
                                                        _files.add(
                                                            File(element.path));
                                                      }
                                                      setState(
                                                        () {},
                                                      );
                                                    },
                                                    color: Colors.grey[200],
                                                    bordercolor:
                                                        Colors.grey[400],
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Wrap(
                                                    alignment:
                                                        WrapAlignment.start,
                                                    children:
                                                        _buildAttachmentImages(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : BlocBuilder<ReadInstructionBloc,
                                          ReadInstructionState>(
                                          builder: (context, state) {
                                            if (state
                                                is ReadInstructionLoadedSuccess) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3),
                                                child: Card(
                                                  color: Colors.white,
                                                  elevation: 2,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SectionTitle(
                                                              text: AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .translate(
                                                                      'files'),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        Wrap(
                                                          alignment:
                                                              WrapAlignment
                                                                  .start,
                                                          children:
                                                              _buildFilesImages(
                                                                  state
                                                                      .instruction
                                                                      .docs!),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Shimmer.fromColors(
                                                baseColor: (Colors.grey[300])!,
                                                highlightColor:
                                                    (Colors.grey[100])!,
                                                enabled: true,
                                                direction: ShimmerDirection.ttb,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemBuilder: (_, __) =>
                                                      Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 15,
                                                            vertical: 5),
                                                        height: 150.h,
                                                        width: double.infinity,
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  itemCount: 1,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                  widget.shipment.shipmentinstructionv2 == null
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Consumer<TaskNumProvider>(
                                              builder: (context, taskProvider,
                                                  child) {
                                            return BlocConsumer<
                                                InstructionCreateBloc,
                                                InstructionCreateState>(
                                              listener: (context, state) {
                                                taskProvider.decreaseTaskNum();

                                                if (state
                                                    is InstructionCreateSuccessState) {
                                                  print(state.shipment);
                                                  // instructionProvider.addInstruction(state.shipment);
                                                  BlocProvider.of<
                                                              ReadInstructionBloc>(
                                                          context)
                                                      .add(
                                                          ReadInstructionLoadEvent(
                                                              state.shipment
                                                                  .id!));
                                                  showCustomSnackBar(
                                                    context: context,
                                                    backgroundColor:
                                                        AppColor.deepGreen,
                                                    message: localeState.value
                                                                .languageCode ==
                                                            'en'
                                                        ? 'Instructions Submitted.'
                                                        : 'تم إدخال التعليمات.',
                                                  );

                                                  Navigator.pop(context);
                                                  BlocProvider.of<
                                                              ShipmentTaskListBloc>(
                                                          context)
                                                      .add(
                                                          ShipmentTaskListLoadEvent());
                                                }
                                                if (state
                                                    is InstructionCreateFailureState) {
                                                  print(state.errorMessage);
                                                }
                                              },
                                              builder: (context, state) {
                                                if (state
                                                    is InstructionLoadingProgressState) {
                                                  return CustomButton(
                                                    title: LoadingIndicator(),
                                                    onTap: () {},
                                                  );
                                                } else {
                                                  return CustomButton(
                                                    title: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .translate(
                                                              'add_instruction'),
                                                      style: TextStyle(
                                                        fontSize: 20.sp,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();

                                                      if (selectedRadioTile
                                                          .isNotEmpty) {
                                                        if (_shipperDetailsformKey
                                                            .currentState!
                                                            .validate()) {
                                                          _shipperDetailsformKey
                                                              .currentState
                                                              ?.save();
                                                          if (_commodityInfoformKey
                                                              .currentState!
                                                              .validate()) {
                                                            _commodityInfoformKey
                                                                .currentState
                                                                ?.save();
                                                            if (_weightInfoformKey
                                                                .currentState!
                                                                .validate()) {
                                                              _weightInfoformKey
                                                                  .currentState!
                                                                  .save();
                                                              Shipmentinstruction
                                                                  shipmentInstruction =
                                                                  Shipmentinstruction();
                                                              shipmentInstruction
                                                                      .shipment =
                                                                  widget
                                                                      .shipment
                                                                      .id!;
                                                              shipmentInstruction
                                                                      .userType =
                                                                  selectedRadioTile;
                                                              shipmentInstruction
                                                                      .chargerName =
                                                                  charger_name_controller
                                                                      .text;
                                                              // shipmentInstruction
                                                              //         .chargerAddress =
                                                              //     charger_address_controller
                                                              //         .text;
                                                              shipmentInstruction
                                                                      .chargerPhone =
                                                                  charger_phone_controller
                                                                      .text;
                                                              shipmentInstruction
                                                                      .recieverName =
                                                                  reciever_name_controller
                                                                      .text;
                                                              // shipmentInstruction
                                                              //         .recieverAddress =
                                                              //     reciever_address_controller
                                                              //         .text;
                                                              shipmentInstruction
                                                                      .recieverPhone =
                                                                  reciever_phone_controller
                                                                      .text;
                                                              shipmentInstruction
                                                                      .netWeight =
                                                                  double.parse(net_weight_controller
                                                                          .text
                                                                          .replaceAll(
                                                                              ",",
                                                                              ""))
                                                                      .toInt();
                                                              shipmentInstruction
                                                                      .truckWeight =
                                                                  double.parse(truck_weight_controller
                                                                          .text
                                                                          .replaceAll(
                                                                              ",",
                                                                              ""))
                                                                      .toInt();
                                                              shipmentInstruction
                                                                      .finalWeight =
                                                                  double.parse(final_weight_controller
                                                                          .text
                                                                          .replaceAll(
                                                                              ",",
                                                                              ""))
                                                                      .toInt();

                                                              List<CommodityItems>
                                                                  items = [];
                                                              for (var i = 0;
                                                                  i <
                                                                      commodityWeight_controller
                                                                          .length;
                                                                  i++) {
                                                                CommodityItems
                                                                    item =
                                                                    CommodityItems(
                                                                  commodityName:
                                                                      commodityName_controller[
                                                                              i]
                                                                          .text,
                                                                  commodityQuantity:
                                                                      int.parse(
                                                                    commodityQuantity_controller[
                                                                            i]
                                                                        .text
                                                                        .replaceAll(
                                                                            ",",
                                                                            ""),
                                                                  ),
                                                                  commodityWeight:
                                                                      double
                                                                          .parse(
                                                                    commodityWeight_controller[
                                                                            i]
                                                                        .text
                                                                        .replaceAll(
                                                                            ",",
                                                                            ""),
                                                                  ).toInt(),
                                                                  // packageType:
                                                                  //     packageType_controller[i]!
                                                                  //         .id!,
                                                                );
                                                                items.add(item);
                                                              }
                                                              print("asd");
                                                              shipmentInstruction
                                                                      .commodityItems =
                                                                  items;

                                                              BlocProvider.of<
                                                                          InstructionCreateBloc>(
                                                                      context)
                                                                  .add(
                                                                InstructionCreateButtonPressed(
                                                                    shipmentInstruction,
                                                                    _files),
                                                              );
                                                            } else {
                                                              Scrollable
                                                                  .ensureVisible(
                                                                key3.currentContext!,
                                                                duration:
                                                                    const Duration(
                                                                  milliseconds:
                                                                      500,
                                                                ),
                                                              );
                                                            }
                                                          } else {
                                                            Scrollable
                                                                .ensureVisible(
                                                              key2.currentContext!,
                                                              duration:
                                                                  const Duration(
                                                                milliseconds:
                                                                    500,
                                                              ),
                                                            );
                                                          }
                                                        } else {
                                                          Scrollable
                                                              .ensureVisible(
                                                            key1.currentContext!,
                                                            duration:
                                                                const Duration(
                                                              milliseconds: 500,
                                                            ),
                                                          );
                                                        }
                                                      } else {
                                                        setState(() {
                                                          selectedRadioTileError =
                                                              true;
                                                        });
                                                        Scrollable
                                                            .ensureVisible(
                                                          key1.currentContext!,
                                                          duration:
                                                              const Duration(
                                                            milliseconds: 500,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  );
                                                }
                                              },
                                            );
                                          }),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            )
                          : ShipmentPaymentScreen(
                              shipment: widget.shipment,
                              subshipmentIndex: selectedIndex,
                            ),
                    ],
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
