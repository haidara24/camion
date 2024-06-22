import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/truck_fixes/create_truck_fix_bloc.dart';
import 'package:camion/business_logic/bloc/truck_fixes/fix_type_list_bloc.dart';
import 'package:camion/business_logic/bloc/truck_fixes/truck_fix_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/formatter.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/driver_appbar.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:intl/intl.dart' as intel;

class CreateFixScreen extends StatefulWidget {
  CreateFixScreen({Key? key}) : super(key: key);

  @override
  State<CreateFixScreen> createState() => _CreateFixScreenState();
}

class _CreateFixScreenState extends State<CreateFixScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _noteController = TextEditingController();

  TextEditingController _dateController = TextEditingController();

  TextEditingController _costController = TextEditingController();

  DateTime fixDate = DateTime.now();

  ExpenseType? fixtype;

  var f = intel.NumberFormat("#,###", "en_US");

  setLoadDate(DateTime date, String lang) {
    List months = [
      'jan',
      'feb',
      'mar',
      'april',
      'may',
      'jun',
      'july',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec'
    ];
    List monthsAr = [
      'كانون الثاني',
      'شباط',
      'أذار',
      'نيسان',
      'أيار',
      'حزيران',
      'تموز',
      'آب',
      'أيلول',
      'تشرين الأول',
      'تشرين الثاني',
      'كانون الأول'
    ];
    var mon = date.month;
    var month = lang == "en" ? months[mon - 1] : monthsAr[mon - 1];
    _dateController.text = '${date.year}-$month-${date.day}';
    fixDate = date;
  }

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
                  setLoadDate(fixDate!, lang);

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
                  initialDateTime: fixDate,
                  mode: cupertino.CupertinoDatePickerMode.date,
                  minimumYear: DateTime.now().year,
                  minimumDate: DateTime.now().subtract(const Duration(days: 1)),
                  maximumYear: DateTime.now().year + 1,
                  onDateTimeChanged: (value) {
                    setLoadDate(value, lang);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
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
          child: SafeArea(
            child: Scaffold(
              backgroundColor: AppColor.lightGrey200,
              appBar: DriverAppBar(
                title: "إضافة مصروف",
              ),
              body: SingleChildScrollView(
                // physics: const NeverScrollableScrollPhysics(),
                child: Form(
                  key: _formKey,
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
                            SectionTitle(text: "اختر المصروف"),
                            BlocBuilder<FixTypeListBloc, FixTypeListState>(
                              builder: (context, state) {
                                if (state is FixTypeListLoadedSuccess) {
                                  return DropdownButtonHideUnderline(
                                    child: DropdownButton2<ExpenseType>(
                                      isExpanded: true,
                                      hint: Text(
                                        "اختر نوع المصروف",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                      items: state.types
                                          .map((ExpenseType item) =>
                                              DropdownMenuItem<ExpenseType>(
                                                value: item,
                                                child: SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    localeState.value
                                                                .languageCode ==
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
                                      value: fixtype,
                                      onChanged: (ExpenseType? value) {
                                        setState(() {
                                          fixtype = value;
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
                                } else {
                                  return LinearProgressIndicator();
                                }
                              },
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SectionTitle(text: "التكلفة"),
                            SizedBox(
                              // width: 350.w,
                              child: TextFormField(
                                controller: _costController,
                                onTap: () {
                                  _costController.selection = TextSelection(
                                      baseOffset:
                                          _costController.value.text.length,
                                      extentOffset:
                                          _costController.value.text.length);
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
                                  hintText: "أدخل تكلفة المصروف",
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
                                  _costController.text = newValue!;
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SectionTitle(
                                text: AppLocalizations.of(context)!
                                    .translate('date')),
                            SizedBox(
                              // width: 350.w,
                              child: InkWell(
                                onTap: () {
                                  _showDatePicker(
                                      localeState.value.languageCode);
                                },
                                child: TextFormField(
                                  controller: _dateController,
                                  enabled: false,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "أدخل تاريخ المصروف",
                                    floatingLabelStyle: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 11.0, horizontal: 9.0),
                                    suffixIcon: Icon(
                                      Icons.calendar_month,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return AppLocalizations.of(context)!
                                          .translate('insert_value_validate');
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SectionTitle(text: "تفاصيل إضافية"),
                            SizedBox(
                              // width: 350.w,
                              child: TextFormField(
                                controller: _noteController,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.sp,
                                ),
                                maxLines: 4,
                                onTap: () {
                                  _costController.selection = TextSelection(
                                      baseOffset:
                                          _costController.value.text.length,
                                      extentOffset:
                                          _costController.value.text.length);
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
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 9.0),
                                  hintStyle: TextStyle(
                                    color: Colors.grey[900],
                                    fontSize: 18,
                                  ),
                                  hintText:
                                      "أدخل أية تكاليف إضافية\n مثال: دواليب ماركة Dunlop.",
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .translate('insert_value_validate');
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  _noteController.text = newValue!;
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2.5),
                              child: BlocConsumer<CreateTruckFixBloc,
                                  CreateTruckFixState>(
                                listener: (context, state) {
                                  print(state);
                                  if (state is CreateTruckFixLoadedSuccess) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      backgroundColor: AppColor.deepGreen,
                                      dismissDirection: DismissDirection.up,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              150,
                                          left: 10,
                                          right: 10),
                                      content: Text("تم إنشاء مصروف جديد"),
                                      duration: const Duration(seconds: 5),
                                    ));
                                    BlocProvider.of<TruckFixListBloc>(context)
                                        .add(TruckFixListLoad());
                                    Navigator.pop(context);
                                  }
                                  if (state is CreateTruckFixLoadedFailed) {
                                    print(state.errorstring);
                                  }
                                },
                                builder: (context, state) {
                                  if (state is CreateTruckFixLoadingProgress) {
                                    return CustomButton(
                                      title: const LoadingIndicator(),
                                      onTap: () {},
                                    );
                                  } else {
                                    return CustomButton(
                                      title: Text(
                                        "إنشاء مصروف جديد",
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                        ),
                                      ),
                                      onTap: () {
                                        TruckExpense fix = TruckExpense();
                                        fix.amount = double.parse(
                                            _costController.text
                                                .replaceAll(",", ""));
                                        fix.fixType = " ";
                                        fix.dob = fixDate;
                                        fix.expenseType = fixtype;
                                        fix.note = _noteController.text;
                                        BlocProvider.of<CreateTruckFixBloc>(
                                                context)
                                            .add(
                                          CreateTruckFixButtonPressed(fix),
                                        );
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
