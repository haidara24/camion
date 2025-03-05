import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/bloc/truck_prices_list_bloc.dart';
import 'package:camion/business_logic/bloc/bloc/update_truck_price_bloc.dart';
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
  final TruckPrice? price; // Optional parameter for editing an existing price

  AddNewPriceScreen({
    super.key,
    required this.truckId,
    this.price, // Pass null for creating a new price
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
  void initState() {
    super.initState();

    // If editing an existing price, populate the fields
    if (widget.price != null) {
      _priceController.text = widget.price!.value!.toString();
      // Fetch and set the selected governorates (point1 and point2)
      // You may need to load the governorates list first
      _loadGovernoratesForEditing();
    }
  }

  void _loadGovernoratesForEditing() {
    final governoratesBloc = BlocProvider.of<GovernoratesListBloc>(context);
    if (governoratesBloc.state is GovernoratesListLoadedSuccess) {
      final governorates =
          (governoratesBloc.state as GovernoratesListLoadedSuccess)
              .governorates;

      // Set point1 and point2 based on the existing price
      point1 = governorates.firstWhere(
        (gov) => gov.name == widget.price!.point1,
      );
      point2 = governorates.firstWhere(
        (gov) => gov.name == widget.price!.point2,
      );
    }
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
              backgroundColor: Colors.grey[100],
              appBar: DriverAppBar(
                title: widget.price == null
                    ? AppLocalizations.of(context)!.translate('add_price')
                    : AppLocalizations.of(context)!.translate('edit_price'),
              ),
              body: SingleChildScrollView(
                child: Form(
                  key: _addPriceformKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SectionTitle(
                                text: AppLocalizations.of(context)!
                                    .translate('pickup_address')),
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
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.black26,
                                          ),
                                        ),
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
                            const SizedBox(height: 8),
                            SectionTitle(
                                text: AppLocalizations.of(context)!
                                    .translate('delivery_address')),
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
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.black26,
                                          ),
                                        ),
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
                            const SizedBox(height: 16),
                            SectionTitle(
                                text: AppLocalizations.of(context)!
                                    .translate('price')),
                            SizedBox(
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
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 9.0),
                                  hintStyle: TextStyle(
                                    color: Colors.grey[900],
                                    fontSize: 18,
                                  ),
                                  fillColor: Colors.white,
                                  hintText: AppLocalizations.of(context)!
                                      .translate('enter_price'),
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
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2.5),
                              child: widget.price == null
                                  ? BlocConsumer<CreateTruckPriceBloc,
                                      CreateTruckPriceState>(
                                      listener: (context, state) {
                                        if (state
                                            is CreateTruckPriceSuccessState) {
                                          showCustomSnackBar(
                                            context: context,
                                            backgroundColor: AppColor.deepGreen,
                                            message: AppLocalizations.of(
                                                    context)!
                                                .translate('new_price_created'),
                                          );

                                          BlocProvider.of<TruckPricesListBloc>(
                                                  context)
                                              .add(TruckPricesListLoadEvent());
                                          Navigator.pop(context);
                                        }
                                        if (state
                                            is CreateTruckPriceFailureState) {
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
                                                  .translate(
                                                      'create_new_price'),
                                              style: TextStyle(
                                                fontSize: 20.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onTap: () {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();

                                              if (_addPriceformKey.currentState!
                                                  .validate()) {
                                                _addPriceformKey.currentState
                                                    ?.save();
                                                Map<String, dynamic>
                                                    truckPrice = {
                                                  'point1': point1!.id!,
                                                  'point2': point2!.id!,
                                                  'value': double.parse(
                                                    _priceController.text
                                                        .replaceAll(",", ""),
                                                  ).toInt()
                                                };
                                                BlocProvider.of<
                                                            CreateTruckPriceBloc>(
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
                                    )
                                  : BlocConsumer<UpdateTruckPriceBloc,
                                      UpdateTruckPriceState>(
                                      listener: (context, state) {
                                        if (state
                                            is UpdateTruckPriceSuccessState) {
                                          showCustomSnackBar(
                                            context: context,
                                            backgroundColor: AppColor.deepGreen,
                                            message:
                                                AppLocalizations.of(context)!
                                                    .translate('price_updated'),
                                          );

                                          BlocProvider.of<TruckPricesListBloc>(
                                                  context)
                                              .add(TruckPricesListLoadEvent());
                                          Navigator.pop(context);
                                        }
                                        if (state
                                            is UpdateTruckPriceFailureState) {
                                          debugPrint(state.errorMessage);
                                        }
                                      },
                                      builder: (context, state) {
                                        if (state
                                            is UpdateTruckPriceLoadingProgressState) {
                                          return CustomButton(
                                            title: LoadingIndicator(),
                                            onTap: () {},
                                          );
                                        } else {
                                          return CustomButton(
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .translate('update_price'),
                                              style: TextStyle(
                                                fontSize: 20.sp,
                                              ),
                                            ),
                                            onTap: () {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();

                                              if (_addPriceformKey.currentState!
                                                  .validate()) {
                                                _addPriceformKey.currentState
                                                    ?.save();
                                                Map<String, dynamic>
                                                    truckPrice = {
                                                  'point1': point1!.id!,
                                                  'point2': point2!.id!,
                                                  'value': double.parse(
                                                    _priceController.text
                                                        .replaceAll(",", ""),
                                                  ).toInt()
                                                };

                                                if (widget.price != null) {
                                                  // If editing, include the price ID
                                                  truckPrice['id'] =
                                                      widget.price!.id;
                                                  BlocProvider.of<
                                                              UpdateTruckPriceBloc>(
                                                          context)
                                                      .add(
                                                    UpdateTruckPriceButtonPressed(
                                                      truckPrice,
                                                    ),
                                                  );
                                                }
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
