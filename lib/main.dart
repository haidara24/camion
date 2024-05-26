import 'dart:io';

import 'package:camion/Localization/app_localizations_setup.dart';
import 'package:camion/business_logic/bloc/check_point/charge_types_list_bloc.dart';
import 'package:camion/business_logic/bloc/check_point/check_point_list_bloc.dart';
import 'package:camion/business_logic/bloc/check_point/pass_charge_details_bloc.dart';
import 'package:camion/business_logic/bloc/check_point/permission_details_bloc.dart';
import 'package:camion/business_logic/bloc/core/auth_bloc.dart';
import 'package:camion/business_logic/bloc/core/commodity_category_bloc.dart';
import 'package:camion/business_logic/bloc/core/k_commodity_category_bloc.dart';
import 'package:camion/business_logic/bloc/core/search_category_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/create_price_request_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/driver_active_shipment_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/incoming_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/inprogress_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/instruction_create_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/payment_create_bloc.dart';
import 'package:camion/business_logic/bloc/core/notification_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/read_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/managment/complete_managment_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/create_category_bloc.dart';
import 'package:camion/business_logic/bloc/check_point/create_pass_charges_bloc.dart';
import 'package:camion/business_logic/bloc/managment/create_permission_bloc.dart';
import 'package:camion/business_logic/bloc/managment/managment_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/managment_shipment_update_status_bloc.dart';
import 'package:camion/business_logic/bloc/managment/passcharges_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/permissions_list_bloc.dart';
import 'package:camion/business_logic/bloc/managment/price_request_bloc.dart';
import 'package:camion/business_logic/bloc/managment/shipment_update_status_bloc.dart';
import 'package:camion/business_logic/bloc/managment/simple_category_list_bloc.dart';
import 'package:camion/business_logic/bloc/order_truck_bloc.dart';
import 'package:camion/business_logic/bloc/owner_shipments/owner_active_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/owner_shipments/owner_incoming_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/owner_shipments/owner_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/package_type_bloc.dart';
import 'package:camion/business_logic/bloc/post_bloc.dart';
import 'package:camion/business_logic/bloc/core/draw_route_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/shipment_update_status_bloc.dart';
import 'package:camion/business_logic/bloc/requests/accept_request_for_merchant_bloc.dart';
import 'package:camion/business_logic/bloc/requests/driver_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/requests/reject_request_for_merchant_bloc.dart';
import 'package:camion/business_logic/bloc/requests/request_details_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/active_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_complete_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_multi_create_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_running_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shippment_create_bloc.dart';
import 'package:camion/business_logic/bloc/truck/owner_trucks_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_details_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_type_bloc.dart';
import 'package:camion/business_logic/bloc/truck/trucks_list_bloc.dart';
import 'package:camion/business_logic/bloc/truck_papers/create_truck_paper_bloc.dart';
import 'package:camion/business_logic/bloc/truck_papers/truck_papers_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/unassigned_shipment_list_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/internet_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/providers/active_shipment_provider.dart';
import 'package:camion/data/providers/add_multi_shipment_provider.dart';
import 'package:camion/data/providers/add_shippment_provider.dart';
import 'package:camion/data/providers/notification_provider.dart';
import 'package:camion/data/providers/shipment_instructions_provider.dart';
import 'package:camion/data/providers/task_num_provider.dart';
import 'package:camion/data/providers/truck_provider.dart';
import 'package:camion/data/repositories/auth_repository.dart';
import 'package:camion/data/repositories/category_repository.dart';
import 'package:camion/data/repositories/check_point_repository.dart';
import 'package:camion/data/repositories/instruction_repository.dart';
import 'package:camion/data/repositories/notification_repository.dart';
import 'package:camion/data/repositories/post_repository.dart';
import 'package:camion/data/repositories/price_request_repository.dart';
import 'package:camion/data/repositories/request_repository.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:camion/data/repositories/truck_repository.dart';
import 'package:camion/firebase_options.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/splash_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // you need to initialize firebase first
  await Firebase.initializeApp(
    name: "Camion",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Permission.notification.isDenied.then((value) {
  //   if (value) {
  //     Permission.notification.request();
  //   }
  // });
  final LocaleCubit localeCubit = LocaleCubit();
  await localeCubit.initializeFromPreferences();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String lang = prefs.getString("language") ?? "en";
  // Stripe.publishableKey =
  //     "pk_test_51IZr3HApYMiHRCEPfSdLaWzGSzImzW2kc61cSI4mYf3JptVXsfFj2SG1xcBLBgLVdvW8EXckH50FgzKZeNp454dK00xplc6hCI";
  // Stripe.merchantIdentifier = "AcrossMena";
  // await Stripe.instance.applySettings();
  await Firebase.initializeApp(
    name: "Camion",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  HttpOverrides.global = MyHttpOverrides();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp(
    lang: lang,
  ));
}

class MyApp extends StatelessWidget {
  final String? lang;
  MyApp({super.key, required this.lang});
  final Connectivity connectivity = Connectivity();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return ScreenUtilInit(
          designSize: orientation == Orientation.portrait
              ? const Size(428, 926)
              : const Size(926, 428),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MultiRepositoryProvider(
              providers: [
                RepositoryProvider(
                  create: (context) => AuthRepository(),
                ),
                RepositoryProvider(
                  create: (context) => PostRepository(),
                ),
                RepositoryProvider(
                  create: (context) => NotificationRepository(),
                ),
                RepositoryProvider(
                  create: (context) => ShipmentRepository(),
                ),
                RepositoryProvider(
                  create: (context) => InstructionRepository(),
                ),
                RepositoryProvider(
                  create: (context) => TruckRepository(),
                ),
                RepositoryProvider(
                  create: (context) => PriceRequestRepository(),
                ),
                RepositoryProvider(
                  create: (context) => CategoryRepository(),
                ),
                RepositoryProvider(
                  create: (context) => CheckPointRepository(),
                ),
                RepositoryProvider(
                  create: (context) => RequestRepository(),
                ),
              ],
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                      create: (context) => AuthBloc(
                          authRepository:
                              RepositoryProvider.of<AuthRepository>(context))),
                  BlocProvider(
                      create: (context) => NotificationBloc(
                          notificationRepository:
                              RepositoryProvider.of<NotificationRepository>(
                                  context))),
                  BlocProvider(
                    create: (context) => PostBloc(
                        postRepository:
                            RepositoryProvider.of<PostRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => CheckPointListBloc(
                        checkPointRepository:
                            RepositoryProvider.of<CheckPointRepository>(
                                context)),
                  ),
                  BlocProvider(
                    create: (context) => DriverRequestsListBloc(
                        requestRepository:
                            RepositoryProvider.of<RequestRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => RequestDetailsBloc(
                        requestRepository:
                            RepositoryProvider.of<RequestRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => AcceptRequestForMerchantBloc(
                        requestRepository:
                            RepositoryProvider.of<RequestRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => RejectRequestForMerchantBloc(
                        requestRepository:
                            RepositoryProvider.of<RequestRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => ChargeTypesListBloc(
                        checkPointRepository:
                            RepositoryProvider.of<CheckPointRepository>(
                                context)),
                  ),
                  BlocProvider(
                    create: (context) => PermissionsListBloc(
                        checkPointRepository:
                            RepositoryProvider.of<CheckPointRepository>(
                                context)),
                  ),
                  BlocProvider(
                    create: (context) => CreatePermissionBloc(
                        checkPointRepository:
                            RepositoryProvider.of<CheckPointRepository>(
                                context)),
                  ),
                  BlocProvider(
                    create: (context) => CreatePassChargesBloc(
                        checkPointRepository:
                            RepositoryProvider.of<CheckPointRepository>(
                                context)),
                  ),
                  BlocProvider(
                    create: (context) => PasschargesListBloc(
                        checkPointRepository:
                            RepositoryProvider.of<CheckPointRepository>(
                                context)),
                  ),
                  BlocProvider(
                    create: (context) => PassChargeDetailsBloc(
                        checkPointRepository:
                            RepositoryProvider.of<CheckPointRepository>(
                                context)),
                  ),
                  BlocProvider(
                    create: (context) => PermissionDetailsBloc(
                        checkPointRepository:
                            RepositoryProvider.of<CheckPointRepository>(
                                context)),
                  ),
                  BlocProvider(
                    create: (context) => TrucksListBloc(
                        truckRepository:
                            RepositoryProvider.of<TruckRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => PriceRequestBloc(
                        priceRepository:
                            RepositoryProvider.of<PriceRequestRepository>(
                                context)),
                  ),
                  BlocProvider(
                    create: (context) => CreatePriceRequestBloc(
                        priceRequestRepository:
                            RepositoryProvider.of<PriceRequestRepository>(
                                context)),
                  ),
                  BlocProvider(
                    create: (context) => CreateCategoryBloc(
                        categoryRepository:
                            RepositoryProvider.of<CategoryRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => SimpleCategoryListBloc(
                        categoryRepository:
                            RepositoryProvider.of<CategoryRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => OwnerTrucksBloc(
                        truckRepository:
                            RepositoryProvider.of<TruckRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => TruckDetailsBloc(
                        truckRepository:
                            RepositoryProvider.of<TruckRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => TruckPapersBloc(
                        truckRepository:
                            RepositoryProvider.of<TruckRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => CreateTruckPaperBloc(
                        truckRepository:
                            RepositoryProvider.of<TruckRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => SearchCategoryListBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => ShipmentUpdateStatusBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => ManagmentShipmentUpdateStatusBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => TruckTypeBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => CommodityCategoryBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => KCommodityCategoryBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => PackageTypeBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => ShippmentCreateBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => ShipmentMultiCreateBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => InstructionCreateBloc(
                        instructionRepository:
                            RepositoryProvider.of<InstructionRepository>(
                                context)),
                  ),
                  BlocProvider(
                    create: (context) => ReadInstructionBloc(
                        instructionRepository:
                            RepositoryProvider.of<InstructionRepository>(
                                context)),
                  ),
                  BlocProvider(
                    create: (context) => PaymentCreateBloc(
                        instructionRepository:
                            RepositoryProvider.of<InstructionRepository>(
                                context)),
                  ),
                  BlocProvider(
                    create: (context) => OrderTruckBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => ShipmentListBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => ManagmentShipmentListBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => CompleteManagmentShipmentListBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => OwnerShipmentListBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => ShipmentCompleteListBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => IncomingShipmentsBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => OwnerIncomingShipmentsBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => InprogressShipmentsBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => ActiveShipmentListBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => DriverActiveShipmentBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => OwnerActiveShipmentsBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => UnassignedShipmentListBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => DriverShipmentUpdateStatusBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => ShipmentDetailsBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => SubShipmentDetailsBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(
                    create: (context) => ShipmentRunningBloc(
                        shipmentRepository:
                            RepositoryProvider.of<ShipmentRepository>(context)),
                  ),
                  BlocProvider(create: (context) => DrawRouteBloc()),
                  BlocProvider(create: (context) => BottomNavBarCubit()),
                  BlocProvider(
                      create: (context) =>
                          InternetCubit(connectivity: connectivity)),
                  BlocProvider(create: (context) => LocaleCubit()),
                ],
                child: MultiProvider(
                  providers: [
                    ChangeNotifierProvider(create: (_) => TaskNumProvider()),
                    ChangeNotifierProvider(
                        create: (_) => ShipmentInstructionsProvider()),
                    ChangeNotifierProvider(
                        create: (_) => NotificationProvider()),
                    ChangeNotifierProvider(
                        create: (_) => AddShippmentProvider()),
                    ChangeNotifierProvider(
                        create: (_) => AddMultiShipmentProvider()),
                    ChangeNotifierProvider(
                        create: (_) => ActiveShippmentProvider()),
                    ChangeNotifierProvider(create: (_) => TruckProvider()),
                  ],
                  child: BlocBuilder<LocaleCubit, LocaleState>(
                    buildWhen: (previous, current) => previous != current,
                    builder: (context, localeState) {
                      return MaterialApp(
                        title: 'Camion',
                        debugShowCheckedModeBanner: false,
                        localizationsDelegates:
                            AppLocalizationsSetup.localizationsDelegates,
                        supportedLocales:
                            AppLocalizationsSetup.supportedLocales,
                        // localeResolutionCallback: AppLocalizationsSetup.,
                        locale: localeState.value,
                        scrollBehavior:
                            ScrollConfiguration.of(context).copyWith(
                          physics: const ClampingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                        ),
                        theme: ThemeData(
                          colorScheme: ColorScheme.fromSeed(
                            seedColor: AppColor.deepYellow,
                          ),
                          useMaterial3: true,
                          cardTheme: const CardTheme(
                            surfaceTintColor: Colors.white,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          inputDecorationTheme: InputDecorationTheme(
                            labelStyle: TextStyle(
                                fontSize: 18, color: Colors.grey[600]!),
                            suffixStyle: const TextStyle(
                              fontSize: 20,
                            ),
                            floatingLabelStyle: const TextStyle(
                              fontSize: 20,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 11.0,
                              horizontal: 9.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black26,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColor.deepYellow,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          textTheme: GoogleFonts.robotoTextTheme(
                            Theme.of(context).textTheme,
                          ),
                          dividerColor: Colors.grey[400],
                          scaffoldBackgroundColor: Colors.white,
                        ),
                        home: SplashScreen(),
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(textScaleFactor: 1.0),
                            child: child!,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          });
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
