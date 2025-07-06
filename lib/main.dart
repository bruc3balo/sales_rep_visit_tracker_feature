import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
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
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';
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
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_theme_notifier.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/routing/routes.dart';
import 'package:path_provider/path_provider.dart';

import 'data/utils/hive_cypher_generator.dart';
import 'domain/use_cases/visit/sync_unsynced_local_visits_use_case.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///Logger

  //LogFile
  var appDir = await getApplicationDocumentsDirectory();
  final File logFile = File('${appDir.path}/com-sales-logs.log');
  if (!logFile.existsSync()) logFile.createSync(recursive: true, exclusive: true);

  AppLog(
    output: FileLogOutput(logFile.absolute.path),
    printer: TagPrinter(),
    level: Level.all,
  );

  AppLog.I.i("MAIN", "Logger initiated");

  ///Environment variables
  const supabaseBaseUrl = String.fromEnvironment('SUPABASE_BASE_URL');
  const supabaseApiKey = String.fromEnvironment('SUPABASE_API_KEY');
  const hiveEncryptionKeyName = String.fromEnvironment('HIVE_ENCRYPTION_KEY_NAME');
  if (supabaseApiKey.isEmpty || supabaseBaseUrl.isEmpty || hiveEncryptionKeyName.isEmpty) exit(1);

  AppLog.I.d("MAIN", "supabaseBaseUrl = $supabaseBaseUrl");
  AppLog.I.d("MAIN", "supabaseApiKey = $supabaseApiKey");
  AppLog.I.d("MAIN", "hiveEncryptionKeyName = $hiveEncryptionKeyName");

  /// Services
  // Network
  NetworkService ns = DioNetworkService();
  GetIt.I.registerSingleton(ns);
  AppLog.I.d("MAIN", "initializing network service");

  // Database
  await Hive.initFlutter();
  Hive.registerAdapter(UnSyncedLocalVisitAdapter());
  Hive.registerAdapter(LocalCustomerAdapter());
  Hive.registerAdapter(LocalActivityAdapter());
  Hive.registerAdapter(LocalVisitStatisticsAdapter());
  AppLog.I.d("MAIN", "Registering hive adapters");

  LocalDatabaseService db = HiveLocalDatabaseService(
    cipher: await HiveKeyGenerator(keyName: hiveEncryptionKeyName).obtainHiveAesCipher(),
  );
  GetIt.I.registerSingleton(db);
  AppLog.I.d("MAIN", "Initializing local database");

  // Connectivity
  ConnectivityService connectivityService = ConnectivityPlusConnectionService()..initialize();
  GetIt.I.registerSingleton(connectivityService);
  AppLog.I.d("MAIN", "Initializing connectivity");

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
  AppLog.I.d("MAIN", "Initializing remote activity repository");

  // Local
  LocalActivityRepository localActivityRepository = HiveLocalActivityRepository(
    localActivityCrud: db,
  );
  GetIt.I.registerSingleton(localActivityRepository);
  AppLog.I.d("MAIN", "Initializing local activity repository");

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
  AppLog.I.d("MAIN", "Initializing remote customer repository");

  // Local
  LocalCustomerRepository localCustomerRepository = HiveLocalCustomerRepository(
    localCustomerCrud: db,
  );
  GetIt.I.registerSingleton(localCustomerRepository);
  AppLog.I.d("MAIN", "Initializing local customer repository");

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
  AppLog.I.d("MAIN", "Initializing remote visit repository");

  // Local
  LocalUnsyncedVisitRepository unsyncedVR = HiveLocalUnsyncedVisitRepository(
    localUnSyncedLocalVisitCrud: db,
  );
  GetIt.I.registerSingleton(unsyncedVR);
  AppLog.I.d("MAIN", "Initializing local unsynced visit repository");

  // Visit statistics
  LocalVisitStatisticsRepository localVisitStatisticsRepository = HiveLocalVisitStatisticsRepository(
    statisticsCrud: db,
  );
  GetIt.I.registerSingleton(localVisitStatisticsRepository);
  AppLog.I.d("MAIN", "Initializing local visit stats repository");

  /// Global use cases
  SyncUnsyncedLocalVisitsUseCase syncCase = SyncUnsyncedLocalVisitsUseCase(
    remoteVisitRepository: GetIt.I(),
    localUnsyncedVisitRepository: GetIt.I(),
    connectivityService: GetIt.I(),
  );
  GetIt.I.registerSingleton(syncCase);
  AppLog.I.d("MAIN", "Initializing global visit sync use case");

  runApp(const SalesRepVisitTrackerApplication());
}

class SalesRepVisitTrackerApplication extends StatefulWidget {
  const SalesRepVisitTrackerApplication({super.key});

  @override
  State<SalesRepVisitTrackerApplication> createState() => _SalesRepVisitTrackerApplicationState();
}

class _SalesRepVisitTrackerApplicationState extends State<SalesRepVisitTrackerApplication> {
  late final StreamSubscription<ToastMessage> toastStream;
  late final StreamSubscription<bool> connectivityStream;


  @override
  void initState() {
    toastStream = GlobalToastMessage().toastStream.listen((toast) => toast.show());

    //TODO: Fix remove unnecessary initial message
    connectivityStream = GetIt.I<ConnectivityService>().onConnectionChange.listen(
      (online) {
        GlobalToastMessage().add(
          InfoMessage(
            message: online ? "Connected" : "No internet connection",
          ),
        );
      },
    );
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
    return ValueListenableBuilder(
      valueListenable: GlobalThemeNotifier(),
      builder: (context, themeMode, __) {
        return SafeArea(
          child: MaterialApp(
            title: 'Visit Tracker',
            debugShowCheckedModeBanner: false,
            //TODO: Make theme dynamic and listenable
            themeMode: themeMode,
            theme: lightTheme,
            darkTheme: darkTheme,
            initialRoute: AppRoutes.splashScreen.path,
            routes: {for (var route in AppRoutes.values) route.path: route.getPage},
          ),
        );
      },
    );
  }
}
