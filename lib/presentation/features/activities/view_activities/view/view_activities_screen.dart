import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/update_activity_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/edit_activity/view/edit_activity_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/edit_activity/view_model/edit_activity_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/model/view_activities_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/view_model/view_activities_view_model.dart';

class ViewActivitiesScreen extends StatelessWidget {
  const ViewActivitiesScreen({
    required this.viewActivitiesViewModel,
    required this.updateActivityUseCase,
    super.key,
  });

  final ViewActivitiesViewModel viewActivitiesViewModel;
  final UpdateActivityUseCase updateActivityUseCase;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewActivitiesViewModel,
      builder: (context, __) {
        var deleteState = viewActivitiesViewModel.deleteState;
        bool isLoading = viewActivitiesViewModel.itemsState is LoadingViewActivitiesState;
        var activities = viewActivitiesViewModel.activities;
        int itemCount = viewActivitiesViewModel.activities.length + (isLoading ? 1 : 0);

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            bool isAtEndOfList = scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent;
            if (!isLoading && isAtEndOfList) {
              viewActivitiesViewModel.loadMoreItems();
            }

            return true;
          },
          child: RefreshIndicator(
            onRefresh: () => viewActivitiesViewModel.refresh(),
            child: ListView.builder(
              itemCount: itemCount + 1, // Add one extra slot for the SizedBox
              itemBuilder: (context, index) {
                if (index >= activities.length) {
                  if (isLoading && index == activities.length) return InfiniteLoader();
                  return const SizedBox(height: 120); // Spacer for last item for FAB
                }

                var activity = activities[index];
                bool activityIsBeingDeleted = deleteState is LoadingDeleteActivityState && activity.id == deleteState.activity.id;
                if (activityIsBeingDeleted) {
                  return const Icon(
                    Icons.auto_delete_outlined,
                    color: Colors.red,
                  );
                }

                return Dismissible(
                  key: ValueKey(activity.id),
                  onDismissed: (d) {
                    switch (d) {
                      case DismissDirection.endToStart:
                        viewActivitiesViewModel.deleteActivity(activity: activity);
                        break;
                      default:
                        break;
                    }
                  },
                  confirmDismiss: (d) async {
                    switch (d) {
                      case DismissDirection.endToStart:
                        return await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Delete activity',
                                    textAlign: TextAlign.center,
                                  ),
                                  content: Text(
                                    "Confirm deletion of '${activity.description}'",
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

                      case DismissDirection.startToEnd:
                        var updatedActivity = await showDialog<Activity?>(
                          context: context,
                          builder: (context) {
                            return EditActivityScreen(
                              editActivityViewModel: EditActivityViewModel(
                                updateActivityUseCase: updateActivityUseCase,
                                activity: activity,
                              ),
                            );
                          },
                        );

                        if (updatedActivity != null) {
                          viewActivitiesViewModel.updateItem(updatedActivity);
                        }

                        return false;

                      default:
                        return false;
                    }
                  },
                  background: Container(
                    color: Theme.of(context).colorScheme.primary,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ActivityListTile(
                    activity: activity,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class ActivityListTile extends StatelessWidget {
  const ActivityListTile({
    required this.activity,
    super.key,
  });

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary,
          child: Icon(
            Icons.run_circle_outlined,
            color: colorScheme.onPrimary,
          ),
        ),
        title: Text(
          activity.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
