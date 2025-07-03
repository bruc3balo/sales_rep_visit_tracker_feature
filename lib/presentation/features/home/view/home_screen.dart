import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/delete_activity_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/update_activity_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/view_local_activities_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/view_remote_activities_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/delete_customer_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/view_local_customers_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/view_remote_customers_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/visit_list_of_past_visits_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/view/view_activities_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/view_model/view_activities_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/view_customers/view/view_customers_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/view_customers/view_model/view_customers_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/home/model/home_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/home/view_model/home_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/view/view_visits_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/view_model/view_visits_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/routing/routes.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.homeViewModel,
    super.key,
  });

  final HomeViewModel homeViewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{


  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.homeViewModel,
      builder: (_, __) {
        var syncState = widget.homeViewModel.visitCountState;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.homeViewModel.currentPage.label),
            actions: [
              switch (syncState) {
                LoadingCountVisitState() => InfiniteLoader(),
                LoadedCountVisitState() => Visibility(
                    visible: (syncState.unSyncedVisitCount ?? 0) > 0,
                    child: badges.Badge(
                      badgeContent: Text(syncState.unSyncedVisitCount?.toString() ?? '-'),
                      badgeAnimation: badges.BadgeAnimation.rotation(),
                      position: badges.BadgePosition.center(),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.visitUnsyncedVisits.path,
                          );
                        },
                        icon: Icon(
                          Icons.sync,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
              },
              IconButton(
                onPressed: ()  {
                  switch (widget.homeViewModel.currentPage) {
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
                      Navigator.of(context).pushNamed(
                        AppRoutes.addCustomer.path,
                      );
                      break;
                  }
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
          body: switch (widget.homeViewModel.currentPage) {
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
                updateActivityUseCase: UpdateActivityUseCase(
                  remoteActivityRepository: GetIt.I(),
                  localActivityRepository: GetIt.I(),
                ),
                viewActivitiesViewModel: ViewActivitiesViewModel(
                  connectivityService: GetIt.I(),
                  remoteActivitiesUseCase: ViewRemoteActivitiesUseCase(
                    remoteActivityRepository: GetIt.I(),
                    localActivityRepository: GetIt.I(),
                  ),
                  localActivitiesUseCase: ViewLocalActivitiesUseCase(
                    localActivityRepository: GetIt.I(),
                  ),
                  deleteActivityUseCase: DeleteActivityUseCase(
                    remoteActivityRepository: GetIt.I(),
                    localActivityRepository: GetIt.I(),
                  ),
                ),
              ),
            HomePages.customers => ViewCustomersScreen(
                localCustomerRepository: GetIt.I(),
                remoteCustomerRepository: GetIt.I(),
                viewCustomersViewModel: ViewCustomersViewModel(
                  viewRemoteCustomersUseCase: ViewRemoteCustomersUseCase(
                    remoteCustomerRepository: GetIt.I(),
                    localCustomerRepository: GetIt.I(),
                  ),
                  viewLocalCustomersUseCase: ViewLocalCustomersUseCase(
                    localCustomerRepository: GetIt.I(),
                  ),
                  deleteCustomerUseCase: DeleteCustomerUseCase(
                    remoteCustomerRepository: GetIt.I(),
                    localCustomerRepository: GetIt.I(),
                  ),
                  connectivityService: GetIt.I(),
                ),
              ),
          },
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: widget.homeViewModel.currentPage.index,
            onTap: widget.homeViewModel.changePage,
            items: widget.homeViewModel.homePages
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
