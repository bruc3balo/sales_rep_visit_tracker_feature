import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
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
            title: Text("Visit Details"),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    "Visit Summary",
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Divider(
                  height: 2,
                ),
                ListTile(
                  leading: Text("Customer"),
                  title: Text(visit.customer?.name ?? 'Unknown customer'),
                ),
                Divider(
                  height: 2,
                ),
                ListTile(
                  leading: Text("Visit Date"),
                  title: Text(visit.visit.visitDate.humanReadable),
                ),
                Divider(
                  height: 2,
                ),
                ListTile(
                  leading: Text("Visit Location"),
                  title: Text(visit.visit.location),
                ),
                Divider(
                  height: 2,
                ),

                ListTile(
                  leading: Text("Visit Status"),
                  title: Text(visit.visit.status),
                ),

                Text(
                  "Activities",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),

                ...visit
                    .activityMap
                    .values
                    .map((a) =>
                    ListTile(
                      leading: Icon(Icons.circle),
                      title: Text(a.description),
                    ),
                ),

                Text(
                  "Notes",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),

                Text(
                  visit.visit.notes,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyLarge,
                  textAlign: TextAlign.left,
                ),

              ],
            ),
          ),
        );
      },
    );
  }
}
