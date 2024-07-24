import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/check_point/charge_types_list_bloc.dart';
import 'package:camion/business_logic/bloc/check_point/check_point_list_bloc.dart';
import 'package:camion/business_logic/bloc/check_point/create_pass_charges_bloc.dart';
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

class AddChargesScreen extends StatefulWidget {
  final ManagmentShipment shipment;
  AddChargesScreen({Key? key, required this.shipment}) : super(key: key);

  @override
  State<AddChargesScreen> createState() => _AddChargesScreenState();
}

class _AddChargesScreenState extends State<AddChargesScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _drivernameController = TextEditingController();
  TextEditingController _idnumberController = TextEditingController();
  TextEditingController _truckTypeController = TextEditingController();
  TextEditingController _truckNumberController = TextEditingController();
  TextEditingController _deliveryLocationController = TextEditingController();
  List<TextEditingController> _commodityNameController = [];
  List<TextEditingController> _commodityWeightController = [];
  String _noteController = "";
  DateTime? loadDate;
  CheckPathPoint? checkpooint;
  List<int> selectedCharges = [];
  List<ChargeType> chargeTypes = [];
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

  void _onChargeSelected(bool selected, category_id) {
    if (selected == true) {
      setState(() {
        selectedCharges.add(category_id);
      });
    } else {
      setState(() {
        selectedCharges.remove(category_id);
      });
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
              // resizeToAvoidBottomInset: false,
              backgroundColor: AppColor.lightGrey200,
              appBar: CustomAppBar(
                title: "إنشاء مخالفة",
              ),
              body: SingleChildScrollView(
                // physics: const NeverScrollableScrollPhysics(),
                child: Card(
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
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      widget.shipment.shipmentItems!.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          // width: 350.w,
                                          child: TextFormField(
                                            controller:
                                                _commodityNameController[index],
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
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
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
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                      items: pathpoints
                                          .map((CheckPathPoint item) =>
                                              DropdownMenuItem<CheckPathPoint>(
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
                                  )
                                : SizedBox.shrink(),
                            BlocListener<ChargeTypesListBloc,
                                ChargeTypesListState>(
                              listener: (context, state2) {
                                if (state2 is ChargeTypesListLoadedSuccess) {
                                  setState(() {
                                    chargeTypes = state2.chargeTypes;
                                  });
                                }
                              },
                              child: const SizedBox(
                                height: 12,
                              ),
                            ),
                            const Text("اختر نوع المخالفة",
                                style: TextStyle(fontSize: 17)),
                            const SizedBox(
                              height: 12,
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: chargeTypes.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return CheckboxListTile(
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    value: selectedCharges
                                        .contains(chargeTypes[index].id!),
                                    onChanged: (value) {
                                      _onChargeSelected(
                                          value!, chargeTypes[index].id!);
                                    },
                                    title: Text(chargeTypes[index].name!),
                                  );
                                }),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              "الملاحظات",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 15.h,
                            ),
                            TextFormField(
                              maxLines: 4,
                              textInputAction: TextInputAction.done,
                              style: const TextStyle(fontSize: 18),
                              onChanged: (value) {
                                _noteController = value;
                              },
                              // scrollPadding: EdgeInsets.only(
                              //   bottom:
                              //       MediaQuery.of(context).viewInsets.bottom +
                              //           150,
                              // ),
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  hintText: "أدخل أية ملاحظات اضافية للمخالفة"),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2.5),
                              child: BlocConsumer<CreatePassChargesBloc,
                                  CreatePassChargesState>(
                                listener: (context, state) {
                                  print(state);
                                  if (state is CreatePassChargesLoadedSuccess) {
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
                                      content: Text(
                                          "تم إنشاء المخالفة بنجاح وإرسالها إلى الإدارة لمراجعتها"),
                                      duration: const Duration(seconds: 5),
                                    ));
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ControlView(),
                                        ),
                                        (route) => false);
                                  }
                                  if (state is CreatePassChargesLoadedFailed) {
                                    print(state.error);
                                  }
                                },
                                builder: (context, state) {
                                  if (state
                                      is CreatePassChargesLoadingProgress) {
                                    return CustomButton(
                                      title: LoadingIndicator(),
                                      onTap: () {},
                                    );
                                  } else {
                                    return CustomButton(
                                      title: Text(
                                        "إنشاء مخالفة",
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                        ),
                                      ),
                                      onTap: () {
                                        PassCharges charge = PassCharges();
                                        charge.shipment = widget.shipment.id!;
                                        charge.checkPoint = checkpooint!.id!;
                                        charge.charges_type = selectedCharges;
                                        charge.note = _noteController;
                                        BlocProvider.of<CreatePassChargesBloc>(
                                                context)
                                            .add(
                                          CreatePassChargesButtonPressedEvent(
                                              charges: charge),
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
