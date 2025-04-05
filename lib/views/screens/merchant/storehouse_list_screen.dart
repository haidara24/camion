import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/bloc/delete_store_bloc.dart';
import 'package:camion/business_logic/bloc/bloc/delete_truck_price_bloc.dart';
import 'package:camion/business_logic/bloc/store_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/merchant/add_storehouse_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/no_reaults_widget.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intel;

class StorehouseListScreen extends StatefulWidget {
  const StorehouseListScreen({super.key});

  @override
  State<StorehouseListScreen> createState() => _StorehouseListScreenState();
}

class _StorehouseListScreenState extends State<StorehouseListScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  var f = intel.NumberFormat("#,###", "en_US");

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: AppColor.deepBlack, // Make status bar transparent
          statusBarIconBrightness:
              Brightness.light, // Light icons for dark backgrounds
          systemNavigationBarColor: Colors.white, // Works on Android
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: Scaffold(
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.translate('my_stores'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocConsumer<StoreListBloc, StoreListState>(
                listener: (context, state) {
                  // TODO: implement listener
                },
                builder: (context, storestate) {
                  if (storestate is StoreListLoadedSuccess) {
                    return Column(
                      children: [
                        storestate.stores.isNotEmpty
                            ? ListView.builder(
                                itemCount: storestate.stores.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return AbsorbPointer(
                                    absorbing: false,
                                    child: Card(
                                      color: AppColor.lightYellow,
                                      elevation: 1,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        side: BorderSide(
                                          color: AppColor.deepYellow,
                                          width: 2,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SectionTitle(
                                                  text: storestate
                                                      .stores[index].address!,
                                                ),
                                                BlocConsumer<DeleteStoreBloc,
                                                    DeleteStoreState>(
                                                  listener:
                                                      (context, deletestate) {
                                                    if (deletestate
                                                        is DeleteStoreSuccessState) {
                                                      BlocProvider.of<
                                                                  StoreListBloc>(
                                                              context)
                                                          .add(
                                                        StoreListLoadEvent(),
                                                      );
                                                    }
                                                  },
                                                  builder:
                                                      (context, deletestate) {
                                                    if (deletestate
                                                            is DeleteStoreLoadingProgressState &&
                                                        selectedIndex ==
                                                            index) {
                                                      return LoadingIndicator();
                                                    } else {
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                selectedIndex =
                                                                    index;
                                                              });
                                                              print(
                                                                  selectedIndex);
                                                              showDialog<void>(
                                                                context:
                                                                    context,
                                                                barrierDismissible:
                                                                    false, // user must tap button!
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    title: Text(AppLocalizations.of(
                                                                            context)!
                                                                        .translate(
                                                                            'delete')),
                                                                    actions: <Widget>[
                                                                      TextButton(
                                                                        child: Text(
                                                                            AppLocalizations.of(context)!.translate('cancel')),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                      TextButton(
                                                                        child: Text(
                                                                            AppLocalizations.of(context)!.translate('ok')),
                                                                        onPressed:
                                                                            () {
                                                                          BlocProvider.of<DeleteStoreBloc>(context)
                                                                              .add(
                                                                            DeleteStoreButtonPressed(storestate.stores[index].id!),
                                                                          );
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: SizedBox(
                                                              height: 25.h,
                                                              width: 25.h,
                                                              child: SvgPicture
                                                                  .asset(
                                                                      "assets/icons/delete.svg"),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })
                            : NoResultsWidget(
                                text: AppLocalizations.of(context)!
                                    .translate("store_not_found"),
                              ),
                        SizedBox(
                          height: 4.h,
                        ),
                        CustomButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddStoreHouseScreen(),
                              ),
                            );
                          },
                          title: SizedBox(
                            height: 50.h,
                            width: MediaQuery.sizeOf(context).width * .9,
                            child: Center(
                              child: SectionBody(
                                text: AppLocalizations.of(context)!
                                    .translate("add_store"),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(child: LoadingIndicator()),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
      );
    });
  }
}
