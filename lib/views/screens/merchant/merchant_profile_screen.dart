import 'dart:io';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/core/upload_image_bloc.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MerchantProfileScreen extends StatefulWidget {
  // final Merchant user;
  const MerchantProfileScreen({Key? key}) : super(key: key);

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

  final bool _loading = false;

  final ImagePicker _picker = ImagePicker();

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
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: AppColor.deepBlack, // Make status bar transparent
            statusBarIconBrightness:
                Brightness.light, // Light icons for dark backgrounds
            systemNavigationBarColor: Colors.grey[200], // Works on Android
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: SafeArea(
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
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            print("asd");
                                            var pickedImage =
                                                await _picker.pickImage(
                                              source: ImageSource.gallery,
                                            );

                                            if (pickedImage != null) {
                                              var image =
                                                  File(pickedImage.path);
                                              BlocProvider.of<UploadImageBloc>(
                                                      context)
                                                  .add(UpdateUserImage(image));
                                            }
                                          },
                                          child: CircleAvatar(
                                            radius: 65.h,
                                            backgroundColor:
                                                AppColor.deepYellow,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(180),
                                              child: BlocConsumer<
                                                  UploadImageBloc,
                                                  UploadImageState>(
                                                listener: (context,
                                                    imagestate) async {
                                                  if (imagestate
                                                      is UserImageUpdateSuccess) {
                                                    SharedPreferences prefs =
                                                        await SharedPreferences
                                                            .getInstance();

                                                    var merchant = prefs
                                                        .getInt("merchant");
                                                    // print(merchant);
                                                    // ignore: use_build_context_synchronously
                                                    BlocProvider.of<
                                                                MerchantProfileBloc>(
                                                            context)
                                                        .add(
                                                            MerchantProfileLoad(
                                                                merchant!));
                                                  }
                                                  if (imagestate
                                                      is UserImageUpdateError) {}
                                                },
                                                builder: (context, imagestate) {
                                                  if (imagestate
                                                      is UserImageUpdateLoading) {
                                                    return Center(
                                                      child: LoadingIndicator(),
                                                    );
                                                  } else {
                                                    return SizedBox(
                                                      child: Image.network(
                                                        state.merchant.image ??
                                                            "",
                                                        fit: BoxFit.fill,
                                                        height: 130.h,
                                                        width: 130.h,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            Center(
                                                          child: Text(
                                                            "${state.merchant.firstname![0].toUpperCase()} ${state.merchant.lastname![0].toUpperCase()}",
                                                            style: TextStyle(
                                                              fontSize: 28.sp,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: false,
                                          child: Positioned(
                                            bottom: 0,
                                            left: 0,
                                            child: IconButton(
                                              onPressed: () async {
                                                print("asd");
                                                var pickedImage =
                                                    await _picker.pickImage(
                                                  source: ImageSource.gallery,
                                                );

                                                if (pickedImage != null) {
                                                  var image =
                                                      File(pickedImage.path);
                                                  BlocProvider.of<
                                                              UploadImageBloc>(
                                                          context)
                                                      .add(UpdateUserImage(
                                                          image));
                                                }
                                              },
                                              icon: Container(
                                                decoration: BoxDecoration(
                                                    color: AppColor.lightGrey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            45)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: const Icon(
                                                    Icons.cloud_upload_outlined,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
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
                                  const SizedBox(
                                    width: 40,
                                  ),
                                  SectionTitle(
                                    text:
                                        '${state.merchant.firstname} ${state.merchant.lastname}',
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        editMode = !editMode;
                                        firstNameController.text =
                                            state.merchant.firstname!;
                                        lastNameController.text =
                                            state.merchant.lastname!;
                                        phoneController.text =
                                            state.merchant.phone!;
                                        emailController.text =
                                            state.merchant.email!;
                                        addressController.text =
                                            state.merchant.address!;
                                        companyNameController.text =
                                            state.merchant.companyName!;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: AppColor.deepYellow,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              editMode
                                  ? Column(
                                      children: [
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: firstNameController,
                                                onTap: () {
                                                  firstNameController
                                                          .selection =
                                                      TextSelection(
                                                          baseOffset: 0,
                                                          extentOffset:
                                                              firstNameController
                                                                  .value
                                                                  .text
                                                                  .length);
                                                },
                                                scrollPadding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                                .viewInsets
                                                                .bottom +
                                                            20),
                                                textInputAction:
                                                    TextInputAction.done,
                                                style: const TextStyle(
                                                    fontSize: 18),
                                                decoration: InputDecoration(
                                                  labelText: AppLocalizations
                                                          .of(context)!
                                                      .translate('first_name'),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
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
                                                autovalidateMode:
                                                    AutovalidateMode
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
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextFormField(
                                                controller: lastNameController,
                                                onTap: () {
                                                  lastNameController.selection =
                                                      TextSelection(
                                                          baseOffset: 0,
                                                          extentOffset:
                                                              lastNameController
                                                                  .value
                                                                  .text
                                                                  .length);
                                                },
                                                scrollPadding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                                .viewInsets
                                                                .bottom +
                                                            20),
                                                textInputAction:
                                                    TextInputAction.done,
                                                style: const TextStyle(
                                                    fontSize: 18),
                                                decoration: InputDecoration(
                                                  labelText: AppLocalizations
                                                          .of(context)!
                                                      .translate('last_name'),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
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
                                                autovalidateMode:
                                                    AutovalidateMode
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
                                                  lastNameController.text =
                                                      newValue!;
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                              const SizedBox(height: 16),
                              editMode
                                  ? TextFormField(
                                      controller: phoneController,
                                      onTap: () {
                                        phoneController.selection =
                                            TextSelection(
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
                                        labelText: AppLocalizations.of(context)!
                                            .translate('phone'),
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
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return AppLocalizations.of(context)!
                                              .translate(
                                                  'insert_value_validate');
                                        }
                                        return null;
                                      },
                                      onSaved: (newValue) {
                                        phoneController.text = newValue!;
                                      },
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SectionBody(
                                          text:
                                              '${AppLocalizations.of(context)!.translate('phone')}: ',
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        SectionBody(
                                          text: state.merchant.phone!.isEmpty
                                              ? '---'
                                              : '${state.merchant.phone}',
                                        ),
                                      ],
                                    ),
                              const SizedBox(
                                height: 16,
                              ),
                              editMode
                                  ? TextFormField(
                                      controller: emailController,
                                      onTap: () {
                                        emailController.selection =
                                            TextSelection(
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
                                        labelText: AppLocalizations.of(context)!
                                            .translate('email'),
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
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return AppLocalizations.of(context)!
                                              .translate(
                                                  'insert_value_validate');
                                        }
                                        return null;
                                      },
                                      onSaved: (newValue) {
                                        emailController.text = newValue!;
                                      },
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SectionBody(
                                          text:
                                              '${AppLocalizations.of(context)!.translate('email')}: ',
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        SectionBody(
                                          text: state.merchant.email!.isEmpty
                                              ? '---'
                                              : '${state.merchant.email}',
                                        ),
                                      ],
                                    ),
                              const SizedBox(
                                height: 16,
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
                                        labelText: AppLocalizations.of(context)!
                                            .translate('address'),
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
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return AppLocalizations.of(context)!
                                              .translate(
                                                  'insert_value_validate');
                                        }
                                        return null;
                                      },
                                      onSaved: (newValue) {
                                        addressController.text = newValue!;
                                      },
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SectionBody(
                                          text:
                                              '${AppLocalizations.of(context)!.translate('address')}: ',
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
                                height: 16,
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
                                        labelText: AppLocalizations.of(context)!
                                            .translate('company_name'),
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
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return AppLocalizations.of(context)!
                                              .translate(
                                                  'insert_value_validate');
                                        }
                                        return null;
                                      },
                                      onSaved: (newValue) {
                                        companyNameController.text = newValue!;
                                      },
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SectionBody(
                                          text:
                                              '${AppLocalizations.of(context)!.translate('company_name')} : ',
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
                            ],
                          ),
                        ),
                        const Spacer(),
                        editMode
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: BlocConsumer<MerchantUpdateProfileBloc,
                                    MerchantUpdateProfileState>(
                                  listener: (context, btnstate) {
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
                                        title: Text(
                                          AppLocalizations.of(context)!
                                              .translate("save"),
                                        ),
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
                                            merchant.email =
                                                emailController.text;
                                            merchant.phone =
                                                phoneController.text;
                                            merchant.firstname =
                                                firstNameController.text;
                                            merchant.lastname =
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
                        const SizedBox(height: 16),
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
          ),
        );
      },
    );
  }
}
