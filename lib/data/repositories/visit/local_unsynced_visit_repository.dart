
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

abstract class LocalUnsyncedVisitRepository {

  Stream<void> get unsyncedVisitUpdatedStream;

  Future<TaskResult<int>> countUnsyncedVisits();

  Future<TaskResult<UnSyncedLocalVisit?>> findByHash({
    required LocalVisitHash hash,
  });

  Future<TaskResult<List<UnSyncedLocalVisit>>> getUnsyncedVisits({
    required int page,
    required int pageSize,
  });

  Future<TaskResult<void>> setUnsyncedVisit({
    required UnSyncedLocalVisit visit,
  });

  Future<TaskResult<void>> removeUnsyncedVisit({
    required UnSyncedLocalVisit visit,
  });

  Future<TaskResult<void>> removeUnsyncedVisitByHash({
    required LocalVisitHash hash,
  });

}