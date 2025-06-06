// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/core/governorates_list_bloc.dart';
import 'package:camion/business_logic/bloc/truck/create_truck_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_type_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/core_model.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/models/truck_type_model.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/services/users_services.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:camion/views/screens/control_view.dart';
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
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CreateTruckForDriverScreen extends StatefulWidget {
  final int driverId;
  const CreateTruckForDriverScreen({Key? key, required this.driverId})
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

  final List<File> _files = [];
  final ImagePicker _picker = ImagePicker();
  LatLng? selectedPosition;

  final RegExp phoneRegExp = RegExp(r'^09\d{8}$');
  bool isLoading = false;

  bool isPhoneValid = false;
  bool isOwnerExist = true;
  bool isGovernorateValid = true;
  Governorate? governorate;

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

  List<TruckOwner> suggestions = [];

  Future<Map<String, dynamic>?> fetchOwner(String phone) async {
    var url = '${OWNERS_ENDPOINT}search_by_phone/?q=00963${phone.substring(1)}';
    var rs = await http.get(Uri.parse(url));

    print('${OWNERS_ENDPOINT}search_by_phone/?q=00963${phone.substring(1)}');
    print(rs.body);
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      print(result);
      if (result.isNotEmpty) {
        truckowner = result[0]['id'];
        return {
          "id": result[0]['id'].toString(),
          "first_name": result[0]['user']['first_name'],
          "last_name": result[0]['user']['last_name'],
        };
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  void validateAndFetchOwner(String phone) async {
    if (!phoneRegExp.hasMatch(phone)) {
      setState(() {
        isOwnerExist = false;
        isLoading = false;
      });
      return;
    }

    setState(() {
      isOwnerExist = true;
      isLoading = true;
    });

    final owner = await fetchOwner(phone);

    if (owner != null) {
      setState(() {
        isLoading = false;
        isOwnerExist = true;
      });
    } else {
      setState(() {
        isOwnerExist = false;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // truckownerController.addListener(_onPhoneChanged);
    truckownerController.addListener(() {
      setState(() {
        // Check if the entered text matches the phone number pattern
        isPhoneValid = phoneRegExp.hasMatch(truckownerController.text);
      });
      if (isPhoneValid) {
        validateAndFetchOwner(truckownerController.text);
      }
    });
  }

  // void _onPhoneChanged() async {
  //   // Update the validity of the phone number
  //   setState(() {
  //     isPhoneValid = _validatePhone(truckownerController.text);
  //   });

  //   // Fetch suggestions only if the phone number is valid
  //   if (isPhoneValid) {
  //     final results =
  //         await UserService.searchTruckOwners(truckownerController.text);
  //     setState(() {
  //       suggestions = results;
  //     });
  //   } else {
  //     setState(() {
  //       suggestions = [];
  //     });
  //   }
  // }

  bool _validatePhone(String phone) {
    // Add your phone validation logic here
    return phone.length == 10; // Example: valid if phone number has 10 digits
  }

  @override
  void dispose() {
    truckownerController.dispose();
    super.dispose();
  }

  Widget? suffixOwnerPhone() {
    if (isPhoneValid) {
      return Icon(
        Icons.check_circle_outline,
        color: AppColor.deepGreen,
      );
    } else if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(10.0),
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    } else {
      return null;
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
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: AppColor.deepBlack, // Make status bar transparent
              statusBarIconBrightness:
                  Brightness.light, // Light icons for dark backgrounds
              systemNavigationBarColor: Colors.grey[100], // Works on Android
              systemNavigationBarIconBrightness: Brightness.light,
            ),
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.grey[100],
                appBar: CustomAppBar(
                  title:
                      AppLocalizations.of(context)!.translate('add_new_truck'),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Form(
                        key: _newtruckFormKey,
                        child: Card(
                          margin: const EdgeInsets.all(16.0),
                          color: Colors.white,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SectionTitle(
                                      text: AppLocalizations.of(context)!
                                          .translate('truck_info'),
                                    ),
                                  ],
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
                                SizedBox(
                                  height: 4.h,
                                ),
                                Visibility(
                                  visible: !istruckOwner,
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: truckownerController,
                                        keyboardType: TextInputType.phone,
                                        onSubmitted: validateAndFetchOwner,
                                        decoration: InputDecoration(
                                          labelText: AppLocalizations.of(
                                                  context)!
                                              .translate('truck_owner_phone'),
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .translate('enter_phone'),
                                          errorText: isPhoneValid
                                              ? null
                                              : "رقم الجوال خاطئ أو أن المالك غير موجود",
                                          suffixIcon: suffixOwnerPhone(),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 11.0,
                                                  horizontal: 9.0),
                                        ),
                                      ),
                                      if (!isOwnerExist)
                                        const Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            "المالك غير موجود,الرجاء التأكد من رقم الجوال.",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 14),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
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
                                  height: 16.h,
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
                                    const SizedBox(width: 8),
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
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          // Row(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.start,
                                          //   children: [
                                          //     const SizedBox(
                                          //       width: 10,
                                          //     ),
                                          //     Text(
                                          //       AppLocalizations.of(context)!
                                          //           .translate('number_of_axels'),
                                          //       style: TextStyle(
                                          //         fontSize: 19.sp,
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                          // SizedBox(
                                          //   height: 4.h,
                                          // ),
                                          SizedBox(
                                            width: 350.w,
                                            child: TextFormField(
                                              controller:
                                                  numberOfAxelsController,
                                              onTap: () {
                                                numberOfAxelsController
                                                        .selection =
                                                    TextSelection(
                                                        baseOffset: 0,
                                                        extentOffset:
                                                            numberOfAxelsController
                                                                .value
                                                                .text
                                                                .length);
                                              },
                                              scrollPadding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context)
                                                          .viewInsets
                                                          .bottom +
                                                      20),
                                              textInputAction:
                                                  TextInputAction.done,
                                              keyboardType: TextInputType.phone,
                                              style:
                                                  const TextStyle(fontSize: 18),
                                              decoration: InputDecoration(
                                                labelText: AppLocalizations.of(
                                                        context)!
                                                    .translate(
                                                        'number_of_axels'),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 11.0,
                                                        horizontal: 9.0),
                                              ),
                                              onTapOutside: (event) {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                              },
                                              onEditingComplete: () {
                                                FocusManager
                                                    .instance.primaryFocus
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
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
                                  height: 16,
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
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SectionTitle(
                                        text: AppLocalizations.of(context)!
                                            .translate('governorate')),
                                  ],
                                ),
                                BlocBuilder<GovernoratesListBloc,
                                    GovernoratesListState>(
                                  builder: (context, state) {
                                    if (state
                                        is GovernoratesListLoadedSuccess) {
                                      return DropdownButtonHideUnderline(
                                        child: DropdownButton2<Governorate>(
                                          isExpanded: true,
                                          hint: Text(
                                            AppLocalizations.of(context)!
                                                .translate(
                                                    'select_governorate'),
                                            style: TextStyle(
                                              fontSize: 18,
                                              color:
                                                  Theme.of(context).hintColor,
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
                                          value: governorate,
                                          onChanged: (Governorate? value) {
                                            setState(() {
                                              governorate = value;
                                              trafficController.text =
                                                  value!.id!.toString();
                                              isGovernorateValid = true;
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
                                    } else {
                                      return const LinearProgressIndicator();
                                    }
                                  },
                                ),
                                if (!isGovernorateValid)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "الرجاء اختيار محافظة.",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
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
                                    const SizedBox(width: 8),
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
                                  height: 12,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SectionTitle(
                                      text: AppLocalizations.of(context)!
                                          .translate('upload_images'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                CustomButton(
                                  title: const Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 35,
                                  ),
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
                                  color: Colors.grey[200],
                                  bordercolor: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  children: _buildAttachmentImages(),
                                ),
                                const SizedBox(height: 8),
                                BlocConsumer<CreateTruckBloc, CreateTruckState>(
                                  listener: (context, state) async {
                                    if (state is CreateTruckSuccessState) {
                                      // instructionProvider.addInstruction(state.shipment);
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      showCustomSnackBar(
                                        context: context,
                                        backgroundColor: AppColor.deepGreen,
                                        message: localeState
                                                    .value.languageCode ==
                                                'en'
                                            ? 'A Truck has been created successfully.'
                                            : 'تم انشاء مركبة جديدة بنجاح.',
                                      );

                                      prefs.setInt("truckId", state.truck.id!);
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ControlView(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                    if (state is CreateTruckFailureState) {
                                      debugPrint(state.errorMessage);
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
                                          AppLocalizations.of(context)!
                                              .translate("add_new_truck"),
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                          ),
                                        ),
                                        onTap: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();

                                          if (governorate != null) {
                                            if (_newtruckFormKey.currentState!
                                                .validate()) {
                                              _newtruckFormKey.currentState
                                                  ?.save();
                                              KTruck truck = KTruck();
                                              truck.height = double.parse(
                                                      heightController.text)
                                                  .toInt();
                                              truck.width = double.parse(
                                                      widthController.text)
                                                  .toInt();
                                              truck.locationLat =
                                                  "35.363149,35.932120";
                                              truck.long = double.parse(
                                                      longController.text)
                                                  .toInt();
                                              truck.truckNumber = double.parse(
                                                      truckNumberController
                                                          .text)
                                                  .toInt();
                                              truck.traffic = governorate!.id!;
                                              truck
                                                  .numberOfAxels = double.parse(
                                                      numberOfAxelsController
                                                          .text)
                                                  .toInt();
                                              truck.emptyWeight = double.parse(
                                                      emptyWeightController
                                                          .text)
                                                  .toInt();
                                              truck.grossWeight = double.parse(
                                                      grossWeightController
                                                          .text)
                                                  .toInt();

                                              truck.truckuser = widget.driverId;

                                              if (istruckOwner) {
                                                truck.owner = 0;
                                              } else {
                                                truck.phoneowner =
                                                    truckownerController.text;
                                              }
                                              truck.truckType = trucktype;
                                              truck.gpsId = gpsController.text;
                                              BlocProvider.of<CreateTruckBloc>(
                                                      context)
                                                  .add(
                                                CreateTruckButtonPressed(
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
                                          } else {
                                            setState(() {
                                              isGovernorateValid = false;
                                            });
                                          }
                                        },
                                      );
                                    }
                                  },
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
          ),
        );
      },
    );
  }
}
