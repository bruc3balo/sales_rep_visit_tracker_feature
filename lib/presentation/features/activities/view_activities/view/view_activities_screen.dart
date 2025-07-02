import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/components.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/edit_activity/view/edit_activity_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/edit_activity/view_model/edit_activity_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/model/view_activities_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/view_model/view_activities_view_model.dart';

class ViewActivitiesScreen extends StatelessWidget {
  const ViewActivitiesScreen({
    required this.viewActivitiesViewModel,
    required this.remoteActivityRepository,
    super.key,
  });

  final ViewActivitiesViewModel viewActivitiesViewModel;
  final RemoteActivityRepository remoteActivityRepository;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewActivitiesViewModel,
      builder: (context, __) {
        var deleteState = viewActivitiesViewModel.deleteState;
        bool isLoading = viewActivitiesViewModel.itemsState is LoadingViewActivitiesState;
        var activities = viewActivitiesViewModel.activities;

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
              itemCount: viewActivitiesViewModel.activities.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= activities.length) {
                  return InfiniteLoader();
                }

                var activity = activities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.run_circle_outlined, color: Colors.black,),
                  ),
                  title: Text(activity.description),
                  trailing: Builder(
                    builder: (context) {
                      if(
                      deleteState is LoadingDeleteActivityState
                          &&
                      deleteState.activity.id == activity.id) {
                        return Icon(Icons.auto_delete_outlined, color: Colors.red,);
                      }

                      return MenuAnchor(
                        builder: (_, controller, __) {
                          return IconButton(
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                                return;
                              }
                              controller.open();
                            },
                            icon: const Icon(Icons.more_vert),
                            tooltip: 'Activity options',
                          );
                        },
                        menuChildren: ActivityTileMenuItem.values
                            .map((menu) => MenuItemButton(
                          onPressed: () async {
                            switch(menu) {

                              case ActivityTileMenuItem.delete:
                                viewActivitiesViewModel.deleteActivity(
                                    activity: activity
                                );
                                break;
                              case ActivityTileMenuItem.edit:
                                var updatedActivity = await showDialog<Activity?>(
                                  context: context,
                                  builder: (context) {
                                    return EditActivityScreen(
                                      editActivityViewModel: EditActivityViewModel(
                                        remoteActivityRepository: remoteActivityRepository,
                                        activity: activity,
                                      ),
                                    );
                                  },
                                );

                                if(updatedActivity == null) return;
                                viewActivitiesViewModel.updateItem(updatedActivity);
                                break;
                            }
                          },
                          child: Text(
                            menu.name.capitalize,
                            style: TextStyle(color:  Colors.black),
                          ),
                        ),
                        ).toList(),
                      );
                    },
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


