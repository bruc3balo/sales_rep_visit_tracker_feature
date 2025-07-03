import 'dart:async';

import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_unsynced_local_visit_crud.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class HiveLocalUnsyncedVisitRepository extends LocalUnsyncedVisitRepository {
  final LocalUnSyncedLocalVisitCrud _localUnSyncedLocalVisitCrud;
  final StreamController<void> _visitAddedStream = StreamController.broadcast();

  HiveLocalUnsyncedVisitRepository({
    required LocalUnSyncedLocalVisitCrud localUnSyncedLocalVisitCrud,
  }) : _localUnSyncedLocalVisitCrud = localUnSyncedLocalVisitCrud;

  @override
  Future<TaskResult<List<UnSyncedLocalVisit>>> getUnsyncedVisits({
    required int page,
    required int pageSize,
  }) async {
    return await _localUnSyncedLocalVisitCrud.getUnsyncedLocalVisits(page: page, pageSize: pageSize);
  }

  @override
  Future<TaskResult<void>> setUnsyncedVisit({required UnSyncedLocalVisit visit}) async {
    var result = await _localUnSyncedLocalVisitCrud.setLocalVisit(visit: visit);
    if (result is SuccessResult<void>) {
      _visitAddedStream.add(null);
    }
    return result;
  }

  @override
  Future<TaskResult<void>> removeUnsyncedVisit({required UnSyncedLocalVisit visit}) async {
    var result = await _localUnSyncedLocalVisitCrud.removeLocalVisit(visit: visit);
    if (result is SuccessResult<void>) {
      _visitAddedStream.add(null);
    }
    return result;
  }

  @override
  Future<TaskResult<UnSyncedLocalVisit?>> findByHash({required LocalVisitHash hash}) async {
    return await _localUnSyncedLocalVisitCrud.findByHash(hash: hash);
  }

  @override
  Future<TaskResult<int>> countUnsyncedVisits() async {
    return await _localUnSyncedLocalVisitCrud.countUnsyncedVisits();
  }

  @override
  Future<TaskResult<void>> removeUnsyncedVisitByHash({required LocalVisitHash hash}) async {
    var result = await _localUnSyncedLocalVisitCrud.removeLocalVisitByHash(hash: hash);
    if (result is SuccessResult<void>) {
      _visitAddedStream.add(null);
    }
    return result;
  }

  @override
  Stream<void> get unsyncedVisitUpdatedStream => _visitAddedStream.stream;
}
