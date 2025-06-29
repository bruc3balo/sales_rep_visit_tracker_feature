import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class ViewVisitDetailsViewModel extends ChangeNotifier {
  final VisitAggregate _visit;

  ViewVisitDetailsViewModel({
    required VisitAggregate visit,
  }) : _visit = visit;

  VisitAggregate get visit => _visit;
}
