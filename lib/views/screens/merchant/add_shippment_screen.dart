// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/core/draw_route_bloc.dart';
import 'package:camion/business_logic/bloc/core/k_commodity_category_bloc.dart';
import 'package:camion/business_logic/bloc/core/search_category_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/create_price_request_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shippment_create_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/commodity_category_model.dart';
import 'package:camion/data/models/kshipment_model.dart';
import 'package:camion/data/providers/add_shippment_provider.dart';
import 'package:camion/data/services/places_service.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/formatter.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/screens/merchant/add_shippment_pickup_map.dart';
import 'package:camion/views/screens/merchant/select_truck_widget.dart';
import 'package:camion/views/screens/merchant/shipment_map_preview.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ensure_visible_when_focused/ensure_visible_when_focused.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' as intel;

class AddShippmentScreen extends StatefulWidget {
  AddShippmentScreen({Key? key}) : super(key: key);

  @override
  State<AddShippmentScreen> createState() => _AddShippmentScreenState();
}

class _AddShippmentScreenState extends State<AddShippmentScreen> {
  final FocusNode _commodity_node = FocusNode();
  final FocusNode _truck_node = FocusNode();
  var key1 = GlobalKey();
  var key2 = GlobalKey();
  var key3 = GlobalKey();

  final GlobalKey<FormState> _addShipmentformKey = GlobalKey<FormState>();
  AddShippmentProvider? addShipmentProvider;
  String _mapStyle = "";
  String _darkmapStyle = "";

  TextEditingController _requestNameController = TextEditingController();

  late BitmapDescriptor pickupicon;
  late BitmapDescriptor deliveryicon;

  createMarkerIcons() async {
    pickupicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location1.png");
    deliveryicon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/icons/location2.png");
    setState(() {});
  }

