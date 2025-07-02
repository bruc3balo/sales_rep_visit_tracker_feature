import 'dart:collection';

import 'package:hive/hive.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_database_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class HiveLocalDatabaseService implements LocalDatabaseService {

  Future<Box<UnSyncedLocalVisit>> get openUnsyncedBox async => await Hive.openBox('unsynced_visits');
  Future<Box<LocalCustomer>> get openCustomerBox async => await Hive.openBox('customers');
  Future<Box<LocalActivity>> get openActivityBox async => await Hive.openBox('activities');

  @override
  Future<TaskResult<List<UnSyncedLocalVisit>>> getUnsyncedLocalVisits({
    required int page,
    required int pageSize
  }) async {
    try {
      var box = await openUnsyncedBox;
      var data=  box.values.skip(page * pageSize).take(pageSize).toList();
      return SuccessResult(data: data);
    } catch(e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<LocalVisitKey>> setLocalVisit({
    required UnSyncedLocalVisit visit,
  }) async {
    try {
      var box = await openUnsyncedBox;
      var hash = visit.hash;
      await box.put(hash.value, visit);
      return SuccessResult(data: hash);
    } catch(e, trace) {
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
      await box.delete(hash.value);
      return SuccessResult(data: null);
    } catch(e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<bool>> containsUnsyncedVisitKey({
    required LocalVisitKey key,
  }) async {
    try {
      var box = await openUnsyncedBox;
      return SuccessResult(data: box.containsKey(key.value));
    } catch(e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> clearAllLocalActivities() async {
    try {
      var box = await openActivityBox;
      await box.clear();
      return SuccessResult(data: null);
    } catch(e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> clearAllLocalCustomers()  async {
    try {
      var box = await openCustomerBox;
      await box.clear();
      return SuccessResult(data: null);
    } catch(e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<List<LocalActivity>>> getLocalActivities({
    required int page,
    required int pageSize
  })  async {
    try {
      var box = await openActivityBox;
      var data = box.values.skip(page * pageSize).take(pageSize).toList();
      return SuccessResult(data: data);
    } catch (e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<Map<int, LocalActivity>>> getLocalActivitiesByIds({
    required List<int> ids,
  })  async {
    try {
      var idSet = HashSet.from(ids);
      var box = await openActivityBox;
      var dataList = box.values.where((a) => idSet.contains(a.id)).toList();
      var data = {for(var d in dataList) d.id : d};
      return SuccessResult(data: data);
    } catch(e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<Map<int, LocalCustomer>>> getLocalCustomerByIds({
    required List<int> ids,
  })  async {
    try {
      var idSet = HashSet.from(ids);
      var box = await openCustomerBox;
      var dataList = box.values.where((a) => idSet.contains(a.id)).toList();
      var data = {for(var d in dataList) d.id : d};
      return SuccessResult(data: data);
    } catch(e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<List<LocalCustomer>>> getLocalCustomers({
    required int page,
    required int pageSize,
  })  async {
    try {
      var box = await openCustomerBox;
      var data = box.values.skip(page * pageSize).take(pageSize).toList();
      return SuccessResult(data: data);
    } catch(e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> setLocalActivities({required List<LocalActivity> activities})  async {
    try {
      var box = await openActivityBox;
      await box.putAll({for(var a in activities) a.id : a});
      return SuccessResult(data: null);
    } catch(e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> setLocalActivity({required LocalActivity activity})  async {
    try {
      var box = await openActivityBox;
      await box.put(activity.id, activity);
      return SuccessResult(data: null);
    } catch(e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<void>> setLocalCustomer({required LocalCustomer customer})  async {
    try {
      var box = await openCustomerBox;
      await box.put(customer.id, customer);
      return SuccessResult(data: null);
    } catch(e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

  @override
  Future<TaskResult<int>> countUnsyncedVisits() async {
    try {
      var box = await openUnsyncedBox;
      return SuccessResult(data: box.length);
    } catch(e, trace) {
      return ErrorResult(error: e.toString(), trace: trace, failure: FailureType.localDatabase);
    }
  }

}