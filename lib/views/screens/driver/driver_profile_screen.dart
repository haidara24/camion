import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/profile/driver_profile_bloc.dart';
import 'package:camion/business_logic/bloc/profile/driver_update_profile_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriverProfileScreen extends StatefulWidget {
  final UserModel user;

  const DriverProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final GlobalKey<FormState> _driverprofileFormKey = GlobalKey<FormState>();

  bool editMode = false;

  TextEditingController firstNameController = TextEditingController();

  TextEditingController lastNameController = TextEditingController();

  TextEditingController phoneController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return SafeArea(
          child: Scaffold(
            // appBar: CustomAppBar(
            //   title: " ",
            // ),
            body: BlocBuilder<DriverProfileBloc, DriverProfileState>(
              builder: (context, state) {
                if (state is DriverProfileLoadedSuccess) {
                  return Form(
                    key: _driverprofileFormKey,
                    child: Column(children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            color: AppColor.deepBlack,
                            height: 100.h,
                          ),
                          Positioned(
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -45,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 65.h,
                                    backgroundColor: AppColor.deepYellow,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(180),
                                      child: SizedBox(
                                        child: Image.network(
                                          state.driver.user!.image!,
                                          fit: BoxFit.fill,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Center(
                                            child: Text(
                                              "${state.driver.user!.firstName![0].toUpperCase()} ${state.driver.user!.lastName![0].toUpperCase()}",
                                              style: TextStyle(
                                                fontSize: 28.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 50,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SectionTitle(
                                  text:
                                      '${state.driver.user!.firstName} ${state.driver.user!.lastName}',
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      editMode = !editMode;
                                      firstNameController.text =
                                          state.driver.user!.firstName!;
                                      lastNameController.text =
                                          state.driver.user!.lastName!;
                                      phoneController.text =
                                          state.driver.user!.phone!;
                                      emailController.text =
                                          state.driver.user!.email!;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.edit,
                                      color: AppColor.deepYellow,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            editMode
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        child: TextFormField(
                                          controller: firstNameController,
                                          onTap: () {
                                            firstNameController.selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        firstNameController
                                                            .value.text.length);
                                          },
                                          scrollPadding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom +
                                                  20),
                                          textInputAction: TextInputAction.done,
                                          style: const TextStyle(fontSize: 18),
                                          decoration: const InputDecoration(
                                            labelText: "الاسم الأول",
                                            contentPadding:
                                                EdgeInsets.symmetric(
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
                                            firstNameController.text =
                                                newValue!;
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        child: TextFormField(
                                          controller: lastNameController,
                                          onTap: () {
                                            lastNameController.selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        lastNameController
                                                            .value.text.length);
                                          },
                                          scrollPadding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom +
                                                  20),
                                          textInputAction: TextInputAction.done,
                                          style: const TextStyle(fontSize: 18),
                                          decoration: const InputDecoration(
                                            labelText: "الاسم الأول",
                                            contentPadding:
                                                EdgeInsets.symmetric(
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
                                            lastNameController.text = newValue!;
                                          },
                                        ),
                                      )
                                    ],
                                  )
                                : const SizedBox.shrink(),
                            editMode
                                ? TextFormField(
                                    controller: phoneController,
                                    onTap: () {
                                      phoneController.selection = TextSelection(
                                          baseOffset: 0,
                                          extentOffset: phoneController
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
                                      labelText: "رقم الجوال",
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                      phoneController.text = newValue!;
                                    },
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SectionBody(
                                        text: 'رقم الجوال: ',
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      SectionBody(
                                        text: state.driver.user!.phone!.isEmpty
                                            ? '---'
                                            : '${state.driver.user!.phone}',
                                      ),
                                    ],
                                  ),
                            const SizedBox(
                              height: 4,
                            ),
                            editMode
                                ? TextFormField(
                                    controller: emailController,
                                    onTap: () {
                                      emailController.selection = TextSelection(
                                          baseOffset: 0,
                                          extentOffset: emailController
                                              .value.text.length);
                                    },
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom +
                                            20),
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(fontSize: 18),
                                    decoration: InputDecoration(
                                      labelText: "البريد الالكتروني",
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                      emailController.text = newValue!;
                                    },
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SectionBody(
                                        text: 'البريد الالكتروني: ',
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      SectionBody(
                                        text: state.driver.user!.email!.isEmpty
                                            ? '---'
                                            : '${state.driver.user!.email}',
                                      ),
                                    ],
                                  ),
                            const SizedBox(
                              height: 4,
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      editMode
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: BlocConsumer<DriverUpdateProfileBloc,
                                  DriverUpdateProfileState>(
                                listener: (context, btnstate) {
                                  print(btnstate);
                                  if (btnstate
                                      is DriverUpdateProfileLoadedSuccess) {
                                    setState(() {
                                      editMode = false;
                                    });
                                    BlocProvider.of<DriverProfileBloc>(context)
                                        .add(DriverProfileLoad(
                                            state.driver.id!));
                                  }
                                },
                                builder: (context, btnstate) {
                                  if (btnstate
                                      is DriverUpdateProfileLoadingProgress) {
                                    return CustomButton(
                                      title: LoadingIndicator(),
                                      onTap: () {},
                                    );
                                  } else {
                                    return CustomButton(
                                      title: Text("حفظ التغيرات"),
                                      onTap: () {
                                        _driverprofileFormKey.currentState!
                                            .save();
                                        if (_driverprofileFormKey.currentState!
                                            .validate()) {
                                          Driver driver = Driver();
                                          driver.id = state.driver.id!;
                                          driver.user = UserModel();
                                          driver.user!.email =
                                              emailController.text;
                                          driver.user!.phone =
                                              phoneController.text;
                                          driver.user!.firstName =
                                              firstNameController.text;
                                          driver.user!.lastName =
                                              lastNameController.text;
                                          BlocProvider.of<
                                                      DriverUpdateProfileBloc>(
                                                  context)
                                              .add(
                                                  DriverUpdateProfileButtonPressed(
                                                      driver, null));
                                        }
                                      },
                                    );
                                  }
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 8),
                    ]),
                  );
                } else {
                  return Center(
                    child: LoadingIndicator(),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
