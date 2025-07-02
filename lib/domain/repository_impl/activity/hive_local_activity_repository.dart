import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_activity_crud.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class HiveLocalActivityRepository extends LocalActivityRepository {
  final LocalActivityCrud _localActivityCrud;

  HiveLocalActivityRepository({
    required LocalActivityCrud localActivityCrud,
  }) : _localActivityCrud = localActivityCrud;

  @override
  Future<TaskResult<void>> clearLocalActivities() async {
    return await _localActivityCrud.clearAllLocalActivities();
  }

  @override
  Future<TaskResult<Map<int, LocalActivity>>> getLocalActivities({required List<int> activityIds}) async {
    return await _localActivityCrud.getLocalActivitiesByIds(ids: activityIds);
  }

  @override
  Future<TaskResult<void>> setLocalActivity({required LocalActivity activity}) async {
    return await _localActivityCrud.setLocalActivity(activity: activity);
  }

  @override
  Future<TaskResult<void>> setLocalActivities({required List<LocalActivity> activities}) async {
    return await _localActivityCrud.setLocalActivities(activities: activities);
  }

  @override
  Future<TaskResult<List<LocalActivity>>> fetchLocalActivities({required int page, required int pageSize}) async {
    return await _localActivityCrud.getLocalActivities(page: page, pageSize: pageSize);
  }

  @override
  Future<TaskResult<void>> deleteLocalActivity({required int activityId}) async {
    return await _localActivityCrud.deleteLocalActivity(activityId: activityId);
  }

  @override
  Future<TaskResult<List<LocalActivity>>> searchLocalActivities({
    required String likeDescription, 
    required int page,
    required int pageSize,
  }) async {
    return await _localActivityCrud.searchLocalActivities(
      likeDescription: likeDescription, 
      page: page, 
      pageSize: pageSize,
    );
  }

}