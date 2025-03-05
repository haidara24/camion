import 'dart:io';
import 'dart:isolate';

import 'package:camion/Localization/app_localizations_setup.dart';
import 'package:camion/business_logic/bloc/bloc/delete_truck_price_bloc.dart';
import 'package:camion/business_logic/bloc/bloc/truck_prices_list_bloc.dart';
import 'package:camion/business_logic/bloc/bloc/update_truck_price_bloc.dart';
import 'package:camion/business_logic/bloc/core/auth_bloc.dart';
import 'package:camion/business_logic/bloc/core/commodity_category_bloc.dart';
import 'package:camion/business_logic/bloc/core/create_truck_price_bloc.dart';
import 'package:camion/business_logic/bloc/core/governorates_list_bloc.dart';
import 'package:camion/business_logic/bloc/core/k_commodity_category_bloc.dart';
import 'package:camion/business_logic/bloc/core/owner_notifications_bloc.dart';
import 'package:camion/business_logic/bloc/core/search_category_list_bloc.dart';
import 'package:camion/business_logic/bloc/core/upload_image_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/activate_shipment_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/assign_shipment_bloc.dart';
import 'package:camion/business_logic/bloc/gps_reports/over_speed_bloc.dart';
import 'package:camion/business_logic/bloc/gps_reports/parking_report_bloc.dart';
import 'package:camion/business_logic/bloc/gps_reports/total_milage_day_bloc.dart';
import 'package:camion/business_logic/bloc/gps_reports/total_statistics_bloc.dart';
import 'package:camion/business_logic/bloc/gps_reports/trip_report_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/read_payment_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/driver_active_shipment_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/incoming_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/inprogress_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/sub_shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/instruction_create_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/payment_create_bloc.dart';
import 'package:camion/business_logic/bloc/core/notification_bloc.dart';
import 'package:camion/business_logic/bloc/instructions/read_instruction_bloc.dart';
import 'package:camion/business_logic/bloc/order_truck_bloc.dart';
import 'package:camion/business_logic/bloc/owner_shipments/owner_active_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/profile/driver_profile_bloc.dart';
import 'package:camion/business_logic/bloc/profile/driver_update_profile_bloc.dart';
import 'package:camion/business_logic/bloc/profile/owner_profile_bloc.dart';
import 'package:camion/business_logic/bloc/profile/owner_update_profile_bloc.dart';
import 'package:camion/business_logic/bloc/profile/upload_image_id_bloc.dart';
import 'package:camion/business_logic/bloc/profile/upload_trade_license_bloc.dart';
import 'package:camion/business_logic/bloc/requests/accept_request_for_driver_bloc.dart';
import 'package:camion/business_logic/bloc/requests/owner_incoming_shipments_bloc.dart';
import 'package:camion/business_logic/bloc/owner_shipments/owner_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/core/package_type_bloc.dart';
import 'package:camion/business_logic/bloc/post_bloc.dart';
import 'package:camion/business_logic/bloc/core/draw_route_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/shipment_update_status_bloc.dart';
import 'package:camion/business_logic/bloc/profile/create_store_bloc.dart';
import 'package:camion/business_logic/bloc/profile/merchant_profile_bloc.dart';
import 'package:camion/business_logic/bloc/profile/merchant_update_profile_bloc.dart';
import 'package:camion/business_logic/bloc/requests/accept_request_for_merchant_bloc.dart';
import 'package:camion/business_logic/bloc/requests/driver_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/requests/merchant_requests_list_bloc.dart';
import 'package:camion/business_logic/bloc/requests/reject_request_for_driver_bloc.dart';
import 'package:camion/business_logic/bloc/requests/reject_request_for_merchant_bloc.dart';
import 'package:camion/business_logic/bloc/requests/request_details_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_update_status_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/active_shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/cancel_shipment_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/complete_sub_shipment_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/re_active_shipment_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_complete_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_details_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_list_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_multi_create_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_running_bloc.dart';
import 'package:camion/business_logic/bloc/shipments/shipment_task_list_bloc.dart';
import 'package:camion/business_logic/bloc/store_list_bloc.dart';
import 'package:camion/business_logic/bloc/truck/create_truck_bloc.dart';
import 'package:camion/business_logic/bloc/truck/owner_trucks_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_details_bloc.dart';
import 'package:camion/business_logic/bloc/truck/truck_type_bloc.dart';
import 'package:camion/business_logic/bloc/truck/trucks_list_bloc.dart';
import 'package:camion/business_logic/bloc/truck_active_status_bloc.dart';
import 'package:camion/business_logic/bloc/truck_fixes/fix_type_list_bloc.dart';
import 'package:camion/business_logic/bloc/truck_fixes/truck_fix_list_bloc.dart';
import 'package:camion/business_logic/bloc/truck_fixes/create_truck_fix_bloc.dart';
import 'package:camion/business_logic/bloc/truck_papers/create_truck_paper_bloc.dart';
import 'package:camion/business_logic/bloc/truck_papers/truck_papers_bloc.dart';
import 'package:camion/business_logic/bloc/driver_shipments/unassigned_shipment_list_bloc.dart';
import 'package:camion/business_logic/cubit/bottom_nav_bar_cubit.dart';
import 'package:camion/business_logic/cubit/internet_cubit.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/data/providers/active_shipment_provider.dart';
import 'package:camion/data/providers/request_num_provider.dart';
import 'package:camion/data/providers/truck_active_status_provider.dart';
import 'package:camion/data/providers/add_multi_shipment_provider.dart';
import 'package:camion/data/providers/notification_provider.dart';
import 'package:camion/data/providers/shipment_instructions_provider.dart';
import 'package:camion/data/providers/task_num_provider.dart';
import 'package:camion/data/providers/truck_provider.dart';
import 'package:camion/data/providers/user_provider.dart';
import 'package:camion/data/repositories/auth_repository.dart';
import 'package:camion/data/repositories/category_repository.dart';
import 'package:camion/data/repositories/core_repository.dart';
import 'package:camion/data/repositories/gps_repository.dart';
import 'package:camion/data/repositories/instruction_repository.dart';
import 'package:camion/data/repositories/notification_repository.dart';
import 'package:camion/data/repositories/post_repository.dart';
import 'package:camion/data/repositories/profile_repository.dart';
import 'package:camion/data/repositories/request_repository.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:camion/data/repositories/store_repository.dart';
import 'package:camion/data/repositories/truck_price_repository.dart';
import 'package:camion/data/repositories/truck_repository.dart';
import 'package:camion/firebase_options.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/splash_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase
  await Firebase.initializeApp(
    name: "Camion",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("Handling a background message: ${message.messageId}");

  // Display local notification for background/terminated messages
  // await showLocalNotification(message);
  if (!isMainIsolate()) return; // Prevent unnecessary service initialization
}

