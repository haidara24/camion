// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/truck/create_truck_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_type_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/models/truck_type_model.dart';
import 'package:camion/data/services/users_services.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTruckForDriverScreen extends StatefulWidget {
  final int driverId;
  CreateTruckForDriverScreen({Key? key, required this.driverId})
      : super(key: key);

  @override
  State<CreateTruckForDriverScreen> createState() =>
      _CreateTruckForDriverScreenState();
}

class _CreateTruckForDriverScreenState
    extends State<CreateTruckForDriverScreen> {
  final GlobalKey<FormState> _newtruckFormKey = GlobalKey<FormState>();

  int truckowner = 0;
  bool truckownerError = false;

  bool istruckOwner = false;

  TruckType? trucktype;
  bool trucktypeError = false;

  TextEditingController truckownerController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController longController = TextEditingController();
  TextEditingController numberOfAxelsController = TextEditingController();
  TextEditingController truckNumberController = TextEditingController();
  TextEditingController emptyWeightController = TextEditingController();
  TextEditingController grossWeightController = TextEditingController();
  TextEditingController trafficController = TextEditingController();
  TextEditingController gpsController = TextEditingController();

  List<File> _files = [];
  final ImagePicker _picker = ImagePicker();
  LatLng? selectedPosition;

  List<Widget> _buildAttachmentImages() {
    List<Widget> list = [];
    if (_files.isNotEmpty) {
      for (var i = 0; i < _files.length; i++) {
        var elem = Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topLeft,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              width: 80.w,
              height: 95.h,
              child: Image(
                height: 80.w,
                width: 95.h,
                fit: BoxFit.fill,
                image: FileImage(_files[i]),
              ),
            ),
            Positioned(
              top: -24,
              left: -8,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _files.removeAt(i);
                  });
                },
                icon: Card(
                  color: Colors.grey[200]!,
                  child: Icon(
                    Icons.delete,
                    color: Colors.red[400],
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
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: AppColor.lightGrey200,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.translate('add_new_truck'),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: _newtruckFormKey,
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        color: Colors.white,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 4.h,
                              ),
                              Visibility(
                                visible: !istruckOwner,
                                child: TypeAheadField(
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    // autofocus: true,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    controller: truckownerController,
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom +
                                            150),
                                    onTap: () {
                                      truckownerController.selection =
                                          TextSelection(
                                              baseOffset: 0,
                                              extentOffset: truckownerController
                                                  .value.text.length);
                                    },
                                    style: const TextStyle(fontSize: 18),
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!
                                          .translate('truck_owner'),
                                      labelText: AppLocalizations.of(context)!
                                          .translate('truck_owner'),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 9.0,
                                        vertical: 11.0,
                                      ),
                                      // prefixIcon: false
                                      //     ? SizedBox(
                                      //         height: 25,
                                      //         width: 25,
                                      //         child: LoadingIndicator(),
                                      //       )
                                      //     : null,
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
                                    return pattern.isEmpty
                                        ? []
                                        : await UserService.searchTruckOwners(
                                            pattern);
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return Container(
                                      color: Colors.white,
                                      child: Column(
                                        children: [
                                          ListTile(
                                            leading: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(180),
                                              child: Image.network(
                                                suggestion.user!.image!,
                                                height: 55.h,
                                                width: 55.w,
                                                fit: BoxFit.fill,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Center(
                                                  child: Text(
                                                    "${suggestion.user!.firstName![0].toUpperCase()} ${suggestion.user!.lastName![0].toUpperCase()}",
                                                    style: TextStyle(
                                                      fontSize: 28.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            tileColor: Colors.white,
                                            title: Text(
                                              '${suggestion.user!.firstName!} ${suggestion.user!.lastName!}',
                                            ),
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
                                    setState(() {
                                      truckowner = suggestion.id!;
                                      truckownerController.text =
                                          '${suggestion.user!.firstName!} ${suggestion.user!.lastName!}';
                                    });
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: istruckOwner,
                                onChanged: (value) {
                                  setState(() {
                                    istruckOwner = !istruckOwner;
                                  });
                                },
                                title: Text(AppLocalizations.of(context)!
                                    .translate('is_owner')),
                              ),
                              const SizedBox(
                                height: 8,
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
                                                      item.nameAr!,
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                      ),
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                        value: trucktype,
                                        onChanged: (TruckType? value) {
                                          setState(() {
                                            trucktype = value!;
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
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            color: Colors.white,
                                          ),
                                          scrollbarTheme: ScrollbarThemeData(
                                            radius: const Radius.circular(40),
                                            thickness:
                                                MaterialStateProperty.all(6),
                                            thumbVisibility:
                                                MaterialStateProperty.all(true),
                                          ),
                                        ),
                                        menuItemStyleData:
                                            const MenuItemStyleData(
                                          height: 40,
                                        ),
                                      ),
                                    );
                                  } else if (state2
                                      is TruckTypeLoadingProgress) {
                                    return const Center(
                                      child: LinearProgressIndicator(),
                                    );
                                  } else if (state2 is TruckTypeLoadedFailed) {
                                    return Center(
                                      child: InkWell(
                                        onTap: () {
                                          BlocProvider.of<TruckTypeBloc>(
                                                  context)
                                              .add(TruckTypeLoadEvent());
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .translate('list_error'),
                                              style: const TextStyle(
                                                  color: Colors.red),
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
                                height: 4.h,
                              ),
                              TextFormField(
                                controller: heightController,
                                onTap: () {
                                  heightController.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset:
                                          heightController.value.text.length);
                                },
                                scrollPadding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom +
                                        20),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .translate('height'),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 9.0),
                                  suffix: Text(
                                    localeState.value.languageCode == "en"
                                        ? "m"
                                        : "م",
                                  ),
                                  suffixStyle: const TextStyle(fontSize: 15),
                                ),
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                onEditingComplete: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .translate('insert_value_validate');
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  heightController.text = newValue!;
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              TextFormField(
                                controller: widthController,
                                onTap: () {
                                  widthController.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset:
                                          widthController.value.text.length);
                                },
                                scrollPadding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom +
                                        20),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .translate('width'),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 9.0),
                                  suffix: Text(
                                    localeState.value.languageCode == "en"
                                        ? "m"
                                        : "م",
                                  ),
                                  suffixStyle: const TextStyle(fontSize: 15),
                                ),
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                onEditingComplete: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .translate('insert_value_validate');
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  widthController.text = newValue!;
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              TextFormField(
                                controller: longController,
                                onTap: () {
                                  longController.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset:
                                          longController.value.text.length);
                                },
                                scrollPadding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom +
                                        20),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .translate('long'),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 9.0),
                                  suffix: Text(
                                    localeState.value.languageCode == "en"
                                        ? "m"
                                        : "م",
                                  ),
                                  suffixStyle: const TextStyle(fontSize: 15),
                                ),
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                onEditingComplete: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .translate('insert_value_validate');
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  longController.text = newValue!;
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              TextFormField(
                                controller: numberOfAxelsController,
                                onTap: () {
                                  numberOfAxelsController.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset: numberOfAxelsController
                                              .value.text.length);
                                },
                                scrollPadding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom +
                                        20),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .translate('number_of_axels'),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 9.0),
                                ),
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                onEditingComplete: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .translate('insert_value_validate');
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  numberOfAxelsController.text = newValue!;
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              TextFormField(
                                controller: truckNumberController,
                                onTap: () {
                                  truckNumberController.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset: truckNumberController
                                              .value.text.length);
                                },
                                scrollPadding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom +
                                        20),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .translate('truck_number'),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 9.0),
                                ),
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                onEditingComplete: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .translate('insert_value_validate');
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  truckNumberController.text = newValue!;
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              TextFormField(
                                controller: trafficController,
                                onTap: () {
                                  trafficController.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset:
                                          trafficController.value.text.length);
                                },
                                scrollPadding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom +
                                        20),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .translate('truck_number'),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 9.0),
                                ),
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                onEditingComplete: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .translate('insert_value_validate');
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  trafficController.text = newValue!;
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              TextFormField(
                                controller: emptyWeightController,
                                onTap: () {
                                  emptyWeightController.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset: emptyWeightController
                                              .value.text.length);
                                },
                                scrollPadding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom +
                                        20),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .translate('empty_weight'),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 9.0),
                                  suffix: Text(
                                    localeState.value.languageCode == "en"
                                        ? "kg"
                                        : "كغ",
                                  ),
                                  suffixStyle: const TextStyle(fontSize: 15),
                                ),
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                onEditingComplete: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .translate('insert_value_validate');
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  emptyWeightController.text = newValue!;
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              TextFormField(
                                controller: grossWeightController,
                                onTap: () {
                                  grossWeightController.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset: grossWeightController
                                              .value.text.length);
                                },
                                scrollPadding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom +
                                        20),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .translate('gross_weight'),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 9.0),
                                  suffix: Text(
                                    localeState.value.languageCode == "en"
                                        ? "kg"
                                        : "كغ",
                                  ),
                                  suffixStyle: const TextStyle(fontSize: 15),
                                ),
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                onEditingComplete: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .translate('insert_value_validate');
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  grossWeightController.text = newValue!;
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              TextFormField(
                                controller: gpsController,
                                onTap: () {
                                  gpsController.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset:
                                          gpsController.value.text.length);
                                },
                                scrollPadding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom +
                                        20),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontSize: 18),
                                decoration: const InputDecoration(
                                  labelText: "أدخل معرف الgps",
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 9.0),
                                ),
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                onEditingComplete: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .translate('insert_value_validate');
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  gpsController.text = newValue!;
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          const SectionTitle(
                                              text: "ارفع الصور والملفات"),
                                          InkWell(
                                            onTap: () async {
                                              var pickedImages = await _picker
                                                  .pickMultiImage();
                                              for (var element
                                                  in pickedImages) {
                                                _files.add(File(element.path));
                                              }
                                              setState(
                                                () {},
                                              );
                                            },
                                            child: Card(
                                              elevation: 1,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: SizedBox(
                                                    height: 40.h,
                                                    width: 50.w,
                                                    child: SvgPicture.asset(
                                                        "assets/icons/cloud.svg"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Wrap(
                                        alignment: WrapAlignment.start,
                                        children: _buildAttachmentImages(),
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: BlocConsumer<CreateTruckBloc,
                                            CreateTruckState>(
                                          listener: (context, state) async {
                                            if (state
                                                is CreateTruckSuccessState) {
                                              // instructionProvider.addInstruction(state.shipment);
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                backgroundColor:
                                                    AppColor.deepGreen,
                                                dismissDirection:
                                                    DismissDirection.up,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                margin: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height -
                                                            150,
                                                    left: 10,
                                                    right: 10),
                                                content: localeState.value
                                                            .languageCode ==
                                                        'en'
                                                    ? const Text(
                                                        'A Truck has been created successfully.',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      )
                                                    : const Text(
                                                        'تم انشاء مركبة جديدة بنجاح..',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                duration:
                                                    const Duration(seconds: 3),
                                              ));
                                              prefs.setInt(
                                                  "truckId", state.truck.id!);
                                              prefs.setString(
                                                  "gpsId", state.truck.gpsId!);
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ControlView(),
                                                ),
                                                (route) => false,
                                              );
                                            }
                                            if (state
                                                is CreateTruckFailureState) {
                                              print(state.errorMessage);
                                            }
                                          },
                                          builder: (context, state) {
                                            if (state
                                                is CreateTruckLoadingProgressState) {
                                              return CustomButton(
                                                title: LoadingIndicator(),
                                                onTap: () {},
                                              );
                                            } else {
                                              return CustomButton(
                                                title: Text(
                                                  "إضافة مركبة جديدة",
                                                  style: TextStyle(
                                                    fontSize: 20.sp,
                                                  ),
                                                ),
                                                onTap: () {
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();

                                                  if (_newtruckFormKey
                                                      .currentState!
                                                      .validate()) {
                                                    _newtruckFormKey
                                                        .currentState
                                                        ?.save();
                                                    if (trucktype! != null) {
                                                      KTruck truck = KTruck();
                                                      truck
                                                          .height = double.parse(
                                                              heightController
                                                                  .text)
                                                          .toInt();
                                                      truck
                                                          .width = double.parse(
                                                              widthController
                                                                  .text)
                                                          .toInt();
                                                      truck.long = double.parse(
                                                              longController
                                                                  .text)
                                                          .toInt();
                                                      truck.truckNumber =
                                                          double.parse(
                                                                  truckNumberController
                                                                      .text)
                                                              .toInt();
                                                      truck
                                                          .traffic = double.parse(
                                                              trafficController
                                                                  .text)
                                                          .toInt();
                                                      truck.numberOfAxels =
                                                          double.parse(
                                                                  numberOfAxelsController
                                                                      .text)
                                                              .toInt();
                                                      truck.emptyWeight =
                                                          double.parse(
                                                                  emptyWeightController
                                                                      .text)
                                                              .toInt();
                                                      truck.grossWeight =
                                                          double.parse(
                                                                  grossWeightController
                                                                      .text)
                                                              .toInt();

                                                      truck.truckuser =
                                                          KTuckUser(
                                                              id: widget
                                                                  .driverId);

                                                      if (istruckOwner) {
                                                        truck.owner = 0;
                                                      } else {
                                                        truck.owner =
                                                            truckowner;
                                                      }
                                                      truck.truckType =
                                                          trucktype;
                                                      truck.gpsId =
                                                          gpsController.text;
                                                      BlocProvider.of<
                                                                  CreateTruckBloc>(
                                                              context)
                                                          .add(
                                                        CreateTruckButtonPressed(
                                                            truck, _files),
                                                      );
                                                    } else {
                                                      trucktypeError = true;
                                                    }
                                                  } else {
                                                    // Scrollable.ensureVisible(
                                                    //   key1.currentContext!,
                                                    //   duration: const Duration(
                                                    //     milliseconds: 500,
                                                    //   ),
                                                    // );
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
                              const SizedBox(
                                height: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 96,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
