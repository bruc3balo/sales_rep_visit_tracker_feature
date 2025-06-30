import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sales_rep_visit_tracker_feature/config/config.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_database_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/activity/activity_supabase_api.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/customer/customer_supabase_api.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/visit/visit_supabase_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/network_service.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/activity/hive_local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/activity/supabase_remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/customer/hive_local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/customer/supabase_remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/visit/hive_local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/visit/supabase_remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/service_impl/dio_network_service.dart';
import 'package:sales_rep_visit_tracker_feature/domain/service_impl/hive_local_database_service.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/count_visit_statistics_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/themes/dark_theme.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/themes/light_theme.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/view_model/view_visit_statistics_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/routing/routes.dart';

Future<void> main() async {

  /// Services

  // Network
  NetworkService ns = DioNetworkService();
  GetIt.I.registerSingleton(ns);

  // Database
  await Hive.initFlutter();
  Hive.registerAdapter(UnSyncedLocalVisitAdapter());

  LocalDatabaseService db = HiveLocalDatabaseService();
  GetIt.I.registerSingleton(db);

  /// Repositories

  // Activity
  //Remote
  RemoteActivityRepository activityRepository = SupabaseActivityRepository(
    activityApi: ActivitySupabaseApi(
      networkService: ns,
      baseUrl: supabaseBaseUrl,
      apiKey: supabaseApiKey,
    ),
  );
  GetIt.I.registerSingleton(activityRepository);

  //Local
  LocalActivityRepository localActivityRepository = HiveLocalActivityRepository(
    localActivityCrud: db,
  );
  GetIt.I.registerSingleton(localActivityRepository);

  // Customer
  //Remote
  RemoteCustomerRepository customerRepository = SupabaseCustomerRepository(
    customerApi: CustomerSupabaseApi(
      networkService: ns,
      baseUrl: supabaseBaseUrl,
      apiKey: supabaseApiKey,
    ),
  );
  GetIt.I.registerSingleton(customerRepository);

  //Local
  LocalCustomerRepository localCustomerRepository = HiveLocalCustomerRepository(
    localCustomerCrud: db,
  );
  GetIt.I.registerSingleton(localCustomerRepository);

  // Visit
  // Remote
  RemoteVisitRepository visitRepository = SupabaseVisitRepository(
    localDatabaseService: db,
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

  /// Global view models

  // ViewVisitStatisticsViewModel
  ViewVisitStatisticsViewModel statsVm = ViewVisitStatisticsViewModel(
    countVisitStatisticsUseCase: CountVisitStatisticsUseCase(
      visitRepository: visitRepository,
    ),
  );
  GetIt.I.registerSingleton(statsVm);

  runApp(const SalesRepVisitTrackerApplication());
}

class SalesRepVisitTrackerApplication extends StatelessWidget {
  const SalesRepVisitTrackerApplication({super.key});

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