bool isMainIsolate() {
  return Isolate.current.debugName == 'main';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final LocaleCubit localeCubit = LocaleCubit();
  await localeCubit.initializeFromPreferences();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String lang = prefs.getString("language") ?? "ar";

  await Firebase.initializeApp(
    name: "Camion",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  HttpOverrides.global = MyHttpOverrides();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppColor.deepBlack,
      systemNavigationBarColor: AppColor.deepBlack,
    ),
  );
  print("Running on isolate: ${Isolate.current.debugName}");
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
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => TaskNumProvider()),
                ChangeNotifierProvider(create: (_) => RequestNumProvider()),
                ChangeNotifierProvider(
                    create: (_) => ShipmentInstructionsProvider()),
                ChangeNotifierProvider(create: (_) => NotificationProvider()),
                ChangeNotifierProvider(
                    create: (_) => AddMultiShipmentProvider()),
                ChangeNotifierProvider(
                    create: (_) => ActiveShippmentProvider()),
                ChangeNotifierProvider(
                    create: (_) => TruckActiveStatusProvider()),
                ChangeNotifierProvider(create: (_) => UserProvider()),
                ChangeNotifierProvider(create: (_) => TruckProvider()),
              ],
              child: MultiRepositoryProvider(
                providers: [
                  RepositoryProvider(
                    create: (context) => AuthRepository(context),
                  ),
                  RepositoryProvider(
                    create: (context) => PostRepository(),
                  ),
                  RepositoryProvider(
                    create: (context) => TruckPriceRepository(),
                  ),
                  RepositoryProvider(
                    create: (context) => CoreRepository(),
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
                    create: (context) => ProfileRepository(),
                  ),
                  RepositoryProvider(
                    create: (context) => CategoryRepository(),
                  ),
                  RepositoryProvider(
                    create: (context) => RequestRepository(),
                  ),
                  RepositoryProvider(
                    create: (context) => StoreRepository(),
                  ),
                  RepositoryProvider(
                    create: (context) => GpsRepository(),
                  ),
                ],
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => AuthBloc(
                        authRepository:
                            RepositoryProvider.of<AuthRepository>(context),
                        userProvider:
                            Provider.of<UserProvider>(context, listen: false),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => TruckPricesListBloc(
                        truckPriceRepository:
                            RepositoryProvider.of<TruckPriceRepository>(
                                context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => CreateTruckPriceBloc(
                        truckPriceRepository:
                            RepositoryProvider.of<TruckPriceRepository>(
                                context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => UpdateTruckPriceBloc(
                        truckPriceRepository:
                            RepositoryProvider.of<TruckPriceRepository>(
                                context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => DeleteTruckPriceBloc(
                        truckPriceRepository:
                            RepositoryProvider.of<TruckPriceRepository>(
                                context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => GovernoratesListBloc(
                        coreRepository:
                            RepositoryProvider.of<CoreRepository>(context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => UploadImageBloc(
                        profileRepository:
                            RepositoryProvider.of<ProfileRepository>(context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => UploadImageIdBloc(
                        profileRepository:
                            RepositoryProvider.of<ProfileRepository>(context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => UploadTradeLicenseBloc(
                        profileRepository:
                            RepositoryProvider.of<ProfileRepository>(context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => OwnerProfileBloc(
                        profileRepository:
                            RepositoryProvider.of<ProfileRepository>(context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => MerchantProfileBloc(
                        profileRepository:
                            RepositoryProvider.of<ProfileRepository>(context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => DriverProfileBloc(
                        profileRepository:
                            RepositoryProvider.of<ProfileRepository>(context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => CreateStoreBloc(
                        profileRepository:
                            RepositoryProvider.of<ProfileRepository>(context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => StoreListBloc(
                        storeRepository:
                            RepositoryProvider.of<StoreRepository>(context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => CreateTruckBloc(
                        truckRepository:
                            RepositoryProvider.of<TruckRepository>(context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => MerchantUpdateProfileBloc(
                        profileRepository:
                            RepositoryProvider.of<ProfileRepository>(context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => OwnerUpdateProfileBloc(
                        profileRepository:
                            RepositoryProvider.of<ProfileRepository>(context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => DriverUpdateProfileBloc(
                        profileRepository:
                            RepositoryProvider.of<ProfileRepository>(context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => NotificationBloc(
                        notificationRepository:
                            RepositoryProvider.of<NotificationRepository>(
                                context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => OwnerNotificationsBloc(
                        notificationRepository:
                            RepositoryProvider.of<NotificationRepository>(
                                context),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => PostBloc(
                          postRepository:
                              RepositoryProvider.of<PostRepository>(context)),
                    ),
                    BlocProvider(
                      create: (context) => DriverRequestsListBloc(
                          requestRepository:
                              RepositoryProvider.of<RequestRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => MerchantRequestsListBloc(
                          requestRepository:
                              RepositoryProvider.of<RequestRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => RequestDetailsBloc(
                          requestRepository:
                              RepositoryProvider.of<RequestRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => AcceptRequestForMerchantBloc(
                          requestRepository:
                              RepositoryProvider.of<RequestRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => RejectRequestForMerchantBloc(
                          requestRepository:
                              RepositoryProvider.of<RequestRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => AcceptRequestForDriverBloc(
                          requestRepository:
                              RepositoryProvider.of<RequestRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => RejectRequestForDriverBloc(
                          requestRepository:
                              RepositoryProvider.of<RequestRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => TrucksListBloc(
                          truckRepository:
                              RepositoryProvider.of<TruckRepository>(context)),
                    ),
                    BlocProvider(
                      create: (context) => TruckFixListBloc(
                          truckRepository:
                              RepositoryProvider.of<TruckRepository>(context)),
                    ),
                    BlocProvider(
                      create: (context) => CreateTruckFixBloc(
                          truckRepository:
                              RepositoryProvider.of<TruckRepository>(context)),
                    ),
                    BlocProvider(
                      create: (context) => FixTypeListBloc(
                          truckRepository:
                              RepositoryProvider.of<TruckRepository>(context)),
                    ),
                    BlocProvider(
                      create: (context) => OwnerTrucksBloc(
                          truckRepository:
                              RepositoryProvider.of<TruckRepository>(context)),
                    ),
                    BlocProvider(
                      create: (context) => TruckActiveStatusBloc(
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
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => CancelShipmentBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => CompleteSubShipmentBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => ReActiveShipmentBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => ActivateShipmentBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => TruckTypeBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => CommodityCategoryBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => KCommodityCategoryBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => PackageTypeBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => ShipmentMultiCreateBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => ShipmentUpdateStatusBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
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
                      create: (context) => ReadPaymentInstructionBloc(
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
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => AssignShipmentBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => ShipmentListBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => OwnerShipmentListBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => ShipmentCompleteListBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => IncomingShipmentsBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => OwnerIncomingShipmentsBloc(
                          requestRepository:
                              RepositoryProvider.of<RequestRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => InprogressShipmentsBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => ActiveShipmentListBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => DriverActiveShipmentBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => OwnerActiveShipmentsBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => UnassignedShipmentListBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => DriverShipmentUpdateStatusBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => ShipmentDetailsBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => SubShipmentDetailsBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => ShipmentRunningBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => ShipmentTaskListBloc(
                          shipmentRepository:
                              RepositoryProvider.of<ShipmentRepository>(
                                  context)),
                    ),
                    BlocProvider(
                      create: (context) => OverSpeedBloc(
                          gpsRepository:
                              RepositoryProvider.of<GpsRepository>(context)),
                    ),
                    BlocProvider(
                      create: (context) => ParkingReportBloc(
                          gpsRepository:
                              RepositoryProvider.of<GpsRepository>(context)),
                    ),
                    BlocProvider(
                      create: (context) => TotalMilageDayBloc(
                          gpsRepository:
                              RepositoryProvider.of<GpsRepository>(context)),
                    ),
                    BlocProvider(
                      create: (context) => TotalStatisticsBloc(
                          gpsRepository:
                              RepositoryProvider.of<GpsRepository>(context)),
                    ),
                    BlocProvider(
                      create: (context) => TripReportBloc(
                          gpsRepository:
                              RepositoryProvider.of<GpsRepository>(context)),
                    ),
                    BlocProvider(create: (context) => DrawRouteBloc()),
                    BlocProvider(create: (context) => BottomNavBarCubit()),
                    BlocProvider(
                        create: (context) =>
                            InternetCubit(connectivity: connectivity)),
                    BlocProvider(create: (context) => LocaleCubit()),
                  ],
                  child: BlocBuilder<LocaleCubit, LocaleState>(
                    buildWhen: (previous, current) => previous != current,
                    builder: (context, localeState) {
                      return MaterialApp(
                        title: 'Camion',
                        debugShowCheckedModeBanner: false,
                        navigatorKey: navigatorKey,
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
                                fontSize: 16, color: Colors.grey[600]!),
                            suffixStyle: const TextStyle(
                              fontSize: 18,
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
                          textTheme: localeState.value.languageCode == "en"
                              ? GoogleFonts.tajawalTextTheme(
                                  Theme.of(context).textTheme,
                                )
                              : GoogleFonts.instrumentSansTextTheme(
                                  Theme.of(context).textTheme,
                                ),
                          dividerColor: Colors.grey[400],
                          scaffoldBackgroundColor: Colors.white,
                        ),
                        home: const SplashScreen(),
                        builder: (context, child) {
                          return AnnotatedRegion<SystemUiOverlayStyle>(
                            value: SystemUiOverlayStyle(
                              statusBarColor:
                                  Colors.white, // Make status bar transparent
                              statusBarIconBrightness: Brightness
                                  .light, // Light icons for dark backgrounds
                              systemNavigationBarColor:
                                  AppColor.landscapeNatural, // Works on Android
                              systemNavigationBarIconBrightness:
                                  Brightness.light,
                            ),
                            child: MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(textScaleFactor: 1.0),
                              child: child ?? Container(),
                            ),
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