  var f = intel.NumberFormat("#,###", "en_US");
  final TextEditingController _searchController = TextEditingController();
  bool isSearch = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      addShipmentProvider =
          Provider.of<AddShippmentProvider>(context, listen: false);
      createMarkerIcons();
    });

    rootBundle.loadString('assets/style/normal_style.json').then((string) {
      _mapStyle = string;
    });
    rootBundle.loadString('assets/style/map_style.json').then((string) {
      _darkmapStyle = string;
    });
  }

  @override
  void dispose() {
    addShipmentProvider!.dispose();
    super.dispose();
  }

  String getTruckType(int type) {
    switch (type) {
      case 1:
        return "سطحة";
      case 2:
        return "براد";
      case 3:
        return "حاوية";
      case 4:
        return "شحن";
      case 5:
        return "قاطرة ومقطورة";
      case 6:
        return "tier";
      default:
        return "سطحة";
    }
  }

  String weightLabel(String unit) {
    switch (unit) {
      case "طن":
        return "وزن البضاعة";
      case "كغ":
        return "وزن البضاعة";
      case "تنكة":
        return "العدد";
      default:
        return "وزن البضاعة";
    }
  }

  String getEnTruckType(int type) {
    switch (type) {
      case 1:
        return "Flatbed";
      case 2:
        return "Refrigerated";
      case 3:
        return "Container";
      case 4:
        return "Semi Trailer";
      case 5:
        return "Jumbo Trailer";
      case 6:
        return "tier";
      default:
        return "FlatBed";
    }
  }

  bool evaluateCo2() {
    // for (var element in commodityName_controllers) {
    //   if (element.text.isEmpty) {
    //     return false;
    //   }
    // }
    // for (var element in commodityWeight_controllers) {
    //   if (element.text.isEmpty) {
    //     return false;
    //   }
    // }
    if (addShipmentProvider!.delivery_controller.text.isNotEmpty &&
        addShipmentProvider!.pickup_controller.text.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  final FocusNode _nodeCommodityName = FocusNode();
  final FocusNode _orderTypenode = FocusNode();

  final FocusNode _nodeCommodityWeight = FocusNode();

  buildSubCategoriesTiles(List<KCommodityCategory>? subCategories, int index) {
    List<Widget> list = [];
    list.add(Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 0.0),
      child: ListView.builder(
        // key: Key('subchapterbuilder ${subchapterselected.toString()}'),
        shrinkWrap: true,
        itemCount: subCategories!.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index3) {
          return Column(
            children: [
              index3 == 0
                  ? Column(
                      children: [
                        Container(
                          color: Colors.grey[100],
                          // height: 30.h,
                          width: double.infinity,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'اسم البضاعة',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  'قيمة العبور',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: AppColor.deepYellow,
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
              InkWell(
                onTap: () {
                  addShipmentProvider!
                      .setCommodityCategory(subCategories[index3], index);
                  addShipmentProvider!.calculateCosts();
                  Navigator.pop(context);
                },
                child: AbsorbPointer(
                  absorbing: true,
                  child: SizedBox(
                    height: 55.h,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            subCategories[index3]!.nameAr!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            "${f.format(subCategories[index3]!.price! / subCategories[index3]!.weight!)} ${subCategories[index3]!.unit_type!}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              subCategories.length - 1 == index3
                  ? const SizedBox.shrink()
                  : Divider(
                      height: 1,
                      color: AppColor.deepYellow,
                    ),
            ],
          );
        },
      ),
    ));

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Consumer<AddShippmentProvider>(
              builder: (context, shipmentProvider, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Scaffold(
                  backgroundColor: AppColor.lightGrey200,
                  body: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              EnsureVisibleWhenFocused(
                                focusNode: _orderTypenode,
                                child: Card(
                                  key: key3,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      'select_operation_type'),
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              )),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .28,
                                            child: RadioListTile(
                                              contentPadding: EdgeInsets.zero,
                                              value: "I",
                                              groupValue: shipmentProvider
                                                  .selectedRadioTile,
                                              title: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .translate('import'),
                                                  overflow: TextOverflow.fade,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              // subtitle: Text("Radio 1 Subtitle"),
                                              onChanged: (val) {
                                                // print("Radio Tile pressed $val");
                                                shipmentProvider
                                                    .setSelectedRadioTile(val!);
                                              },
                                              activeColor: AppColor.deepYellow,
                                              selected: shipmentProvider
                                                      .selectedRadioTile ==
                                                  "I",
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .28,
                                            child: RadioListTile(
                                              value: "E",
                                              contentPadding: EdgeInsets.zero,

                                              groupValue: shipmentProvider
                                                  .selectedRadioTile,
                                              title: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .translate('export'),
                                                  overflow: TextOverflow.fade,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              // subtitle: Text("Radio 2 Subtitle"),
                                              onChanged: (val) {
                                                shipmentProvider
                                                    .setSelectedRadioTile(val!);
                                              },
                                              activeColor: AppColor.deepYellow,

                                              selected: shipmentProvider
                                                      .selectedRadioTile ==
                                                  "E",
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .28,
                                            child: RadioListTile(
                                              value: "T",
                                              contentPadding: EdgeInsets.zero,

                                              groupValue: shipmentProvider
                                                  .selectedRadioTile,
                                              title: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .translate('transsit'),
                                                  overflow: TextOverflow.fade,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              // subtitle: Text("Radio 2 Subtitle"),
                                              onChanged: (val) {
                                                shipmentProvider
                                                    .setSelectedRadioTile(val!);
                                              },
                                              activeColor: AppColor.deepYellow,

                                              selected: shipmentProvider
                                                      .selectedRadioTile ==
                                                  "T",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                                  ),
                                ),
                              ),
                              EnsureVisibleWhenFocused(
                                focusNode: _commodity_node,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      key: key1,
                                      child: Form(
                                        key: _addShipmentformKey,
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: shipmentProvider
                                                .commodityCategories.length,
                                            itemBuilder: (context, index) {
                                              return Stack(
                                                children: [
                                                  Card(
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
                                                          index == 0
                                                              ? Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                      shipmentProvider.count >
                                                                              1
                                                                          ? SizedBox(
                                                                              width: 35.w,
                                                                            )
                                                                          : const SizedBox
                                                                              .shrink(),
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .translate('commodity_info'),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              AppColor.darkGrey,
                                                                        ),
                                                                      ),
                                                                    ])
                                                              : const SizedBox
                                                                  .shrink(),
                                                          index != 0
                                                              ? const SizedBox(
                                                                  height: 30,
                                                                )
                                                              : const SizedBox
                                                                  .shrink(),
                                                          const SizedBox(
                                                            height: 7,
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              showModalBottomSheet(
                                                                context:
                                                                    context,
                                                                isScrollControlled:
                                                                    true,
                                                                useSafeArea:
                                                                    true,
                                                                builder: (context) =>
                                                                    Consumer<
                                                                        AddShippmentProvider>(
                                                                  builder: (context,
                                                                      valueProvider,
                                                                      child) {
                                                                    return Container(
                                                                      constraints:
                                                                          BoxConstraints(
                                                                        maxHeight: MediaQuery.of(context)
                                                                            .size
                                                                            .height,
                                                                        minHeight: MediaQuery.of(context)
                                                                            .size
                                                                            .height,
                                                                      ),
                                                                      width: double
                                                                          .infinity,
                                                                      child:
                                                                          Stack(
                                                                        alignment:
                                                                            Alignment.topCenter,
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                SingleChildScrollView(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  const SizedBox(
                                                                                    height: 160,
                                                                                  ),
                                                                                  valueProvider.isSearch
                                                                                      ? BlocBuilder<SearchCategoryListBloc, SearchCategoryListState>(
                                                                                          builder: (context, state) {
                                                                                            if (state is SearchCategoryListLoadedSuccess) {
                                                                                              return state.commodityCategories.isEmpty
                                                                                                  ? Center(
                                                                                                      child: Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                        children: [
                                                                                                          Text(
                                                                                                            AppLocalizations.of(context)!.translate('no_result_found'),
                                                                                                            maxLines: 2,
                                                                                                            style: const TextStyle(color: Colors.grey),
                                                                                                          ),
                                                                                                          const Icon(
                                                                                                            Icons.warning_rounded,
                                                                                                            color: Colors.grey,
                                                                                                          )
                                                                                                        ],
                                                                                                      ),
                                                                                                    )
                                                                                                  : Card(
                                                                                                      clipBehavior: Clip.antiAlias,
                                                                                                      elevation: 1,
                                                                                                      color: Colors.grey[200],
                                                                                                      shape: RoundedRectangleBorder(
                                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                                        side: BorderSide(color: Colors.grey, width: 2),
                                                                                                      ),
                                                                                                      child: ListView.builder(
                                                                                                        shrinkWrap: true,
                                                                                                        physics: const NeverScrollableScrollPhysics(),
                                                                                                        itemCount: state.commodityCategories.length,
                                                                                                        itemBuilder: (context, index4) {
                                                                                                          return Column(
                                                                                                            children: [
                                                                                                              InkWell(
                                                                                                                onTap: () {
                                                                                                                  addShipmentProvider!.setCommodityCategory(state.commodityCategories[index4], index);
                                                                                                                  addShipmentProvider!.calculateCosts();
                                                                                                                  addShipmentProvider!.setIsSearch(false);
                                                                                                                  Navigator.pop(context);
                                                                                                                  _searchController.text = "";
                                                                                                                },
                                                                                                                child: AbsorbPointer(
                                                                                                                  absorbing: true,
                                                                                                                  child: SizedBox(
                                                                                                                    height: 55.h,
                                                                                                                    width: double.infinity,
                                                                                                                    child: Padding(
                                                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                                                      child: Row(
                                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                        children: [
                                                                                                                          Text(
                                                                                                                            state.commodityCategories[index4]!.nameAr!,
                                                                                                                            style: const TextStyle(
                                                                                                                              fontWeight: FontWeight.bold,
                                                                                                                              fontSize: 17,
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                          Text(
                                                                                                                            "${f.format(state.commodityCategories[index4]!.price! / state.commodityCategories[index4]!.weight!)} ${state.commodityCategories[index4]!.unit_type!}",
                                                                                                                            style: const TextStyle(
                                                                                                                              fontWeight: FontWeight.bold,
                                                                                                                              fontSize: 17,
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ],
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                              state.commodityCategories.length - 1 == index4
                                                                                                                  ? const SizedBox.shrink()
                                                                                                                  : Divider(
                                                                                                                      height: 1,
                                                                                                                      color: AppColor.deepYellow,
                                                                                                                    ),
                                                                                                            ],
                                                                                                          );
                                                                                                        },
                                                                                                      ),
                                                                                                    );
                                                                                            } else if (state is SearchCategoryListLoadingProgress) {
                                                                                              return Shimmer.fromColors(
                                                                                                baseColor: (Colors.grey[300])!,
                                                                                                highlightColor: (Colors.grey[100])!,
                                                                                                enabled: true,
                                                                                                child: ListView.builder(
                                                                                                  shrinkWrap: true,
                                                                                                  itemBuilder: (_, __) => Container(
                                                                                                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
                                                                                                    clipBehavior: Clip.antiAlias,
                                                                                                    decoration: BoxDecoration(
                                                                                                      color: Colors.white,
                                                                                                      borderRadius: BorderRadius.circular(10),
                                                                                                    ),
                                                                                                    child: SizedBox(
                                                                                                      height: 90.h,
                                                                                                    ),
                                                                                                  ),
                                                                                                  itemCount: 10,
                                                                                                ),
                                                                                              );
                                                                                            } else {
                                                                                              return Center(
                                                                                                child: InkWell(
                                                                                                  onTap: () {
                                                                                                    // BlocProvider.of<SectionBloc>(context)
                                                                                                    //     .add(SectionLoadEvent());
                                                                                                  },
                                                                                                  child: Row(
                                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                                    children: [
                                                                                                      Text(
                                                                                                        AppLocalizations.of(context)!.translate('list_error'),
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
                                                                                            }
                                                                                          },
                                                                                        )
                                                                                      : BlocConsumer<KCommodityCategoryBloc, KCommodityCategoryState>(
                                                                                          listener: (context, state) {
                                                                                            if (state is KCommodityCategoryLoadedSuccess) {
                                                                                              // Future.delayed(const Duration(milliseconds: 400))
                                                                                              //     .then((value) => Scrollable.ensureVisible(
                                                                                              //           sectionKeys[selected!].currentContext!,
                                                                                              //           duration: const Duration(
                                                                                              //             milliseconds: 500,
                                                                                              //           ),
                                                                                              //         ));
                                                                                            }
                                                                                          },
                                                                                          builder: (context, state) {
                                                                                            if (state is KCommodityCategoryLoadedSuccess) {
                                                                                              return Container(
                                                                                                color: Colors.grey[200],
                                                                                                padding: const EdgeInsets.only(top: 3.0),
                                                                                                child: ListView.builder(
                                                                                                  // key: Key('chapterbuilder ${chapterselected.toString()}'),
                                                                                                  shrinkWrap: true,
                                                                                                  itemCount: state.commodityCategories.length,
                                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                                  itemBuilder: (context, index2) {
                                                                                                    return Card(
                                                                                                      margin: const EdgeInsets.all(2),
                                                                                                      clipBehavior: Clip.antiAlias,
                                                                                                      elevation: 1,
                                                                                                      color: Colors.grey[200],
                                                                                                      shape: RoundedRectangleBorder(
                                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                                        side: BorderSide(color: Colors.grey, width: 2),
                                                                                                      ),
                                                                                                      child: ListTileTheme(
                                                                                                        contentPadding: const EdgeInsets.all(0),
                                                                                                        dense: true,
                                                                                                        horizontalTitleGap: 0.0,
                                                                                                        minLeadingWidth: 0,
                                                                                                        child: ExpansionTile(
                                                                                                          // tilePadding: EdgeInsets.zero,
                                                                                                          controlAffinity: ListTileControlAffinity.trailing,
                                                                                                          childrenPadding: EdgeInsets.zero,
                                                                                                          // leading: const SizedBox.shrink(),

                                                                                                          title: Row(
                                                                                                            // key: chapterKeys[index2],
                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                            children: [
                                                                                                              SizedBox(
                                                                                                                width: 17.w,
                                                                                                              ),
                                                                                                              Flexible(
                                                                                                                child: Row(
                                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                  children: [
                                                                                                                    Text(
                                                                                                                      state.commodityCategories[index2].nameAr!,
                                                                                                                      style: const TextStyle(
                                                                                                                        fontWeight: FontWeight.bold,
                                                                                                                        fontSize: 18,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    SizedBox(
                                                                                                                      width: 5.w,
                                                                                                                    ),
                                                                                                                  ],
                                                                                                                ),
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                          key: Key(index2.toString()), //attention
                                                                                                          // initiallyExpanded: false,

                                                                                                          onExpansionChanged: (value) {},
                                                                                                          children: buildSubCategoriesTiles(state.commodityCategories[index2].subCategories!, index),
                                                                                                        ),
                                                                                                      ),
                                                                                                    );
                                                                                                  },
                                                                                                ),
                                                                                              );
                                                                                            } else {
                                                                                              return Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                children: [
                                                                                                  Shimmer.fromColors(
                                                                                                    baseColor: (Colors.grey[300])!,
                                                                                                    highlightColor: (Colors.grey[100])!,
                                                                                                    enabled: true,
                                                                                                    child: SizedBox(
                                                                                                      width: MediaQuery.of(context).size.width * .85,
                                                                                                      child: ListView.builder(
                                                                                                        shrinkWrap: true,
                                                                                                        itemBuilder: (_, __) => Container(
                                                                                                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
                                                                                                          clipBehavior: Clip.antiAlias,
                                                                                                          decoration: BoxDecoration(
                                                                                                            color: Colors.white,
                                                                                                            borderRadius: BorderRadius.circular(10),
                                                                                                          ),
                                                                                                          child: SizedBox(
                                                                                                            height: 40.h,
                                                                                                          ),
                                                                                                        ),
                                                                                                        itemCount: 4,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              );
                                                                                            }
                                                                                          },
                                                                                        ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            height:
                                                                                156,
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            color:
                                                                                Colors.white,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                const SizedBox(
                                                                                  height: 15,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    InkWell(
                                                                                      onTap: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: const Padding(
                                                                                        padding: EdgeInsets.all(8.0),
                                                                                        child: Icon(Icons.arrow_back),
                                                                                      ),
                                                                                    ),
                                                                                    const Text('اختر نوع البضاعة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                                                    const Spacer(),
                                                                                    InkWell(
                                                                                      onTap: () {
                                                                                        Navigator.pop(context);
                                                                                        showDialog(
                                                                                          context: context,
                                                                                          builder: (context) => StatefulBuilder(builder: (context, StateSetter setState2) {
                                                                                            return SimpleDialog(
                                                                                              backgroundColor: Colors.white,
                                                                                              title: const Text('طلب تسعير'),
                                                                                              shape: RoundedRectangleBorder(
                                                                                                borderRadius: BorderRadius.circular(15),
                                                                                              ),
                                                                                              contentPadding: EdgeInsets.all(8.h),
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
                                                                                                  child: TextField(
                                                                                                    controller: _requestNameController,
                                                                                                    decoration: InputDecoration(
                                                                                                      // isDense: true,
                                                                                                      contentPadding: const EdgeInsets.symmetric(
                                                                                                        horizontal: 10,
                                                                                                        vertical: 8,
                                                                                                      ),
                                                                                                      labelText: "أدخل اسم البضاعة",
                                                                                                      border: OutlineInputBorder(
                                                                                                        borderRadius: BorderRadius.circular(8),
                                                                                                      ),
                                                                                                    ),
                                                                                                    style: const TextStyle(fontSize: 18),
                                                                                                  ),
                                                                                                ),
                                                                                                BlocConsumer<CreatePriceRequestBloc, CreatePriceRequestState>(
                                                                                                  listener: (context, state) {
                                                                                                    if (state is CreatePriceRequestLoadedSuccess) {
                                                                                                      Navigator.pop(context);
                                                                                                    }
                                                                                                  },
                                                                                                  builder: (context, state) {
                                                                                                    if (state is CreatePriceRequestLoadingProgress) {
                                                                                                      return const Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                        children: [
                                                                                                          Center(child: CircularProgressIndicator()),
                                                                                                        ],
                                                                                                      );
                                                                                                    } else {
                                                                                                      return Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                                        children: [
                                                                                                          CustomButton(
                                                                                                              title: SizedBox(
                                                                                                                width: 90,
                                                                                                                child: Center(child: Text("تراجع")),
                                                                                                              ),
                                                                                                              onTap: () {
                                                                                                                Navigator.pop(context);
                                                                                                              }),
                                                                                                          CustomButton(
                                                                                                              title: const SizedBox(width: 90, child: Center(child: Text("إرسال"))),
                                                                                                              onTap: () {
                                                                                                                BlocProvider.of<CreatePriceRequestBloc>(context).add(CreatePriceRequestButtonPressedEvent(
                                                                                                                  name: _requestNameController.text,
                                                                                                                ));
                                                                                                              }),
                                                                                                        ],
                                                                                                      );
                                                                                                    }
                                                                                                  },
                                                                                                )
                                                                                              ],
                                                                                            );
                                                                                          }),
                                                                                        );
                                                                                      },
                                                                                      child: const AbsorbPointer(
                                                                                        absorbing: true,
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.all(8.0),
                                                                                          child: Row(
                                                                                            children: [
                                                                                              Text("أرسل طلب تسعير",
                                                                                                  style: TextStyle(
                                                                                                    fontSize: 18,
                                                                                                  )),
                                                                                              SizedBox(width: 7),
                                                                                              Icon(
                                                                                                Icons.add_circle_outline,
                                                                                                color: Colors.green,
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: BlocListener<SearchCategoryListBloc, SearchCategoryListState>(
                                                                                    listener: (context, state) {
                                                                                      if (state is SearchCategoryListLoadedSuccess) {
                                                                                        // print(jsonEncode(state.sections));
                                                                                      }
                                                                                      if (state is SearchCategoryListLoadedFailed) {}
                                                                                    },
                                                                                    child: TextFormField(
                                                                                      controller: _searchController,
                                                                                      onTap: () {
                                                                                        _searchController.selection = TextSelection(baseOffset: 0, extentOffset: _searchController.value.text.length);
                                                                                      },
                                                                                      style: TextStyle(fontSize: 18.sp),
                                                                                      scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 50),
                                                                                      decoration: InputDecoration(
                                                                                        labelText: AppLocalizations.of(context)!.translate('search'),
                                                                                        hintText: AppLocalizations.of(context)!.translate('search'),
                                                                                        hintStyle: TextStyle(fontSize: 18.sp),
                                                                                        suffixIcon: InkWell(
                                                                                          onTap: () {
                                                                                            FocusManager.instance.primaryFocus?.unfocus();

                                                                                            if (_searchController.text.isNotEmpty) {
                                                                                              BlocProvider.of<SearchCategoryListBloc>(context).add(SearchKCommodityCategoryEvent(query: _searchController.text));
                                                                                              valueProvider.setIsSearch(true);
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
                                                                                          valueProvider.setIsSearch(false);
                                                                                        }
                                                                                      },
                                                                                      onFieldSubmitted: (value) {
                                                                                        BlocProvider.of<BottomNavBarCubit>(context).emitShow();
                                                                                        _searchController.text = value;
                                                                                        if (value.isNotEmpty) {
                                                                                          BlocProvider.of<SearchCategoryListBloc>(context).add(SearchKCommodityCategoryEvent(query: value));
                                                                                          valueProvider.setIsSearch(true);
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                            child:
                                                                TextFormField(
                                                              controller:
                                                                  shipmentProvider
                                                                          .commodityCategory_controller[
                                                                      index],
                                                              enabled: false,
                                                              maxLines: null,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText: AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'commodity_name'),
                                                                suffixIcon: shipmentProvider
                                                                        .commodityCategory_controller[
                                                                            index]!
                                                                        .text
                                                                        .isEmpty
                                                                    ? Icon(
                                                                        Icons
                                                                            .arrow_forward_ios,
                                                                        color: AppColor
                                                                            .deepYellow,
                                                                      )
                                                                    : Icon(
                                                                        Icons
                                                                            .edit,
                                                                        color: AppColor
                                                                            .deepYellow,
                                                                      ),
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      9.0,
                                                                  vertical:
                                                                      11.0,
                                                                ),
                                                              ),
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
                                                            child:
                                                                TextFormField(
                                                              controller:
                                                                  shipmentProvider
                                                                          .commodityWeight_controllers[
                                                                      index],
                                                              onTap: () {
                                                                BlocProvider.of<
                                                                            BottomNavBarCubit>(
                                                                        context)
                                                                    .emitHide();
                                                                shipmentProvider
                                                                        .commodityWeight_controllers[
                                                                            index]
                                                                        .selection =
                                                                    TextSelection(
                                                                  baseOffset: 0,
                                                                  extentOffset: shipmentProvider
                                                                      .commodityWeight_controllers[
                                                                          index]
                                                                      .value
                                                                      .text
                                                                      .length,
                                                                );
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
                                                                  const TextInputType
                                                                      .numberWithOptions(
                                                                      decimal:
                                                                          true,
                                                                      signed:
                                                                          true),
                                                              inputFormatters: [
                                                                DecimalFormatter(),
                                                              ],
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          20),
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText: shipmentProvider.commodityCategoriesObjects[
                                                                            index] !=
                                                                        null
                                                                    ? weightLabel(shipmentProvider
                                                                        .commodityCategoriesObjects[
                                                                            index]!
                                                                        .unit_type!)
                                                                    : "وزن البضاعة",
                                                                suffix:
                                                                    shipmentProvider.commodityCategoriesObjects[index] !=
                                                                            null
                                                                        ? Text(
                                                                            shipmentProvider.commodityCategoriesObjects[index]!.unit_type!,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black,
                                                                            ),
                                                                          )
                                                                        : null,
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            9.0),
                                                              ),
                                                              onTapOutside:
                                                                  (event) {},
                                                              onEditingComplete:
                                                                  () {
                                                                addShipmentProvider!
                                                                    .calculateCosts();
                                                              },
                                                              onChanged:
                                                                  (value) {
                                                                addShipmentProvider!
                                                                    .calculateCosts();
                                                              },
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
                                                                shipmentProvider
                                                                    .commodityWeight_controllers[
                                                                        index]
                                                                    .text = newValue!;
                                                              },
                                                              onFieldSubmitted:
                                                                  (value) {
                                                                addShipmentProvider!
                                                                    .calculateCosts();

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
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  (shipmentProvider.count > 1)
                                                      ? Positioned(
                                                          left: 5,
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
                                                                topLeft: Radius
                                                                    .circular(
                                                                        12),
                                                                topRight: Radius
                                                                    .circular(
                                                                        5),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        5),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                (index + 1)
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
                                                  (shipmentProvider.count >
                                                              1) &&
                                                          (index != 0)
                                                      ? Positioned(
                                                          right: 0,
                                                          child: InkWell(
                                                            onTap: () {
                                                              shipmentProvider
                                                                  .removeitem(
                                                                      index);
                                                            },
                                                            child: Container(
                                                              height: 30,
                                                              width: 30,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    Colors.red,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            45),
                                                              ),
                                                              child:
                                                                  const Center(
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
                                    Positioned(
                                      bottom: -18,
                                      left: 0,
                                      child: InkWell(
                                        onTap: shipmentProvider.additem,
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
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 2.5),
                          child: EnsureVisibleWhenFocused(
                            focusNode: _truck_node,
                            child: Card(
                              key: key2,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 7.5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        // BlocProvider.of<TrucksListBloc>(context)
                                        //     .add(TrucksListLoadEvent(1));
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SelectTruckWidget(),
                                          ),
                                        );
                                      },
                                      child: AbsorbPointer(
                                        absorbing: true,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Text(
                                                "اختر شاحنة",
                                                style: TextStyle(
                                                  // color: AppColor.lightBlue,
                                                  fontSize: 19.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            shipmentProvider.truck != null
                                                ? Icon(Icons.edit,
                                                    color: AppColor.deepYellow)
                                                : Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: AppColor.deepYellow,
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    shipmentProvider.truck != null
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.network(
                                                shipmentProvider
                                                    .truck!.truckType!.image!,
                                                height: 75.h,
                                                width: 150.w,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    height: 75.h,
                                                    width: 150.w,
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
                                                    height: 75.h,
                                                    width: 150.w,
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
                                                      '${AppLocalizations.of(context)!.translate('truck_type')}: ${localeState.value.languageCode == 'en' ? shipmentProvider.truck!.truckType!.name : shipmentProvider.truck!.truckType!.nameAr}',
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
                                                      'اسم السائق: ${shipmentProvider.truck!.truckuser!.usertruck!.firstName} ${shipmentProvider.truck!.truckuser!.usertruck!.lastName}',
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
                                                      '${AppLocalizations.of(context)!.translate('truck_number')}: ${shipmentProvider.truck!.truckNumber}',
                                                      style: TextStyle(
                                                          // color: AppColor.lightBlue,
                                                          fontSize: 18.sp,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                    Visibility(
                                      visible: shipmentProvider.truckError,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      'select_truck_type_error'),
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
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 2.5),
                          child: Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 7.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        useSafeArea: true,
                                        builder: (context) =>
                                            Consumer<AddShippmentProvider>(
                                          builder:
                                              (context, valueProvider, child) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .height),
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 15.h,
                                                  ),
                                                  Visibility(
                                                    visible: shipmentProvider
                                                            .selectedRadioTile !=
                                                        "E",
                                                    child: TypeAheadField(
                                                      textFieldConfiguration:
                                                          TextFieldConfiguration(
                                                        // autofocus: true,
                                                        keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                        maxLines: null,
                                                        controller: valueProvider
                                                            .pickup_controller,
                                                        scrollPadding: EdgeInsets.only(
                                                            bottom: MediaQuery.of(
                                                                        context)
                                                                    .viewInsets
                                                                    .bottom +
                                                                150),
                                                        onTap: () {
                                                          valueProvider
                                                                  .pickup_controller
                                                                  .selection =
                                                              TextSelection(
                                                                  baseOffset: 0,
                                                                  extentOffset:
                                                                      valueProvider
                                                                          .pickup_controller
                                                                          .value
                                                                          .text
                                                                          .length);
                                                        },
                                                        style: const TextStyle(
                                                            fontSize: 18),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: AppLocalizations
                                                                  .of(context)!
                                                              .translate(
                                                                  'enter_pickup_address'),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 9.0,
                                                            vertical: 11.0,
                                                          ),
                                                          suffixIcon: InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ShippmentPickUpMapScreen(
                                                                    type: 0,
                                                                    location:
                                                                        valueProvider
                                                                            .pickup_latlng,
                                                                  ),
                                                                ),
                                                              ).then((value) =>
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus());
                                                              Future.delayed(const Duration(
                                                                      milliseconds:
                                                                          1500))
                                                                  .then(
                                                                      (value) {
                                                                // if (evaluateCo2()) {
                                                                //   calculateCo2Report();
                                                                // }
                                                              });
                                                            },
                                                            child: Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(7),
                                                              width: 55.0,
                                                              height: 15.0,
                                                              child: Icon(
                                                                Icons.map,
                                                                color: AppColor
                                                                    .deepYellow,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        onSubmitted: (value) {
                                                          // BlocProvider.of<StopScrollCubit>(context)
                                                          //     .emitEnable();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                        },
                                                      ),
                                                      loadingBuilder:
                                                          (context) {
                                                        return Container(
                                                          color: Colors.white,
                                                          child: Center(
                                                            child:
                                                                LoadingIndicator(),
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder:
                                                          (context, error) {
                                                        return Container(
                                                          color: Colors.white,
                                                        );
                                                      },
                                                      noItemsFoundBuilder:
                                                          (value) {
                                                        var localizedMessage =
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .translate(
                                                                    'no_result_found');
                                                        return Container(
                                                          width:
                                                              double.infinity,
                                                          color: Colors.white,
                                                          child: Center(
                                                            child: Text(
                                                              localizedMessage,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      18.sp),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      suggestionsCallback:
                                                          (pattern) async {
                                                        // if (pattern.isNotEmpty) {
                                                        //   BlocProvider.of<StopScrollCubit>(context)
                                                        //       .emitDisable();
                                                        // }
                                                        return pattern.isEmpty
                                                            ? []
                                                            : await PlaceService
                                                                .getAutocomplete(
                                                                    pattern);
                                                      },
                                                      itemBuilder: (context,
                                                          suggestion) {
                                                        return Container(
                                                          color: Colors.white,
                                                          child: Column(
                                                            children: [
                                                              ListTile(
                                                                // leading: Icon(Icons.shopping_cart),
                                                                tileColor:
                                                                    Colors
                                                                        .white,
                                                                title: Text(
                                                                    suggestion
                                                                        .description!),
                                                                // subtitle: Text('\$${suggestion['price']}'),
                                                              ),
                                                              Divider(
                                                                color: Colors
                                                                    .grey[300],
                                                                height: 3,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                      onSuggestionSelected:
                                                          (suggestion) async {
                                                        valueProvider
                                                            .setPickupInfo(
                                                                suggestion);

                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                        // if (evaluateCo2()) {
                                                        //   calculateCo2Report();
                                                        // }
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Visibility(
                                                    visible: !valueProvider
                                                            .deliveryPosition &&
                                                        shipmentProvider
                                                                .selectedRadioTile !=
                                                            "E",
                                                    child: !valueProvider
                                                            .pickupLoading
                                                        ? InkWell(
                                                            onTap: () {
                                                              // _(() {
                                                              //   pickupPosition = true;
                                                              //   pickupLoading = true;
                                                              // });
                                                              valueProvider
                                                                  .setPickupLoading(
                                                                      true);
                                                              valueProvider
                                                                  .setPickupPositionClick(
                                                                      true);

                                                              valueProvider
                                                                  .getCurrentPositionForPickup(
                                                                      context)
                                                                  .then(
                                                                (value) {
                                                                  valueProvider
                                                                      .setPickupLoading(
                                                                          false);
                                                                  valueProvider
                                                                      .setPickupPositionClick(
                                                                          false);
                                                                },
                                                              );
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .location_on,
                                                                  color: AppColor
                                                                      .deepYellow,
                                                                ),
                                                                SizedBox(
                                                                  width: 5.w,
                                                                ),
                                                                Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .translate(
                                                                          'pick_my_location'),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                height: 25,
                                                                width: 25,
                                                                child:
                                                                    LoadingIndicator(),
                                                              ),
                                                            ],
                                                          ),
                                                  ),
                                                  const SizedBox(
                                                    height: 12,
                                                  ),
                                                  Visibility(
                                                    visible: (valueProvider
                                                                .pickup_controller
                                                                .text
                                                                .isNotEmpty &&
                                                            valueProvider
                                                                .delivery_controller
                                                                .text
                                                                .isNotEmpty) &&
                                                        shipmentProvider
                                                                .selectedRadioTile !=
                                                            "E",
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            itemCount: valueProvider
                                                                .stoppoints_controller
                                                                .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index2) {
                                                              return Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .85,
                                                                        child:
                                                                            TypeAheadField(
                                                                          textFieldConfiguration:
                                                                              TextFieldConfiguration(
                                                                            // autofocus: true,
                                                                            keyboardType:
                                                                                TextInputType.multiline,
                                                                            maxLines:
                                                                                null,
                                                                            controller:
                                                                                valueProvider.stoppoints_controller[index2],
                                                                            scrollPadding:
                                                                                EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 150),
                                                                            onTap:
                                                                                () {
                                                                              valueProvider.stoppoints_controller[index2].selection = TextSelection(
                                                                                baseOffset: 0,
                                                                                extentOffset: valueProvider.stoppoints_controller[index2].value.text.length,
                                                                              );
                                                                            },

                                                                            style:
                                                                                const TextStyle(fontSize: 18),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              hintText: AppLocalizations.of(context)!.translate('enter_load\\unload_address'),
                                                                              contentPadding: const EdgeInsets.symmetric(
                                                                                horizontal: 9.0,
                                                                                vertical: 11.0,
                                                                              ),
                                                                              suffixIcon: InkWell(
                                                                                onTap: () {
                                                                                  Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => ShippmentPickUpMapScreen(
                                                                                        type: 2,
                                                                                        index: index2,
                                                                                        location: valueProvider.delivery_latlng,
                                                                                      ),
                                                                                    ),
                                                                                  ).then((value) => FocusManager.instance.primaryFocus?.unfocus());

                                                                                  print("delivry address co2 evaluation");
                                                                                  // Get.to(SearchFilterView());
                                                                                  Future.delayed(const Duration(milliseconds: 1500)).then((value) {
                                                                                    // if (evaluateCo2()) {
                                                                                    //   calculateCo2Report();
                                                                                    // }
                                                                                  });
                                                                                },
                                                                                child: Container(
                                                                                  margin: const EdgeInsets.all(7),
                                                                                  width: 55.0,
                                                                                  height: 15.0,
                                                                                  // decoration: new BoxDecoration(
                                                                                  //   borderRadius: BorderRadius.circular(10),
                                                                                  //   border: Border.all(
                                                                                  //       color: Colors.black87, width: 1),
                                                                                  // ),
                                                                                  child: Icon(
                                                                                    Icons.map,
                                                                                    color: AppColor.deepYellow,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onSubmitted:
                                                                                (value) {
                                                                              // BlocProvider.of<StopScrollCubit>(context)
                                                                              //     .emitEnable();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                          ),
                                                                          loadingBuilder:
                                                                              (context) {
                                                                            return Container(
                                                                              color: Colors.white,
                                                                              child: Center(
                                                                                child: LoadingIndicator(),
                                                                              ),
                                                                            );
                                                                          },
                                                                          errorBuilder:
                                                                              (context, error) {
                                                                            return Container(
                                                                              color: Colors.white,
                                                                            );
                                                                          },
                                                                          noItemsFoundBuilder:
                                                                              (value) {
                                                                            var localizedMessage =
                                                                                AppLocalizations.of(context)!.translate('no_result_found');
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
                                                                          suggestionsCallback:
                                                                              (pattern) async {
                                                                            // if (pattern.isNotEmpty) {
                                                                            //   BlocProvider.of<StopScrollCubit>(context)
                                                                            //       .emitDisable();
                                                                            // }
                                                                            return pattern.isEmpty
                                                                                ? []
                                                                                : await PlaceService.getAutocomplete(pattern);
                                                                          },
                                                                          itemBuilder:
                                                                              (context, suggestion) {
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
                                                                          onSuggestionSelected:
                                                                              (suggestion) async {
                                                                            valueProvider.setStopPointInfo(suggestion,
                                                                                index2);

                                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                                            // if (evaluateCo2()) {
                                                                            //   calculateCo2Report();
                                                                            // }
                                                                          },
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          valueProvider
                                                                              .removestoppoint(index2);
                                                                          // _showAlertDialog(index);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              30,
                                                                          width:
                                                                              30,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.red,
                                                                            borderRadius:
                                                                                BorderRadius.circular(45),
                                                                          ),
                                                                          child:
                                                                              const Center(
                                                                            child:
                                                                                Icon(
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
                                                                  InkWell(
                                                                    onTap: () {
                                                                      valueProvider.setStopPointLoading(
                                                                          true,
                                                                          index2);
                                                                      valueProvider.setStopPointPositionClick(
                                                                          true,
                                                                          index2);

                                                                      valueProvider.getCurrentPositionForStop(
                                                                          context,
                                                                          index2);

                                                                      // _getCurrentPositionForDelivery();
                                                                    },
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .location_on,
                                                                          color:
                                                                              AppColor.deepYellow,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5.w,
                                                                        ),
                                                                        Text(
                                                                          AppLocalizations.of(context)!
                                                                              .translate('pick_my_location'),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  // const SizedBox(
                                                                  //   height: 12,
                                                                  // ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              valueProvider
                                                                  .addstoppoint();
                                                            },
                                                            child:
                                                                AbsorbPointer(
                                                              absorbing: true,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          32.h,
                                                                      width:
                                                                          32.w,
                                                                      child: SvgPicture
                                                                          .asset(
                                                                              "assets/icons/add.svg"),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 7,
                                                                  ),
                                                                  const Text(
                                                                      "add check point")
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                  ),
                                                  Visibility(
                                                    visible: valueProvider
                                                            .pickup_controller
                                                            .text
                                                            .isNotEmpty ||
                                                        shipmentProvider
                                                                .selectedRadioTile ==
                                                            "E",
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        TypeAheadField(
                                                          textFieldConfiguration:
                                                              TextFieldConfiguration(
                                                            // autofocus: true,
                                                            keyboardType:
                                                                TextInputType
                                                                    .multiline,
                                                            maxLines: null,
                                                            controller:
                                                                valueProvider
                                                                    .delivery_controller,
                                                            scrollPadding: EdgeInsets.only(
                                                                bottom: MediaQuery.of(
                                                                            context)
                                                                        .viewInsets
                                                                        .bottom +
                                                                    150),
                                                            onTap: () {
                                                              valueProvider
                                                                      .delivery_controller
                                                                      .selection =
                                                                  TextSelection(
                                                                baseOffset: 0,
                                                                extentOffset:
                                                                    valueProvider
                                                                        .delivery_controller
                                                                        .value
                                                                        .text
                                                                        .length,
                                                              );
                                                            },

                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        18),
                                                            decoration:
                                                                InputDecoration(
                                                              hintText: AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .translate(
                                                                      'enter_delivery_address'),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 9.0,
                                                                vertical: 11.0,
                                                              ),
                                                              suffixIcon:
                                                                  InkWell(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              ShippmentPickUpMapScreen(
                                                                        type: 1,
                                                                        location:
                                                                            valueProvider.delivery_latlng,
                                                                      ),
                                                                    ),
                                                                  ).then((value) => FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus());

                                                                  print(
                                                                      "delivry address co2 evaluation");
                                                                  // Get.to(SearchFilterView());
                                                                  Future.delayed(const Duration(
                                                                          milliseconds:
                                                                              1500))
                                                                      .then(
                                                                          (value) {
                                                                    // if (evaluateCo2()) {
                                                                    //   calculateCo2Report();
                                                                    // }
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          7),
                                                                  width: 55.0,
                                                                  height: 15.0,
                                                                  // decoration: new BoxDecoration(
                                                                  //   borderRadius: BorderRadius.circular(10),
                                                                  //   border: Border.all(
                                                                  //       color: Colors.black87, width: 1),
                                                                  // ),
                                                                  child: Icon(
                                                                    Icons.map,
                                                                    color: AppColor
                                                                        .deepYellow,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            onSubmitted:
                                                                (value) {
                                                              // BlocProvider.of<StopScrollCubit>(context)
                                                              //     .emitEnable();
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                            },
                                                          ),
                                                          loadingBuilder:
                                                              (context) {
                                                            return Container(
                                                              color:
                                                                  Colors.white,
                                                              child: Center(
                                                                child:
                                                                    LoadingIndicator(),
                                                              ),
                                                            );
                                                          },
                                                          errorBuilder:
                                                              (context, error) {
                                                            return Container(
                                                              color:
                                                                  Colors.white,
                                                            );
                                                          },
                                                          noItemsFoundBuilder:
                                                              (value) {
                                                            var localizedMessage =
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'no_result_found');
                                                            return Container(
                                                              width: double
                                                                  .infinity,
                                                              color:
                                                                  Colors.white,
                                                              child: Center(
                                                                child: Text(
                                                                  localizedMessage,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18.sp),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          suggestionsCallback:
                                                              (pattern) async {
                                                            // if (pattern.isNotEmpty) {
                                                            //   BlocProvider.of<StopScrollCubit>(context)
                                                            //       .emitDisable();
                                                            // }
                                                            return pattern
                                                                    .isEmpty
                                                                ? []
                                                                : await PlaceService
                                                                    .getAutocomplete(
                                                                        pattern);
                                                          },
                                                          itemBuilder: (context,
                                                              suggestion) {
                                                            return Container(
                                                              color:
                                                                  Colors.white,
                                                              child: Column(
                                                                children: [
                                                                  ListTile(
                                                                    // leading: Icon(Icons.shopping_cart),
                                                                    tileColor:
                                                                        Colors
                                                                            .white,
                                                                    title: Text(
                                                                        suggestion
                                                                            .description!),
                                                                    // subtitle: Text('\$${suggestion['price']}'),
                                                                  ),
                                                                  Divider(
                                                                    color: Colors
                                                                            .grey[
                                                                        300],
                                                                    height: 3,
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                          onSuggestionSelected:
                                                              (suggestion) async {
                                                            valueProvider
                                                                .setDeliveryInfo(
                                                                    suggestion);

                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                            // if (evaluateCo2()) {
                                                            //   calculateCo2Report();
                                                            // }
                                                          },
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Visibility(
                                                          visible: !valueProvider
                                                              .pickupPosition,
                                                          child: !valueProvider
                                                                  .deliveryLoading
                                                              ? InkWell(
                                                                  onTap: () {
                                                                    valueProvider
                                                                        .setDeliveryLoading(
                                                                            true);
                                                                    valueProvider
                                                                        .setDeliveryPositionClick(
                                                                            true);

                                                                    valueProvider
                                                                        .getCurrentPositionForDelivery(
                                                                            context);

                                                                    // _getCurrentPositionForDelivery();
                                                                  },
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .location_on,
                                                                        color: AppColor
                                                                            .deepYellow,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5.w,
                                                                      ),
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .translate('pick_my_location'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              : Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          25,
                                                                      width: 25,
                                                                      child:
                                                                          LoadingIndicator(),
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
                                                  Spacer(),
                                                  BlocListener<DrawRouteBloc,
                                                      DrawRouteState>(
                                                    listener: (context, state) {
                                                      if (state
                                                          is DrawRouteSuccess) {
                                                        Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        400))
                                                            .then((value) {
                                                          if (shipmentProvider
                                                              .delivery_controller
                                                              .text
                                                              .isNotEmpty) {
                                                            // getPolyPoints();
                                                            shipmentProvider
                                                                .initMapbounds();
                                                          }
                                                        });
                                                      }
                                                    },
                                                    child: SizedBox(
                                                      height: 300.h,
                                                      child: AbsorbPointer(
                                                        absorbing: false,
                                                        child: GoogleMap(
                                                          onMapCreated:
                                                              (controller) {
                                                            shipmentProvider
                                                                .onMap2Created(
                                                                    controller,
                                                                    _mapStyle);
                                                          },
                                                          myLocationButtonEnabled:
                                                              false,
                                                          zoomGesturesEnabled:
                                                              false,
                                                          scrollGesturesEnabled:
                                                              false,
                                                          tiltGesturesEnabled:
                                                              false,
                                                          rotateGesturesEnabled:
                                                              false,
                                                          // zoomControlsEnabled: false,
                                                          initialCameraPosition:
                                                              CameraPosition(
                                                            target:
                                                                shipmentProvider
                                                                    .center,
                                                            zoom:
                                                                shipmentProvider
                                                                    .zoom,
                                                          ),
                                                          gestureRecognizers: {},
                                                          markers: (shipmentProvider
                                                                          .pickup_latlng !=
                                                                      null ||
                                                                  shipmentProvider
                                                                          .delivery_latlng !=
                                                                      null)
                                                              ? {
                                                                  shipmentProvider
                                                                              .pickup_latlng !=
                                                                          null
                                                                      ? Marker(
                                                                          markerId:
                                                                              const MarkerId("pickup"),
                                                                          position: LatLng(
                                                                              double.parse(shipmentProvider.pickup_location.split(",")[0]),
                                                                              double.parse(shipmentProvider.pickup_location.split(",")[1])),
                                                                          icon:
                                                                              pickupicon,
                                                                        )
                                                                      : const Marker(
                                                                          markerId:
                                                                              MarkerId("pickup"),
                                                                        ),
                                                                  shipmentProvider
                                                                              .delivery_latlng !=
                                                                          null
                                                                      ? Marker(
                                                                          markerId:
                                                                              const MarkerId("delivery"),
                                                                          position: LatLng(
                                                                              double.parse(shipmentProvider.delivery_location.split(",")[0]),
                                                                              double.parse(shipmentProvider.delivery_location.split(",")[1])),
                                                                          icon:
                                                                              deliveryicon,
                                                                        )
                                                                      : const Marker(
                                                                          markerId:
                                                                              MarkerId("delivery"),
                                                                        ),
                                                                }
                                                              : {},
                                                          polylines:
                                                              shipmentProvider
                                                                      .polylineCoordinates
                                                                      .isNotEmpty
                                                                  ? {
                                                                      Polyline(
                                                                        polylineId:
                                                                            const PolylineId("route"),
                                                                        points:
                                                                            shipmentProvider.polylineCoordinates,
                                                                        color: AppColor
                                                                            .deepYellow,
                                                                        width:
                                                                            5,
                                                                      ),
                                                                    }
                                                                  : {},
                                                          mapType:
                                                              shipmentProvider
                                                                  .mapType,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: AbsorbPointer(
                                      absorbing: true,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .translate(
                                                    'choose_shippment_path'),
                                            style: TextStyle(
                                              // color: AppColor.lightBlue,
                                              fontSize: 19.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          shipmentProvider.pickup_controller
                                                      .text.isNotEmpty ||
                                                  shipmentProvider
                                                      .delivery_controller
                                                      .text
                                                      .isNotEmpty
                                              ? Icon(Icons.edit,
                                                  color: AppColor.deepYellow)
                                              : Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: AppColor.deepYellow,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 7.h,
                                  ),
                                  Visibility(
                                    visible: shipmentProvider.pickup_controller
                                            .text.isNotEmpty ||
                                        shipmentProvider.delivery_controller
                                            .text.isNotEmpty,
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Visibility(
                                          visible: shipmentProvider
                                                  .selectedRadioTile !=
                                              "E",
                                          child: TextFormField(
                                            controller: shipmentProvider
                                                .pickup_controller,
                                            enabled: false,
                                            maxLines: null,
                                            style:
                                                const TextStyle(fontSize: 18),
                                            decoration: InputDecoration(
                                              labelText: AppLocalizations.of(
                                                      context)!
                                                  .translate('pickup_address'),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 9.0,
                                                vertical: 11.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Visibility(
                                          visible: shipmentProvider
                                                  .selectedRadioTile !=
                                              "E",
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: shipmentProvider
                                                .stoppoints_controller.length,
                                            itemBuilder: (context, index2) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextFormField(
                                                    controller: shipmentProvider
                                                            .stoppoints_controller[
                                                        index2],
                                                    enabled: false,
                                                    maxLines: null,
                                                    style: const TextStyle(
                                                        fontSize: 18),
                                                    decoration: InputDecoration(
                                                      labelText: AppLocalizations
                                                                  .of(context)!
                                                              .translate(
                                                                  'load\\unload_address') +
                                                          (index2 + 1)
                                                              .toString(),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 9.0,
                                                        vertical: 11.0,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 12,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                        TextFormField(
                                          controller: shipmentProvider
                                              .delivery_controller,
                                          enabled: false,
                                          maxLines: null,
                                          style: const TextStyle(fontSize: 18),
                                          decoration: InputDecoration(
                                            labelText: AppLocalizations.of(
                                                    context)!
                                                .translate('delivery_address'),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 9.0,
                                              vertical: 11.0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
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
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .translate('choose_path_error'),
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
                          ),
                        ),
                        Visibility(
                          visible: shipmentProvider.selectedRadioTile == "I",
                          child: Container(
                            color: AppColor.darkGrey,
                            height: 50,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    print("normal");
                                    shipmentProvider.setMapMode(MapType.normal);
                                    shipmentProvider.setMapStyle(_mapStyle);
                                  },
                                  child: SizedBox(
                                    height: 50,
                                    width: 70,
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('normal'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    print("dark");
                                    shipmentProvider.setMapMode(MapType.normal);
                                    shipmentProvider.setMapStyle(_darkmapStyle);
                                  },
                                  child: SizedBox(
                                    height: 50,
                                    width: 70,
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('dark'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    shipmentProvider.setMapMode(MapType.hybrid);
                                  },
                                  child: SizedBox(
                                    height: 50,
                                    width: 70,
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('satellite'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                (shipmentProvider.pickup_controller.text
                                            .isNotEmpty &&
                                        shipmentProvider.delivery_controller
                                            .text.isNotEmpty)
                                    ? InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  ShipmentMapPreview(
                                                pickup: shipmentProvider
                                                    .pickup_latlng!,
                                                delivery: shipmentProvider
                                                    .delivery_latlng!,
                                              ),
                                              transitionDuration:
                                                  const Duration(
                                                      milliseconds: 1000),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                var begin =
                                                    const Offset(0.0, -1.0);
                                                var end = Offset.zero;
                                                var curve = Curves.ease;

                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));

                                                return SlideTransition(
                                                  position:
                                                      animation.drive(tween),
                                                  child: child,
                                                );
                                              },
                                            ),
                                          ).then((value) {
                                            if (shipmentProvider
                                                .delivery_controller
                                                .text
                                                .isNotEmpty) {
                                              // getPolyPoints();
                                              shipmentProvider.initMapbounds();
                                            }
                                          });
                                          // shipmentProvider.setMapMode(MapType.satellite);
                                        },
                                        child: const SizedBox(
                                          height: 50,
                                          width: 70,
                                          child: Center(
                                            child: Icon(
                                              Icons.zoom_out_map,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: shipmentProvider.selectedRadioTile != "E",
                          child: BlocListener<DrawRouteBloc, DrawRouteState>(
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
                            child: SizedBox(
                              height: 300.h,
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
                                  // zoomControlsEnabled: false,
                                  initialCameraPosition: CameraPosition(
                                    target: shipmentProvider.center,
                                    zoom: shipmentProvider.zoom,
                                  ),
                                  gestureRecognizers: {},
                                  markers: (shipmentProvider.pickup_latlng !=
                                              null ||
                                          shipmentProvider.delivery_latlng !=
                                              null)
                                      ? {
                                          shipmentProvider.pickup_latlng != null
                                              ? Marker(
                                                  markerId:
                                                      const MarkerId("pickup"),
                                                  position: LatLng(
                                                      double.parse(
                                                          shipmentProvider
                                                              .pickup_location
                                                              .split(",")[0]),
                                                      double.parse(
                                                          shipmentProvider
                                                              .pickup_location
                                                              .split(",")[1])),
                                                  icon: pickupicon,
                                                )
                                              : const Marker(
                                                  markerId: MarkerId("pickup"),
                                                ),
                                          shipmentProvider.delivery_latlng !=
                                                  null
                                              ? Marker(
                                                  markerId: const MarkerId(
                                                      "delivery"),
                                                  position: LatLng(
                                                      double.parse(
                                                          shipmentProvider
                                                              .delivery_location
                                                              .split(",")[0]),
                                                      double.parse(
                                                          shipmentProvider
                                                              .delivery_location
                                                              .split(",")[1])),
                                                  icon: deliveryicon,
                                                )
                                              : const Marker(
                                                  markerId:
                                                      MarkerId("delivery"),
                                                ),
                                        }
                                      : {},
                                  polylines: shipmentProvider
                                          .polylineCoordinates.isNotEmpty
                                      ? {
                                          Polyline(
                                            polylineId:
                                                const PolylineId("route"),
                                            points: shipmentProvider
                                                .polylineCoordinates,
                                            color: AppColor.deepYellow,
                                            width: 5,
                                          ),
                                        }
                                      : {},
                                  mapType: shipmentProvider.mapType,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: false,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(AppLocalizations.of(context)!
                                .translate('shipment_load_complete_error')),
                          ),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 2.5),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: localeState.value.languageCode == 'en'
                                    ? [
                                        AppColor.lightYellow,
                                        AppColor.deepYellow,
                                      ]
                                    : [
                                        AppColor.deepYellow,
                                        AppColor.lightYellow,
                                      ],
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                              ),
                              border:
                                  Border.all(color: Colors.black26, width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "رسم عبور البضاعة: ${f.format(shipmentProvider.totalPassFeeValue)} ل.س",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17.sp,
                                  ),
                                ),
                                Text(
                                  "رسم تفتيش ساحة: ${f.format(1000000)} ل.س",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17.sp,
                                  ),
                                ),
                                Text(
                                  "أجار شاحنة: ${f.format(shipmentProvider.truck != null ? shipmentProvider.truck!.fees! : 0)} ل.س",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17.sp,
                                  ),
                                ),
                                const Divider(color: Colors.grey),
                                Text(
                                  "اجمالي التكاليف: ${f.format(shipmentProvider.totalCosts)} ل.س",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Visibility(
                          visible: shipmentProvider
                                  .delivery_controller.text.isNotEmpty &&
                              shipmentProvider.co2report != null,
                          child: true
                              ? SizedBox(
                                  height: 10,
                                  child: LinearProgressIndicator(
                                    color: AppColor.deepYellow,
                                  ),
                                )
                              : shipmentStatistics(),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 2.5),
                          child: BlocConsumer<ShippmentCreateBloc,
                              ShippmentCreateState>(
                            listener: (context, state) {
                              print(state);
                              if (state is ShippmentCreateSuccessState) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  backgroundColor: AppColor.deepGreen,
                                  dismissDirection: DismissDirection.up,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(context).size.height -
                                              150,
                                      left: 10,
                                      right: 10),
                                  content: Text(AppLocalizations.of(context)!
                                      .translate('shipment_created_success')),
                                  duration: const Duration(seconds: 3),
                                ));
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ControlView(),
                                    ),
                                    (route) => false);
                                shipmentProvider.initForm();
                              }
                              if (state is ShippmentCreateFailureState) {
                                print(state.errorMessage);
                              }
                            },
                            builder: (context, state) {
                              if (state is ShippmentLoadingProgressState) {
                                return CustomButton(
                                  title: LoadingIndicator(),
                                  onTap: () {},
                                );
                              } else {
                                return CustomButton(
                                  title: Text(
                                    "أرسل طلب",
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                  onTap: () {
                                    if (shipmentProvider.thereARoute) {
                                      _addShipmentformKey.currentState?.save();
                                      if (_addShipmentformKey.currentState!
                                          .validate()) {
                                        if (shipmentProvider.truck != null) {
                                          setState(() {
                                            shipmentProvider
                                                .setTruckError(false);
                                          });
                                          if (shipmentProvider.pickup_controller
                                                  .text.isNotEmpty &&
                                              shipmentProvider
                                                  .delivery_controller
                                                  .text
                                                  .isNotEmpty) {
                                            setState(() {
                                              shipmentProvider
                                                  .setPathError(false);
                                            });
                                            KShipment shipment = KShipment();

                                            shipment.truckType =
                                                shipmentProvider
                                                    .truck!.truckType!;
                                            shipment.shipmentType =
                                                shipmentProvider
                                                    .selectedRadioTile;
                                            shipment.truck = Simpletruck(
                                                id: shipmentProvider
                                                    .truck!.id!);

                                            var totalWeight = 0;
                                            List<ShipmentItems> items = [];
                                            for (var i = 0;
                                                i <
                                                    shipmentProvider
                                                        .commodityWeight_controllers!
                                                        .length;
                                                i++) {
                                              ShipmentItems item =
                                                  ShipmentItems(
                                                commodityCategory:
                                                    shipmentProvider
                                                        .commodityCategories[i]!,
                                                commodityWeight: double.parse(
                                                        shipmentProvider
                                                            .commodityWeight_controllers[
                                                                i]
                                                            .text
                                                            .replaceAll(
                                                                ",", ""))
                                                    .toInt(),
                                              );
                                              items.add(item);
                                              totalWeight += double.parse(
                                                      shipmentProvider
                                                          .commodityWeight_controllers[
                                                              i]
                                                          .text
                                                          .replaceAll(",", ""))
                                                  .toInt();
                                            }

                                            List<PathPoint> points = [];
                                            if (shipmentProvider
                                                    .pickup_latlng !=
                                                null) {
                                              points.add(PathPoint(
                                                pointType: "P",
                                                location:
                                                    "${shipmentProvider.pickup_latlng!.latitude},${shipmentProvider.pickup_latlng!.longitude}",
                                                name: shipmentProvider
                                                    .pickup_controller.text,
                                                number: 0,
                                                city: 1,
                                              ));
                                            }
                                            if (shipmentProvider
                                                    .delivery_latlng !=
                                                null) {
                                              points.add(PathPoint(
                                                pointType: "D",
                                                location:
                                                    "${shipmentProvider.delivery_latlng!.latitude},${shipmentProvider.delivery_latlng!.longitude}",
                                                name: shipmentProvider
                                                    .delivery_controller.text,
                                                number: 0,
                                                city: 1,
                                              ));
                                            }

                                            for (var s = 0;
                                                s <
                                                    shipmentProvider
                                                        .stoppoints_controller
                                                        .length;
                                                s++) {
                                              points.add(PathPoint(
                                                pointType: "S",
                                                location:
                                                    "${shipmentProvider.stoppoints_latlng[s]!.latitude},${shipmentProvider.stoppoints_latlng[s]!.longitude}",
                                                name: shipmentProvider
                                                    .stoppoints_controller[s]
                                                    .text,
                                                number: s,
                                                city: 1,
                                              ));
                                            }
                                            shipment.totalWeight = totalWeight;
                                            shipment.shipmentItems = items;
                                            shipment.pathPoints = points;
                                            // shipment.pickupDate = DateTime.now();
                                            BlocProvider.of<
                                                        ShippmentCreateBloc>(
                                                    context)
                                                .add(
                                                    ShippmentCreateButtonPressed(
                                                        shipment));
                                          } else {
                                            setState(() {
                                              shipmentProvider
                                                  .setPathError(true);
                                            });
                                          }
                                        } else {
                                          setState(() {
                                            shipmentProvider
                                                .setTruckError(true);
                                          });
                                          Scrollable.ensureVisible(
                                            key2.currentContext!,
                                            duration: const Duration(
                                              milliseconds: 500,
                                            ),
                                          );
                                        }
                                      } else {
                                        Scrollable.ensureVisible(
                                          key1.currentContext!,
                                          duration: const Duration(
                                            milliseconds: 500,
                                          ),
                                        );
                                      }

                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    } else {
                                      shipmentProvider
                                          .setIsThereRoutError(true);
                                    }
                                  },
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: 7.h,
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: !shipmentProvider.isThereARoute,
                  child: InkWell(
                    onTap: () {
                      shipmentProvider.setIsThereRout(true);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black54,
                        ),
                        Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: SizedBox(
                            height: 160.h,
                            width: MediaQuery.of(context).size.width * .75,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "there is no route between these two locations.",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          shipmentProvider.setIsThereRout(true);
                                        },
                                        child: AbsorbPointer(
                                          absorbing: true,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate('ok'),
                                              style: const TextStyle(
                                                fontSize: 17,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget shipmentStatistics() {
    return addShipmentProvider != null && addShipmentProvider!.co2report != null
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              // height: 40.h,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: BlocBuilder<LocaleCubit, LocaleState>(
                builder: (context, localeState) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: SvgPicture.asset(
                                    "assets/icons/distance.svg"),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .75,
                                child: Text(
                                  localeState.value.languageCode == 'en'
                                      ? "${addShipmentProvider!.co2report!.distance}"
                                      : "${addShipmentProvider!.co2report!.distance!.replaceAll(RegExp('km'), 'كم')}",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: AppColor.lightGrey,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 30,
                                width: 30,
                                child:
                                    SvgPicture.asset("assets/icons/time.svg"),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .75,
                                child: Text(
                                  localeState.value.languageCode == 'en'
                                      ? "${addShipmentProvider!.co2report!.duration}"
                                      : "${addShipmentProvider!.co2report!.duration!.replaceAll(RegExp('mins'), 'دقيقة').replaceAll(RegExp('hours'), 'ساعة')}",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: AppColor.lightGrey,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: SvgPicture.asset(
                                    "assets/icons/co2fingerprint.svg"),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .75,
                                child: Text(
                                  "${AppLocalizations.of(context)!.translate('total_co2')}: ${f.format(addShipmentProvider!.co2report!.et!.toInt())} ${localeState.value.languageCode == 'en' ? "kg" : "كغ"}",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
