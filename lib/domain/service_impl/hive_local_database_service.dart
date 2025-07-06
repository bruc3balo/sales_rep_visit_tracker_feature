import 'dart:collection';

import 'package:hive/hive.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_database_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class HiveLocalDatabaseService implements LocalDatabaseService {
  final HiveAesCipher _cipher;

  Future<Box<UnSyncedLocalVisit>> get openUnsyncedBox async => await Hive.openBox('unsynced_visits', encryptionCipher: _cipher);

  Future<Box<LocalCustomer>> get openCustomerBox async => await Hive.openBox('customers', encryptionCipher: _cipher);

  Future<Box<LocalActivity>> get openActivityBox async => await Hive.openBox('activities', encryptionCipher: _cipher);

  Future<Box<LocalVisitStatistics>> get openVisitStatisticsBox async => await Hive.openBox('visit_statistics', encryptionCipher: _cipher);

  HiveLocalDatabaseService({
    required HiveAesCipher cipher,
  }) : _cipher = cipher;

  @override
  Future<TaskResult<List<UnSyncedLocalVisit>>> getUnsyncedLocalVisits({required int page, required int pageSize}) async {
    try {
      var box = await openUnsyncedBox;
      if (box.isEmpty) return SuccessResult(data: []);

      var data = box.values.skip(page * pageSize).take(pageSize).toList();
      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<LocalVisitHash>> setLocalVisit({
    required UnSyncedLocalVisit visit,
  }) async {
    try {
      var box = await openUnsyncedBox;
      var hash = visit.hash;
      await box.put(hash, visit);
      return SuccessResult(data: LocalVisitHash(value: hash));
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> removeLocalVisit({
    required UnSyncedLocalVisit visit,
  }) async {
    try {
      var box = await openUnsyncedBox;
      var hash = visit.hash;
      await box.delete(hash);
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<UnSyncedLocalVisit?>> findByHash({
    required LocalVisitHash hash,
  }) async {
    try {
      var box = await openUnsyncedBox;
      var data = box.get(hash.value);
      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> clearAllLocalActivities() async {
    try {
      var box = await openActivityBox;
      await box.clear();
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> clearAllLocalCustomers() async {
    try {
      var box = await openCustomerBox;
      await box.clear();
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<List<LocalActivity>>> getLocalActivities({required int page, required int pageSize}) async {
    try {
      var box = await openActivityBox;
      if (box.isEmpty) return SuccessResult(data: []);

      var data = box.values.skip(page * pageSize).take(pageSize).toList();
      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<Map<int, LocalActivity>>> getLocalActivitiesByIds({
    required List<int> ids,
  }) async {
    try {
      var idSet = HashSet.from(ids);
      var box = await openActivityBox;
      var dataList = box.values.where((a) => idSet.contains(a.id)).toList();
      var data = {for (var d in dataList) d.id: d};
      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<Map<int, LocalCustomer>>> getLocalCustomerByIds({
    required List<int> ids,
  }) async {
    try {
      var idSet = HashSet.from(ids);
      var box = await openCustomerBox;
      var dataList = box.values.where((a) => idSet.contains(a.id)).toList();
      var data = {for (var d in dataList) d.id: d};
      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<List<LocalCustomer>>> getLocalCustomers({
    required int page,
    required int pageSize,
  }) async {
    try {
      var box = await openCustomerBox;
      if (box.isEmpty) return SuccessResult(data: []);

      var data = box.values.skip(page * pageSize).take(pageSize).toList();
      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> setLocalActivities({required List<LocalActivity> activities}) async {
    try {
      var box = await openActivityBox;
      await box.putAll({for (var a in activities) a.id: a});
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> setLocalActivity({required LocalActivity activity}) async {
    try {
      var box = await openActivityBox;
      await box.put(activity.id, activity);
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> setLocalCustomer({required LocalCustomer customer}) async {
    try {
      var box = await openCustomerBox;
      await box.put(customer.id, customer);
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<int>> countUnsyncedVisits() async {
    try {
      var box = await openUnsyncedBox;
      return SuccessResult(data: box.length);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> deleteLocalActivity({required int activityId}) async {
    try {
      var box = await openUnsyncedBox;
      await box.delete(activityId);
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<List<LocalActivity>>> searchLocalActivities({required String likeDescription, required int page, required int pageSize}) async {
    try {
      var box = await openActivityBox;
      if (box.isEmpty) return SuccessResult(data: []);

      var data =
          box.values.where((e) => e.description.toLowerCase().contains(likeDescription.toLowerCase())).skip(page * pageSize).take(pageSize).toList();

      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(
        error: e.toString(),
        trace: trace,
        failure: FailureType.localDatabase,
      );
    }
  }

  @override
  Future<TaskResult<void>> deleteLocalCustomer({required int customerId}) async {
    try {
      var box = await openCustomerBox;
      await box.delete(customerId);
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<List<LocalCustomer>>> searchLocalCustomers({
    required int page,
    required int pageSize,
    required String likeName,
  }) async {
    try {
      var box = await openCustomerBox;
      if (box.isEmpty) return SuccessResult(data: []);

      var data = box.values.where((e) => e.name.toLowerCase().contains(likeName.toLowerCase())).skip(page * pageSize).take(pageSize).toList();
      print("${data.length} customers for $likeName");
      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(
        error: e.toString(),
        trace: trace,
        failure: FailureType.localDatabase,
      );
    }
  }

  @override
  Future<TaskResult<void>> setLocalCustomers({
    required List<LocalCustomer> customers,
  }) async {
    try {
      var box = await openCustomerBox;
      await box.putAll({for (var a in customers) a.id: a});
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(
        error: e.toString(),
        trace: trace,
        failure: FailureType.localDatabase,
      );
    }
  }

  @override
  Future<TaskResult<void>> removeLocalVisitByHash({
    required LocalVisitHash hash,
  }) async {
    try {
      var box = await openUnsyncedBox;
      if (!box.containsKey(hash.value)) {
        return ErrorResult(
          error: "Visit key not found",
          failure: FailureType.localDatabase,
        );
      }
      await box.delete(hash.value);
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(
        error: e.toString(),
        trace: trace,
        failure: FailureType.localDatabase,
      );
    }
  }

  @override
  Future<TaskResult<LocalVisitStatistics?>> getStatistics() async {
    try {
      var box = await openVisitStatisticsBox;
      var data = box.values.firstOrNull;
      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(
        error: e.toString(),
        trace: trace,
        failure: FailureType.localDatabase,
      );
    }
  }

  @override
  Future<TaskResult<void>> setStatistics({
    required LocalVisitStatistics stats,
  }) async {
    try {
      var box = await openVisitStatisticsBox;
      await box.clear();
      await box.add(stats);
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(
        error: e.toString(),
        trace: trace,
        failure: FailureType.localDatabase,
      );
    }
  }
}
