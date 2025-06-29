import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/components.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/model/view_visits_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/view_model/view_visits_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/routing/routes.dart';

class ViewVisitsScreen extends StatelessWidget {
  const ViewVisitsScreen({
    required this.viewVisitsViewModel,
    super.key,
  });

  final ViewVisitsViewModel viewVisitsViewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
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
                  return VisitTile(visit: visit);
                },
              ),
            ),
          );
        },
      ),
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
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.visitDetails.path,
          arguments: visit,
        );
      },
      title: Text(visit.visit.id.toString()),
      subtitle: Text(visit.customer?.name ?? 'Unknown Customer'),
      trailing: CircleAvatar(
        child: Text(visit.activityMap.length.toString()),
      ),
    );
  }
}
