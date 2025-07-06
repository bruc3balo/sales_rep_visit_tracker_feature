import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_activity_crud.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class HiveLocalActivityRepository extends LocalActivityRepository {
  final LocalActivityCrud _localActivityCrud;

  HiveLocalActivityRepository({
    required LocalActivityCrud localActivityCrud,
  }) : _localActivityCrud = localActivityCrud;

  static const _tag = "HiveLocalActivityRepository";

  @override
  Future<TaskResult<void>> clearLocalActivities() async {
    AppLog.I.i(_tag, "clearLocalActivities()");
    return await _localActivityCrud.clearAllLocalActivities();
  }

  @override
  Future<TaskResult<Map<int, Activity>>> getLocalActivities({
    required List<int> activityIds,
  }) async {
    AppLog.I.i(_tag, "getLocalActivities(activityIds: $activityIds)");
    var result = await _localActivityCrud.getLocalActivitiesByIds(ids: activityIds);
    switch (result) {
      case ErrorResult<Map<int, LocalActivity>>():
        return ErrorResult(
          error: result.error,
          trace: result.trace,
          failure: result.failure,
        );
      case SuccessResult<Map<int, LocalActivity>>():
        var data = {for (var a in result.data.values) a.id: a.toDomain};
        return SuccessResult(data: data);
    }
  }

  @override
  Future<TaskResult<void>> setLocalActivity({
    required Activity activity,
  }) async {
    AppLog.I.i(_tag, "setLocalActivity(activity: ${activity.id})");
    return await _localActivityCrud.setLocalActivity(activity: activity.toLocal);
  }

  @override
  Future<TaskResult<void>> setLocalActivities({
    required List<Activity> activities,
  }) async {
    AppLog.I.i(_tag, "setLocalActivities(activities count: ${activities.length})");
    return await _localActivityCrud.setLocalActivities(
      activities: activities.map((e) => e.toLocal).toList(),
    );
  }

  @override
  Future<TaskResult<List<Activity>>> fetchLocalActivities({
    required int page,
    required int pageSize,
  }) async {
    AppLog.I.i(_tag, "fetchLocalActivities(page: $page, pageSize: $pageSize)");
    var result = await _localActivityCrud.getLocalActivities(page: page, pageSize: pageSize);
    switch (result) {
      case ErrorResult<List<LocalActivity>>():
        return ErrorResult(
          error: result.error,
          trace: result.trace,
          failure: result.failure,
        );
      case SuccessResult<List<LocalActivity>>():
        return SuccessResult(data: result.data.map((a) => a.toDomain).toList());
    }
  }

  @override
  Future<TaskResult<void>> deleteLocalActivity({
    required int activityId,
  }) async {
    AppLog.I.i(_tag, "deleteLocalActivity(activityId: $activityId)");
    return await _localActivityCrud.deleteLocalActivity(activityId: activityId);
  }

  @override
  Future<TaskResult<List<Activity>>> searchLocalActivities({
    required String likeDescription,
    required int page,
    required int pageSize,
  }) async {
    AppLog.I.i(_tag,
        "searchLocalActivities(likeDescription: '$likeDescription', page: $page, pageSize: $pageSize)");
    var result = await _localActivityCrud.searchLocalActivities(
      likeDescription: likeDescription,
      page: page,
      pageSize: pageSize,
    );

    switch (result) {
      case ErrorResult<List<LocalActivity>>():
        return ErrorResult(
          error: result.error,
          trace: result.trace,
          failure: result.failure,
        );
      case SuccessResult<List<LocalActivity>>():
        return SuccessResult(data: result.data.map((a) => a.toDomain).toList());
    }
  }
}