import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/bloc/truck_prices_list_bloc.dart';
import 'package:camion/business_logic/bloc/core/create_truck_price_bloc.dart';
import 'package:camion/business_logic/bloc/core/governorates_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/core_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/formatter.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/driver_appbar.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/snackbar_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddNewPriceScreen extends StatefulWidget {
  final int truckId;
  AddNewPriceScreen({
    super.key,
    required this.truckId,
  });

  @override
  State<AddNewPriceScreen> createState() => _AddNewPriceScreenState();
}

class _AddNewPriceScreenState extends State<AddNewPriceScreen> {
  final TextEditingController _priceController = TextEditingController();

  final GlobalKey<FormState> _addPriceformKey = GlobalKey<FormState>();

  Governorate? point1;

  Governorate? point2;

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
              backgroundColor: Colors.grey[100],
              appBar: DriverAppBar(
                title: AppLocalizations.of(context)!.translate('add_spending'),
              ),
              body: SingleChildScrollView(
                // physics: const NeverScrollableScrollPhysics(),
                child: Form(
                  key: _addPriceformKey,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              height: 8,
                            ),
                            SectionTitle(
                                text:
                                    "${AppLocalizations.of(context)!.translate('select_governorate')} 1"),
                            BlocBuilder<GovernoratesListBloc,
                                GovernoratesListState>(
                              builder: (context, state) {
                                if (state is GovernoratesListLoadedSuccess) {
                                  return DropdownButtonHideUnderline(
                                    child: DropdownButton2<Governorate>(
                                      isExpanded: true,
                                      hint: Text(
                                        AppLocalizations.of(context)!
                                            .translate('select_governorate'),
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                      items: state.governorates
                                          .map((Governorate item) =>
                                              DropdownMenuItem<Governorate>(
                                                value: item,
                                                child: SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    localeState.value
                                                                .languageCode ==
                                                            "en"
                                                        ? item.nameEn!
                                                        : item.name!,
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                      value: point1,
                                      onChanged: (Governorate? value) {
                                        setState(() {
                                          point1 = value;
                                        });
                                      },
                                      buttonStyleData: ButtonStyleData(
                                        height: 50,
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9.0,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.black26,
                                          ),
                                          // color: Colors.white,
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
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          color: Colors.white,
                                        ),
                                        scrollbarTheme: ScrollbarThemeData(
                                          radius: const Radius.circular(40),
                                          thickness: WidgetStateProperty.all(6),
                                          thumbVisibility:
                                              WidgetStateProperty.all(true),
                                        ),
                                      ),
                                      menuItemStyleData:
                                          const MenuItemStyleData(
                                        height: 40,
                                      ),
                                    ),
                                  );
                                } else {
                                  return const LinearProgressIndicator();
                                }
                              },
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SectionTitle(
                                text:
                                    "${AppLocalizations.of(context)!.translate('select_governorate')} 2"),
                            BlocBuilder<GovernoratesListBloc,
                                GovernoratesListState>(
                              builder: (context, state) {
                                if (state is GovernoratesListLoadedSuccess) {
                                  return DropdownButtonHideUnderline(
                                    child: DropdownButton2<Governorate>(
                                      isExpanded: true,
                                      hint: Text(
                                        AppLocalizations.of(context)!
                                            .translate('select_governorate'),
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                      items: state.governorates
                                          .map((Governorate item) =>
                                              DropdownMenuItem<Governorate>(
                                                value: item,
                                                child: SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    localeState.value
                                                                .languageCode ==
                                                            "en"
                                                        ? item.nameEn!
                                                        : item.name!,
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                      value: point2,
                                      onChanged: (Governorate? value) {
                                        setState(() {
                                          point2 = value;
                                        });
                                      },
                                      buttonStyleData: ButtonStyleData(
                                        height: 50,
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9.0,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.black26,
                                          ),
                                          // color: Colors.white,
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
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          color: Colors.white,
                                        ),
                                        scrollbarTheme: ScrollbarThemeData(
                                          radius: const Radius.circular(40),
                                          thickness: WidgetStateProperty.all(6),
                                          thumbVisibility:
                                              WidgetStateProperty.all(true),
                                        ),
                                      ),
                                      menuItemStyleData:
                                          const MenuItemStyleData(
                                        height: 40,
                                      ),
                                    ),
                                  );
                                } else {
                                  return const LinearProgressIndicator();
                                }
                              },
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SectionTitle(
                                text: AppLocalizations.of(context)!
                                    .translate('price')),
                            SizedBox(
                              // width: 350.w,
                              child: TextFormField(
                                controller: _priceController,
                                onTap: () {
                                  _priceController.selection = TextSelection(
                                      baseOffset:
                                          _priceController.value.text.length,
                                      extentOffset:
                                          _priceController.value.text.length);
                                },
                                scrollPadding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom +
                                          20,
                                ),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  DecimalFormatter(),
                                ],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.sp,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 9.0),
                                  hintStyle: TextStyle(
                                    color: Colors.grey[900],
                                    fontSize: 18,
                                  ),
                                  hintText: AppLocalizations.of(context)!
                                      .translate('enter_price'),
                                  // filled: true,
                                  // fillColor: Colors.white,
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .translate('insert_value_validate');
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  _priceController.text = newValue!;
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2.5),
                              child: BlocConsumer<CreateTruckPriceBloc,
                                  CreateTruckPriceState>(
                                listener: (context, state) {
                                  if (state is CreateTruckPriceSuccessState) {
                                    showCustomSnackBar(
                                      context: context,
                                      backgroundColor: AppColor.deepGreen,
                                      message: AppLocalizations.of(context)!
                                          .translate('new_price_created'),
                                    );

                                    BlocProvider.of<TruckPricesListBloc>(
                                            context)
                                        .add(TruckPricesListLoadEvent());
                                    Navigator.pop(context);
                                  }
                                  if (state is CreateTruckPriceFailureState) {
                                    debugPrint(state.errorMessage);
                                  }
                                },
                                builder: (context, state) {
                                  if (state
                                      is CreateTruckPriceLoadingProgressState) {
                                    return CustomButton(
                                      title: LoadingIndicator(),
                                      onTap: () {},
                                    );
                                  } else {
                                    return CustomButton(
                                      title: Text(
                                        AppLocalizations.of(context)!
                                            .translate('create_new_price'),
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                        ),
                                      ),
                                      onTap: () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        if (_addPriceformKey.currentState!
                                            .validate()) {
                                          _addPriceformKey.currentState?.save();
                                          Map<String, dynamic> truckPrice = {
                                            'point1': point1!.id!,
                                            'point2': point2!.id!,
                                            'value': double.parse(
                                              _priceController.text
                                                  .replaceAll(",", ""),
                                            ).toInt()
                                          };

                                          BlocProvider.of<CreateTruckPriceBloc>(
                                                  context)
                                              .add(
                                            CreateTruckPriceButtonPressed(
                                              truckPrice,
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
