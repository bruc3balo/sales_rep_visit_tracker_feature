import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

abstract class LocalActivityRepository {

  Future<TaskResult<void>> setLocalActivity({
    required LocalActivity activity,
  });

  Future<TaskResult<void>> setLocalActivities({
    required List<LocalActivity> activities,
  });

  Future<TaskResult<Map<int, LocalActivity>>> getLocalActivities({
    required List<int> activityIds,
  });

  Future<TaskResult<List<LocalActivity>>> searchLocalActivities({
    required String likeDescription,
    required int page,
    required int pageSize,
  });

  Future<TaskResult<List<LocalActivity>>> fetchLocalActivities({
    required int page,
    required int pageSize,
  });

  Future<TaskResult<void>> deleteLocalActivity({
    required int activityId,
  });

  Future<TaskResult<void>> clearLocalActivities();

}