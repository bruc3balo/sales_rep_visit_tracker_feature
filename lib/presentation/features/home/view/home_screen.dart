import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit_list_of_past_visits_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/view/view_activities_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/view_model/view_activities_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/view_customers/view/view_customers_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/view_customers/view_model/view_customers_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/home/model/home_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/view/view_visits_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/view_model/view_visits_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  final List<HomePages> homePages = HomePages.values;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: DefaultTabController(
        length: homePages.length,
        child: Flex(
          direction: Axis.vertical,
          children: [
            Flexible(
              child: TabBar(
                tabs: homePages
                    .map(
                      (h) => Tab(
                        text: h.label,
                        icon: Icon(h.iconData),
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: homePages.map(
                  (h) {
                    return switch (h) {
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
                    };
                  },
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
