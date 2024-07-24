import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/profile/driver_update_profile_bloc.dart';
import 'package:camion/business_logic/bloc/profile/merchant_update_profile_bloc.dart';
import 'package:camion/business_logic/bloc/profile/owner_update_profile_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateProfileScreen extends StatefulWidget {
  CreateProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();

  String userType = "Merchant";

  int profileId = 0;

  TextEditingController firstNameController = TextEditingController();

  TextEditingController lastNameController = TextEditingController();

  TextEditingController phoneController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController addressController = TextEditingController();

  TextEditingController companyNameController = TextEditingController();

  getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userType = prefs.getString("userType") ?? "";
    switch (userType) {
      case "Merchant":
        profileId = prefs.getInt("merchant")!;
      case "Driver":
        profileId = prefs.getInt("truckuser")!;
      case "Owner":
        profileId = prefs.getInt("truckowner")!;
        break;
      default:
    }
  }

  @override
  void initState() {
    super.initState();
    getUserType();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == "en"
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: SafeArea(
            child: Scaffold(
              // appBar: CustomAppBar(
              //   title: " ",
              // ),
              body: Form(
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
                                    child: Center(
                                      child: Text(
                                        "asd",
                                        style: TextStyle(
                                          fontSize: 28.sp,
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
                        const SizedBox(height: 50),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: firstNameController,
                                  decoration: const InputDecoration(
                                    labelText: "الاسم الأول",
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 11.0, horizontal: 9.0),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter a value';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: lastNameController,
                                  decoration: const InputDecoration(
                                    labelText: "الاسم الأخير",
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 11.0, horizontal: 9.0),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter a value';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: "البريد الالكتروني",
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 11.0, horizontal: 9.0),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a value';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (userType == "Merchant")
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: addressController,
                              decoration: const InputDecoration(
                                labelText: "العنوان",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 11.0, horizontal: 9.0),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a value';
                                }
                                return null;
                              },
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (userType == "Merchant")
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: companyNameController,
                              decoration: const InputDecoration(
                                labelText: "اسم الشركة",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 11.0, horizontal: 9.0),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a value';
                                }
                                return null;
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: buildupdateProfileBtn(userType),
                  ),
                  const SizedBox(height: 8),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }

  buildupdateProfileBtn(String userType) {
    switch (userType) {
      case "Merchant":
        return BlocConsumer<MerchantUpdateProfileBloc,
            MerchantUpdateProfileState>(
          listener: (context, btnstate) {
            print(btnstate);
            if (btnstate is MerchantUpdateProfileLoadedSuccess) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => ControlView(),
                ),
                (route) => false,
              );
            }
          },
          builder: (context, btnstate) {
            if (btnstate is MerchantUpdateProfileLoadingProgress) {
              return CustomButton(
                title: LoadingIndicator(),
                onTap: () {},
              );
            } else {
              return CustomButton(
                title: Text("حفظ التغيرات"),
                onTap: () {
                  _profileFormKey.currentState!.save();
                  if (_profileFormKey.currentState!.validate()) {
                    print(profileId);
                    Merchant merchant = Merchant();
                    // merchant.id = state.merchant.id!;
                    // merchant.id = profileId;
                    merchant.address = addressController.text;
                    merchant.companyName = companyNameController.text;
                    merchant.user = UserModel();
                    merchant.user!.email = emailController.text;
                    // merchant.user!.phone = phoneController.text;
                    merchant.user!.firstName = firstNameController.text;
                    merchant.user!.lastName = lastNameController.text;
                    BlocProvider.of<MerchantUpdateProfileBloc>(context).add(
                        MerchantUpdateProfileButtonPressed(merchant, null));
                  }
                },
              );
            }
          },
        );
      case "Driver":
        return BlocConsumer<DriverUpdateProfileBloc, DriverUpdateProfileState>(
          listener: (context, btnstate) {
            print(btnstate);
            if (btnstate is DriverUpdateProfileLoadedSuccess) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => ControlView(),
                ),
                (route) => false,
              );
            }
          },
          builder: (context, btnstate) {
            if (btnstate is DriverUpdateProfileLoadingProgress) {
              return CustomButton(
                title: LoadingIndicator(),
                onTap: () {},
              );
            } else {
              return CustomButton(
                title: Text("حفظ التغيرات"),
                onTap: () {
                  _profileFormKey.currentState!.save();
                  if (_profileFormKey.currentState!.validate()) {
                    Driver driver = Driver();
                    driver.id = profileId;
                    driver.user = UserModel();
                    driver.user!.email = emailController.text;
                    // driver.user!.phone = phoneController.text;
                    driver.user!.firstName = firstNameController.text;
                    driver.user!.lastName = lastNameController.text;
                    BlocProvider.of<DriverUpdateProfileBloc>(context)
                        .add(DriverUpdateProfileButtonPressed(driver, null));
                  }
                },
              );
            }
          },
        );
      case "Owner":
        return BlocConsumer<OwnerUpdateProfileBloc, OwnerUpdateProfileState>(
          listener: (context, btnstate) {
            print(btnstate);
            if (btnstate is OwnerUpdateProfileLoadedSuccess) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => ControlView(),
                ),
                (route) => false,
              );
            }
          },
          builder: (context, btnstate) {
            if (btnstate is OwnerUpdateProfileLoadingProgress) {
              return CustomButton(
                title: LoadingIndicator(),
                onTap: () {},
              );
            } else {
              return CustomButton(
                title: const Text("حفظ التغيرات"),
                onTap: () {
                  _profileFormKey.currentState!.save();
                  if (_profileFormKey.currentState!.validate()) {
                    TruckOwner owner = TruckOwner();
                    owner.id = profileId;
                    owner.user = UserModel();
                    owner.user!.email = emailController.text;
                    // owner.user!.phone = phoneController.text;
                    owner.user!.firstName = firstNameController.text;
                    owner.user!.lastName = lastNameController.text;
                    BlocProvider.of<OwnerUpdateProfileBloc>(context).add(
                      OwnerUpdateProfileButtonPressed(owner, null),
                    );
                  }
                },
              );
            }
          },
        );
      default:
    }
  }
}
