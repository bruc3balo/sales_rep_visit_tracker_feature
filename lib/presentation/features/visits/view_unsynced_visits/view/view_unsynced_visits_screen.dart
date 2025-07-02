import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_unsynced_visits/view_model/view_unsynced_visits_view_model.dart';

class ViewUnsyncedVisitsScreen extends StatelessWidget {
  const ViewUnsyncedVisitsScreen({
    required this.viewUnsyncedVisitsViewModel,
    super.key,
  });

  final ViewUnsyncedVisitsViewModel viewUnsyncedVisitsViewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unsynced visits"),
      ),
      body: ListenableBuilder(
        listenable: viewUnsyncedVisitsViewModel,
        builder: (_, __) {
          return Placeholder();
        },
      ),
    );
  }
}
