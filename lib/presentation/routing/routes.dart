import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/create_activity_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/search_local_activities_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/search_remote_activities_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/create_customer_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/search_local_customers_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/search_remote_customer_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/add_a_new_visit_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/count_unsynced_visit_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/count_visit_statistics_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/delete_unsynced_visit_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/get_local_visit_statistics_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/sync_unsynced_local_visits_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/update_unsynced_visit_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/view_unsynced_local_visits_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/add_activity/view/add_activity_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/add_activity/view_model/add_activity_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view_model/search_activities_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/add_customer/view/add_customer_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/add_customer/view_model/add_customer_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view_model/search_customers_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/home/view/home_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/home/view_model/home_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/splash/view/splash_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/add_visit/view/add_visit_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/add_visit/view_model/add_visit_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/update_unsynced_visit/view/update_unsynced_visit_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/update_unsynced_visit/view_model/update_unsynced_visit_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_unsynced_visits/view/view_unsynced_visits_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_unsynced_visits/view_model/view_unsynced_visits_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_details/view/view_visit_details_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_details/view_model/view_visit_details_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/view/view_visit_statistics_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/view_model/view_visit_statistics_view_model.dart';

enum AppRoutes {
  splashScreen("/"),
  home("/home"),
  addVisit("/addVisit"),
  addActivity("/addActivity"),
  addCustomer("/addCustomer"),
  visitDetails("/visitDetails"),
  visitUnsyncedVisits("/visitUnsyncedVisits"),
  updateUnsyncedVisits("/updateUnsyncedVisits"),
  viewVisitStatistics("/visitStatistics");

  final String path;

  const AppRoutes(this.path);
}

extension RoutePage on AppRoutes {
  Widget getPage(BuildContext context) {
    return switch (this) {
      AppRoutes.splashScreen => SplashScreen(),
      AppRoutes.home => HomeScreen(
          homeViewModel: HomeViewModel(
            countUnsyncedVisitsUseCase: CountUnsyncedVisitsUseCase(
              localUnsyncedVisitRepository: GetIt.I(),
            ),
          ),
        ),
      AppRoutes.addVisit => AddVisitScreen(
          searchActivitiesViewModel: SearchActivitiesViewModel(
            searchLocalActivitiesUseCase: SearchLocalActivitiesUseCase(
              localActivityRepository: GetIt.I(),
            ),
            searchRemoteActivitiesUseCase: SearchRemoteActivitiesUseCase(
              remoteActivityRepository: GetIt.I(),
              localActivityRepository: GetIt.I(),
            ),
            connectivityService: GetIt.I(),
          ),
          searchCustomersViewModel: SearchCustomersViewModel(
            searchRemoteCustomerUseCase: SearchRemoteCustomerUseCase(
              remoteCustomerRepository: GetIt.I(),
              localCustomerRepository: GetIt.I(),
            ),
            searchLocalCustomersUseCase: SearchLocalCustomersUseCase(
              localCustomerRepository: GetIt.I(),
            ),
            connectivityService: GetIt.I(),
          ),
          addVisitViewModel: AddVisitViewModel(
            addANewVisitUseCase: AddANewVisitUseCase(
              visitRepository: GetIt.I(),
              localUnsyncedVisitRepository: GetIt.I(),
              localCustomerRepository: GetIt.I(),
              localActivityRepository: GetIt.I(),
            ),
          ),
        ),
      AppRoutes.visitDetails => ViewVisitDetailsScreen(
          viewVisitDetailsViewModel: ViewVisitDetailsViewModel(
            visit: ModalRoute.of(context)!.settings.arguments as VisitAggregate,
          ),
        ),
      AppRoutes.addActivity => AddActivityScreen(
          addActivityViewModel: AddActivityViewModel(
            createActivityUseCase: CreateActivityUseCase(
              remoteActivityRepository: GetIt.I(),
              localActivityRepository: GetIt.I(),
            ),
          ),
        ),
      AppRoutes.addCustomer => AddCustomerScreen(
          addCustomerViewModel: AddCustomerViewModel(
            createCustomerUseCase: CreateCustomerUseCase(
              remoteCustomerRepository: GetIt.I(),
              localCustomerRepository: GetIt.I(),
            ),
          ),
        ),
      AppRoutes.visitUnsyncedVisits => ViewUnsyncedVisitsScreen(
          viewUnsyncedVisitsViewModel: ViewUnsyncedVisitsViewModel(
            deleteUnsyncedVisitUseCase: DeleteUnsyncedVisitUseCase(
              localUnsyncedVisitRepository: GetIt.I(),
            ),
            viewUnsyncedLocalVisitsUseCase: ViewUnsyncedLocalVisitsUseCase(
              localUnsyncedVisitRepository: GetIt.I(),
              localActivityRepository: GetIt.I(),
              localCustomerRepository: GetIt.I(),
            ),
            syncUnsyncedLocalVisitsUseCase: GetIt.I(),
          ),
        ),
      AppRoutes.updateUnsyncedVisits => UpdateUnsyncedVisitScreen(
          searchCustomersViewModel: SearchCustomersViewModel(
            searchRemoteCustomerUseCase: SearchRemoteCustomerUseCase(
              remoteCustomerRepository: GetIt.I(),
              localCustomerRepository: GetIt.I(),
            ),
            searchLocalCustomersUseCase: SearchLocalCustomersUseCase(
              localCustomerRepository: GetIt.I(),
            ),
            connectivityService: GetIt.I(),
          ),
          searchActivitiesViewModel: SearchActivitiesViewModel(
            searchRemoteActivitiesUseCase: SearchRemoteActivitiesUseCase(
              remoteActivityRepository: GetIt.I(),
              localActivityRepository: GetIt.I(),
            ),
            searchLocalActivitiesUseCase: SearchLocalActivitiesUseCase(
              localActivityRepository: GetIt.I(),
            ),
            connectivityService: GetIt.I(),
          ),
          updateUnsyncedVisitViewModel: UpdateUnsyncedVisitViewModel(
            updateUnsyncedVisitUseCase: UpdateUnsyncedVisitUseCase(
              localUnsyncedVisitRepository: GetIt.I(),
              localActivityRepository: GetIt.I(),
              localCustomerRepository: GetIt.I(),
            ),
            visit: ModalRoute.of(context)?.settings.arguments as UnsyncedVisitAggregate,
          ),
        ),
      AppRoutes.viewVisitStatistics => ViewVisitStatisticsScreen(
          statisticsViewModel: ViewVisitStatisticsViewModel(
            getLocalVisitStatisticsUseCase: GetLocalVisitStatisticsUseCase(
              localVisitStatisticsRepository: GetIt.I(),
            ),
            countVisitStatisticsUseCase: CountVisitStatisticsUseCase(
              visitRepository: GetIt.I(),
              localVisitStatisticsRepository: GetIt.I(),
            ),
          ),
        ),
    };
  }
}
