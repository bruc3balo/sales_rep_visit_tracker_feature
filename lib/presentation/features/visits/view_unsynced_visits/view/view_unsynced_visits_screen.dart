import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/components.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_unsynced_visits/model/view_unsynced_visits_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_unsynced_visits/view_model/view_unsynced_visits_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/routing/routes.dart';
import 'package:badges/badges.dart' as badges;

class ViewUnsyncedVisitsScreen extends StatefulWidget {
  const ViewUnsyncedVisitsScreen({
    required this.viewUnsyncedVisitsViewModel,
    super.key,
  });

  final ViewUnsyncedVisitsViewModel viewUnsyncedVisitsViewModel;

  @override
  State<ViewUnsyncedVisitsScreen> createState() => _ViewUnsyncedVisitsScreenState();
}

class _ViewUnsyncedVisitsScreenState extends State<ViewUnsyncedVisitsScreen> {
  late final StreamSubscription<ToastMessage> toastSubscription;

  @override
  void initState() {
    toastSubscription = widget.viewUnsyncedVisitsViewModel.toastStream.listen((t) => t.show());
    super.initState();
  }

  @override
  void dispose() {
    toastSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unsynced visits"),
        actions: [
          IconButton(
            onPressed: widget.viewUnsyncedVisitsViewModel.sync,
            icon: Icon(Icons.sync),
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewUnsyncedVisitsViewModel,
        builder: (_, __) {
          bool isLoading = widget.viewUnsyncedVisitsViewModel.state is LoadingUnsyncedVisitState;
          var visits = widget.viewUnsyncedVisitsViewModel.unsyncedVisits;

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              bool isAtEndOfList = scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent;
              if (!isLoading && isAtEndOfList) {
                widget.viewUnsyncedVisitsViewModel.loadMoreItems();
              }

              return true;
            },
            child: RefreshIndicator(
              onRefresh: () => widget.viewUnsyncedVisitsViewModel.refresh(),
              child: ListView.builder(
                itemCount: widget.viewUnsyncedVisitsViewModel.unsyncedVisits.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= visits.length) {
                    return InfiniteLoader();
                  }
                  var visit = visits[index];
                  return UnsyncedVisit(visit: visit);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class UnsyncedVisit extends StatelessWidget {
  const UnsyncedVisit({
    required this.visit,
    super.key,
  });

  final UnsyncedVisitAggregate visit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {

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
      subtitle: Text(visit.status.name.capitalize),
      trailing: Text(visit.visitDate.readableDateTime2Line),
    );
  }
}
