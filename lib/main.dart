import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sales_rep_visit_tracker_feature/config/config.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/activity/activity_supabase_api.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/customer/customer_supabase_api.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/visit/visit_supabase_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/network_service.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/supabase_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/supabase_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/repository_impl/supabase_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/domain/service_impl/dio_network_service.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/routing/routes.dart';

void main() {

  /// Services

  // Network
  NetworkService ns = DioNetworkService();
  GetIt.I.registerSingleton(ns);

  /// Repositories

  // Activity
  ActivityRepository activityRepository = SupabaseActivityRepository(
    activityApi: ActivitySupabaseApi(
      networkService: ns,
      baseUrl: supabaseBaseUrl,
      apiKey: supabaseApiKey,
    ),
  );
  GetIt.I.registerSingleton(activityRepository);

  // Customer
  CustomerRepository customerRepository = SupabaseCustomerRepository(
    customerApi: CustomerSupabaseApi(
      networkService: ns,
      baseUrl: supabaseBaseUrl,
      apiKey: supabaseApiKey,
    ),
  );
  GetIt.I.registerSingleton(customerRepository);

  // Visit
  VisitRepository visitRepository = SupabaseVisitRepository(
    visitApi: SupabaseVisitApi(
      networkService: ns,
      baseUrl: supabaseBaseUrl,
      apiKey: supabaseApiKey,
    ),
  );
  GetIt.I.registerSingleton(visitRepository);

  runApp(const SalesRepVisitTrackerApplication());
}

class SalesRepVisitTrackerApplication extends StatelessWidget {
  const SalesRepVisitTrackerApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visit Tracker',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splashScreen.path,
      routes: {for (var route in AppRoutes.values) route.path: route.getPage},
    );
  }
}
