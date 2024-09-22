import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/truck/truck_type_bloc.dart';
import 'package:camion/business_logic/bloc/truck/trucks_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/truck_type_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/truck_details_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class SearchTruckScreen extends StatefulWidget {
  final int subshipmentId;
  SearchTruckScreen({Key? key, required this.subshipmentId}) : super(key: key);

  @override
  State<SearchTruckScreen> createState() => _SearchTruckScreenState();
}

class _SearchTruckScreenState extends State<SearchTruckScreen> {
  final TextEditingController _searchController = TextEditingController();

  TruckType? truckType;

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
              backgroundColor: AppColor.lightGrey200,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.translate('select_truck'),
              ),
              body: SingleChildScrollView(
                // physics: const NeverScrollableScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height),
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 10.h,
                      ),
                      TextFormField(
                        controller: _searchController,
                        onTap: () {
                          _searchController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset:
                                  _searchController.value.text.length);
                        },
                        style: TextStyle(fontSize: 18.sp),
                        scrollPadding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 50),
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
                                BlocProvider.of<TrucksListBloc>(context).add(
                                    TrucksListSearchEvent(
                                        _searchController.text));
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
                            BlocProvider.of<TrucksListBloc>(context).add(
                                TrucksListSearchEvent(_searchController.text));
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
                                              localeState.value.languageCode ==
                                                      "en"
                                                  ? item.name!
                                                  : item.nameAr!,
                                              style: const TextStyle(
                                                fontSize: 17,
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: truckType,
                                onChanged: (TruckType? value) {
                                  setState(() {
                                    truckType = value;
                                  });
                                  BlocProvider.of<TrucksListBloc>(context)
                                      .add(TrucksListLoadEvent([value!.id!]));
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
                                    thumbVisibility:
                                        MaterialStateProperty.all(true),
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
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TruckDetailsScreen(
                                                    truck: state.trucks[index],
                                                    index: index,
                                                    ops: 'assign_new_truck',
                                                    subshipmentId:
                                                        widget.subshipmentId,
                                                  ),
                                                ));
                                            // Navigator.pop(context);
                                          },
                                          child: Card(
                                            elevation: 1,
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
                                                  state.trucks[index].images!
                                                          .isNotEmpty
                                                      ? state.trucks[index]
                                                          .images![0].image!
                                                      : "",
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
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
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
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${AppLocalizations.of(context)!.translate('driver_name')}: ${state.trucks[index].driver_firstname} ${state.trucks[index].driver_lastname}',
                                                        style: TextStyle(
                                                            // color: AppColor.lightBlue,
                                                            fontSize: 18.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                                                FontWeight
                                                                    .bold),
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
                                                                FontWeight
                                                                    .bold),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 5),
                                        height: 250.h,
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
