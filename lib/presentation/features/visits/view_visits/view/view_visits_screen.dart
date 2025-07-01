import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/components.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/model/view_visits_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/view_model/view_visits_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/routing/routes.dart';
import 'package:badges/badges.dart' as badges;

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
      leading: Container(
        padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
              borderRadius: BorderRadius.all(Radius.circular(10)),
          ),

          child: badges.Badge(
            position: badges.BadgePosition.topEnd(),
            badgeAnimation: badges.BadgeAnimation.scale(
              toAnimate: true,
              curve: Curves.slowMiddle,
              loopAnimation: false,
            ),
            stackFit: StackFit.passthrough,
            badgeContent: Text(visit.activityMap.length.toString()),
            badgeStyle: badges.BadgeStyle(
              badgeColor: Colors.white,
              borderSide: BorderSide(
                color: Colors.cyan,

              ),
            ),
            child: Icon(Icons.business_outlined),
          ),
      ),
      title: Text(visit.customer?.name ?? 'Unknown Customer'),
      subtitle: Text(visit.visit.status),
      trailing: Text(visit.visit.visitDate.readableDateTime2Line),
    );
  }
}