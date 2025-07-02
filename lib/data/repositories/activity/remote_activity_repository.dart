import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

abstract class RemoteActivityRepository {

  Future<TaskResult<void>> createActivity({required String description});

  Future<TaskResult<List<Activity>>> getActivities({
    List<int>? ids,
    String? likeDescription,
    String? equalDescription,
    required int page,
    required int pageSize,
    String? order,
  });

  Future<TaskResult<void>> updateActivity({
    required int activityId,
    String? description,
  });

  Future<TaskResult<void>> deleteActivity({required int activityId});

}
