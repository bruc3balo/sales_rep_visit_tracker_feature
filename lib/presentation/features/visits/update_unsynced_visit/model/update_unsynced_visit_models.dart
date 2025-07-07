import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

sealed class UpdateUnsyncedVisitState {}

final class LoadedUpdateUnsyncedVisitState extends UpdateUnsyncedVisitState {
  final UnsyncedVisitAggregate visit;

  LoadedUpdateUnsyncedVisitState({
    required this.visit,
  }) {
    AppLog.I.i("LoadedUpdateUnsyncedVisitState :: new", visit.customer?.name);
  }
}

final class LoadingUpdateUnsyncedVisitState extends UpdateUnsyncedVisitState {}
