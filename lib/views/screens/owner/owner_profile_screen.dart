import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/profile/owner_profile_bloc.dart';
import 'package:camion/business_logic/bloc/profile/owner_update_profile_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/owner/add_new_truck_screen.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OwnerProfileScreen extends StatefulWidget {
  final UserModel user;
  OwnerProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();

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
            body: BlocBuilder<OwnerProfileBloc, OwnerProfileState>(
              builder: (context, state) {
                if (state is OwnerProfileLoadedSuccess) {
                  return Form(
                    key: _profileFormKey,
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
                                          state.owner.user!.image!,
                                          fit: BoxFit.fill,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Center(
                                            child: Text(
                                              "${state.owner.user!.firstName![0].toUpperCase()} ${state.owner.user!.lastName![0].toUpperCase()}",
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
                                      '${state.owner.user!.firstName} ${state.owner.user!.lastName}',
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      editMode = !editMode;
                                      if (editMode) {
                                        firstNameController.text =
                                            state.owner.user!.firstName!;
                                        lastNameController.text =
                                            state.owner.user!.lastName!;
                                        phoneController.text =
                                            state.owner.user!.phone!;
                                        emailController.text =
                                            state.owner.user!.email!;
                                      }
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
                                    decoration: const InputDecoration(
                                      labelText: "رقم الجوال",
                                      contentPadding: EdgeInsets.symmetric(
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
                                        text: state.owner.user!.phone!.isEmpty
                                            ? '---'
                                            : '${state.owner.user!.phone}',
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
                                    decoration: const InputDecoration(
                                      labelText: "البريد الالكتروني",
                                      contentPadding: EdgeInsets.symmetric(
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
                                        text: state.owner.user!.email!.isEmpty
                                            ? '---'
                                            : '${state.owner.user!.email}',
                                      ),
                                    ],
                                  ),
                            const Divider(),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SectionTitle(text: "شاحناتي"),
                              ],
                            ),
                            state.owner.trucks!.isNotEmpty
                                ? Table(
                                    border: TableBorder.all(
                                      color: Colors.grey[400]!,
                                      width: 1,
                                    ),
                                    children: [
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                            color: AppColor.lightYellow,
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("اسم السائق"),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            color: AppColor.lightYellow,
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("نوع المركبة"),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            color: AppColor.lightYellow,
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("رقم المركبة"),
                                            ),
                                          ),
                                        ),
                                      ]),
                                      ...List.generate(
                                        state.owner.trucks!.length,
                                        (index) => TableRow(children: [
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  "${state.owner.trucks![index].truckuser!.usertruck!.firstName!} ${state.owner.trucks![index].truckuser!.usertruck!.lastName!}"),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(localeState
                                                          .value.languageCode ==
                                                      "en"
                                                  ? state.owner.trucks![index]
                                                      .truckType!.name!
                                                  : state.owner.trucks![index]
                                                      .truckType!.nameAr!),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(state.owner
                                                  .trucks![index].truckNumber!
                                                  .toString()),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ],
                                  )
                                : const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("لم يتم إضافة أية مركبات"),
                                  ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // shipmentProvider
                                    //     .additem(
                                    //         selectedIndex);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddNewTruckScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "إضافة مركبة  ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.deepYellow,
                                    ),
                                  ),
                                ),
                                // InkWell(
                                //   onTap: () =>
                                //       shipmentProvider
                                //           .additem(selectedIndex),
                                //   child:
                                //       AbsorbPointer(
                                //     absorbing:
                                //         true,
                                //     child:
                                //         Padding(
                                //       padding: const EdgeInsets
                                //           .all(
                                //           8.0),
                                //       child:
                                //           SizedBox(
                                //         height:
                                //             32.h,
                                //         width:
                                //             32.w,
                                //         child:
                                //             SvgPicture.asset("assets/icons/add.svg"),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const Spacer(),
                      editMode
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: BlocConsumer<OwnerUpdateProfileBloc,
                                  OwnerUpdateProfileState>(
                                listener: (context, btnstate) {
                                  print(btnstate);
                                  if (btnstate
                                      is OwnerUpdateProfileLoadedSuccess) {
                                    setState(() {
                                      editMode = false;
                                    });
                                    BlocProvider.of<OwnerProfileBloc>(context)
                                        .add(OwnerProfileLoad(state.owner.id!));
                                  }
                                },
                                builder: (context, btnstate) {
                                  if (btnstate
                                      is OwnerUpdateProfileLoadingProgress) {
                                    return CustomButton(
                                      title: LoadingIndicator(),
                                      onTap: () {},
                                    );
                                  } else {
                                    return CustomButton(
                                      title: const Text("حفظ التغيرات"),
                                      onTap: () {
                                        _profileFormKey.currentState!.save();
                                        if (_profileFormKey.currentState!
                                            .validate()) {
                                          TruckOwner owner = TruckOwner();
                                          owner.id = state.owner.id!;
                                          owner.user = UserModel();
                                          owner.user!.email =
                                              emailController.text;
                                          owner.user!.phone =
                                              phoneController.text;
                                          owner.user!.firstName =
                                              firstNameController.text;
                                          owner.user!.lastName =
                                              lastNameController.text;
                                          BlocProvider.of<
                                                      OwnerUpdateProfileBloc>(
                                                  context)
                                              .add(
                                            OwnerUpdateProfileButtonPressed(
                                                owner, null),
                                          );
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
