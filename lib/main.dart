import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_visit_statistics_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/connectivity/connectivity_plus_connection_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/connectivity/connectivity_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_database_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/activity/activity_supabase_api.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/customer/customer_supabase_api.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/visit/visit_supabase_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/network_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/activity/hive_local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/activity/supabase_remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/customer/hive_local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/customer/supabase_remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/visit/hive_local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/visit/hive_local_visit_statistics_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/visit/supabase_remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/service_impl/dio_network_service.dart';
import 'package:sales_rep_visit_tracker_feature/domain/service_impl/hive_local_database_service.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/themes/dark_theme.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/themes/light_theme.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/routing/routes.dart';

import 'data/utils/hive_cypher_generator.dart';
import 'domain/use_cases/visit/sync_unsynced_local_visits_use_case.dart';

Future<void> main() async {

  ///Environment variables
  const supabaseBaseUrl = String.fromEnvironment('SUPABASE_BASE_URL');
  const supabaseApiKey = String.fromEnvironment('SUPABASE_API_KEY');
  const hiveEncryptionKeyName = String.fromEnvironment('HIVE_ENCRYPTION_KEY_NAME');
  if(supabaseApiKey.isEmpty || supabaseBaseUrl.isEmpty || hiveEncryptionKeyName.isEmpty) exit(1);

  /// Services
  // Network
  NetworkService ns = DioNetworkService();
  GetIt.I.registerSingleton(ns);

  // Database
  await Hive.initFlutter();
  Hive.registerAdapter(UnSyncedLocalVisitAdapter());
  Hive.registerAdapter(LocalCustomerAdapter());
  Hive.registerAdapter(LocalActivityAdapter());
  Hive.registerAdapter(LocalVisitStatisticsAdapter());

  LocalDatabaseService db = HiveLocalDatabaseService(
    cipher: await HiveKeyGenerator(keyName: hiveEncryptionKeyName).obtainHiveAesCipher(),
  );
  GetIt.I.registerSingleton(db);

  // Connectivity
  ConnectivityService connectivityService = ConnectivityPlusConnectionService();
  GetIt.I.registerSingleton(connectivityService);

  /// Repositories

  // Activity
  // Remote
  RemoteActivityRepository activityRepository = SupabaseActivityRepository(
    activityApi: ActivitySupabaseApi(
      networkService: ns,
      baseUrl: supabaseBaseUrl,
      apiKey: supabaseApiKey,
    ),
  );
  GetIt.I.registerSingleton(activityRepository);

  // Local
  LocalActivityRepository localActivityRepository = HiveLocalActivityRepository(
    localActivityCrud: db,
  );
  GetIt.I.registerSingleton(localActivityRepository);

  // Customer
  // Remote
  RemoteCustomerRepository customerRepository = SupabaseCustomerRepository(
    customerApi: CustomerSupabaseApi(
      networkService: ns,
      baseUrl: supabaseBaseUrl,
      apiKey: supabaseApiKey,
    ),
  );
  GetIt.I.registerSingleton(customerRepository);

  // Local
  LocalCustomerRepository localCustomerRepository = HiveLocalCustomerRepository(
    localCustomerCrud: db,
  );
  GetIt.I.registerSingleton(localCustomerRepository);

  // Visit
  // Remote
  RemoteVisitRepository visitRepository = SupabaseVisitRepository(
    visitApi: SupabaseVisitApi(
      networkService: ns,
      baseUrl: supabaseBaseUrl,
      apiKey: supabaseApiKey,
    ),
  );
  GetIt.I.registerSingleton(visitRepository);

  // Local
  LocalUnsyncedVisitRepository unsyncedVR = HiveLocalUnsyncedVisitRepository(
    localUnSyncedLocalVisitCrud: db,
  );
  GetIt.I.registerSingleton(unsyncedVR);

  // Visit statistics
  LocalVisitStatisticsRepository localVisitStatisticsRepository = HiveLocalVisitStatisticsRepository(
    statisticsCrud: db,
  );
  GetIt.I.registerSingleton(localVisitStatisticsRepository);

  /// Global use cases
  SyncUnsyncedLocalVisitsUseCase syncCase = SyncUnsyncedLocalVisitsUseCase(
    remoteVisitRepository: GetIt.I(),
    localUnsyncedVisitRepository: GetIt.I(),
    connectivityService: GetIt.I(),
  );
  GetIt.I.registerSingleton(syncCase);

  runApp(const SalesRepVisitTrackerApplication());
}

class SalesRepVisitTrackerApplication extends StatefulWidget {
  const SalesRepVisitTrackerApplication({super.key});

  @override
  State<SalesRepVisitTrackerApplication> createState() => _SalesRepVisitTrackerApplicationState();
}

class _SalesRepVisitTrackerApplicationState extends State<SalesRepVisitTrackerApplication> {
  late final StreamSubscription<ToastMessage> toastStream;

  @override
  void initState() {
    toastStream = GlobalToastMessage().toastStream.listen((toast) => toast.show());
    super.initState();
  }

  @override
  void dispose() {
    toastStream.cancel();
    GlobalToastMessage().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'Visit Tracker',
        debugShowCheckedModeBanner: false,

        //TODO: Make theme dynamic and listenable
        themeMode: ThemeMode.light,
        theme: lightTheme,
        darkTheme: darkTheme,
        initialRoute: AppRoutes.splashScreen.path,
        routes: {for (var route in AppRoutes.values) route.path: route.getPage},
      ),
    );
  }
}
