import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/components.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/model/view_visits_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/view_model/view_visits_view_model.dart';

class ViewVisitsScreen extends StatelessWidget {
  const ViewVisitsScreen({
    required this.viewVisitsViewModel,
    super.key,
  });

  final ViewVisitsViewModel viewVisitsViewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewVisitsViewModel,
      builder: (context, __) {
        bool isLoading = viewVisitsViewModel.itemsState is LoadingViewVisitsState;
        var visits = viewVisitsViewModel.visits;

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
            child: ListView.builder(
              itemCount: viewVisitsViewModel.visits.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= visits.length) {
                  return InfiniteLoader();
                }
                var visit = visits[index];
                return ListTile(
                  title: Text(visit.visit.id.toString()),
                  subtitle: Text("${visit.activityMap.length} activities"),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
