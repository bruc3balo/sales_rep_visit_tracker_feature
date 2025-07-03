import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

abstract class LocalActivityRepository {

  Future<TaskResult<void>> setLocalActivity({
    required Activity activity,
  });

  Future<TaskResult<void>> setLocalActivities({
    required List<Activity> activities,
  });

  Future<TaskResult<Map<int, Activity>>> getLocalActivities({
    required List<int> activityIds,
  });

  Future<TaskResult<List<Activity>>> searchLocalActivities({
    required String likeDescription,
    required int page,
    required int pageSize,
  });

  Future<TaskResult<List<Activity>>> fetchLocalActivities({
    required int page,
    required int pageSize,
  });

  Future<TaskResult<void>> deleteLocalActivity({
    required int activityId,
  });

  Future<TaskResult<void>> clearLocalActivities();

}