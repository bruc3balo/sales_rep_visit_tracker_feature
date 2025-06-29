import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/components.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/model/view_activities_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/view_model/view_activities_view_model.dart';

class ViewActivitiesScreen extends StatelessWidget {
  const ViewActivitiesScreen({
    required this.viewActivitiesViewModel,
    super.key,
  });

  final ViewActivitiesViewModel viewActivitiesViewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewActivitiesViewModel,
      builder: (context, __) {
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
                  title: Text(activity.description),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
