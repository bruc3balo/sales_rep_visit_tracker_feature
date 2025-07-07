import 'dart:collection';
import 'dart:math';

import 'package:hive/hive.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_database_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class HiveLocalDatabaseService implements LocalDatabaseService {
  final HiveAesCipher _cipher;

  Future<Box<UnSyncedLocalVisit>> get openUnsyncedBox async => await Hive.openBox('unsynced_visits', encryptionCipher: _cipher);

  Future<Box<LocalCustomer>> get openCustomerBox async => await Hive.openBox('customers', encryptionCipher: _cipher);

  Future<Box<LocalActivity>> get openActivityBox async => await Hive.openBox('activities', encryptionCipher: _cipher);

  Future<Box<LocalVisitStatistics>> get openVisitStatisticsBox async => await Hive.openBox('visit_statistics', encryptionCipher: _cipher);

  HiveLocalDatabaseService({
    required HiveAesCipher cipher,
  }) : _cipher = cipher {
    AppLog.I.i("HiveLocalDatabaseService", "Hive database created with cypher");
  }

  @override
  Future<TaskResult<List<UnSyncedLocalVisit>>> getUnsyncedLocalVisits({required int page, required int pageSize}) async {
    AppLog.I.i("HiveLocalDatabaseService", "getUnsyncedLocalVisits called");
    try {
      var box = await openUnsyncedBox;
      final pagedKeys = box.keys.toList().toPage(page: page, pageSize: pageSize);
      final data = pagedKeys.map((e) => box.get(e)).whereType<UnSyncedLocalVisit>().toList();
      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> setLocalVisit({
    required UnSyncedLocalVisit visit,
  }) async {
    AppLog.I.i("HiveLocalDatabaseService", "setLocalVisit called");
    try {
      var box = await openUnsyncedBox;

      await box.put(visit.key, visit);
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> removeLocalVisit({required UnSyncedLocalVisit visit}) async {
    AppLog.I.i("HiveLocalDatabaseService", "removeLocalVisit called");
    try {
      var box = await openUnsyncedBox;
      await box.delete(visit.key);
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<UnSyncedLocalVisit?>> findByHash({required LocalVisitHash hash}) async {
    AppLog.I.i("HiveLocalDatabaseService", "findByHash called $hash");
    try {
      var box = await openUnsyncedBox;
      var data = box.values.where((e) => e.hash == hash.value).firstOrNull;
      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<UnSyncedLocalVisit?>> findByKey({required dynamic key}) async {
    AppLog.I.i("HiveLocalDatabaseService", "findByKey called $key");
    try {
      var box = await openUnsyncedBox;
      var data = box.get(key);
      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> removeLocalVisitByHash({required LocalVisitHash hash}) async {
    AppLog.I.i("HiveLocalDatabaseService", "removeLocalVisitByHash called");
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
  Future<TaskResult<int>> countUnsyncedVisits() async {
    AppLog.I.i("HiveLocalDatabaseService", "countUnsyncedVisits called");
    try {
      var box = await openUnsyncedBox;
      return SuccessResult(data: box.length);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> clearAllLocalActivities() async {
    AppLog.I.i("HiveLocalDatabaseService", "clearAllLocalActivities called");
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
    AppLog.I.i("HiveLocalDatabaseService", "clearAllLocalCustomers called");
    try {
      var box = await openCustomerBox;
      await box.clear();
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> deleteLocalActivity({required int activityId}) async {
    AppLog.I.i("HiveLocalDatabaseService", "deleteLocalActivity called");
    try {
      var box = await openUnsyncedBox;
      await box.delete(activityId);
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> deleteLocalCustomer({required int customerId}) async {
    AppLog.I.i("HiveLocalDatabaseService", "deleteLocalCustomer called");
    try {
      var box = await openCustomerBox;
      await box.delete(customerId);
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<List<LocalActivity>>> getLocalActivities({required int page, required int pageSize}) async {
    AppLog.I.i("HiveLocalDatabaseService", "getLocalActivities called");
    try {
      var box = await openActivityBox;

      final pagedKeys = box.keys.toList().toPage(page: page, pageSize: pageSize);
      final data = pagedKeys.map((e) => box.get(e)).whereType<LocalActivity>().toList();
      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<Map<int, LocalActivity>>> getLocalActivitiesByIds({required List<int> ids}) async {
    AppLog.I.i("HiveLocalDatabaseService", "getLocalActivitiesByIds called");
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
  Future<TaskResult<Map<int, LocalCustomer>>> getLocalCustomerByIds({required List<int> ids}) async {
    AppLog.I.i("HiveLocalDatabaseService", "getLocalCustomerByIds called");
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
  Future<TaskResult<List<LocalCustomer>>> getLocalCustomers({required int page, required int pageSize}) async {
    AppLog.I.i("HiveLocalDatabaseService", "getLocalCustomers called");
    try {
      var box = await openCustomerBox;
      final pagedKeys = box.keys.toList().toPage(page: page, pageSize: pageSize);
      final data = pagedKeys.map((e) => box.get(e)).whereType<LocalCustomer>().toList();
      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> setLocalActivities({required List<LocalActivity> activities}) async {
    AppLog.I.i("HiveLocalDatabaseService", "setLocalActivities called");
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
    AppLog.I.i("HiveLocalDatabaseService", "setLocalActivity called");
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
    AppLog.I.i("HiveLocalDatabaseService", "setLocalCustomer called");
    try {
      var box = await openCustomerBox;
      await box.put(customer.id, customer);
      return SuccessResult(data: null);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<List<LocalActivity>>> searchLocalActivities({required String likeDescription, required int page, required int pageSize}) async {
    AppLog.I.i("HiveLocalDatabaseService", "searchLocalActivities called");
    try {
      var box = await openActivityBox;
      var data = box.values
          .where((e) => e.description.toLowerCase().contains(likeDescription.toLowerCase()))
          .toList()
          .toPage<LocalActivity>(page: page, pageSize: pageSize);

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
  Future<TaskResult<List<LocalCustomer>>> searchLocalCustomers({required int page, required int pageSize, required String likeName}) async {
    AppLog.I.i("HiveLocalDatabaseService", "searchLocalCustomers called");
    try {
      var box = await openCustomerBox;
      var data = box.values
          .where((e) => e.name.toLowerCase().contains(likeName.toLowerCase()))
          .toList()
          .toPage<LocalCustomer>(page: page, pageSize: pageSize);

      AppLog.I.i("HiveLocalDatabaseService", "${data.length} customers for $likeName");
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
  Future<TaskResult<void>> setLocalCustomers({required List<LocalCustomer> customers}) async {
    AppLog.I.i("HiveLocalDatabaseService", "setLocalCustomers called");
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
  Future<TaskResult<LocalVisitStatistics?>> getStatistics() async {
    AppLog.I.i("HiveLocalDatabaseService", "getStatistics called");
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
  Future<TaskResult<void>> setStatistics({required LocalVisitStatistics stats}) async {
    AppLog.I.i("HiveLocalDatabaseService", "setStatistics called");
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
