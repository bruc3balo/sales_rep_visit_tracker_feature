import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit_list_of_past_visits_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/view/view_activities_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/view_model/view_activities_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/view_customers/view/view_customers_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/view_customers/view_model/view_customers_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/home/model/home_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/home/view_model/home_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/view/view_visit_statistics_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/view_model/view_visit_statistics_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/view/view_visits_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/view_model/view_visits_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/routing/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.homeViewModel,
    super.key,
  });

  final HomeViewModel homeViewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: homeViewModel,
      builder: (_, __) {
        return Scaffold(
          appBar: AppBar(
            title: Text(homeViewModel.currentPage.label),
            actions: [
              IconButton(
                onPressed: () {
                  switch(homeViewModel.currentPage) {

                    case HomePages.visits:
                      Navigator.of(context).pushNamed(
                        AppRoutes.addVisit.path,
                      );
                      break;
                    case HomePages.activities:
                      Navigator.of(context).pushNamed(
                        AppRoutes.addActivity.path,
                      );
                      break;
                    case HomePages.customers:
                      break;
                  }
                },
                icon: Icon(Icons.add),
              )
            ],
          ),
          body: switch (homeViewModel.currentPage) {
            HomePages.visits => ViewVisitsScreen(
                viewVisitsViewModel: ViewVisitsViewModel(
                  pastVisitsUseCase: VisitListOfPastVisitsUseCase(
                    visitRepository: GetIt.I(),
                    activityRepository: GetIt.I(),
                    customerRepository: GetIt.I(),
                  ),
                ),
              ),
            HomePages.activities => ViewActivitiesScreen(
                viewActivitiesViewModel: ViewActivitiesViewModel(
                  activityRepository: GetIt.I(),
                ),
              ),
            HomePages.customers => ViewCustomersScreen(
                viewCustomersViewModel: ViewCustomersViewModel(
                  customerRepository: GetIt.I(),
                ),
              ),
          },
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: homeViewModel.currentPage.index,
            onTap: homeViewModel.changePage,
            items: homeViewModel.homePages
                .map(
                  (p) => BottomNavigationBarItem(
                    icon: Icon(p.iconData),
                    label: p.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
