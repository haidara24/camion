import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/check_point/check_point_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/create_permission_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/check_point_model.dart';
import 'package:camion/data/models/kshipment_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart' as cupertino;

class AddPermissionScreen extends StatefulWidget {
  final ManagmentShipment shipment;
  AddPermissionScreen({Key? key, required this.shipment}) : super(key: key);

  @override
  State<AddPermissionScreen> createState() => _AddPermissionScreenState();
}

class _AddPermissionScreenState extends State<AddPermissionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _drivernameController = TextEditingController();
  TextEditingController _idnumberController = TextEditingController();
  TextEditingController _truckTypeController = TextEditingController();
  TextEditingController _truckNumberController = TextEditingController();
  TextEditingController _deliveryLocationController = TextEditingController();
  List<TextEditingController> _commodityNameController = [];
  List<TextEditingController> _commodityWeightController = [];
  TextEditingController _dateController = TextEditingController();
  TextEditingController _durationController = TextEditingController();
  DateTime? loadDate;
  CheckPathPoint? checkpooint;
  List<CheckPathPoint> pathpoints = [];

  @override
  void initState() {
    super.initState();
    _drivernameController.text =
        "${widget.shipment.truck!.truckuser!.usertruck!.firstName!} ${widget.shipment.truck!.truckuser!.usertruck!.lastName!}";
    _idnumberController.text =
        widget.shipment.truck!.truckuser!.usertruck!.id_number!;
    _truckTypeController.text = widget.shipment.truckType!.nameAr!;
    _truckNumberController.text =
        widget.shipment.truck!.truck_number!.toString();
    _deliveryLocationController.text = widget.shipment.pathPoints!
        .singleWhere((element) => element.pointType == "D")
        .name!;
    for (var element in widget.shipment.shipmentItems!) {
      _commodityNameController.add(
          TextEditingController(text: element.commodityCategory!.name_ar!));
      _commodityWeightController.add(
          TextEditingController(text: element.commodityWeight!.toString()));
    }
  }

  setLoadDate(DateTime date) {
    List months = [
      'كانون ثاني',
      'شباط',
      'أذار',
      'نيسان',
      'أيار',
      'حزيران',
      'تموز',
      'آب',
      'أيلول',
      'تشرين أول',
      'تشرين ثاني',
      'كانون أول'
    ];
    var mon = date.month;
    var month = months[mon - 1];
    setState(() {
      _dateController.text = '${date.day}-$month-${date.year}';
      loadDate = date;
    });
  }

  _showDatePicker() {
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
                  setLoadDate(DateTime.now());

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
                locale: const Locale('ar', 'SY'),
                delegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                child: cupertino.CupertinoDatePicker(
                  backgroundColor: Colors.white10,
                  initialDateTime: loadDate,
                  mode: cupertino.CupertinoDatePickerMode.date,
                  minimumYear: DateTime.now().year,
                  minimumDate: DateTime.now().subtract(const Duration(days: 1)),
                  maximumYear: DateTime.now().year + 1,
                  onDateTimeChanged: (value) {
                    setLoadDate(value);
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
              resizeToAvoidBottomInset: false,
              backgroundColor: AppColor.lightGrey200,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.translate('permissions'),
              ),
              body: SingleChildScrollView(
                // physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(8),
                      elevation: 1,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      color: Colors.white,
                      child: Container(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  height: 12,
                                ),
                                SizedBox(
                                  // width: 350.w,
                                  child: TextFormField(
                                    controller: _drivernameController,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 19.sp,
                                    ),
                                    enabled: false,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20.w, vertical: 2.h),
                                      label: const Text(
                                        "اسم السائق",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                SizedBox(
                                  // width: 350.w,
                                  child: TextFormField(
                                    controller: _idnumberController,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 19.sp,
                                    ),
                                    enabled: false,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20.w, vertical: 2.h),
                                      label: const Text(
                                        "رقم الهوية",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                SizedBox(
                                  // width: 350.w,
                                  child: TextFormField(
                                    controller: _truckNumberController,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 19.sp,
                                    ),
                                    enabled: false,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20.w, vertical: 2.h),
                                      label: const Text(
                                        "رقم الشاحنة",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                SizedBox(
                                  // width: 350.w,
                                  child: TextFormField(
                                    controller: _truckTypeController,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 19.sp,
                                    ),
                                    enabled: false,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20.w, vertical: 2.h),
                                      label: const Text(
                                        "نوع المركبة",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                SizedBox(
                                  // width: 350.w,
                                  child: TextFormField(
                                    controller: _deliveryLocationController,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 19.sp,
                                    ),
                                    enabled: false,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20.w, vertical: 2.h),
                                      label: const Text(
                                        "موقع التفريغ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Card(
                                  margin: const EdgeInsets.all(5),
                                  elevation: 1,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  color: Colors.grey[100],
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount:
                                          widget.shipment.shipmentItems!.length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            SizedBox(
                                              // width: 350.w,
                                              child: InkWell(
                                                onTap: _showDatePicker,
                                                child: TextFormField(
                                                  controller:
                                                      _commodityNameController[
                                                          index],
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 19.sp,
                                                  ),
                                                  enabled: false,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20.w,
                                                            vertical: 2.h),
                                                    label: const Text(
                                                      "نوع البضاعة",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 12,
                                            ),
                                            SizedBox(
                                              // width: 350.w,
                                              child: InkWell(
                                                onTap: _showDatePicker,
                                                child: TextFormField(
                                                  controller:
                                                      _commodityWeightController[
                                                          index],
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 19.sp,
                                                  ),
                                                  enabled: false,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20.w,
                                                            vertical: 2.h),
                                                    label: const Text(
                                                      "وزن البضاعة",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                BlocListener<CheckPointListBloc,
                                    CheckPointListState>(
                                  listener: (context, state2) {
                                    if (state2 is CheckPointListLoadedSuccess) {
                                      setState(() {
                                        pathpoints = state2.pathpoints;
                                      });
                                    }
                                  },
                                  child: const SizedBox(
                                    height: 12,
                                  ),
                                ),
                                pathpoints.isNotEmpty
                                    ? DropdownButtonHideUnderline(
                                        child: DropdownButton2<CheckPathPoint>(
                                          isExpanded: true,
                                          hint: Text(
                                            "اختر المعبر",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color:
                                                  Theme.of(context).hintColor,
                                            ),
                                          ),
                                          items: pathpoints
                                              .map((CheckPathPoint item) =>
                                                  DropdownMenuItem<
                                                      CheckPathPoint>(
                                                    value: item,
                                                    child: SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                        item.name!,
                                                        style: const TextStyle(
                                                          fontSize: 17,
                                                        ),
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                          value: checkpooint,
                                          onChanged: (CheckPathPoint? value) {
                                            setState(() {
                                              checkpooint = value;
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
                                                  MaterialStateProperty.all(6),
                                              thumbVisibility:
                                                  MaterialStateProperty.all(
                                                      true),
                                            ),
                                          ),
                                          menuItemStyleData:
                                              const MenuItemStyleData(
                                            height: 40,
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                const SizedBox(
                                  height: 12,
                                ),
                                SizedBox(
                                  // width: 350.w,
                                  child: InkWell(
                                    onTap: _showDatePicker,
                                    child: TextFormField(
                                      controller: _dateController,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 19.sp,
                                      ),
                                      enabled: false,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20.w, vertical: 2.h),
                                        labelText: _dateController.text.isEmpty
                                            ? "حدد تاريخ العبور"
                                            : "تاريخ العبور",
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                SizedBox(
                                  // width: 350.w,
                                  child: TextFormField(
                                    controller: _durationController,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 19.sp,
                                    ),
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom +
                                            50),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20.w, vertical: 2.h),
                                      labelText: _dateController.text.isEmpty
                                          ? "حدد مدة العبور"
                                          : "مدة العبور",
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 2.5),
                                  child: BlocConsumer<CreatePermissionBloc,
                                      CreatePermissionState>(
                                    listener: (context, state) {
                                      print(state);
                                      if (state
                                          is CreatePermissionLoadedSuccess) {
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
                                          content: Text(AppLocalizations.of(
                                                  context)!
                                              .translate(
                                                  'shipment_created_success')),
                                          duration: const Duration(seconds: 3),
                                        ));
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ControlView(),
                                            ),
                                            (route) => false);
                                      }
                                      if (state
                                          is CreatePermissionLoadedFailed) {
                                        print(state.error);
                                      }
                                    },
                                    builder: (context, state) {
                                      if (state
                                          is CreatePermissionLoadingProgress) {
                                        return CustomButton(
                                          title: const LoadingIndicator(),
                                          onTap: () {},
                                        );
                                      } else {
                                        return CustomButton(
                                          title: Text(
                                            "إنشاء أمر مرور إداري",
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                            ),
                                          ),
                                          onTap: () {
                                            Permission permission =
                                                Permission();
                                            permission.shipment =
                                                widget.shipment.id!;
                                            permission.checkPoint =
                                                checkpooint!.id!;
                                            permission.passdate = loadDate;
                                            permission.passDuration = int.parse(
                                                _durationController.text);
                                            BlocProvider.of<
                                                        CreatePermissionBloc>(
                                                    context)
                                                .add(
                                              CreatePermissionButtonPressedEvent(
                                                  permission: permission),
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
