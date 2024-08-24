// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/profile/driver_update_profile_bloc.dart';
import 'package:camion/business_logic/bloc/profile/merchant_update_profile_bloc.dart';
import 'package:camion/business_logic/bloc/profile/owner_update_profile_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_type_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/providers/user_provider.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:camion/views/screens/control_view.dart';
import 'package:camion/views/screens/driver/create_truck_for%20driver.dart';
import 'package:camion/views/widgets/custom_botton.dart';
import 'package:camion/views/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
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

  UserProvider? userProvider;
  bool btnLoading = false;
  getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString("userType") ?? "";
    });
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      userProvider = Provider.of<UserProvider>(context, listen: false);
    });
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
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!
                                        .translate('first_name'),
                                    contentPadding: const EdgeInsets.symmetric(
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
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!
                                        .translate('last_name'),
                                    contentPadding: const EdgeInsets.symmetric(
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
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!
                                  .translate('email'),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 11.0, horizontal: 9.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (userType == "Merchant")
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: addressController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .translate('address'),
                                contentPadding: const EdgeInsets.symmetric(
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
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .translate('company_name'),
                                contentPadding: const EdgeInsets.symmetric(
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
                  const Spacer(),
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
          listener: (context, btnstate) async {
            print(btnstate);
            if (btnstate is MerchantUpdateProfileLoadedSuccess) {
              setState(() {
                btnLoading = true;
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var jwt = prefs.getString("token");
              Response userresponse =
                  await HttpHelper.get(PROFILE_ENDPOINT, apiToken: jwt);
              print("userresponse.statusCode${userresponse.statusCode}");
              var myDataString = utf8.decode(userresponse.bodyBytes);

              prefs.setString("userProfile", myDataString);
              // print("userProfile${myDataString}");
              var result = jsonDecode(myDataString);
              var userProfile = UserModel.fromJson(result);
              if (userresponse.statusCode == 200) {
                if (userType.isNotEmpty) {
                  prefs.setInt("merchant", userProfile.merchant!);
                  Response merchantResponse = await HttpHelper.get(
                      '$MERCHANTS_ENDPOINT${userProfile.merchant}/',
                      apiToken: jwt);
                  if (merchantResponse.statusCode == 200) {
                    var merchantDataString =
                        utf8.decode(merchantResponse.bodyBytes);
                    var res = jsonDecode(merchantDataString);
                    userProvider!.setMerchant(Merchant.fromJson(res));
                  }
                }
              }
              setState(() {
                btnLoading = false;
              });
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const ControlView(),
                ),
                (route) => false,
              );
            }
          },
          builder: (context, btnstate) {
            if (btnstate is MerchantUpdateProfileLoadingProgress ||
                btnLoading) {
              return CustomButton(
                title: LoadingIndicator(),
                onTap: () {},
              );
            } else {
              return CustomButton(
                title: Text(AppLocalizations.of(context)!.translate('save')),
                onTap: () {
                  _profileFormKey.currentState!.save();
                  if (_profileFormKey.currentState!.validate()) {
                    print(profileId);
                    Merchant merchant = Merchant();
                    // merchant.id = state.merchant.id!;
                    merchant.id = profileId;
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
          listener: (context, btnstate) async {
            print(btnstate);
            if (btnstate is DriverUpdateProfileLoadedSuccess) {
              setState(() {
                btnLoading = true;
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var jwt = prefs.getString("token");
              Response userresponse =
                  await HttpHelper.get(PROFILE_ENDPOINT, apiToken: jwt);
              print("userresponse.statusCode${userresponse.statusCode}");
              var myDataString = utf8.decode(userresponse.bodyBytes);

              prefs.setString("userProfile", myDataString);
              print("userProfile${myDataString}");
              var result = jsonDecode(myDataString);
              var userProfile = UserModel.fromJson(result);
              prefs.setInt("truckuser", userProfile.truckuser!);
              Response driverResponse = await HttpHelper.get(
                  '$DRIVERS_ENDPOINT${userProfile.truckuser}/',
                  apiToken: jwt);
              if (driverResponse.statusCode == 200) {
                var driverDataString = utf8.decode(driverResponse.bodyBytes);
                var res = jsonDecode(driverDataString);
                userProvider!.setDriver(Driver.fromJson(res));
                // prefs.setInt("truckId", res['truck2']["id"]);
                // prefs.setString("gpsId", res['truck2']["gpsId"]);
              }
              BlocProvider.of<TruckTypeBloc>(context).add(TruckTypeLoadEvent());

              setState(() {
                btnLoading = false;
              });
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateTruckForDriverScreen(driverId: btnstate.driver.id!),
                ),
                (route) => false,
              );
            }
          },
          builder: (context, btnstate) {
            if (btnstate is DriverUpdateProfileLoadingProgress || btnLoading) {
              return CustomButton(
                title: LoadingIndicator(),
                onTap: () {},
              );
            } else {
              return CustomButton(
                title: Text(AppLocalizations.of(context)!.translate('save')),
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
          listener: (context, btnstate) async {
            print(btnstate);
            if (btnstate is OwnerUpdateProfileLoadedSuccess) {
              setState(() {
                btnLoading = true;
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var jwt = prefs.getString("token");
              Response userresponse =
                  await HttpHelper.get(PROFILE_ENDPOINT, apiToken: jwt);
              print("userresponse.statusCode${userresponse.statusCode}");
              var myDataString = utf8.decode(userresponse.bodyBytes);

              prefs.setString("userProfile", myDataString);
              // print("userProfile${myDataString}");
              var result = jsonDecode(myDataString);
              var userProfile = UserModel.fromJson(result);
              print(userProfile.truckowner!);

              prefs.setInt("truckowner", userProfile.truckowner!);
              Response ownerResponse = await HttpHelper.get(
                  '$OWNERS_ENDPOINT${userProfile.truckowner}/',
                  apiToken: jwt);
              if (ownerResponse.statusCode == 200) {
                var ownerDataString = utf8.decode(ownerResponse.bodyBytes);
                print(ownerDataString);
                var res = jsonDecode(ownerDataString);
                userProvider!.setTruckOwner(TruckOwner.fromJson(res));
              }
              setState(() {
                btnLoading = false;
              });
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const ControlView(),
                ),
                (route) => false,
              );
            }
          },
          builder: (context, btnstate) {
            if (btnstate is OwnerUpdateProfileLoadingProgress || btnLoading) {
              return CustomButton(
                title: LoadingIndicator(),
                onTap: () {},
              );
            } else {
              return CustomButton(
                title: Text(AppLocalizations.of(context)!.translate('save')),
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
