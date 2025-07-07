import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/visit_filter/view/visit_filter_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/visit_filter/model/visit_filter_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view_model/search_activities_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view_model/search_customers_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/model/view_visits_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/view_model/view_visits_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/routing/routes.dart';
import 'package:badges/badges.dart' as badges;

class ViewVisitsScreen extends StatelessWidget {
  const ViewVisitsScreen({
    required this.viewVisitsViewModel,
    required this.searchCustomersViewModel,
    required this.searchActivitiesViewModel,
    super.key,
  });

  final ViewVisitsViewModel viewVisitsViewModel;
  final SearchCustomersViewModel searchCustomersViewModel;
  final SearchActivitiesViewModel searchActivitiesViewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: viewVisitsViewModel,
        builder: (context, __) {
          var state = viewVisitsViewModel.itemsState;
          bool isLoading = state is LoadingViewVisitsState;
          var visits = viewVisitsViewModel.visits;
          var itemCount = viewVisitsViewModel.visits.length + (isLoading ? 1 : 0);

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              bool isAtEndOfList = scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent;
              if (!isLoading && isAtEndOfList) {
                viewVisitsViewModel.loadMoreItems();
              }

              return true;
            },
            child: RefreshIndicator(
              onRefresh: () => viewVisitsViewModel.refresh(),
              child: Visibility(
                visible: state is! OfflineViewVisitsState,
                replacement: Center(
                  child: Text("Go online to see past visits"),
                ),
                child: ListView.builder(
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (index >= visits.length) {

                      // Show InfiniteLoader if still loading
                      if (isLoading && index == visits.length) return InfiniteLoader();

                      // Otherwise, show bottom spacer
                      return const SizedBox(height: 120);
                    }

                    var visit = visits[index];
                    return VisitTile(visit: visit);
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0, right: 3),
        child: FloatingActionButton.small(
          onPressed: () async {
            var filters = await showVisitFilterBottomSheet(
              context: context,
              searchCustomersViewModel: searchCustomersViewModel,
              searchActivitiesViewModel: searchActivitiesViewModel,
              initialFilter: viewVisitsViewModel.filterState,
            );

            if (filters == null) return;
            viewVisitsViewModel.updateFilter(filters);
          },
          child: Icon(Icons.filter_list),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}

class VisitTile extends StatelessWidget {
  const VisitTile({
    required this.visit,
    super.key,
  });

  final VisitAggregate visit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;
    final badgeBackground = isDark ? colorScheme.surface : colorScheme.primaryContainer;
    final badgeTextColor = isDark ? Colors.white : Colors.black;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: VisitStatus.findByCapitalizedString(visit.visit.status)?.color,
      child: Card(
        margin: const EdgeInsets.only(bottom: 4.0),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.visitDetails.path,
              arguments: visit,
            );
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: badges.Badge(
              position: badges.BadgePosition.topEnd(),
              badgeAnimation: badges.BadgeAnimation.scale(
                toAnimate: true,
                curve: Curves.easeInOut,
                loopAnimation: false,
              ),
              stackFit: StackFit.passthrough,
              badgeContent: Text(
                visit.activityMap.length.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: badgeTextColor,
                ),
              ),
              badgeStyle: badges.BadgeStyle(
                badgeColor: badgeBackground,
                borderSide: BorderSide(
                  color: colorScheme.onPrimary,
                  width: 2,
                ),
                padding: const EdgeInsets.all(4),
              ),
              child: Icon(
                Icons.business_outlined,
                color: colorScheme.onPrimary,
                size: 24,
              ),
            ),
          ),
          title: Text(
            visit.customer?.name ?? 'Unknown Customer',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            visit.visit.status,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Text(
            visit.visit.visitDate.readableDateTime2Line,
            textAlign: TextAlign.right,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}