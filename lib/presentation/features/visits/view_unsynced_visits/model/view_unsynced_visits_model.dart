import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

sealed class UnsyncedVisitsState {}

class LoadingUnsyncedVisitState extends UnsyncedVisitsState {}

class DisplayingUnsyncedVisitState extends UnsyncedVisitsState {}

class SyncingVisitState extends UnsyncedVisitsState {}

class FinishedSyncingVisitState extends UnsyncedVisitsState {
  final String results;

  FinishedSyncingVisitState({required this.results});
}