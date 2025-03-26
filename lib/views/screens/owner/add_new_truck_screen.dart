import 'dart:io';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/profile/owner_profile_bloc.dart';
import 'package:camion/business_logic/bloc/truck/create_truck_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_type_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/models/truck_type_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:camion/views/widgets/snackbar_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNewTruckScreen extends StatefulWidget {
  final int ownerId;
  const AddNewTruckScreen({Key? key, required this.ownerId}) : super(key: key);

  @override
  State<AddNewTruckScreen> createState() => _AddNewTruckScreenState();
}

class _AddNewTruckScreenState extends State<AddNewTruckScreen> {
  final GlobalKey<FormState> _newtruckFormKey = GlobalKey<FormState>();

  int truckuser = 0;
  bool truckuserError = false;

  TruckType? trucktype;
  bool trucktypeError = false;

  TextEditingController truckuserController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController longController = TextEditingController();
  TextEditingController numberOfAxelsController = TextEditingController();
  TextEditingController truckNumberController = TextEditingController();
  TextEditingController emptyWeightController = TextEditingController();
  TextEditingController grossWeightController = TextEditingController();
  TextEditingController trafficController = TextEditingController();

  final RegExp phoneRegExp = RegExp(r'^09\d{8}$');

  bool isPhoneValid = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final List<File> _files = [];
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
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {
        // Check if the entered text matches the phone number pattern
        isPhoneValid = phoneRegExp.hasMatch(_phoneController.text);
      });
    });
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
                resizeToAvoidBottomInset: true,
                backgroundColor: AppColor.lightGrey200,
                appBar: CustomAppBar(
                  title: "إضافة مركبة جديدة",
                ),
                body: SingleChildScrollView(
                  child: Form(
                    key: _newtruckFormKey,
                    child: Column(
                      children: [
                        Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          color: Colors.white,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SectionTitle(
                                      text: "معلومات الشاحنة",
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 12,
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
                                              color:
                                                  Theme.of(context).hintColor,
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
                                            iconEnabledColor:
                                                AppColor.deepYellow,
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
                                                  WidgetStateProperty.all(6),
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
                                    } else if (state2
                                        is TruckTypeLoadingProgress) {
                                      return const Center(
                                        child: LinearProgressIndicator(),
                                      );
                                    } else if (state2
                                        is TruckTypeLoadedFailed) {
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
                                  height: 12.h,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        width: 350.w,
                                        child: TextFormField(
                                          controller: heightController,
                                          onTap: () {
                                            heightController.selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        heightController
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
                                            labelText:
                                                AppLocalizations.of(context)!
                                                    .translate('height'),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 11.0,
                                                    horizontal: 9.0),
                                            suffix: Text(
                                              localeState.value.languageCode ==
                                                      "en"
                                                  ? "m"
                                                  : "م",
                                            ),
                                            suffixStyle:
                                                const TextStyle(fontSize: 15),
                                          ),
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          onEditingComplete: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return AppLocalizations.of(
                                                      context)!
                                                  .translate(
                                                      'insert_value_validate');
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            heightController.text = newValue!;
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: SizedBox(
                                        width: 350.w,
                                        child: TextFormField(
                                          controller: widthController,
                                          onTap: () {
                                            widthController.selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        widthController
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
                                            labelText:
                                                AppLocalizations.of(context)!
                                                    .translate('width'),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 11.0,
                                                    horizontal: 9.0),
                                            suffix: Text(
                                              localeState.value.languageCode ==
                                                      "en"
                                                  ? "m"
                                                  : "م",
                                            ),
                                            suffixStyle:
                                                const TextStyle(fontSize: 15),
                                          ),
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          onEditingComplete: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return AppLocalizations.of(
                                                      context)!
                                                  .translate(
                                                      'insert_value_validate');
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            widthController.text = newValue!;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        width: 350.w,
                                        child: TextFormField(
                                          controller: numberOfAxelsController,
                                          onTap: () {
                                            numberOfAxelsController.selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        numberOfAxelsController
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
                                            labelText: AppLocalizations.of(
                                                    context)!
                                                .translate('number_of_axels'),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 11.0,
                                                    horizontal: 9.0),
                                          ),
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          onEditingComplete: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return AppLocalizations.of(
                                                      context)!
                                                  .translate(
                                                      'insert_value_validate');
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            numberOfAxelsController.text =
                                                newValue!;
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: SizedBox(
                                        width: 350.w,
                                        child: TextFormField(
                                          controller: longController,
                                          onTap: () {
                                            longController.selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset: longController
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
                                            labelText:
                                                AppLocalizations.of(context)!
                                                    .translate('long'),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 11.0,
                                                    horizontal: 9.0),
                                            suffix: Text(
                                              localeState.value.languageCode ==
                                                      "en"
                                                  ? "m"
                                                  : "م",
                                            ),
                                            suffixStyle:
                                                const TextStyle(fontSize: 15),
                                          ),
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          onEditingComplete: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return AppLocalizations.of(
                                                      context)!
                                                  .translate(
                                                      'insert_value_validate');
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            longController.text = newValue!;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
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
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  onEditingComplete: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
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
                                        extentOffset: trafficController
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
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  onEditingComplete: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        width: 350.w,
                                        child: TextFormField(
                                          controller: emptyWeightController,
                                          onTap: () {
                                            emptyWeightController.selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        emptyWeightController
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
                                            labelText:
                                                AppLocalizations.of(context)!
                                                    .translate('empty_weight'),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 11.0,
                                                    horizontal: 9.0),
                                            suffix: Text(
                                              localeState.value.languageCode ==
                                                      "en"
                                                  ? "kg"
                                                  : "كغ",
                                            ),
                                            suffixStyle:
                                                const TextStyle(fontSize: 15),
                                          ),
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          onEditingComplete: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return AppLocalizations.of(
                                                      context)!
                                                  .translate(
                                                      'insert_value_validate');
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            emptyWeightController.text =
                                                newValue!;
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: SizedBox(
                                        width: 350.w,
                                        child: TextFormField(
                                          controller: grossWeightController,
                                          onTap: () {
                                            grossWeightController.selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        grossWeightController
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
                                            labelText:
                                                AppLocalizations.of(context)!
                                                    .translate('gross_weight'),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 11.0,
                                                    horizontal: 9.0),
                                            suffix: Text(
                                              localeState.value.languageCode ==
                                                      "en"
                                                  ? "kg"
                                                  : "كغ",
                                            ),
                                            suffixStyle:
                                                const TextStyle(fontSize: 15),
                                          ),
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          onEditingComplete: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return AppLocalizations.of(
                                                      context)!
                                                  .translate(
                                                      'insert_value_validate');
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            grossWeightController.text =
                                                newValue!;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          color: Colors.white,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SectionTitle(
                                      text: "معلومات السائق",
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        width: 350.w,
                                        child: TextFormField(
                                          // initialValue: widget.initialValue,
                                          controller: _firstNameController,
                                          onTap: () {
                                            _firstNameController.selection =
                                                TextSelection.collapsed(
                                                    offset: _firstNameController
                                                        .text.length);
                                          },
                                          validator: (value) {
                                            // Regular expression to validate the phone number format 0999999999

                                            if (value!.isEmpty) {
                                              return "First Name is required";
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            _firstNameController.text =
                                                newValue!;
                                          },
                                          // autovalidateMode:
                                          //     AutovalidateMode.onUserInteraction,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 19.sp,
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20.w,
                                                    vertical: 2.h),
                                            labelText:
                                                AppLocalizations.of(context)!
                                                    .translate('first_name'),
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 19.sp,
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: SizedBox(
                                        width: 350.w,
                                        child: TextFormField(
                                          // initialValue: widget.initialValue,
                                          controller: _lastNameController,
                                          onTap: () {
                                            _lastNameController.selection =
                                                TextSelection.collapsed(
                                                    offset: _lastNameController
                                                        .text.length);
                                          },
                                          validator: (value) {
                                            // Regular expression to validate the phone number format 0999999999

                                            if (value!.isEmpty) {
                                              return "Last Name is required";
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            _lastNameController.text =
                                                newValue!;
                                          },
                                          // autovalidateMode:
                                          //     AutovalidateMode.onUserInteraction,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 19.sp,
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20.w,
                                                    vertical: 2.h),
                                            labelText:
                                                AppLocalizations.of(context)!
                                                    .translate('last_name'),
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 19.sp,
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.phone,
                                  // initialValue: widget.initialValue,
                                  controller: _phoneController,
                                  onTap: () {
                                    _phoneController.selection =
                                        TextSelection.collapsed(
                                            offset:
                                                _phoneController.text.length);
                                  },
                                  validator: (value) {
                                    // Regular expression to validate the phone number format 0999999999
                                    final RegExp phoneRegExp =
                                        RegExp(r'^09\d{8}$');

                                    if (value!.isEmpty) {
                                      return "Phone number is required";
                                    } else if (!phoneRegExp.hasMatch(value)) {
                                      return "Enter a valid phone number";
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    _phoneController.text = newValue!;
                                  },
                                  // autovalidateMode:
                                  //     AutovalidateMode.onUserInteraction,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 19.sp,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 2.h),
                                    labelText: AppLocalizations.of(context)!
                                        .translate('phone'),
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 19.sp,
                                    ),
                                    suffixIcon: isPhoneValid
                                        ? Icon(
                                            Icons.check_circle_outline,
                                            color: AppColor.deepGreen,
                                          )
                                        : null,
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          color: Colors.white,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SectionTitle(
                                            text: "ارفع الصور والملفات"),
                                        InkWell(
                                          onTap: () async {
                                            var pickedImages =
                                                await _picker.pickMultiImage();
                                            for (var element in pickedImages) {
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
                                                      "assets/icons/grey/add_image.svg"),
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

                                            showCustomSnackBar(
                                              context: context,
                                              backgroundColor:
                                                  AppColor.deepGreen,
                                              message: localeState
                                                          .value.languageCode ==
                                                      'en'
                                                  ? 'Truck has been created successfully.'
                                                  : 'تم اضافة مركبة جديدة..',
                                            );

                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            var owner =
                                                prefs.getInt("truckowner");
                                            // ignore: use_build_context_synchronously
                                            BlocProvider.of<OwnerProfileBloc>(
                                                    context)
                                                .add(OwnerProfileLoad(owner!));
                                            Navigator.pop(context);
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
                                                  _newtruckFormKey.currentState
                                                      ?.save();
                                                  Map<String, dynamic> truck = {
                                                    'height': double.parse(
                                                            heightController
                                                                .text)
                                                        .toInt(),
                                                    'width': double.parse(
                                                            widthController
                                                                .text)
                                                        .toInt(),
                                                    'long': double.parse(
                                                            longController.text)
                                                        .toInt(),
                                                    'truckNumber': double.parse(
                                                            truckNumberController
                                                                .text)
                                                        .toInt(),
                                                    'traffic': double.parse(
                                                            trafficController
                                                                .text)
                                                        .toInt(),
                                                    'numberOfAxels': double.parse(
                                                            numberOfAxelsController
                                                                .text)
                                                        .toInt(),
                                                    'emptyWeight': double.parse(
                                                            emptyWeightController
                                                                .text)
                                                        .toInt(),
                                                    'grossWeight': double.parse(
                                                            grossWeightController
                                                                .text)
                                                        .toInt(),
                                                    'locationLat': "",
                                                    'driver_first_name':
                                                        _firstNameController
                                                            .text,
                                                    'driver_last_name':
                                                        _lastNameController
                                                            .text,
                                                    'driver_phone':
                                                        _phoneController.text,
                                                    'owner': widget.ownerId,
                                                    'truckType': trucktype,
                                                  };

                                                  BlocProvider.of<
                                                              CreateTruckBloc>(
                                                          context)
                                                      .add(
                                                    CreateOwnerTruckButtonPressed(
                                                        truck, _files),
                                                  );
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
                              ],
                            ),
                          ),
                        ),
                      ],
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
