
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

abstract class LocalUnSyncedLocalVisitCrud {

  Future<TaskResult<int>> countUnsyncedVisits();

  Future<TaskResult<bool>> containsUnsyncedVisitKey({
    required LocalVisitKey key,
  });

  Future<TaskResult<LocalVisitKey>> setLocalVisit({
    required UnSyncedLocalVisit visit,
  });

  Future<TaskResult<List<UnSyncedLocalVisit>>> getUnsyncedLocalVisits({
    required int page,
    required int pageSize,
  });
  Future<TaskResult<void>> removeLocalVisit({
    required UnSyncedLocalVisit visit,
  });

}