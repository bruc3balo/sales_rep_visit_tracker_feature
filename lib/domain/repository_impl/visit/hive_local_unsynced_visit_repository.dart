import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_unsynced_local_visit_crud.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class HiveLocalUnsyncedVisitRepository extends LocalUnsyncedVisitRepository {

  final LocalUnSyncedLocalVisitCrud _localUnSyncedLocalVisitCrud;

  HiveLocalUnsyncedVisitRepository({
    required LocalUnSyncedLocalVisitCrud localUnSyncedLocalVisitCrud,
  }) : _localUnSyncedLocalVisitCrud = localUnSyncedLocalVisitCrud;

  @override
  Future<TaskResult<List<UnSyncedLocalVisit>>> getUnsyncedVisits({
    required int page,
    required int pageSize,
  }) {
    return _localUnSyncedLocalVisitCrud.getUnsyncedLocalVisits(page: page, pageSize: pageSize);
  }

  @override
  Future<TaskResult<void>> setUnsyncedVisit({required UnSyncedLocalVisit visit}) {
    return _localUnSyncedLocalVisitCrud.setLocalVisit(visit: visit);
  }

  @override
  Future<TaskResult<void>> removeUnsyncedVisit({required UnSyncedLocalVisit visit}) {
    return _localUnSyncedLocalVisitCrud.removeLocalVisit(visit: visit);
  }

  @override
  Future<TaskResult<bool>> containsUnsyncedVisitKey({required LocalVisitKey key}) {
    return _localUnSyncedLocalVisitCrud.containsUnsyncedVisitKey(key: key);
  }

}