import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/add_a_new_visit_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view_model/search_activities_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view_model/search_customers_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/home/view/home_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/home/view_model/home_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/splash/view/splash_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/add_visit/view/add_visit_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/add_visit/view_model/add_visit_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_details/view/view_visit_details_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_details/view_model/view_visit_details_view_model.dart';

enum AppRoutes {
  splashScreen("/"),
  home("/home"),
  addVisit("/addVisit"),
  visitDetails("/visitDetails");

  final String path;

  const AppRoutes(this.path);
}

extension RoutePage on AppRoutes {
  Widget getPage(BuildContext context) {
    return switch (this) {
      AppRoutes.splashScreen => SplashScreen(),
      AppRoutes.home => HomeScreen(
          homeViewModel: HomeViewModel(),
        ),
      AppRoutes.addVisit => AddVisitScreen(
          searchActivitiesViewModel: SearchActivitiesViewModel(
            activityRepository: GetIt.I(),
          ),
          searchCustomersViewModel: SearchCustomersViewModel(
            customerRepository: GetIt.I(),
          ),
          addVisitViewModel: AddVisitViewModel(
            addANewVisitUseCase: AddANewVisitUseCase(
              visitRepository: GetIt.I(),
            ),
          ),
        ),
      AppRoutes.visitDetails => ViewVisitDetailsScreen(
          viewVisitDetailsViewModel: ViewVisitDetailsViewModel(
            visit: ModalRoute.of(context)!.settings.arguments as VisitAggregate,
          ),
        ),
    };
  }
}
