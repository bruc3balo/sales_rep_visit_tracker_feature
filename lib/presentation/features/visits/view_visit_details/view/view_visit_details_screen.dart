import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_details/view_model/view_visit_details_view_model.dart';

class ViewVisitDetailsScreen extends StatelessWidget {
  const ViewVisitDetailsScreen({
    required this.viewVisitDetailsViewModel,
    super.key,
  });

  final ViewVisitDetailsViewModel viewVisitDetailsViewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewVisitDetailsViewModel,
      builder: (_, __) {
        var visit = viewVisitDetailsViewModel.visit;
        return Scaffold(
          appBar: AppBar(
            title: Text("${visit.customer?.name}'s visit"),
          ),
          body: ListView(
            children: [
              ListTile(
                title: Text("Visit Date"),
                subtitle: Text(visit.visit.visitDate.toIso8601String()),
              ),
              ListTile(
                title: Text("Visit Location"),
                subtitle: Text(visit.visit.location),
              ),
              ExpansionTile(
                title: Text("Visit Notes"),
                children: [
                  Text(visit.visit.notes),
                ],
              ),
              ListTile(
                title: Text("Visit Status"),
                subtitle: Text(visit.visit.status),
              ),
              ExpansionTile(
                title: Text("Visit Activities"),
                subtitle: Text("${visit.visit.activitiesDone.length} activities"),
                children: visit.activityMap.values
                    .map(
                      (a) => ListTile(
                        title: Text(a.description),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
