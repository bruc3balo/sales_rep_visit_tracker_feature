import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

abstract class ActivityRepository {

  Future<TaskResult<Activity>> createActivity({required String description});

  Future<TaskResult<List<Activity>>> getActivities({
    List<int>? ids,
    String? likeDescription,
    String? equalDescription,
    required int page,
    required int pageSize,
    String? order,
  });

  Future<TaskResult<Activity>> updateActivity({required Activity activity});

  Future<TaskResult<void>> deleteActivity({required int activityId});

}
