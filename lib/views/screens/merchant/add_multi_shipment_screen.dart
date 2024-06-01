import 'dart:convert';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/core/draw_route_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_multi_create_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_type_bloc.dart';
import 'package:camion/business_logic/bloc/truck/trucks_list_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/models/truck_type_model.dart';
import 'package:camion/data/providers/add_multi_shipment_provider.dart';
import 'package:camion/data/services/places_service.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/formatter.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/screens/merchant/add_multishipment_map_picker.dart';
import 'package:camion/views/screens/truck_details_screen.dart';
import 'package:camion/views/widgets/add_shipment_vertical_path_widget.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/path_statistics_widget.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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
  AddMultiShipmentScreen({Key? key}) : super(key: key);

  @override
  State<AddMultiShipmentScreen> createState() => _AddMultiShipmentScreenState();
}

class _AddMultiShipmentScreenState extends State<AddMultiShipmentScreen> {
  // final ScrollController _scrollController = ScrollController();
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

  int mapIndex = 0;
  int truckIndex = 0;

  String _mapStyle = "";
  String _darkmapStyle = "";

  BitmapDescriptor? pickupicon;
  late BitmapDescriptor deliveryicon;
  late BitmapDescriptor stopicon;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

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

  _showDatePicker(int index, String lang) {
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
                      addShippmentProvider!.loadDate[index], index, lang);

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
                  initialDateTime: addShippmentProvider!.loadDate[index],
                  mode: cupertino.CupertinoDatePickerMode.date,
                  minimumYear: DateTime.now().year,
                  minimumDate: DateTime.now().subtract(const Duration(days: 1)),
                  maximumYear: DateTime.now().year + 1,
                  onDateTimeChanged: (value) {
                    // loadDate = value;
                    addShippmentProvider!.setLoadDate(value, index, lang);
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

  _showTimePicker(int index) {
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
                  addShippmentProvider!.setLoadTime(
                      addShippmentProvider!.loadTime[index], index);

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
                  initialDateTime: addShippmentProvider!.loadTime[index],
                  mode: cupertino.CupertinoDatePickerMode.time,
                  minimumDate: DateTime.now(),
                  onDateTimeChanged: (value) {
                    // loadTime = value;
                    addShippmentProvider!.setLoadTime(value, index);

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
    return SizedBox(
      height: 60.h,
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
                  provider.initMapbounds(selectedIndex);
                },
                child: Container(
                  // width: 130.w,
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? AppColor.deepYellow
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "الشاحنة ${index + 1}",
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      addShippmentProvider =
          Provider.of<AddMultiShipmentProvider>(context, listen: false);
      addShippmentProvider!.initShipment();

      createMarkerIcons();
    });

    rootBundle.loadString('assets/style/normal_style.json').then((string) {
      _mapStyle = string;
    });
    rootBundle.loadString('assets/style/map_style.json').then((string) {
      _darkmapStyle = string;
    });
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
            padding: const EdgeInsets.all(8.0),
            constraints:
                BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            width: double.infinity,
            child: ListView(
              // shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: AbsorbPointer(
                          absorbing: false,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: lang == "en"
                                ? const Icon(Icons.arrow_forward)
                                : const Icon(Icons.arrow_back),
                          ),
                        ),
                      ),
                      SectionTitle(
                        text: AppLocalizations.of(context)!
                            .translate('choose_shippment_path'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                SectionBody(
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
                    controller: valueProvider.pickup_controller[selectedIndex],
                    scrollPadding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 150),
                    onTap: () {
                      valueProvider.pickup_controller[selectedIndex].selection =
                          TextSelection(
                              baseOffset: 0,
                              extentOffset: valueProvider
                                  .pickup_controller[selectedIndex]
                                  .value
                                  .text
                                  .length);
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
                      prefixIcon: valueProvider.pickuptextLoading[selectedIndex]
                          ? const SizedBox(
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
                                index: selectedIndex,
                                location:
                                    valueProvider.pickup_latlng[selectedIndex],
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
                      child: const Center(
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
                    valueProvider.setPickupTextLoading(true, selectedIndex);
                    valueProvider.setPickupInfo(suggestion, selectedIndex);

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
                  visible: !valueProvider.deliveryPosition[selectedIndex],
                  child: !valueProvider.pickupLoading[selectedIndex]
                      ? InkWell(
                          onTap: () {
                            valueProvider.setPickupLoading(true, selectedIndex);
                            valueProvider.setPickupPositionClick(
                                true, selectedIndex);

                            valueProvider
                                .getCurrentPositionForPickup(
                                    context, selectedIndex)
                                .then(
                              (value) {
                                valueProvider.setPickupLoading(
                                    false, selectedIndex);
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
                      : const Row(
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
                  visible:
                      valueProvider.pickup_location[selectedIndex].isNotEmpty,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: valueProvider
                            .stoppoints_controller[selectedIndex].length,
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
                                        controller:
                                            valueProvider.stoppoints_controller[
                                                selectedIndex][index2],
                                        scrollPadding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom +
                                                150),
                                        onTap: () {
                                          valueProvider
                                              .stoppoints_controller[
                                                  selectedIndex][index2]
                                              .selection = TextSelection(
                                            baseOffset: 0,
                                            extentOffset: valueProvider
                                                .stoppoints_controller[
                                                    selectedIndex][index2]
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
                                                      .stoppointstextLoading[
                                                  selectedIndex][index2]
                                              ? const SizedBox(
                                                  height: 25,
                                                  width: 25,
                                                  child: LoadingIndicator(),
                                                )
                                              : null,
                                          suffixIcon: InkWell(
                                            onTap: () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) => MultiShippmentPickUpMapScreen(
                                              //       type: 1,
                                              //       index: index,
                                              //       location: valueProvider.delivery_latlng[index],
                                              //     ),
                                              //   ),
                                              // ).then((value) => FocusManager.instance.primaryFocus?.unfocus());

                                              print(
                                                  "delivry address co2 evaluation");
                                              // Get.to(SearchFilterView());
                                              Future.delayed(const Duration(
                                                      milliseconds: 1500))
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
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                      ),
                                      loadingBuilder: (context) {
                                        return Container(
                                          color: Colors.white,
                                          child: const Center(
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
                                            true, selectedIndex, index2);
                                        valueProvider.setStopPointInfo(
                                            suggestion, selectedIndex, index2);

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
                                      valueProvider.removestoppoint(
                                          selectedIndex, index2);
                                      // _showAlertDialog(index);
                                    },
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
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
                          valueProvider.addstoppoint(selectedIndex);
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
                                  child:
                                      SvgPicture.asset("assets/icons/add.svg"),
                                ),
                              ),
                              const SizedBox(
                                width: 7,
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
                  visible:
                      valueProvider.pickup_location[selectedIndex].isNotEmpty,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      SectionBody(
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
                          controller:
                              valueProvider.delivery_controller[selectedIndex],
                          scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom +
                                  150),
                          onTap: () {
                            valueProvider.delivery_controller[selectedIndex]
                                .selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: valueProvider
                                  .delivery_controller[selectedIndex]
                                  .value
                                  .text
                                  .length,
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

                            prefixIcon:
                                valueProvider.deliverytextLoading[selectedIndex]
                                    ? const SizedBox(
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
                                      index: selectedIndex,
                                      location: valueProvider
                                          .delivery_latlng[selectedIndex],
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
                            child: const Center(
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
                              true, selectedIndex);
                          valueProvider.setDeliveryInfo(
                              suggestion, selectedIndex);

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
                        visible: !valueProvider.pickupPosition[selectedIndex],
                        child: !valueProvider.deliveryLoading[selectedIndex]
                            ? InkWell(
                                onTap: () {
                                  valueProvider.setDeliveryLoading(
                                      true, selectedIndex);
                                  valueProvider.setDeliveryPositionClick(
                                      true, selectedIndex);

                                  valueProvider
                                      .getCurrentPositionForDelivery(
                                          context, selectedIndex)
                                      .then(
                                    (value) {
                                      valueProvider.setDeliveryLoading(
                                          false, selectedIndex);
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
                            : const Row(
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
                  visible:
                      valueProvider.pickup_location[selectedIndex].isNotEmpty,
                  child: BlocListener<DrawRouteBloc, DrawRouteState>(
                    listener: (context, state) {
                      if (state is DrawRouteSuccess) {
                        Future.delayed(const Duration(milliseconds: 400))
                            .then((value) {
                          if (valueProvider.delivery_controller[selectedIndex]
                              .text.isNotEmpty) {
                            // getPolyPoints();
                            valueProvider.initMapbounds(selectedIndex);
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
                            valueProvider.initMapbounds(selectedIndex);
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
                          gestureRecognizers: {},
                          markers: (valueProvider
                                          .pickup_latlng[selectedIndex] !=
                                      null ||
                                  valueProvider
                                          .delivery_latlng[selectedIndex] !=
                                      null)
                              ? {
                                  valueProvider.pickup_latlng[selectedIndex] !=
                                          null
                                      ? Marker(
                                          markerId: const MarkerId("pickup"),
                                          position: LatLng(
                                              double.parse(valueProvider
                                                  .pickup_location[
                                                      selectedIndex]
                                                  .split(",")[0]),
                                              double.parse(valueProvider
                                                  .pickup_location[
                                                      selectedIndex]
                                                  .split(",")[1])),
                                          icon: pickupicon!,
                                        )
                                      : const Marker(
                                          markerId: MarkerId("pickup"),
                                        ),
                                  valueProvider
                                              .delivery_latlng[selectedIndex] !=
                                          null
                                      ? Marker(
                                          markerId: const MarkerId("delivery"),
                                          position: LatLng(
                                              double.parse(valueProvider
                                                  .delivery_location[
                                                      selectedIndex]
                                                  .split(",")[0]),
                                              double.parse(valueProvider
                                                  .delivery_location[
                                                      selectedIndex]
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
                              points: deserializeLatLng(jsonEncode(
                                  valueProvider.pathes[selectedIndex])),
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
                  visible: valueProvider
                          .pickup_location[selectedIndex].isNotEmpty &&
                      valueProvider.delivery_location[selectedIndex].isNotEmpty,
                  child: CustomButton(
                    onTap: () {
                      valueProvider.setPathConfirm(
                        true,
                        selectedIndex,
                      );
                      Navigator.pop(context);
                    },
                    title: SizedBox(
                      height: 50.h,
                      width: 150.w,
                      child: const Center(
                        child: Text(
                          "confirm",
                          style: TextStyle(
                            color: Colors.black,
                          ),
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

  showTruckModalSheet(BuildContext context, String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Consumer<AddMultiShipmentProvider>(
          builder: (context, truckProvider, child) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: AbsorbPointer(
                        absorbing: false,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: lang == 'en'
                              ? const Icon(Icons.arrow_forward)
                              : const Icon(Icons.arrow_back),
                        ),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.translate('select_truck'),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              TextFormField(
                controller: _searchController,
                onTap: () {
                  _searchController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _searchController.value.text.length);
                },
                style: TextStyle(fontSize: 18.sp),
                scrollPadding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 50),
                decoration: InputDecoration(
                  // labelText: AppLocalizations.of(context)!
                  //     .translate('search'),
                  hintText: AppLocalizations.of(context)!
                      .translate("search_with_truck_number"),
                  hintStyle: TextStyle(fontSize: 18.sp),
                  suffixIcon: InkWell(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();

                      if (_searchController.text.isNotEmpty) {
                        BlocProvider.of<TrucksListBloc>(context)
                            .add(TrucksListSearchEvent(_searchController.text));
                      }
                    },
                    child: const Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    // setState(() {
                    //   isSearch = false;
                    // });
                  }
                },
                onFieldSubmitted: (value) {
                  _searchController.text = value;
                  if (value.isNotEmpty) {
                    BlocProvider.of<TrucksListBloc>(context)
                        .add(TrucksListSearchEvent(_searchController.text));
                  }
                },
              ),
              SizedBox(
                height: 10.h,
              ),
              BlocBuilder<TruckTypeBloc, TruckTypeState>(
                builder: (context, state2) {
                  if (state2 is TruckTypeLoadedSuccess) {
                    return DropdownButtonHideUnderline(
                      child: DropdownButton2<TruckType>(
                        isExpanded: true,
                        hint: Text(
                          AppLocalizations.of(context)!
                              .translate('select_truck_type'),
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        items: state2.truckTypes
                            .map((TruckType item) =>
                                DropdownMenuItem<TruckType>(
                                  value: item,
                                  child: SizedBox(
                                    width: 200,
                                    child: Text(
                                      lang == "en" ? item.name! : item.nameAr!,
                                      style: const TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                        value: truckProvider.truckType,
                        onChanged: (TruckType? value) {
                          truckProvider.setTruckType(value!);
                          BlocProvider.of<TrucksListBloc>(context)
                              .add(TrucksListLoadEvent([value.id!]));
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 50,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black26,
                            ),
                            color: Colors.white,
                          ),
                          // elevation: 2,
                        ),
                        iconStyleData: IconStyleData(
                          icon: const Icon(
                            Icons.keyboard_arrow_down_sharp,
                          ),
                          iconSize: 20,
                          iconEnabledColor: AppColor.deepYellow,
                          iconDisabledColor: Colors.grey,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                          ),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(40),
                            thickness: MaterialStateProperty.all(6),
                            thumbVisibility: MaterialStateProperty.all(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                        ),
                      ),
                    );
                  } else if (state2 is TruckTypeLoadingProgress) {
                    return const Center(
                      child: LinearProgressIndicator(),
                    );
                  } else if (state2 is TruckTypeLoadedFailed) {
                    return Center(
                      child: InkWell(
                        onTap: () {
                          BlocProvider.of<TruckTypeBloc>(context)
                              .add(TruckTypeLoadEvent());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .translate('list_error'),
                              style: const TextStyle(color: Colors.red),
                            ),
                            const Icon(
                              Icons.refresh,
                              color: Colors.grey,
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
              SizedBox(
                height: 10.h,
              ),
              BlocBuilder<TrucksListBloc, TrucksListState>(
                builder: (context, state) {
                  if (state is TrucksListLoadedSuccess) {
                    return state.trucks.isEmpty
                        ? Expanded(
                            child: Center(
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 100,
                                  ),
                                  SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: SvgPicture.asset(
                                        "assets/icons/search_truck.svg"),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .translate('search_for_truck'),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: state.trucks.length,
                              // physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return truckProvider.selectedTruck
                                        .contains(state.trucks[index].id)
                                    ? const SizedBox.shrink()
                                    : InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TruckDetailsScreen(
                                                  truck: state.trucks[index],
                                                  index: selectedIndex,
                                                  ops: 'create_shipment',
                                                  subshipmentId: 0,
                                                ),
                                              ));
                                          // shipmentProvider.setTruck(state.trucks[index], selectedIndex);
                                          // Navigator.pop(context);
                                        },
                                        child: Card(
                                          elevation: 2,
                                          clipBehavior: Clip.antiAlias,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          color: Colors.white,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.network(
                                                state.trucks[index].images![0]
                                                    .image!,
                                                height: 175.h,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    height: 175.h,
                                                    width: double.infinity,
                                                    color: Colors.grey[300],
                                                    child: const Center(
                                                      child: Text(
                                                          "error on loading "),
                                                    ),
                                                  );
                                                },
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }

                                                  return SizedBox(
                                                    height: 175.h,
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              SizedBox(
                                                height: 7.h,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${AppLocalizations.of(context)!.translate('driver_name')}: ${state.trucks[index].truckuser!.usertruck!.firstName} ${state.trucks[index].truckuser!.usertruck!.lastName}',
                                                      style: TextStyle(
                                                          // color: AppColor.lightBlue,
                                                          fontSize: 18.sp,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      height: 7.h,
                                                    ),
                                                    Text(
                                                      '${AppLocalizations.of(context)!.translate('net_weight')}: ${state.trucks[index].emptyWeight}',
                                                      style: TextStyle(
                                                          // color: AppColor.lightBlue,
                                                          fontSize: 18.sp,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      height: 7.h,
                                                    ),
                                                    Text(
                                                      '${AppLocalizations.of(context)!.translate('truck_number')}: ${state.trucks[index].truckNumber}',
                                                      style: TextStyle(
                                                          // color: AppColor.lightBlue,
                                                          fontSize: 18.sp,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      height: 7.h,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                              },
                            ),
                          );
                  } else {
                    return Expanded(
                      child: Shimmer.fromColors(
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
                                height: 250.h,
                                width: double.infinity,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                          itemCount: 6,
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        );
      }),
    );
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
                body: SingleChildScrollView(
                  // controller: controller,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        shipmentProvider.countpath > 1
                            ? pathList(shipmentProvider, context)
                            : const SizedBox.shrink(),
                        SizedBox(height: 20.h),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                EnsureVisibleWhenFocused(
                                  focusNode: _path_node,
                                  child: Card(
                                    key: key3,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 7.5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (shipmentProvider
                                                  .pathConfirm[selectedIndex]) {
                                                mapIndex = selectedIndex;
                                                showShipmentPathModalSheet(
                                                    context,
                                                    localeState
                                                        .value.countryCode!);
                                              }
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                shipmentProvider.pathConfirm[
                                                        selectedIndex]
                                                    ? SizedBox(
                                                        height: 25.h,
                                                        width: 25.h,
                                                        child: SvgPicture.asset(
                                                            "assets/icons/shipment_path.svg"),
                                                      )
                                                    : const SizedBox.shrink(),
                                                const SizedBox(width: 7),
                                                SectionTitle(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .translate(
                                                          'shippment_path'),
                                                ),
                                                const Spacer(),
                                                shipmentProvider.pathConfirm[
                                                        selectedIndex]
                                                    ? Icon(
                                                        Icons.edit,
                                                        color:
                                                            AppColor.deepYellow,
                                                      )
                                                    : const SizedBox.shrink(),
                                                const SizedBox(width: 10),
                                              ],
                                            ),
                                          ),
                                          !(shipmentProvider
                                                  .pathConfirm[selectedIndex])
                                              ? InkWell(
                                                  onTap: () {
                                                    mapIndex = selectedIndex;
                                                    showShipmentPathModalSheet(
                                                        context,
                                                        localeState.value
                                                            .countryCode!);
                                                  },
                                                  child: AbsorbPointer(
                                                    absorbing: true,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: Colors.grey,
                                                        ),
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
                                                            !(shipmentProvider
                                                                        .pickup_controller[
                                                                            selectedIndex]
                                                                        .text
                                                                        .isNotEmpty &&
                                                                    shipmentProvider
                                                                        .delivery_controller[
                                                                            selectedIndex]
                                                                        .text
                                                                        .isNotEmpty)
                                                                ? SizedBox(
                                                                    height:
                                                                        25.h,
                                                                    width: 25.h,
                                                                    child: SvgPicture
                                                                        .asset(
                                                                            "assets/icons/shipment_path.svg"),
                                                                  )
                                                                : const SizedBox
                                                                    .shrink(),
                                                            const SizedBox(
                                                                width: 8),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child:
                                                                  SectionTitle(
                                                                text: AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'choose_shippment_path'),
                                                              ),
                                                            ),
                                                            Spacer(),
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
                                            visible: shipmentProvider
                                                .pathConfirm[selectedIndex],
                                            child:
                                                AddShipmentPathVerticalWidget(
                                              stations: shipmentProvider
                                                      .stoppoints_controller[
                                                  selectedIndex],
                                              pickup: shipmentProvider
                                                      .pickup_controller[
                                                  selectedIndex],
                                              delivery: shipmentProvider
                                                      .delivery_controller[
                                                  selectedIndex],
                                            ),
                                          ),
                                          Visibility(
                                            visible: shipmentProvider
                                                .pathError[selectedIndex],
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
                                  ),
                                ),
                                BlocListener<DrawRouteBloc, DrawRouteState>(
                                  listener: (context, state) {
                                    if (state is DrawRouteSuccess) {
                                      Future.delayed(
                                              const Duration(milliseconds: 400))
                                          .then((value) {
                                        if (shipmentProvider
                                            .delivery_controller[selectedIndex]
                                            .text
                                            .isNotEmpty) {
                                          // getPolyPoints();
                                          shipmentProvider
                                              .initMapbounds(selectedIndex);
                                        }
                                      });
                                    }
                                  },
                                  child: pickupicon != null
                                      ? Container(
                                          color: Colors.white,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 200.h,
                                                child: AbsorbPointer(
                                                  absorbing: false,
                                                  child: GoogleMap(
                                                    onMapCreated: (controller) {
                                                      shipmentProvider
                                                          .onMapCreated(
                                                              controller,
                                                              _mapStyle);
                                                    },
                                                    myLocationButtonEnabled:
                                                        false,
                                                    zoomGesturesEnabled: false,
                                                    scrollGesturesEnabled:
                                                        false,
                                                    tiltGesturesEnabled: false,
                                                    rotateGesturesEnabled:
                                                        false,
                                                    zoomControlsEnabled: false,
                                                    myLocationEnabled: false,
                                                    initialCameraPosition:
                                                        CameraPosition(
                                                      target: shipmentProvider
                                                          .center,
                                                      zoom:
                                                          shipmentProvider.zoom,
                                                    ),
                                                    gestureRecognizers: {},
                                                    markers: (shipmentProvider
                                                                .pickup_location[
                                                                    selectedIndex]
                                                                .isNotEmpty ||
                                                            shipmentProvider
                                                                .delivery_location[
                                                                    selectedIndex]
                                                                .isNotEmpty)
                                                        ? {
                                                            shipmentProvider
                                                                    .pickup_location[
                                                                        selectedIndex]
                                                                    .isNotEmpty
                                                                ? Marker(
                                                                    markerId:
                                                                        const MarkerId(
                                                                            "pickup"),
                                                                    position: LatLng(
                                                                        double.parse(shipmentProvider.pickup_location[selectedIndex].split(",")[
                                                                            0]),
                                                                        double.parse(shipmentProvider
                                                                            .pickup_location[selectedIndex]
                                                                            .split(",")[1])),
                                                                    icon:
                                                                        pickupicon!,
                                                                  )
                                                                : const Marker(
                                                                    markerId:
                                                                        MarkerId(
                                                                            "pickup"),
                                                                  ),
                                                            shipmentProvider.delivery_latlng[
                                                                        selectedIndex] !=
                                                                    null
                                                                ? Marker(
                                                                    markerId:
                                                                        const MarkerId(
                                                                            "delivery"),
                                                                    position: LatLng(
                                                                        double.parse(shipmentProvider.delivery_location[selectedIndex].split(",")[
                                                                            0]),
                                                                        double.parse(shipmentProvider
                                                                            .delivery_location[selectedIndex]
                                                                            .split(",")[1])),
                                                                    icon:
                                                                        deliveryicon,
                                                                  )
                                                                : const Marker(
                                                                    markerId:
                                                                        MarkerId(
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
                                                                        .pathes[
                                                                    selectedIndex])),
                                                        color:
                                                            AppColor.deepYellow,
                                                        width: 7,
                                                      ),
                                                    },
                                                  ),
                                                ),
                                              ),
                                              shipmentProvider.distance[
                                                          selectedIndex] !=
                                                      0
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 7.5),
                                                      child:
                                                          PathStatisticsWidget(
                                                        distance:
                                                            shipmentProvider
                                                                    .distance[
                                                                selectedIndex],
                                                        period: shipmentProvider
                                                                .period[
                                                            selectedIndex],
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  child: EnsureVisibleWhenFocused(
                                    focusNode: _truck_node,
                                    child: Card(
                                      elevation: 2,
                                      key: key2,
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 7.5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                if (shipmentProvider
                                                        .pickup_location[
                                                            selectedIndex]
                                                        .isNotEmpty &&
                                                    shipmentProvider
                                                        .delivery_location[
                                                            selectedIndex]
                                                        .isNotEmpty) {
                                                  if (shipmentProvider.trucks[
                                                          selectedIndex] !=
                                                      null) {
                                                    showTruckModalSheet(
                                                        context,
                                                        localeState.value
                                                            .languageCode);
                                                  }
                                                } else {
                                                  shipmentProvider.setPathError(
                                                      true, selectedIndex);
                                                  Scrollable.ensureVisible(
                                                    key3.currentContext!,
                                                    duration: const Duration(
                                                      milliseconds: 500,
                                                    ),
                                                  );
                                                }
                                              },
                                              child: AbsorbPointer(
                                                absorbing: true,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    shipmentProvider.trucks[
                                                                selectedIndex] !=
                                                            null
                                                        ? SizedBox(
                                                            height: 25.h,
                                                            width: 25.h,
                                                            child: localeState
                                                                        .value
                                                                        .languageCode ==
                                                                    "en"
                                                                ? SvgPicture.asset(
                                                                    "assets/icons/truck.svg")
                                                                : SvgPicture.asset(
                                                                    "assets/icons/truck_ar.svg"),
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
                                                    const SizedBox(width: 8),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: SectionTitle(
                                                        text: AppLocalizations
                                                                .of(context)!
                                                            .translate(
                                                                'truck_info'),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    shipmentProvider.trucks[
                                                                selectedIndex] !=
                                                            null
                                                        ? Icon(Icons.edit,
                                                            color: AppColor
                                                                .deepYellow)
                                                        : const SizedBox
                                                            .shrink(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            shipmentProvider.trucks[
                                                        selectedIndex] ==
                                                    null
                                                ? InkWell(
                                                    onTap: () {
                                                      if (shipmentProvider
                                                              .pickup_location[
                                                                  selectedIndex]
                                                              .isNotEmpty &&
                                                          shipmentProvider
                                                              .delivery_location[
                                                                  selectedIndex]
                                                              .isNotEmpty) {
                                                        showTruckModalSheet(
                                                            context,
                                                            localeState.value
                                                                .languageCode);
                                                      } else {
                                                        shipmentProvider
                                                            .setPathError(true,
                                                                selectedIndex);
                                                        Scrollable
                                                            .ensureVisible(
                                                          key3.currentContext!,
                                                          duration:
                                                              const Duration(
                                                            milliseconds: 500,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: AbsorbPointer(
                                                      absorbing: true,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                            width: 1,
                                                            color: Colors.grey,
                                                          ),
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
                                                              shipmentProvider.trucks[
                                                                          selectedIndex] ==
                                                                      null
                                                                  ? SizedBox(
                                                                      height:
                                                                          25.h,
                                                                      width:
                                                                          25.h,
                                                                      child: localeState.value.languageCode ==
                                                                              "en"
                                                                          ? SvgPicture.asset(
                                                                              "assets/icons/truck.svg")
                                                                          : SvgPicture.asset(
                                                                              "assets/icons/truck_ar.svg"),
                                                                    )
                                                                  : const SizedBox
                                                                      .shrink(),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        4.0),
                                                                child:
                                                                    SectionTitle(
                                                                  text: AppLocalizations.of(
                                                                          context)!
                                                                      .translate(
                                                                          'select_truck'),
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              shipmentProvider.trucks[
                                                                          selectedIndex] !=
                                                                      null
                                                                  ? Icon(
                                                                      Icons
                                                                          .edit,
                                                                      color: AppColor
                                                                          .deepYellow)
                                                                  : Icon(
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
                                            shipmentProvider.trucks[
                                                        selectedIndex] !=
                                                    null
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Image.network(
                                                        shipmentProvider
                                                            .trucks[
                                                                selectedIndex]!
                                                            .images![0]
                                                            .image!,
                                                        height: 175.h,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Container(
                                                            height: 175.h,
                                                            width:
                                                                double.infinity,
                                                            color: Colors
                                                                .grey[300],
                                                            child: const Center(
                                                              child: Text(
                                                                  "error on loading "),
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

                                                          return SizedBox(
                                                            height: 175.h,
                                                            child: Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                value: loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null
                                                                    ? loadingProgress
                                                                            .cumulativeBytesLoaded /
                                                                        loadingProgress
                                                                            .expectedTotalBytes!
                                                                    : null,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      SizedBox(
                                                        height: 7.h,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SectionBody(
                                                              text:
                                                                  '${AppLocalizations.of(context)!.translate('driver_name')}: ${shipmentProvider.trucks[selectedIndex]!.truckuser!.usertruck!.firstName} ${shipmentProvider.trucks[selectedIndex]!.truckuser!.usertruck!.lastName}',
                                                            ),
                                                            SizedBox(
                                                              height: 7.h,
                                                            ),
                                                            SectionBody(
                                                              text:
                                                                  '${AppLocalizations.of(context)!.translate('net_weight')}: ${shipmentProvider.trucks[selectedIndex]!.emptyWeight}',
                                                            ),
                                                            SizedBox(
                                                              height: 7.h,
                                                            ),
                                                            SectionBody(
                                                              text:
                                                                  '${AppLocalizations.of(context)!.translate('truck_number')}: ${shipmentProvider.trucks[selectedIndex]!.truckNumber}',
                                                            ),
                                                            SizedBox(
                                                              height: 7.h,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : const SizedBox.shrink(),
                                            Visibility(
                                              visible: shipmentProvider
                                                  .truckError[selectedIndex],
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
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
                                                  SizedBox(
                                                    height: 7.h,
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
                                EnsureVisibleWhenFocused(
                                  focusNode: _commodity_node,
                                  child: SizedBox(
                                    key: key1,
                                    child: Form(
                                      key: shipmentProvider
                                          .addShipmentformKey[selectedIndex],
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: shipmentProvider
                                              .count[selectedIndex],
                                          itemBuilder: (context, index2) {
                                            return Stack(
                                              children: [
                                                Card(
                                                  elevation: 2,
                                                  color: Colors.white,
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
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
                                                                  SizedBox(
                                                                    height:
                                                                        25.h,
                                                                    width: 25.h,
                                                                    child: SvgPicture
                                                                        .asset(
                                                                            "assets/icons/goods_information.svg"),
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
                                                          height: 7,
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
                                                                    fontSize:
                                                                        20),
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
                                                                (event) {},
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
                                                                        'insert_value_validate');
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
                                                          height: 12,
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
                                                              FilteringTextInputFormatter
                                                                  .digitsOnly,
                                                            ],
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        20),
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
                                                                (event) {},
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
                                                                        'insert_value_validate');
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
                                                              BlocProvider.of<
                                                                          BottomNavBarCubit>(
                                                                      context)
                                                                  .emitShow();
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 12,
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
                                                                              selectedIndex);
                                                                    },
                                                                    child: Text(
                                                                      "إضافة بضاعة  ",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: AppColor
                                                                            .deepYellow,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  // InkWell(
                                                                  //   onTap: () =>
                                                                  //       shipmentProvider
                                                                  //           .additem(selectedIndex),
                                                                  //   child:
                                                                  //       AbsorbPointer(
                                                                  //     absorbing:
                                                                  //         true,
                                                                  //     child:
                                                                  //         Padding(
                                                                  //       padding: const EdgeInsets
                                                                  //           .all(
                                                                  //           8.0),
                                                                  //       child:
                                                                  //           SizedBox(
                                                                  //         height:
                                                                  //             32.h,
                                                                  //         width:
                                                                  //             32.w,
                                                                  //         child:
                                                                  //             SvgPicture.asset("assets/icons/add.svg"),
                                                                  //       ),
                                                                  //     ),
                                                                  //   ),
                                                                  // ),
                                                                ],
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                (shipmentProvider.count[
                                                            selectedIndex] >
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
                                                                  Radius
                                                                      .circular(
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
                                                                  Radius
                                                                      .circular(
                                                                          5)
                                                              // :
                                                              // const Radius
                                                              //     .circular(
                                                              //     15)
                                                              ,
                                                              bottomLeft: Radius
                                                                  .circular(5),
                                                              bottomRight:
                                                                  Radius
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
                                                                    index2);
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
                                                                      .circular(
                                                                          45),
                                                            ),
                                                            child: const Center(
                                                              child: Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .white,
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
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 1.5),
                                  child: Card(
                                    elevation: 2,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 7.5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SectionTitle(
                                            text: AppLocalizations.of(context)!
                                                .translate('loading_time'),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .45,
                                                child: InkWell(
                                                  onTap: () {
                                                    _showDatePicker(
                                                        selectedIndex,
                                                        localeState.value
                                                            .languageCode);
                                                  },
                                                  child: TextFormField(
                                                    controller: shipmentProvider
                                                            .date_controller[
                                                        selectedIndex],
                                                    enabled: false,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .translate(
                                                                  'date'),
                                                      floatingLabelStyle:
                                                          const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 11.0,
                                                              horizontal: 9.0),
                                                      suffixIcon: Icon(
                                                        Icons.calendar_month,
                                                        color: Colors.grey[900],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .45,
                                                child: InkWell(
                                                  onTap: () {
                                                    _showTimePicker(
                                                        selectedIndex);
                                                  },
                                                  child: TextFormField(
                                                    controller: shipmentProvider
                                                            .time_controller[
                                                        selectedIndex],
                                                    enabled: false,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .translate(
                                                                  'time'),
                                                      floatingLabelStyle:
                                                          const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 11.0,
                                                              horizontal: 9.0),
                                                      suffixIcon: Icon(
                                                        Icons.timer_outlined,
                                                        color: Colors.grey[900],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Visibility(
                                            visible: shipmentProvider
                                                .dateError[selectedIndex],
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
                                                            'pick_date_error'),
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Visibility(
                                            visible: false,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        "there is no available route change destination.",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 17,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Divider(),
                                          Visibility(
                                            visible: addShippmentProvider!
                                                .truckConfirm[selectedIndex],
                                            child: Text(
                                                "الرجاء اكمال بيانات الشاحنة الحالية قبل إضافة شاحنة أخرى.",
                                                style: TextStyle(
                                                  color: Colors.red[400],
                                                )),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  if (addShippmentProvider!
                                                          .pickup_location[
                                                              selectedIndex]
                                                          .isNotEmpty ||
                                                      addShippmentProvider!
                                                          .delivery_location[
                                                              selectedIndex]
                                                          .isNotEmpty) {
                                                    if (addShippmentProvider!
                                                                .trucks[
                                                            selectedIndex] !=
                                                        null) {
                                                      if (addShippmentProvider!
                                                          .addShipmentformKey[
                                                              selectedIndex]
                                                          .currentState!
                                                          .validate()) {
                                                        addShippmentProvider!
                                                            .setTruckConfirm(
                                                                false,
                                                                selectedIndex);
                                                        Scrollable
                                                            .ensureVisible(
                                                          key3.currentContext!,
                                                          duration:
                                                              const Duration(
                                                            milliseconds: 500,
                                                          ),
                                                        );
                                                        addShippmentProvider!
                                                            .addpath();
                                                        setState(() {
                                                          selectedIndex++;
                                                        });
                                                      } else {
                                                        addShippmentProvider!
                                                            .setTruckConfirm(
                                                                true,
                                                                selectedIndex);
                                                      }
                                                    } else {
                                                      addShippmentProvider!
                                                          .setTruckConfirm(true,
                                                              selectedIndex);
                                                    }
                                                  } else {
                                                    addShippmentProvider!
                                                        .setTruckConfirm(true,
                                                            selectedIndex);
                                                  }
                                                },
                                                child: Row(
                                                  children: [
                                                    const Text(
                                                      "إضافة شاحنة ",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        // fontWeight:
                                                        // FontWeight.bold,
                                                        // color: Colors.white,
                                                      ),
                                                    ),
                                                    AbsorbPointer(
                                                      absorbing: true,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: SizedBox(
                                                          height: 25.h,
                                                          width: 25.w,
                                                          child: SvgPicture.asset(
                                                              "assets/icons/add.svg"),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2.5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                // (shipmentProvider.countpath >
                                                //             1) &&
                                                //         (selectedIndex != 0)
                                                //     ? SizedBox(
                                                //         width: MediaQuery.of(
                                                //                     context)
                                                //                 .size
                                                //                 .width *
                                                //             .15,
                                                //         child: CustomButton(
                                                //           color: Colors.red,
                                                //           title: const Center(
                                                //             child: Icon(
                                                //               Icons.close,
                                                //               color:
                                                //                   Colors.white,
                                                //             ),
                                                //           ),
                                                //           onTap: () {
                                                //             shipmentProvider
                                                //                 .removePath(
                                                //               selectedIndex,
                                                //             );
                                                //             if (selectedIndex >
                                                //                 0) {
                                                //               setState(() {
                                                //                 selectedIndex--;
                                                //               });
                                                //             }
                                                //             setState(() {});
                                                //           },
                                                //         ),
                                                //       )
                                                //     : SizedBox(
                                                //         width: MediaQuery.of(
                                                //                     context)
                                                //                 .size
                                                //                 .width *
                                                //             .15,
                                                //         child: CustomButton(
                                                //           color: Colors.red,
                                                //           title: const Center(
                                                //             child: Icon(
                                                //               Icons.delete,
                                                //               color:
                                                //                   Colors.white,
                                                //             ),
                                                //           ),
                                                //           onTap: () {
                                                //             showDialog<void>(
                                                //               context: context,
                                                //               barrierDismissible:
                                                //                   false, // user must tap button!
                                                //               builder:
                                                //                   (BuildContext
                                                //                       context) {
                                                //                 return AlertDialog(
                                                //                   backgroundColor:
                                                //                       Colors
                                                //                           .white,
                                                //                   title: Text(AppLocalizations.of(
                                                //                           context)!
                                                //                       .translate(
                                                //                           'form_init')),
                                                //                   content:
                                                //                       SingleChildScrollView(
                                                //                     child:
                                                //                         ListBody(
                                                //                       children: <Widget>[
                                                //                         Text(
                                                //                             AppLocalizations.of(context)!.translate(
                                                //                                 'form_init_confirm'),
                                                //                             style:
                                                //                                 const TextStyle(fontSize: 18)),
                                                //                       ],
                                                //                     ),
                                                //                   ),
                                                //                   actions: <Widget>[
                                                //                     TextButton(
                                                //                       child: Text(
                                                //                           AppLocalizations.of(context)!.translate(
                                                //                               'no'),
                                                //                           style:
                                                //                               const TextStyle(fontSize: 18)),
                                                //                       onPressed:
                                                //                           () {
                                                //                         Navigator.of(context)
                                                //                             .pop();
                                                //                       },
                                                //                     ),
                                                //                     TextButton(
                                                //                       child: Text(
                                                //                           AppLocalizations.of(context)!.translate(
                                                //                               'yes'),
                                                //                           style:
                                                //                               const TextStyle(fontSize: 18)),
                                                //                       onPressed:
                                                //                           () {
                                                //                         shipmentProvider
                                                //                             .initForm();
                                                //                         Navigator.of(context)
                                                //                             .pop();
                                                //                         setState(
                                                //                           () {},
                                                //                         );
                                                //                       },
                                                //                     ),
                                                //                   ],
                                                //                 );
                                                //               },
                                                //             );
                                                //           },
                                                //         ),
                                                //       ),
                                                BlocConsumer<
                                                    ShipmentMultiCreateBloc,
                                                    ShipmentMultiCreateState>(
                                                  listener: (context, state) {
                                                    if (state
                                                        is ShipmentMultiCreateSuccessState) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                        content: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .translate(
                                                                    'shipment_created_success')),
                                                        duration:
                                                            const Duration(
                                                                seconds: 3),
                                                      ));
                                                      shipmentProvider
                                                          .initForm();

                                                      Navigator
                                                          .pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const ControlView(),
                                                        ),
                                                        (route) => false,
                                                      );
                                                    }
                                                    if (state
                                                        is ShipmentMultiCreateFailureState) {
                                                      print(state.errorMessage);
                                                    }
                                                  },
                                                  builder: (context, state) {
                                                    if (state
                                                        is ShippmentLoadingProgressState) {
                                                      return SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .92,
                                                        child: CustomButton(
                                                          title:
                                                              const LoadingIndicator(),
                                                          onTap: () {},
                                                        ),
                                                      );
                                                    } else {
                                                      return SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .92,
                                                        child: CustomButton(
                                                          title: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .translate(
                                                                    'create_shipment'),
                                                            style: TextStyle(
                                                              fontSize: 20.sp,
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            if (shipmentProvider
                                                                .pickup_location[
                                                                    selectedIndex]
                                                                .isNotEmpty) {
                                                              if (shipmentProvider
                                                                  .delivery_location[
                                                                      selectedIndex]
                                                                  .isNotEmpty) {
                                                                if (shipmentProvider
                                                                            .trucks[
                                                                        selectedIndex] !=
                                                                    null) {
                                                                  if (shipmentProvider
                                                                      .addShipmentformKey[
                                                                          selectedIndex]
                                                                      .currentState!
                                                                      .validate()) {
                                                                    for (var element
                                                                        in shipmentProvider
                                                                            .addShipmentformKey) {
                                                                      element
                                                                          .currentState
                                                                          ?.save();
                                                                    }

                                                                    List<SubShipment>
                                                                        subshipmentsitems =
                                                                        [];

                                                                    for (var i =
                                                                            0;
                                                                        i < shipmentProvider.pickup_controller.length;
                                                                        i++) {
                                                                      List<ShipmentItems>
                                                                          shipmentitems =
                                                                          [];

                                                                      int totalWeight =
                                                                          0;
                                                                      for (var j =
                                                                              0;
                                                                          j < shipmentProvider.commodityWeight_controllers[i].length;
                                                                          j++) {
                                                                        ShipmentItems
                                                                            shipmentitem =
                                                                            ShipmentItems(
                                                                          commodityName: shipmentProvider
                                                                              .commodityName_controllers[i][j]
                                                                              .text,
                                                                          commodityWeight:
                                                                              double.parse(shipmentProvider.commodityWeight_controllers[i][j].text.replaceAll(",", "")).toInt(),
                                                                        );
                                                                        shipmentitems
                                                                            .add(shipmentitem);
                                                                        totalWeight +=
                                                                            double.parse(shipmentProvider.commodityWeight_controllers[i][j].text.replaceAll(",", "")).toInt();
                                                                      }

                                                                      List<PathPoint>
                                                                          points =
                                                                          [];
                                                                      points
                                                                          .add(
                                                                        PathPoint(
                                                                          pointType:
                                                                              "P",
                                                                          location:
                                                                              "${shipmentProvider.pickup_latlng[i]!.latitude},${shipmentProvider.pickup_latlng[i]!.longitude}",
                                                                          name: shipmentProvider
                                                                              .pickup_controller[i]
                                                                              .text,
                                                                          nameEn:
                                                                              shipmentProvider.pickup_eng_string[i],
                                                                          number:
                                                                              0,
                                                                          city:
                                                                              1,
                                                                        ),
                                                                      );
                                                                      points
                                                                          .add(
                                                                        PathPoint(
                                                                          pointType:
                                                                              "D",
                                                                          location:
                                                                              "${shipmentProvider.delivery_latlng[i]!.latitude},${shipmentProvider.delivery_latlng[i]!.longitude}",
                                                                          name: shipmentProvider
                                                                              .delivery_controller[i]
                                                                              .text,
                                                                          nameEn:
                                                                              shipmentProvider.delivery_eng_string[i],
                                                                          number:
                                                                              0,
                                                                          city:
                                                                              1,
                                                                        ),
                                                                      );

                                                                      for (var s =
                                                                              0;
                                                                          s < shipmentProvider.stoppoints_controller[i].length;
                                                                          s++) {
                                                                        points
                                                                            .add(
                                                                          PathPoint(
                                                                            pointType:
                                                                                "S",
                                                                            location:
                                                                                "${shipmentProvider.stoppoints_latlng[i][s]!.latitude},${shipmentProvider.stoppoints_latlng[i][s]!.longitude}",
                                                                            name:
                                                                                shipmentProvider.stoppoints_controller[i][s].text,
                                                                            nameEn:
                                                                                shipmentProvider.stoppoints_eng_string[i][s],
                                                                            number:
                                                                                s,
                                                                            city:
                                                                                1,
                                                                          ),
                                                                        );
                                                                      }

                                                                      SubShipment
                                                                          subshipment =
                                                                          SubShipment(
                                                                        shipmentStatus:
                                                                            "P",
                                                                        paths: jsonEncode(
                                                                            shipmentProvider.pathes[i]),
                                                                        shipmentItems:
                                                                            shipmentitems,
                                                                        totalWeight:
                                                                            totalWeight,
                                                                        distance:
                                                                            shipmentProvider.distance[i],
                                                                        period:
                                                                            shipmentProvider.period[i],
                                                                        pathpoints:
                                                                            points,
                                                                        truck: ShipmentTruck(
                                                                            id: shipmentProvider.trucks[selectedIndex]!.id!),
                                                                        // truckTypes: truckTypes,
                                                                        pickupDate:
                                                                            DateTime(
                                                                          shipmentProvider
                                                                              .loadDate[i]
                                                                              .year,
                                                                          shipmentProvider
                                                                              .loadDate[i]
                                                                              .month,
                                                                          shipmentProvider
                                                                              .loadDate[i]
                                                                              .day,
                                                                          shipmentProvider
                                                                              .loadTime[i]
                                                                              .hour,
                                                                          shipmentProvider
                                                                              .loadTime[i]
                                                                              .day,
                                                                        ),
                                                                        deliveryDate:
                                                                            DateTime(
                                                                          shipmentProvider
                                                                              .loadDate[i]
                                                                              .year,
                                                                          shipmentProvider
                                                                              .loadDate[i]
                                                                              .month,
                                                                          shipmentProvider
                                                                              .loadDate[i]
                                                                              .day,
                                                                          shipmentProvider
                                                                              .loadTime[i]
                                                                              .hour,
                                                                          shipmentProvider
                                                                              .loadTime[i]
                                                                              .day,
                                                                        ),
                                                                      );
                                                                      subshipmentsitems
                                                                          .add(
                                                                              subshipment);
                                                                    }

                                                                    Shipmentv2
                                                                        shipment =
                                                                        Shipmentv2(
                                                                      subshipments:
                                                                          subshipmentsitems,
                                                                    );

                                                                    BlocProvider.of<ShipmentMultiCreateBloc>(
                                                                            context)
                                                                        .add(
                                                                      ShipmentMultiCreateButtonPressed(
                                                                        shipment,
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    Scrollable
                                                                        .ensureVisible(
                                                                      key1.currentContext!,
                                                                      duration:
                                                                          const Duration(
                                                                        milliseconds:
                                                                            500,
                                                                      ),
                                                                    );
                                                                  }
                                                                } else {
                                                                  shipmentProvider
                                                                      .setTruckError(
                                                                          true,
                                                                          selectedIndex);
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
                                                                shipmentProvider
                                                                    .setPathError(
                                                                        true,
                                                                        selectedIndex);

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
                                                              shipmentProvider
                                                                  .setPathError(
                                                                      true,
                                                                      selectedIndex);
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
                                                          },
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            (shipmentProvider.countpath > 1) &&
                                    (selectedIndex != 0)
                                ? Positioned(
                                    left: 5,
                                    top: -10,
                                    child: InkWell(
                                      onTap: () {
                                        shipmentProvider.removePath(
                                          selectedIndex,
                                        );
                                        if (selectedIndex > 0) {
                                          setState(() {
                                            selectedIndex--;
                                          });
                                        }
                                        setState(() {});
                                        // _showAlertDialog(index);
                                      },
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[600],
                                          borderRadius:
                                              BorderRadius.circular(45),
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
                                : Positioned(
                                    left: 5,
                                    top: -10,
                                    child: InkWell(
                                      onTap: () {
                                        showDialog<void>(
                                          context: context,
                                          barrierDismissible:
                                              false, // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: Text(
                                                  AppLocalizations.of(context)!
                                                      .translate('form_init')),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .translate(
                                                                'form_init_confirm'),
                                                        style: const TextStyle(
                                                            fontSize: 18)),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .translate('no'),
                                                      style: const TextStyle(
                                                          fontSize: 18)),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .translate('yes'),
                                                      style: const TextStyle(
                                                          fontSize: 18)),
                                                  onPressed: () {
                                                    shipmentProvider.initForm();
                                                    Navigator.of(context).pop();
                                                    setState(
                                                      () {},
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[600],
                                          borderRadius:
                                              BorderRadius.circular(45),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.sync_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
