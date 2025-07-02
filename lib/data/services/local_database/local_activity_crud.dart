
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

abstract class LocalActivityCrud {

  Future<TaskResult<void>> setLocalActivity({
    required LocalActivity activity,
  });

  Future<TaskResult<void>> setLocalActivities({
    required List<LocalActivity> activities,
  });

  Future<TaskResult<List<LocalActivity>>> getLocalActivities({
    required int page,
    required int pageSize,
  });

  Future<TaskResult<List<LocalActivity>>> searchLocalActivities({
    required String likeDescription,
    required int page,
    required int pageSize,
  });

  Future<TaskResult<Map<int, LocalActivity>>> getLocalActivitiesByIds({
    required List<int> ids,
  });

  Future<TaskResult<void>> deleteLocalActivity({required int activityId});

  Future<TaskResult<void>> clearAllLocalActivities();

}