import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/profile/merchant_profile_bloc.dart';
import 'package:camion/business_logic/bloc/profile/merchant_update_profile_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/merchant/add_storehouse_screen.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:camion/views/widgets/section_body_widget.dart';
import 'package:camion/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MerchantProfileScreen extends StatefulWidget {
  // final Merchant user;
  MerchantProfileScreen({Key? key}) : super(key: key);

  @override
  State<MerchantProfileScreen> createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends State<MerchantProfileScreen> {
  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();

  bool editMode = false;

  TextEditingController firstNameController = TextEditingController();

  TextEditingController lastNameController = TextEditingController();

  TextEditingController phoneController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController addressController = TextEditingController();

  TextEditingController companyNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return SafeArea(
          child: Scaffold(
            // appBar: CustomAppBar(
            //   title: " ",
            // ),
            body: BlocBuilder<MerchantProfileBloc, MerchantProfileState>(
              builder: (context, state) {
                if (state is MerchantProfileLoadedSuccess) {
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
                                          state.merchant.user!.image!,
                                          fit: BoxFit.fill,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Center(
                                            child: Text(
                                              "${state.merchant.user!.firstName![0].toUpperCase()} ${state.merchant.user!.lastName![0].toUpperCase()}",
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
                                      '${state.merchant.user!.firstName} ${state.merchant.user!.lastName}',
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      editMode = !editMode;
                                      firstNameController.text =
                                          state.merchant.user!.firstName!;
                                      lastNameController.text =
                                          state.merchant.user!.lastName!;
                                      phoneController.text =
                                          state.merchant.user!.phone!;
                                      emailController.text =
                                          state.merchant.user!.email!;
                                      addressController.text =
                                          state.merchant.address!;
                                      companyNameController.text =
                                          state.merchant.companyName!;
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
                                        text: state
                                                .merchant.user!.phone!.isEmpty
                                            ? '---'
                                            : '${state.merchant.user!.phone}',
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
                                        text: state
                                                .merchant.user!.email!.isEmpty
                                            ? '---'
                                            : '${state.merchant.user!.email}',
                                      ),
                                    ],
                                  ),
                            const SizedBox(
                              height: 4,
                            ),
                            editMode
                                ? TextFormField(
                                    controller: addressController,
                                    onTap: () {
                                      addressController.selection =
                                          TextSelection(
                                              baseOffset: 0,
                                              extentOffset: addressController
                                                  .value.text.length);
                                    },
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom +
                                            20),
                                    textInputAction: TextInputAction.done,
                                    // keyboardType: TextInputType.phone,
                                    style: const TextStyle(fontSize: 18),
                                    decoration: InputDecoration(
                                      labelText: "العنوان",
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
                                      addressController.text = newValue!;
                                    },
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SectionBody(
                                        text: 'العنوان: ',
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      SectionBody(
                                        text: state.merchant.address!.isEmpty
                                            ? '---'
                                            : '${state.merchant.address}',
                                      ),
                                    ],
                                  ),
                            const SizedBox(
                              height: 4,
                            ),
                            editMode
                                ? TextFormField(
                                    controller: companyNameController,
                                    onTap: () {
                                      companyNameController.selection =
                                          TextSelection(
                                              baseOffset: 0,
                                              extentOffset:
                                                  companyNameController
                                                      .value.text.length);
                                    },
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom +
                                            20),
                                    textInputAction: TextInputAction.done,
                                    style: const TextStyle(fontSize: 18),
                                    decoration: InputDecoration(
                                      labelText: "اسم الشركة",
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
                                      companyNameController.text = newValue!;
                                    },
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SectionBody(
                                        text: 'اسم الشركة: ',
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      SectionBody(
                                        text: state
                                                .merchant.companyName!.isEmpty
                                            ? '---'
                                            : '${state.merchant.companyName}',
                                      ),
                                    ],
                                  ),
                            const Divider(),
                            state.merchant.imageTradeLicense!.isEmpty
                                ? const SectionBody(
                                    text: "لم يتم ترفيع صورة عن السجل التجاري")
                                : SizedBox(
                                    height: 150.h,
                                    child: Image.network(
                                      state.merchant.imageTradeLicense!,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                            const Divider(),
                            state.merchant.imageId!.isEmpty
                                ? const SectionBody(
                                    text: "لم يتم ترفيع صورة عن الهوية الشخصية")
                                : SizedBox(
                                    height: 150.h,
                                    child: Image.network(
                                      state.merchant.imageId!,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                            const Divider(),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SectionTitle(text: "مستودعاتي"),
                              ],
                            ),
                            state.merchant.stores!.isNotEmpty
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
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text("اسم المستودع"),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            color: AppColor.lightYellow,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text("العنوان"),
                                            ),
                                          ),
                                        ),
                                      ]),
                                      ...List.generate(
                                        state.merchant.stores!.length,
                                        (index) => TableRow(children: [
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  "المستودع رقم ${state.merchant.stores![index].id!}"),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(state.merchant
                                                  .stores![index].address!),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ],
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("لم يتم إضافة أية مستودعات"),
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
                                            AddStoreHouseScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "إضافة مستودع  ",
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
                      Spacer(),
                      editMode
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: BlocConsumer<MerchantUpdateProfileBloc,
                                  MerchantUpdateProfileState>(
                                listener: (context, btnstate) {
                                  print(btnstate);
                                  if (btnstate
                                      is MerchantUpdateProfileLoadedSuccess) {
                                    setState(() {
                                      editMode = false;
                                    });
                                    BlocProvider.of<MerchantProfileBloc>(
                                            context)
                                        .add(MerchantProfileLoad(
                                            state.merchant.id!));
                                  }
                                },
                                builder: (context, btnstate) {
                                  if (btnstate
                                      is MerchantUpdateProfileLoadingProgress) {
                                    return CustomButton(
                                      title: LoadingIndicator(),
                                      onTap: () {},
                                    );
                                  } else {
                                    return CustomButton(
                                      title: Text("حفظ التغيرات"),
                                      onTap: () {
                                        _profileFormKey.currentState!.save();
                                        if (_profileFormKey.currentState!
                                            .validate()) {
                                          Merchant merchant = Merchant();
                                          merchant.id = state.merchant.id!;
                                          merchant.address =
                                              addressController.text;
                                          merchant.companyName =
                                              companyNameController.text;
                                          merchant.user = UserModel();
                                          merchant.user!.email =
                                              emailController.text;
                                          merchant.user!.phone =
                                              phoneController.text;
                                          merchant.user!.firstName =
                                              firstNameController.text;
                                          merchant.user!.lastName =
                                              lastNameController.text;
                                          BlocProvider.of<
                                                      MerchantUpdateProfileBloc>(
                                                  context)
                                              .add(
                                                  MerchantUpdateProfileButtonPressed(
                                                      merchant, null));
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
