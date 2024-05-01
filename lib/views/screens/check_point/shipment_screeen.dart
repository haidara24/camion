import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/check_point/charge_types_list_bloc.dart';
import 'package:camion/business_logic/bloc/check_point/check_point_list_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/kshipment_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/check_point/add_charges_screen.dart';
import 'package:camion/views/screens/check_point/add_permission_screen.dart';
import 'package:camion/views/screens/check_point/shipment_details_screen.dart';
import 'package:camion/views/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShipmentOpsScreen extends StatefulWidget {
  final ManagmentShipment shipment;

  ShipmentOpsScreen({Key? key, required this.shipment}) : super(key: key);

  @override
  State<ShipmentOpsScreen> createState() => _ShipmentOpsScreenState();
}

class _ShipmentOpsScreenState extends State<ShipmentOpsScreen> {
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
                title: AppLocalizations.of(context)!.translate('search_result'),
              ),
              body: SingleChildScrollView(
                // physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CheckPointShipmentDetailsScreen(
                                    shipment: widget.shipment),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(5),
                        elevation: 1,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AbsorbPointer(
                            absorbing: true,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "معلومات الشحنة",
                                  style: TextStyle(
                                    // color: AppColor.lightBlue,
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColor.deepYellow,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () {
                        if (widget.shipment.passpermession == null) {
                          BlocProvider.of<ChargeTypesListBloc>(context)
                              .add(ChargeTypesListLoadEvent());
                          BlocProvider.of<CheckPointListBloc>(context)
                              .add(CheckPointListLoadEvent());
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddPermissionScreen(
                                    shipment: widget.shipment),
                              ));
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.all(5),
                        elevation: 1,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AbsorbPointer(
                            absorbing: true,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "أمر مرور اداري",
                                  style: TextStyle(
                                    // color: AppColor.lightBlue,
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                widget.shipment.passpermession == null
                                    ? Icon(
                                        Icons.arrow_forward_ios,
                                        color: AppColor.deepYellow,
                                      )
                                    : Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () {
                        if (widget.shipment.passcharges == null) {
                          BlocProvider.of<ChargeTypesListBloc>(context)
                              .add(ChargeTypesListLoadEvent());
                          BlocProvider.of<CheckPointListBloc>(context)
                              .add(CheckPointListLoadEvent());
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddChargesScreen(shipment: widget.shipment),
                              ));
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.all(5),
                        elevation: 1,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AbsorbPointer(
                            absorbing: true,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "مخالفات",
                                  style: TextStyle(
                                    // color: AppColor.lightBlue,
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                widget.shipment.passcharges == null
                                    ? Icon(
                                        Icons.arrow_forward_ios,
                                        color: AppColor.deepYellow,
                                      )
                                    : Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
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
