
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

sealed class UnsyncedVisitsState {}

class LoadingUnsyncedVisitState extends UnsyncedVisitsState {
  final UnsyncedVisitAggregate? visit;

  LoadingUnsyncedVisitState({this.visit});
}

class DisplayingUnsyncedVisitState extends UnsyncedVisitsState {}

class SyncingVisitState extends UnsyncedVisitsState {}

class FinishedSyncingVisitState extends UnsyncedVisitsState {
  final String results;

  FinishedSyncingVisitState({required this.results});
}