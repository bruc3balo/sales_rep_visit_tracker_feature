import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_unsynced_visits/model/view_unsynced_visits_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_unsynced_visits/view_model/view_unsynced_visits_view_model.dart';
import 'package:badges/badges.dart' as badges;
import 'package:sales_rep_visit_tracker_feature/presentation/routing/routes.dart';

class ViewUnsyncedVisitsScreen extends StatelessWidget {
  const ViewUnsyncedVisitsScreen({
    required this.viewUnsyncedVisitsViewModel,
    super.key,
  });

  final ViewUnsyncedVisitsViewModel viewUnsyncedVisitsViewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unsynced visits"),
      ),
      body: ListenableBuilder(
        listenable: viewUnsyncedVisitsViewModel,
        builder: (_, __) {
          var state = viewUnsyncedVisitsViewModel.state;
          bool isLoading = state is LoadingUnsyncedVisitState;
          var visits = viewUnsyncedVisitsViewModel.unsyncedVisits;




          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              bool isAtEndOfList = scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent;
              if (!isLoading && isAtEndOfList) {
                viewUnsyncedVisitsViewModel.loadMoreItems();
              }

              return true;
            },
            child: RefreshIndicator(
              onRefresh: () => viewUnsyncedVisitsViewModel.refresh(),
              child: ListView.builder(
                itemCount: viewUnsyncedVisitsViewModel.unsyncedVisits.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= visits.length) {
                    return InfiniteLoader();
                  }
                  var visit = visits[index];

                  if(state is SyncingVisitState) {
                    return InfiniteLoader();
                  }

                  return Dismissible(
                    key: ValueKey(visit.hash),
                    onDismissed: (d) {
                      switch (d) {
                        case DismissDirection.endToStart:
                        case DismissDirection.startToEnd:
                          viewUnsyncedVisitsViewModel.delete(visit);
                          break;
                        default:
                          break;
                      }
                    },
                    confirmDismiss: (d) async {
                      switch (d) {
                        case DismissDirection.endToStart:
                        case DismissDirection.startToEnd:
                          return await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Delete Visit',
                                      textAlign: TextAlign.center,
                                    ),
                                    content: Text(
                                      "Confirm deletion of visit",
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              ) ??
                              false;

                        default:
                          return false;
                      }
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: UnsyncedVisitTile(
                      visit: visit,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class UnsyncedVisitTile extends StatelessWidget {
  const UnsyncedVisitTile({
    required this.visit,
    super.key,
  });

  final UnsyncedVisitAggregate visit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;
    final badgeBackground = isDark ? colorScheme.surface : colorScheme.primaryContainer;
    final badgeTextColor = isDark ? Colors.white : Colors.black;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: visit.status.color,
      child: Card(
        margin: const EdgeInsets.only(bottom: 4.0),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.updateUnsyncedVisits.path,
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
            visit.customer?.name ?? 'Unresolved customer',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            visit.status.name.capitalize,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Text(
            visit.visitDate.readableDateTime2Line,
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
