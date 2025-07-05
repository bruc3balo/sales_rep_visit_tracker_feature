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
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index >= activities.length) {
                  return InfiniteLoader();
                }

                var activity = activities[index];
                bool activityIsBeingDeleted = deleteState is LoadingDeleteActivityState && activity.id == deleteState.activity.id;
                if (activityIsBeingDeleted) {
                  return Icon(
                    Icons.auto_delete_outlined,
                    color: Colors.red,
                  );
                }

                bool isLastItem = index + 1 >= viewActivitiesViewModel.activities.length;
                var padding = (isLastItem) ? 120.0 : 0.0;

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
                                  title: const Text('Delete Activity'),
                                  content: Text(
                                    'Confirm to delete ${activity.description}',
                                    style: TextStyle(color: Colors.black),
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

                        if (updatedActivity != null) viewActivitiesViewModel.updateItem(updatedActivity);

                        return false;

                      default:
                        return false;
                    }
                  },
                  background: Container(
                    color: Theme.of(context).colorScheme.primary,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: padding),
                    child: ActivityListTile(
                      activity: activity,
                    ),
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
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.run_circle_outlined,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      title: Text(activity.description),
    );
  }
}
