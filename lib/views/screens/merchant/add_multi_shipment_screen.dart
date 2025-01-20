import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/core/draw_route_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_type_bloc.dart';
import 'package:camion/business_logic/bloc/truck/trucks_list_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/providers/add_multi_shipment_provider.dart';
import 'package:camion/data/services/places_service.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/formatter.dart';
import 'package:camion/views/screens/merchant/add_multishipment_map_picker.dart';
import 'package:camion/views/screens/merchant/add_path_screen.dart';
import 'package:camion/views/screens/merchant/search_for_trucks_screen.dart';
import 'package:camion/views/widgets/add_shipment_vertical_path_widget.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/path_statistics_widget.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_subtitle_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/snackbar_widget.dart';
import 'package:ensure_visible_when_focused/ensure_visible_when_focused.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' as intel;
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, rootBundle;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart' as cupertino;

class AddMultiShipmentScreen extends StatefulWidget {
  const AddMultiShipmentScreen({Key? key}) : super(key: key);

  @override
  State<AddMultiShipmentScreen> createState() => _AddMultiShipmentScreenState();
}

class _AddMultiShipmentScreenState extends State<AddMultiShipmentScreen>
    with SingleTickerProviderStateMixin {
  // final ScrollController _scrollController = ScrollController();
  TabController? _tabController;
  final List<Tab> _tabs = [
    const Tab(text: 'Tab 1'),
    const Tab(icon: Icon(Icons.add))
  ];

  final FocusNode _nodeCommodityName = FocusNode();
  final FocusNode _nodeCommodityWeight = FocusNode();

  final FocusNode _commodity_node = FocusNode();
  final FocusNode _truck_node = FocusNode();
  final FocusNode _path_node = FocusNode();

  // List<bool> co2Loading = [false];
  // List<bool> co2error = [false];

  var key1 = GlobalKey();
  var key2 = GlobalKey();
  var key3 = GlobalKey();

  final ScrollController _scrollController = ScrollController();
  // int mapIndex = 0;
  int truckIndex = 0;

  String _mapStyle = "";

  BitmapDescriptor? pickupicon;
  late BitmapDescriptor deliveryicon;
  late BitmapDescriptor stopicon;

  createMarkerIcons() async {
    pickupicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location1.png");
    deliveryicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location2.png");
    stopicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/locationP.png");
    setState(() {});
  }

  var f = intel.NumberFormat("#,###", "en_US");

  _showDatePicker(String lang) {
    cupertino.showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border:
                Border(top: BorderSide(color: AppColor.deepYellow, width: 2))),
        height: MediaQuery.of(context).size.height * .4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
                onPressed: () {
                  addShippmentProvider!.setLoadDate(
                      addShippmentProvider!.loadDate[selectedIndex],
                      lang,
                      selectedIndex);
                  addShippmentProvider!.setDateError(false, selectedIndex);

                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.translate('ok'),
                  style: TextStyle(
                    color: AppColor.darkGrey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            Expanded(
              child: Localizations(
                locale: const Locale('en', ''),
                delegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                child: cupertino.CupertinoDatePicker(
                  backgroundColor: Colors.white10,
                  initialDateTime:
                      addShippmentProvider!.loadDate[selectedIndex],
                  mode: cupertino.CupertinoDatePickerMode.date,
                  minimumYear: DateTime.now().year,
                  minimumDate: DateTime.now().subtract(const Duration(days: 1)),
                  maximumYear: DateTime.now().year + 1,
                  onDateTimeChanged: (value) {
                    // loadDate = value;
                    addShippmentProvider!
                        .setLoadDate(value, lang, selectedIndex);
                    addShippmentProvider!.setDateError(false, selectedIndex);
                    // order_brokerProvider!.setProductDate(value);
                    // order_brokerProvider!.setDateError(false);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showTimePicker() {
    cupertino.showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColor.deepYellow, width: 2),
          ),
        ),
        height: MediaQuery.of(context).size.height * .4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
                onPressed: () {
                  addShippmentProvider!.setLoadTime(
                      addShippmentProvider!.loadTime[selectedIndex],
                      selectedIndex);
                  addShippmentProvider!.setDateError(false, selectedIndex);

                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.translate('ok'),
                  style: TextStyle(
                    color: AppColor.darkGrey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            Expanded(
              child: Localizations(
                locale: const Locale('en', ''),
                delegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                child: cupertino.CupertinoDatePicker(
                  backgroundColor: Colors.white10,
                  initialDateTime:
                      addShippmentProvider!.loadTime[selectedIndex],
                  mode: cupertino.CupertinoDatePickerMode.time,
                  // minimumDate: DateTime.now(),
                  onDateTimeChanged: (value) {
                    // loadTime = value;
                    addShippmentProvider!.setLoadTime(value, selectedIndex);
                    addShippmentProvider!.setDateError(false, selectedIndex);
                    // order_brokerProvider!.setProductDate(value);
                    // order_brokerProvider!.setDateError(false);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int selectedIndex = 0;

  Widget pathList(AddMultiShipmentProvider provider, BuildContext pathcontext) {
    return Container(
      height: 60.h,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: AppColor.lightYellow,
          ),
        ),
      ),
      child: Row(
        children: [
          ListView.builder(
            itemCount: provider.countpath,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                  provider.initMapbounds();
                },
                child: Container(
                  // width: 130.w,
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.symmetric(
                    // vertical: 5,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    // color: selectedIndex == index
                    //     ? AppColor.deepYellow
                    //     : Colors.grey[400],
                    // borderRadius: BorderRadius.circular(8),
                    border: selectedIndex == index
                        ? Border(
                            bottom: BorderSide(
                              width: 2,
                              color: AppColor.deepYellow,
                            ),
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      "${AppLocalizations.of(context)!.translate("truck")} ${index + 1}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkGrey200,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  print("asd");
                  if (provider.pickup_location.isNotEmpty ||
                      provider.delivery_location.isNotEmpty) {
                    if (provider.addShipmentformKey[selectedIndex].currentState!
                        .validate()) {
                      if (provider
                              .time_controller[selectedIndex].text.isNotEmpty &&
                          provider
                              .date_controller[selectedIndex].text.isNotEmpty) {
                        if (provider.selectedTruckType[selectedIndex] != null) {
                          provider.setTruckConfirm(false, selectedIndex);
                          provider.addpath();
                          setState(() {
                            selectedIndex++;
                          });
                        } else {
                          showCustomSnackBar(
                            context: context,
                            backgroundColor: Colors.red[300]!,
                            message: AppLocalizations.of(context)!
                                .translate('shipment_load_complete_error'),
                          );
                          provider.setTruckTypeError(true);
                          provider.setTruckConfirm(true, selectedIndex);
                        }
                      } else {
                        showCustomSnackBar(
                          context: context,
                          backgroundColor: Colors.red[300]!,
                          message: AppLocalizations.of(context)!
                              .translate('shipment_load_complete_error'),
                        );
                        provider.setDateError(true, selectedIndex);
                      }
                    } else {
                      showCustomSnackBar(
                        context: context,
                        backgroundColor: Colors.red[300]!,
                        message: AppLocalizations.of(context)!
                            .translate('shipment_load_complete_error'),
                      );
                      provider.setTruckConfirm(true, selectedIndex);
                    }
                  } else {
                    showCustomSnackBar(
                      context: context,
                      backgroundColor: Colors.red[300]!,
                      message: AppLocalizations.of(context)!
                          .translate('shipment_load_complete_error'),
                    );
                    provider.setPathError(
                      true,
                    );
                    Scrollable.ensureVisible(
                      key1.currentContext!,
                      duration: const Duration(
                        milliseconds: 500,
                      ),
                    );
                    provider.setTruckConfirm(true, selectedIndex);
                  }
                },
                child: Row(
                  children: [
                    // Text(
                    //   AppLocalizations.of(context)!.translate('add_truck'),
                    //   style: TextStyle(
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.bold,
                    //     color: AppColor.deepYellow,
                    //   ),
                    // ),
                    AbsorbPointer(
                      absorbing: true,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.add_circle_outline_outlined,
                          color: AppColor.deepYellow,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget pathList(AddMultiShipmentProvider provider, BuildContext pathcontext) {
  //   return TabBar(
  //     controller: _tabController,
  //     isScrollable: true,
  //     tabs: [
  //       ..._tabs,
  //     ],
  //     onTap: (index) {
  //       print(_tabController!.length);
  //       print(index);
  //       if (index == _tabs.length) {
  //         if (provider.pickup_location[selectedIndex].isNotEmpty ||
  //             provider.delivery_location[selectedIndex].isNotEmpty) {
  //           if (provider.selectedTruckType[selectedIndex] != null) {
  //             if (provider.addShipmentformKey[selectedIndex].currentState!
  //                 .validate()) {
  //               provider.setTruckConfirm(false, selectedIndex);
  //               provider.addpath();
  //               setState(() {
  //                 int newTabIndex = _tabs.length + 1;
  //                 _tabs.insert(_tabs.length - 1, Tab(text: 'Tab $newTabIndex'));
  //                 _tabController =
  //                     TabController(length: _tabs.length, vsync: this);
  //                 selectedIndex++;
  //               });
  //             } else {
  //               provider.setTruckConfirm(true, selectedIndex);
  //             }
  //           } else {
  //             provider.setTruckConfirm(true, selectedIndex);
  //           }
  //         } else {
  //           provider.setPathError(
  //             true,
  //           );
  //           provider.setTruckConfirm(true, selectedIndex);
  //         }
  //       } else {
  //         setState(() {
  //           selectedIndex = index;
  //         });
  //         provider.initMapbounds();
  //       }
  //     },
  //   );
  // }

  Widget selectedTruckTypesList(AddMultiShipmentProvider provider,
      BuildContext pathcontext, String lang) {
    return provider.selectedTruckType.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            height: 105.h,
            child: ListView.builder(
              itemCount: provider.selectedTruckType.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  // width: 130.w,
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppColor.deepYellow,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 45.h,
                        width: 155.w,
                        child: CachedNetworkImage(
                          imageUrl: provider.selectedTruckType[index]!.image!,
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
                      SizedBox(
                        height: 4.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SectionBody(
                            text: lang == "en"
                                ? provider.selectedTruckType[index]!.name!
                                : provider.selectedTruckType[index]!.nameAr!,
                          ),
                          SectionBody(
                            text:
                                "${lang == "en" ? "Num:" : "عدد:"} ${provider.selectedTruckTypeNum[index]}",
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      addShippmentProvider =
          Provider.of<AddMultiShipmentProvider>(context, listen: false);

      createMarkerIcons();
    });

    rootBundle.loadString('assets/style/normal_style.json').then((string) {
      _mapStyle = string;
    });
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  List<LatLng> deserializeLatLng(String jsonString) {
    List<dynamic> coordinates = json.decode(jsonString);
    List<LatLng> latLngList = [];
    for (var coord in coordinates) {
      latLngList.add(LatLng(coord[0], coord[1]));
    }
    return latLngList;
  }

  AddMultiShipmentProvider? addShippmentProvider;

  showShipmentPathModalSheet(BuildContext context, String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      builder: (context) => Consumer<AddMultiShipmentProvider>(
        builder: (context, valueProvider, child) {
          return Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16.0),
            constraints:
                BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            width: double.infinity,
            child: ListView(
              // shrinkWrap: true,
              // physics: NeverScrollableScrollPhysics(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Spacer(),
                    SectionTitle(
                      text: AppLocalizations.of(context)!
                          .translate('choose_shippment_path'),
                      size: 20,
                    ),
                    const Spacer(),
                    const SizedBox(
                      width: 25,
                    ),
                  ],
                ),
                SizedBox(
                  height: 8.h,
                ),
                SectionTitle(
                  text:
                      AppLocalizations.of(context)!.translate('pickup_address'),
                ),
                SizedBox(
                  height: 8.h,
                ),
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    // autofocus: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: valueProvider.pickup_controller,
                    scrollPadding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 150),
                    onTap: () {
                      valueProvider.pickup_controller.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: valueProvider
                              .pickup_controller.value.text.length);
                    },
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!
                          .translate('enter_pickup_address'),
                      // labelText:
                      //     AppLocalizations.of(context)!.translate('pickup_address'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 9.0,
                        vertical: 11.0,
                      ),
                      prefixIcon: valueProvider.pickuptextLoading
                          ? SizedBox(
                              height: 25,
                              width: 25,
                              child: LoadingIndicator(),
                            )
                          : null,
                      suffixIcon: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MultiShippmentPickUpMapScreen(
                                type: 0,
                                location: valueProvider.pickup_latlng,
                              ),
                            ),
                          ).then((value) =>
                              FocusManager.instance.primaryFocus?.unfocus());
                          Future.delayed(const Duration(milliseconds: 1500))
                              .then((value) {
                            // if (evaluateCo2()) {
                            //   calculateCo2Report();
                            // }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(7),
                          width: 55.0,
                          height: 15.0,
                          child: Icon(
                            Icons.map,
                            color: AppColor.deepYellow,
                          ),
                        ),
                      ),
                    ),
                    onSubmitted: (value) {
                      // BlocProvider.of<StopScrollCubit>(context)
                      //     .emitEnable();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                  loadingBuilder: (context) {
                    return Container(
                      color: Colors.white,
                      child: Center(
                        child: LoadingIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error) {
                    return Container(
                      color: Colors.white,
                    );
                  },
                  noItemsFoundBuilder: (value) {
                    var localizedMessage = AppLocalizations.of(context)!
                        .translate('no_result_found');
                    return Container(
                      width: double.infinity,
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          localizedMessage,
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                    );
                  },
                  suggestionsCallback: (pattern) async {
                    // if (pattern.isNotEmpty) {
                    //   BlocProvider.of<StopScrollCubit>(context)
                    //       .emitDisable();
                    // }
                    return pattern.isEmpty
                        ? []
                        : await PlaceService.getAutocomplete(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            // leading: Icon(Icons.shopping_cart),
                            tileColor: Colors.white,
                            title: Text(suggestion.description!),
                            // subtitle: Text('\$${suggestion['price']}'),
                          ),
                          Divider(
                            color: Colors.grey[300],
                            height: 3,
                          ),
                        ],
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) async {
                    valueProvider.setPickupTextLoading(
                      true,
                    );
                    valueProvider.setPickupInfo(
                      suggestion,
                    );

                    FocusManager.instance.primaryFocus?.unfocus();
                    // if (evaluateCo2()) {
                    //   calculateCo2Report();
                    // }
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                Visibility(
                  visible: !valueProvider.deliveryPosition,
                  child: !valueProvider.pickupLoading
                      ? InkWell(
                          onTap: () {
                            valueProvider.setPickupLoading(
                              true,
                            );
                            valueProvider.setPickupPositionClick(
                              true,
                            );

                            valueProvider
                                .getCurrentPositionForPickup(
                              context,
                            )
                                .then(
                              (value) {
                                valueProvider.setPickupLoading(
                                  false,
                                );
                                // valueProvider.setPickupPositionClick(false, selectedIndex);
                              },
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppColor.deepYellow,
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              Text(
                                AppLocalizations.of(context)!
                                    .translate('pick_my_location'),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 25,
                              width: 25,
                              child: LoadingIndicator(),
                            ),
                          ],
                        ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Visibility(
                  visible: valueProvider.pickup_location.isNotEmpty,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: valueProvider.stoppoints_controller.length,
                        itemBuilder: (context, index2) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .85,
                                    child: TypeAheadField(
                                      textFieldConfiguration:
                                          TextFieldConfiguration(
                                        // autofocus: true,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        controller: valueProvider
                                            .stoppoints_controller[index2],
                                        scrollPadding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom +
                                                150),
                                        onTap: () {
                                          valueProvider
                                              .stoppoints_controller[index2]
                                              .selection = TextSelection(
                                            baseOffset: 0,
                                            extentOffset: valueProvider
                                                .stoppoints_controller[index2]
                                                .value
                                                .text
                                                .length,
                                          );
                                        },

                                        style: const TextStyle(fontSize: 18),
                                        decoration: InputDecoration(
                                          hintText: AppLocalizations.of(
                                                  context)!
                                              .translate(
                                                  'enter_load\\unload_address'),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 9.0,
                                            vertical: 11.0,
                                          ),
                                          prefixIcon: valueProvider
                                                  .stoppointstextLoading[index2]
                                              ? SizedBox(
                                                  height: 25,
                                                  width: 25,
                                                  child: LoadingIndicator(),
                                                )
                                              : null,
                                          // suffixIcon: InkWell(
                                          //   onTap: () {
                                          //     // Navigator.push(
                                          //     //   context,
                                          //     //   MaterialPageRoute(
                                          //     //     builder: (context) => MultiShippmentPickUpMapScreen(
                                          //     //       type: 1,
                                          //     //       index: index,
                                          //     //       location: valueProvider.delivery_latlng[index],
                                          //     //     ),
                                          //     //   ),
                                          //     // ).then((value) => FocusManager.instance.primaryFocus?.unfocus());

                                          //     // Get.to(SearchFilterView());
                                          //     Future.delayed(const Duration(
                                          //             milliseconds: 1500))
                                          //         .then((value) {
                                          //       // if (evaluateCo2()) {
                                          //       //   calculateCo2Report();
                                          //       // }
                                          //     });
                                          //   },
                                          //   child: Container(
                                          //     margin: const EdgeInsets.all(7),
                                          //     width: 55.0,
                                          //     height: 15.0,
                                          //     child: Icon(
                                          //       Icons.map,
                                          //       color: AppColor.deepYellow,
                                          //     ),
                                          //   ),
                                          // ),
                                        ),
                                        onSubmitted: (value) {
                                          // BlocProvider.of<StopScrollCubit>(context)
                                          //     .emitEnable();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                      ),
                                      loadingBuilder: (context) {
                                        return Container(
                                          color: Colors.white,
                                          child: Center(
                                            child: LoadingIndicator(),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error) {
                                        return Container(
                                          color: Colors.white,
                                        );
                                      },
                                      noItemsFoundBuilder: (value) {
                                        var localizedMessage =
                                            AppLocalizations.of(context)!
                                                .translate('no_result_found');
                                        return Container(
                                          width: double.infinity,
                                          color: Colors.white,
                                          child: Center(
                                            child: Text(
                                              localizedMessage,
                                              style: TextStyle(fontSize: 18.sp),
                                            ),
                                          ),
                                        );
                                      },
                                      suggestionsCallback: (pattern) async {
                                        // if (pattern.isNotEmpty) {
                                        //   BlocProvider.of<StopScrollCubit>(context)
                                        //       .emitDisable();
                                        // }
                                        return pattern.isEmpty
                                            ? []
                                            : await PlaceService
                                                .getAutocomplete(pattern);
                                      },
                                      itemBuilder: (context, suggestion) {
                                        return Container(
                                          color: Colors.white,
                                          child: Column(
                                            children: [
                                              ListTile(
                                                // leading: Icon(Icons.shopping_cart),
                                                tileColor: Colors.white,
                                                title: Text(
                                                    suggestion.description!),
                                                // subtitle: Text('\$${suggestion['price']}'),
                                              ),
                                              Divider(
                                                color: Colors.grey[300],
                                                height: 3,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      onSuggestionSelected: (suggestion) async {
                                        valueProvider.setStopPointTextLoading(
                                            true, index2);
                                        valueProvider.setStopPointInfo(
                                            suggestion, index2);

                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        // if (evaluateCo2()) {
                                        //   calculateCo2Report();
                                        // }
                                      },
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      valueProvider.removestoppoint(index2);
                                      // _showAlertDialog(index);
                                    },
                                    child: Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(45),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              // InkWell(
                              //   onTap: () {
                              //     valueProvider.setStopPointLoading(true, selectedIndex, index2);
                              //     valueProvider.setStopPointPositionClick(true, selectedIndex, index2);

                              //     valueProvider.getCurrentPositionForStop(context, selectedIndex, index2).then((value) => valueProvider.setStopPointLoading(false, selectedIndex, index2));

                              //     // _getCurrentPositionForDelivery();
                              //   },
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     children: [
                              //       Icon(
                              //         Icons.location_on,
                              //         color: AppColor.deepYellow,
                              //       ),
                              //       SizedBox(
                              //         width: 5.w,
                              //       ),
                              //       Text(
                              //         AppLocalizations.of(context)!.translate('pick_my_location'),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // const SizedBox(
                              //   height: 12,
                              // ),
                            ],
                          );
                        },
                      ),
                      InkWell(
                        onTap: () {
                          valueProvider.addstoppoint();
                        },
                        child: AbsorbPointer(
                          absorbing: true,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 32.h,
                                  width: 32.w,
                                  child: SvgPicture.asset(
                                    "assets/icons/orange/add.svg",
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(AppLocalizations.of(context)!
                                  .translate('add_station')),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: valueProvider.pickup_location.isNotEmpty,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      SectionTitle(
                        text: AppLocalizations.of(context)!
                            .translate('delivery_address'),
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          // autofocus: true,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          controller: valueProvider.delivery_controller,
                          scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom +
                                  150),
                          onTap: () {
                            valueProvider.delivery_controller.selection =
                                TextSelection(
                              baseOffset: 0,
                              extentOffset: valueProvider
                                  .delivery_controller.value.text.length,
                            );
                          },

                          style: const TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!
                                .translate('enter_delivery_address'),
                            // labelText: AppLocalizations.of(context)!.translate('delivery_address'),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 9.0,
                              vertical: 11.0,
                            ),

                            prefixIcon: valueProvider.deliverytextLoading
                                ? SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: LoadingIndicator(),
                                  )
                                : null,
                            suffixIcon: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MultiShippmentPickUpMapScreen(
                                      type: 1,
                                      location: valueProvider.delivery_latlng,
                                    ),
                                  ),
                                ).then((value) => FocusManager
                                    .instance.primaryFocus
                                    ?.unfocus());

                                Future.delayed(
                                        const Duration(milliseconds: 1500))
                                    .then((value) {
                                  // if (evaluateCo2()) {
                                  //   calculateCo2Report();
                                  // }
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.all(7),
                                width: 55.0,
                                height: 15.0,
                                child: Icon(
                                  Icons.map,
                                  color: AppColor.deepYellow,
                                ),
                              ),
                            ),
                          ),
                          onSubmitted: (value) {
                            // BlocProvider.of<StopScrollCubit>(context)
                            //     .emitEnable();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                        loadingBuilder: (context) {
                          return Container(
                            color: Colors.white,
                            child: Center(
                              child: LoadingIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error) {
                          return Container(
                            color: Colors.white,
                          );
                        },
                        noItemsFoundBuilder: (value) {
                          var localizedMessage = AppLocalizations.of(context)!
                              .translate('no_result_found');
                          return Container(
                            width: double.infinity,
                            color: Colors.white,
                            child: Center(
                              child: Text(
                                localizedMessage,
                                style: TextStyle(fontSize: 18.sp),
                              ),
                            ),
                          );
                        },
                        suggestionsCallback: (pattern) async {
                          // if (pattern.isNotEmpty) {
                          //   BlocProvider.of<StopScrollCubit>(context)
                          //       .emitDisable();
                          // }
                          return pattern.isEmpty
                              ? []
                              : await PlaceService.getAutocomplete(pattern);
                        },
                        itemBuilder: (context, suggestion) {
                          return Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                ListTile(
                                  // leading: Icon(Icons.shopping_cart),
                                  tileColor: Colors.white,
                                  title: Text(suggestion.description!),
                                  // subtitle: Text('\$${suggestion['price']}'),
                                ),
                                Divider(
                                  color: Colors.grey[300],
                                  height: 3,
                                ),
                              ],
                            ),
                          );
                        },
                        onSuggestionSelected: (suggestion) async {
                          valueProvider.setDeliveryTextLoading(
                            true,
                          );
                          valueProvider.setDeliveryInfo(
                            suggestion,
                          );

                          FocusManager.instance.primaryFocus?.unfocus();
                          // if (evaluateCo2()) {
                          //   calculateCo2Report();
                          // }
                        },
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Visibility(
                        visible: !valueProvider.pickupPosition,
                        child: !valueProvider.deliveryLoading
                            ? InkWell(
                                onTap: () {
                                  valueProvider.setDeliveryLoading(
                                    true,
                                  );
                                  valueProvider.setDeliveryPositionClick(
                                    true,
                                  );

                                  valueProvider
                                      .getCurrentPositionForDelivery(
                                    context,
                                  )
                                      .then(
                                    (value) {
                                      valueProvider.setDeliveryLoading(
                                        false,
                                      );
                                      // valueProvider.setPickupPositionClick(false, selectedIndex);
                                    },
                                  );

                                  // _getCurrentPositionForDelivery();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: AppColor.deepYellow,
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .translate('pick_my_location'),
                                    ),
                                  ],
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: LoadingIndicator(),
                                  ),
                                ],
                              ),
                      ),
                      // const SizedBox(
                      //   height: 12,
                      // ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Visibility(
                  visible: valueProvider.pickup_location.isNotEmpty,
                  child: BlocListener<DrawRouteBloc, DrawRouteState>(
                    listener: (context, state) {
                      if (state is DrawRouteSuccess) {
                        Future.delayed(const Duration(milliseconds: 400))
                            .then((value) {
                          if (valueProvider
                              .delivery_controller.text.isNotEmpty) {
                            // getPolyPoints();
                            valueProvider.initMapbounds();
                          }
                        });
                      }
                    },
                    child: SizedBox(
                      height: 400.h,
                      child: AbsorbPointer(
                        absorbing: false,
                        child: GoogleMap(
                          onMapCreated: (controller) {
                            valueProvider.onMap2Created(controller, _mapStyle);
                            valueProvider.initMapbounds();
                          },
                          myLocationButtonEnabled: false,
                          zoomGesturesEnabled: false,
                          scrollGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          rotateGesturesEnabled: false,
                          zoomControlsEnabled: false,
                          myLocationEnabled: false,
                          initialCameraPosition: CameraPosition(
                            target: valueProvider.center,
                            zoom: valueProvider.zoom,
                          ),
                          gestureRecognizers: const {},
                          markers: (valueProvider.pickup_latlng != null ||
                                  valueProvider.delivery_latlng != null)
                              ? {
                                  valueProvider.pickup_latlng != null
                                      ? Marker(
                                          markerId: const MarkerId("pickup"),
                                          position: LatLng(
                                              double.parse(valueProvider
                                                  .pickup_location
                                                  .split(",")[0]),
                                              double.parse(valueProvider
                                                  .pickup_location
                                                  .split(",")[1])),
                                          icon: pickupicon!,
                                        )
                                      : const Marker(
                                          markerId: MarkerId("pickup"),
                                        ),
                                  valueProvider.delivery_latlng != null
                                      ? Marker(
                                          markerId: const MarkerId("delivery"),
                                          position: LatLng(
                                              double.parse(valueProvider
                                                  .delivery_location
                                                  .split(",")[0]),
                                              double.parse(valueProvider
                                                  .delivery_location
                                                  .split(",")[1])),
                                          icon: deliveryicon,
                                        )
                                      : const Marker(
                                          markerId: MarkerId("delivery"),
                                        ),
                                }
                              : {},
                          polylines: {
                            Polyline(
                              polylineId: const PolylineId("route"),
                              points: deserializeLatLng(
                                  jsonEncode(valueProvider.pathes)),
                              color: AppColor.deepYellow,
                              width: 7,
                            ),
                          },
                          // mapType: shipmentProvider.mapType,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Visibility(
                  visible: valueProvider.pickup_location.isNotEmpty &&
                      valueProvider.delivery_location.isNotEmpty,
                  child: CustomButton(
                    onTap: () {
                      valueProvider.setPathConfirm(
                        true,
                      );
                      Navigator.pop(context);
                    },
                    title: SizedBox(
                      height: 50.h,
                      width: 150.w,
                      child: Center(
                        child: SectionTitle(
                          text: AppLocalizations.of(context)!
                              .translate("confirm"),
                          // color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int calculatePrice(
    double distance,
    double weight,
  ) {
    double result = 0.0;
    result = distance * (weight / 1000) * 550;
    return result.toInt();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Consumer<AddMultiShipmentProvider>(
            builder: (context, shipmentProvider, child) {
              return Scaffold(
                backgroundColor: Colors.grey[100],
                body: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SingleChildScrollView(
                      // controller: controller,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 72.h),
                            EnsureVisibleWhenFocused(
                              focusNode: _path_node,
                              child: Card(
                                key: key1,
                                elevation: 1,
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(
                                  // vertical: 10,
                                  horizontal: 16,
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              // showShipmentPathModalSheet(
                                              //     context,
                                              //     localeState
                                              //         .value.languageCode);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddPathScreen(),
                                                ),
                                              );
                                              if (shipmentProvider
                                                  .pathConfirm) {}
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  height: 25.h,
                                                  width: 25.h,
                                                  child: SvgPicture.asset(
                                                      "assets/icons/grey/shipment_path.svg"),
                                                ),
                                                const SizedBox(width: 8),
                                                SectionTitle(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .translate(
                                                          'shippment_path'),
                                                ),
                                                const Spacer(),
                                              ],
                                            ),
                                          ),
                                          !(shipmentProvider.pathConfirm)
                                              ? InkWell(
                                                  onTap: () {
                                                    // showShipmentPathModalSheet(
                                                    //     context,
                                                    //     localeState.value
                                                    //         .languageCode);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddPathScreen(),
                                                      ),
                                                    );
                                                  },
                                                  child: AbsorbPointer(
                                                    absorbing: true,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        // border: Border.all(
                                                        //   width: 1,
                                                        //   color: Colors.grey,
                                                        // ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            SectionSubTitle(
                                                              text: AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .translate(
                                                                      'choose_shippment_path'),
                                                            ),
                                                            const Spacer(),
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_ios,
                                                              color: AppColor
                                                                  .deepYellow,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                          Visibility(
                                            visible:
                                                shipmentProvider.pathConfirm,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                AddShipmentPathVerticalWidget(
                                                  stations: shipmentProvider
                                                      .stoppoints_controller,
                                                  pickup: shipmentProvider
                                                      .pickup_controller,
                                                  delivery: shipmentProvider
                                                      .delivery_controller,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible: shipmentProvider.pathError,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'choose_path_error'),
                                                    style: TextStyle(
                                                      color: Colors.red[400],
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    shipmentProvider.pathConfirm
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  // showShipmentPathModalSheet(
                                                  //     context,
                                                  //     localeState
                                                  //         .value.languageCode);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddPathScreen(),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .translate('edit_path'),
                                                  style: TextStyle(
                                                    // fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    color: AppColor.deepYellow,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddPathScreen(),
                                                    ),
                                                  );
                                                  // showShipmentPathModalSheet(
                                                  //     context,
                                                  //     localeState.value
                                                  //         .languageCode),
                                                },
                                                child: AbsorbPointer(
                                                  absorbing: true,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Icon(
                                                      Icons.edit,
                                                      color:
                                                          AppColor.deepYellow,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            BlocListener<DrawRouteBloc, DrawRouteState>(
                              listener: (context, state) {
                                if (state is DrawRouteSuccess) {
                                  Future.delayed(
                                          const Duration(milliseconds: 400))
                                      .then((value) {
                                    if (shipmentProvider
                                        .delivery_controller.text.isNotEmpty) {
                                      // getPolyPoints();
                                      shipmentProvider.initMapbounds();
                                    }
                                  });
                                }
                              },
                              child: pickupicon != null
                                  ? Card(
                                      elevation: 1,
                                      color: Colors.white,
                                      margin: const EdgeInsets.symmetric(
                                        // vertical: 5,
                                        horizontal: 16,
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 275.h,
                                            child: AbsorbPointer(
                                              absorbing: false,
                                              child: GoogleMap(
                                                onMapCreated: (controller) {
                                                  shipmentProvider.onMapCreated(
                                                      controller, _mapStyle);
                                                },
                                                myLocationButtonEnabled: false,
                                                zoomGesturesEnabled: false,
                                                scrollGesturesEnabled: false,
                                                tiltGesturesEnabled: false,
                                                rotateGesturesEnabled: false,
                                                zoomControlsEnabled: false,
                                                myLocationEnabled: false,
                                                initialCameraPosition:
                                                    CameraPosition(
                                                  target:
                                                      shipmentProvider.center,
                                                  zoom: shipmentProvider.zoom,
                                                ),
                                                gestureRecognizers: const {},
                                                markers: (shipmentProvider
                                                            .pickup_location
                                                            .isNotEmpty ||
                                                        shipmentProvider
                                                            .delivery_location
                                                            .isNotEmpty)
                                                    ? {
                                                        shipmentProvider
                                                                .pickup_location
                                                                .isNotEmpty
                                                            ? Marker(
                                                                markerId:
                                                                    const MarkerId(
                                                                        "pickup"),
                                                                position: LatLng(
                                                                    double.parse(
                                                                        shipmentProvider.pickup_location.split(",")[
                                                                            0]),
                                                                    double.parse(shipmentProvider
                                                                        .pickup_location
                                                                        .split(
                                                                            ",")[1])),
                                                                icon:
                                                                    pickupicon!,
                                                              )
                                                            : const Marker(
                                                                markerId:
                                                                    MarkerId(
                                                                        "pickup"),
                                                              ),
                                                        shipmentProvider
                                                                    .delivery_latlng !=
                                                                null
                                                            ? Marker(
                                                                markerId:
                                                                    const MarkerId(
                                                                        "delivery"),
                                                                position: LatLng(
                                                                    double.parse(
                                                                        shipmentProvider.delivery_location.split(",")[
                                                                            0]),
                                                                    double.parse(shipmentProvider
                                                                        .delivery_location
                                                                        .split(
                                                                            ",")[1])),
                                                                icon:
                                                                    deliveryicon,
                                                              )
                                                            : const Marker(
                                                                markerId: MarkerId(
                                                                    "delivery"),
                                                              ),
                                                      }
                                                    : {},
                                                polylines: {
                                                  Polyline(
                                                    polylineId:
                                                        const PolylineId(
                                                            "route"),
                                                    points: deserializeLatLng(
                                                        jsonEncode(
                                                            shipmentProvider
                                                                .pathes)),
                                                    color: AppColor.deepYellow,
                                                    width: 7,
                                                  ),
                                                },
                                              ),
                                            ),
                                          ),
                                          shipmentProvider.distance != 0
                                              ? Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 7.5,
                                                    horizontal: 4,
                                                  ),
                                                  child: PathStatisticsWidget(
                                                    distance: shipmentProvider
                                                        .distance,
                                                    period:
                                                        shipmentProvider.period,
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            EnsureVisibleWhenFocused(
                              focusNode: _commodity_node,
                              child: SizedBox(
                                key: key2,
                                child: Form(
                                  key: shipmentProvider
                                      .addShipmentformKey[selectedIndex],
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          shipmentProvider.count[selectedIndex],
                                      itemBuilder: (context, index2) {
                                        return Stack(
                                          children: [
                                            Card(
                                              elevation: 1,
                                              color: Colors.white,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                vertical: 5,
                                                horizontal: 16,
                                              ),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 12),
                                                    child: Column(
                                                      children: [
                                                        index2 == 0
                                                            ? Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    height:
                                                                        25.h,
                                                                    width: 25.h,
                                                                    child: SvgPicture
                                                                        .asset(
                                                                            "assets/icons/grey/goods.svg"),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 8),
                                                                  SectionTitle(
                                                                    text: AppLocalizations.of(
                                                                            context)!
                                                                        .translate(
                                                                            'commodity_info'),
                                                                  ),
                                                                ],
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
                                                        index2 != 0
                                                            ? const SizedBox(
                                                                height: 30,
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        Focus(
                                                          focusNode:
                                                              _nodeCommodityName,
                                                          onFocusChange:
                                                              (bool focus) {
                                                            if (!focus) {
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                              BlocProvider.of<
                                                                          BottomNavBarCubit>(
                                                                      context)
                                                                  .emitShow();
                                                            }
                                                          },
                                                          child: TextFormField(
                                                            controller: shipmentProvider
                                                                        .commodityName_controllers[
                                                                    selectedIndex]
                                                                [index2],
                                                            onTap: () {
                                                              BlocProvider.of<
                                                                          BottomNavBarCubit>(
                                                                      context)
                                                                  .emitHide();
                                                              shipmentProvider
                                                                      .commodityName_controllers[
                                                                          selectedIndex]
                                                                          [index2]
                                                                      .selection =
                                                                  TextSelection(
                                                                      baseOffset:
                                                                          0,
                                                                      extentOffset: shipmentProvider
                                                                          .commodityName_controllers[
                                                                              selectedIndex]
                                                                              [
                                                                              index2]
                                                                          .value
                                                                          .text
                                                                          .length);
                                                            },
                                                            // focusNode: _nodeWeight,
                                                            // enabled: !valueEnabled,
                                                            scrollPadding: EdgeInsets.only(
                                                                bottom: MediaQuery.of(
                                                                            context)
                                                                        .viewInsets
                                                                        .bottom +
                                                                    50),
                                                            textInputAction:
                                                                TextInputAction
                                                                    .done,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                            decoration:
                                                                InputDecoration(
                                                              labelText: AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .translate(
                                                                      'commodity_name'),
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
                                                              BlocProvider.of<
                                                                          BottomNavBarCubit>(
                                                                      context)
                                                                  .emitShow();
                                                            },
                                                            onEditingComplete:
                                                                () {
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
                                                              if (value!
                                                                  .isEmpty) {
                                                                return AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'insert_commodity_validate');
                                                              }
                                                              return null;
                                                            },
                                                            onSaved:
                                                                (newValue) {
                                                              shipmentProvider
                                                                  .commodityName_controllers[
                                                                      selectedIndex]
                                                                      [index2]
                                                                  .text = newValue!;
                                                            },
                                                            onFieldSubmitted:
                                                                (value) {
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                              BlocProvider.of<
                                                                          BottomNavBarCubit>(
                                                                      context)
                                                                  .emitShow();
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        Focus(
                                                          focusNode:
                                                              _nodeCommodityWeight,
                                                          onFocusChange:
                                                              (bool focus) {
                                                            if (!focus) {
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                              BlocProvider.of<
                                                                          BottomNavBarCubit>(
                                                                      context)
                                                                  .emitShow();
                                                            }
                                                          },
                                                          child: TextFormField(
                                                            controller: shipmentProvider
                                                                        .commodityWeight_controllers[
                                                                    selectedIndex]
                                                                [index2],
                                                            onTap: () {
                                                              BlocProvider.of<
                                                                          BottomNavBarCubit>(
                                                                      context)
                                                                  .emitHide();
                                                              shipmentProvider
                                                                      .commodityWeight_controllers[
                                                                          selectedIndex]
                                                                          [index2]
                                                                      .selection =
                                                                  TextSelection(
                                                                      baseOffset:
                                                                          0,
                                                                      extentOffset: shipmentProvider
                                                                          .commodityWeight_controllers[
                                                                              selectedIndex]
                                                                              [
                                                                              index2]
                                                                          .value
                                                                          .text
                                                                          .length);
                                                            },
                                                            // focusNode: _nodeWeight,
                                                            // enabled: !valueEnabled,
                                                            scrollPadding: EdgeInsets.only(
                                                                bottom: MediaQuery.of(
                                                                            context)
                                                                        .viewInsets
                                                                        .bottom +
                                                                    50),
                                                            textInputAction:
                                                                TextInputAction
                                                                    .done,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: [
                                                              DecimalFormatter(),
                                                            ],
                                                            autovalidateMode:
                                                                AutovalidateMode
                                                                    .onUserInteraction,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                            decoration:
                                                                InputDecoration(
                                                              labelText: AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .translate(
                                                                      'commodity_weight'),
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
                                                              shipmentProvider
                                                                  .calculateTotalWeight(
                                                                      selectedIndex);
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                              BlocProvider.of<
                                                                          BottomNavBarCubit>(
                                                                      context)
                                                                  .emitShow();
                                                            },
                                                            // autovalidateMode:
                                                            //     AutovalidateMode
                                                            //         .onUserInteraction,
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'insert_weight_validate');
                                                              }
                                                              return null;
                                                            },
                                                            onSaved:
                                                                (newValue) {
                                                              shipmentProvider
                                                                  .commodityWeight_controllers[
                                                                      selectedIndex]
                                                                      [index2]
                                                                  .text = newValue!;
                                                              shipmentProvider
                                                                  .calculateTotalWeight(
                                                                      selectedIndex);
                                                            },
                                                            onFieldSubmitted:
                                                                (value) {
                                                              shipmentProvider
                                                                  .calculateTotalWeight(
                                                                      selectedIndex);
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                              BlocProvider.of<
                                                                          BottomNavBarCubit>(
                                                                      context)
                                                                  .emitShow();
                                                            },
                                                          ),
                                                        ),
                                                        // const SizedBox(
                                                        //   height: 8,
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                  (shipmentProvider.count[
                                                              selectedIndex] ==
                                                          (index2 + 1))
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                shipmentProvider
                                                                    .additem(
                                                                        selectedIndex,
                                                                        index2);
                                                              },
                                                              child: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'add_commodity'),
                                                                style:
                                                                    TextStyle(
                                                                  // fontSize: 16,
                                                                  // fontWeight:
                                                                  //     FontWeight
                                                                  //         .bold,
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                ),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: () =>
                                                                  shipmentProvider
                                                                      .additem(
                                                                          selectedIndex,
                                                                          index2),
                                                              child:
                                                                  AbsorbPointer(
                                                                absorbing: true,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .add_circle_outline_outlined,
                                                                    color: AppColor
                                                                        .deepYellow,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : const SizedBox.shrink(),
                                                ],
                                              ),
                                            ),
                                            (shipmentProvider
                                                        .count[selectedIndex] >
                                                    1)
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
                                            (shipmentProvider.count[
                                                            selectedIndex] >
                                                        1) &&
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
                                                        shipmentProvider
                                                            .removeitem(
                                                          selectedIndex,
                                                          index2,
                                                        );
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
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Card(
                              elevation: 1,
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(
                                // vertical: 10,
                                horizontal: 16,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    EnsureVisibleWhenFocused(
                                      focusNode: _truck_node,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                height: 25.h,
                                                width: 25.h,
                                                child: SvgPicture.asset(
                                                    "assets/icons/grey/truck.svg"),
                                              ),
                                              const SizedBox(width: 8),
                                              SectionTitle(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .translate(
                                                        'select_truck_type'),
                                              ),
                                              const Spacer(),
                                              // Icon(
                                              //   Icons.arrow_forward_ios,
                                              //   color:
                                              //       AppColor.deepYellow,
                                              // ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 160.h,
                                            child: BlocBuilder<TruckTypeBloc,
                                                TruckTypeState>(
                                              builder: (context, state) {
                                                if (state
                                                    is TruckTypeLoadedSuccess) {
                                                  return Scrollbar(
                                                    controller:
                                                        _scrollController,
                                                    thumbVisibility: true,
                                                    thickness: 2.0,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(2.h),
                                                      child: ListView.builder(
                                                        controller:
                                                            _scrollController,
                                                        itemCount: state
                                                            .truckTypes.length,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        clipBehavior: Clip.none,
                                                        shrinkWrap: true,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal: 5.w,
                                                              vertical: 15.h,
                                                            ),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();
                                                                setState(() {
                                                                  shipmentProvider
                                                                      .setTruckTypeError(
                                                                    false,
                                                                  );
                                                                  shipmentProvider
                                                                      .setTruckType(
                                                                    state.truckTypes[
                                                                        index],
                                                                    selectedIndex,
                                                                  );
                                                                });
                                                              },
                                                              child: Stack(
                                                                clipBehavior:
                                                                    Clip.none,
                                                                children: [
                                                                  Container(
                                                                    width:
                                                                        175.w,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              7),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: shipmentProvider.selectedTruckTypeId[selectedIndex] ==
                                                                                state.truckTypes[index].id!
                                                                            ? AppColor.deepYellow
                                                                            : AppColor.lightGrey,
                                                                        width:
                                                                            2.w,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Image
                                                                            .network(
                                                                          state
                                                                              .truckTypes[index]
                                                                              .image!,
                                                                          height:
                                                                              50.h,
                                                                          errorBuilder: (context,
                                                                              error,
                                                                              stackTrace) {
                                                                            return Container(
                                                                              height: 50.h,
                                                                              width: 175.w,
                                                                              color: Colors.grey[300],
                                                                              child: Center(
                                                                                child: Text(AppLocalizations.of(context)!.translate('image_load_error')),
                                                                              ),
                                                                            );
                                                                          },
                                                                          loadingBuilder: (context,
                                                                              child,
                                                                              loadingProgress) {
                                                                            if (loadingProgress ==
                                                                                null) {
                                                                              return child;
                                                                            }

                                                                            return Shimmer.fromColors(
                                                                              baseColor: (Colors.grey[300])!,
                                                                              highlightColor: (Colors.grey[100])!,
                                                                              enabled: true,
                                                                              child: Container(
                                                                                height: 50.h,
                                                                                width: 175.w,
                                                                                color: Colors.white,
                                                                              ),
                                                                            );
                                                                          },
                                                                          // placeholder:
                                                                          //     Container(
                                                                          //   color: Colors
                                                                          //       .white,
                                                                          //   height:
                                                                          //       50.h,
                                                                          //   width: 50.h,
                                                                          // ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              7.h,
                                                                        ),
                                                                        Text(
                                                                          localeState.value.languageCode == 'en'
                                                                              ? state.truckTypes[index].name!
                                                                              : state.truckTypes[index].nameAr!,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17.sp,
                                                                            color:
                                                                                AppColor.deepBlack,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  (shipmentProvider.selectedTruckTypeId[
                                                                              selectedIndex] ==
                                                                          state
                                                                              .truckTypes[
                                                                                  index]
                                                                              .id!)
                                                                      ? Positioned(
                                                                          right:
                                                                              -7.w,
                                                                          top: -10
                                                                              .h,
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                const EdgeInsets.all(2),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: AppColor.deepYellow,
                                                                              borderRadius: BorderRadius.circular(45),
                                                                            ),
                                                                            child: Icon(Icons.check,
                                                                                size: 16.w,
                                                                                color: Colors.white),
                                                                          ),
                                                                        )
                                                                      : const SizedBox
                                                                          .shrink()
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return Shimmer.fromColors(
                                                    baseColor:
                                                        (Colors.grey[300])!,
                                                    highlightColor:
                                                        (Colors.grey[100])!,
                                                    enabled: true,
                                                    direction:
                                                        ShimmerDirection.rtl,
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder: (_, __) =>
                                                          Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 5.w,
                                                                vertical: 15.h),
                                                        child: Container(
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: SizedBox(
                                                            width: 175.w,
                                                            height: 70.h,
                                                          ),
                                                        ),
                                                      ),
                                                      itemCount: 6,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          Visibility(
                                            visible:
                                                shipmentProvider.truckTypeError,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'select_truck_error'),
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Card(
                              elevation: 1,
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(
                                // vertical: 10,
                                horizontal: 16,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 25.h,
                                          width: 25.h,
                                          child: SvgPicture.asset(
                                              "assets/icons/grey/time.svg"),
                                        ),
                                        const SizedBox(width: 8),
                                        SectionTitle(
                                          text: AppLocalizations.of(context)!
                                              .translate('loading_time'),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            _showDatePicker(
                                                localeState.value.languageCode);
                                          },
                                          child: TextFormField(
                                            controller: shipmentProvider
                                                .date_controller[selectedIndex],
                                            enabled: false,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            decoration: InputDecoration(
                                              labelText:
                                                  AppLocalizations.of(context)!
                                                      .translate('date'),
                                              floatingLabelStyle:
                                                  const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 11.0,
                                                      horizontal: 9.0),
                                              suffixIcon: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: SvgPicture.asset(
                                                  "assets/icons/grey/calendar.svg",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            _showTimePicker();
                                          },
                                          child: TextFormField(
                                            controller: shipmentProvider
                                                .time_controller[selectedIndex],
                                            enabled: false,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            decoration: InputDecoration(
                                              labelText:
                                                  AppLocalizations.of(context)!
                                                      .translate('time'),
                                              floatingLabelStyle:
                                                  const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 11.0,
                                                      horizontal: 9.0),
                                              suffixIcon: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: SvgPicture.asset(
                                                  "assets/icons/grey/time.svg",
                                                  height: 15.h,
                                                  width: 15.h,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Visibility(
                                      visible: shipmentProvider
                                          .dateError[selectedIndex],
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate('pick_date_error'),
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 17,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .83,
                                          child: CustomButton(
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      'search_for_truck'),
                                              style: TextStyle(
                                                fontSize: 20.sp,
                                              ),
                                            ),
                                            onTap: () {
                                              if (shipmentProvider
                                                      .pickup_location
                                                      .isNotEmpty ||
                                                  shipmentProvider
                                                      .delivery_location
                                                      .isNotEmpty) {
                                                shipmentProvider
                                                    .setTruckConfirm(
                                                        false, selectedIndex);
                                                if (shipmentProvider
                                                    .addShipmentformKey[
                                                        selectedIndex]
                                                    .currentState!
                                                    .validate()) {
                                                  if (shipmentProvider
                                                          .time_controller[
                                                              selectedIndex]
                                                          .text
                                                          .isNotEmpty &&
                                                      shipmentProvider
                                                          .date_controller[
                                                              selectedIndex]
                                                          .text
                                                          .isNotEmpty) {
                                                    if (shipmentProvider
                                                                .selectedTruckType[
                                                            selectedIndex] !=
                                                        null) {
                                                      List<int> types = [];
                                                      for (var element
                                                          in shipmentProvider
                                                              .selectedTruckType) {
                                                        if (!types.contains(
                                                            element!.id!)) {
                                                          types
                                                              .add(element.id!);
                                                        }
                                                      }
                                                      BlocProvider.of<
                                                                  TrucksListBloc>(
                                                              context)
                                                          .add(
                                                        NearestTrucksListLoadEvent(
                                                          types,
                                                          shipmentProvider
                                                              .pickup_location,
                                                          shipmentProvider
                                                              .pickup_placeId,
                                                          shipmentProvider
                                                              .delivery_placeId,
                                                        ),
                                                      );
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              SearchForTrucksScreen(),
                                                        ),
                                                      );
                                                    } else {
                                                      shipmentProvider
                                                          .setTruckTypeError(
                                                              true);
                                                    }
                                                  } else {
                                                    shipmentProvider
                                                        .setDateError(true,
                                                            selectedIndex);
                                                  }
                                                }
                                              } else {
                                                shipmentProvider.setPathError(
                                                  true,
                                                );
                                                Scrollable.ensureVisible(
                                                  key1.currentContext!,
                                                  duration: const Duration(
                                                    milliseconds: 500,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceAround,
                                    //   children: [
                                    //     TextButton(
                                    //       onPressed: () {
                                    //         showDialog<void>(
                                    //           context: context,
                                    //           barrierDismissible:
                                    //               false, // user must tap button!
                                    //           builder: (BuildContext context) {
                                    //             return AlertDialog(
                                    //               backgroundColor: Colors.white,
                                    //               title: Text(AppLocalizations
                                    //                       .of(context)!
                                    //                   .translate('form_init')),
                                    //               content:
                                    //                   SingleChildScrollView(
                                    //                 child: ListBody(
                                    //                   children: <Widget>[
                                    //                     Text(
                                    //                         AppLocalizations.of(
                                    //                                 context)!
                                    //                             .translate(
                                    //                                 'form_init_confirm'),
                                    //                         style:
                                    //                             const TextStyle(
                                    //                                 fontSize:
                                    //                                     18)),
                                    //                   ],
                                    //                 ),
                                    //               ),
                                    //               actions: <Widget>[
                                    //                 TextButton(
                                    //                   child: Text(
                                    //                       AppLocalizations.of(
                                    //                               context)!
                                    //                           .translate('no'),
                                    //                       style:
                                    //                           const TextStyle(
                                    //                               fontSize:
                                    //                                   18)),
                                    //                   onPressed: () {
                                    //                     Navigator.of(context)
                                    //                         .pop();
                                    //                   },
                                    //                 ),
                                    //                 TextButton(
                                    //                   child: Text(
                                    //                       AppLocalizations.of(
                                    //                               context)!
                                    //                           .translate('yes'),
                                    //                       style:
                                    //                           const TextStyle(
                                    //                               fontSize:
                                    //                                   18)),
                                    //                   onPressed: () {
                                    //                     shipmentProvider
                                    //                         .initForm();
                                    //                     Navigator.of(context)
                                    //                         .pop();
                                    //                     setState(
                                    //                       () {},
                                    //                     );
                                    //                   },
                                    //                 ),
                                    //               ],
                                    //             );
                                    //           },
                                    //         );
                                    //       },
                                    //       child: Text(
                                    //         AppLocalizations.of(context)!
                                    //             .translate('form_clear'),
                                    //         style: TextStyle(
                                    //           fontSize: 20.sp,
                                    //           decoration:
                                    //               TextDecoration.underline,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: pathList(shipmentProvider, context),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
