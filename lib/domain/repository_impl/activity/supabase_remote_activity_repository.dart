import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_remote_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/remote/remote_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/activity/activity_supabase_api.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class SupabaseActivityRepository implements RemoteActivityRepository {
  final ActivitySupabaseApi _activityApi;

  SupabaseActivityRepository({required ActivitySupabaseApi activityApi}) : _activityApi = activityApi;

  static const _tag = "SupabaseActivityRepository";

  @override
  Future<TaskResult<void>> createActivity({required String description}) async {
    AppLog.I.i(_tag, "createActivity(description: $description)");

    // Check if similar activity exists
    var duplicateCheckResponse = await _activityApi.sendGetActivityRequest(
      equalDescription: description,
      page: 0,
      pageSize: 1,
    );

    switch (duplicateCheckResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: duplicateCheckResponse.description,
          trace: duplicateCheckResponse.trace,
        );

      case SuccessNetworkResponse():
        var data = (duplicateCheckResponse.data as List<dynamic>);
        bool duplicateActivity = data.isNotEmpty;
        if (duplicateActivity) {
          return ErrorResult(
            error: "Activity with description exists",
          );
        }
    }

    // Create new activity
    var createResponse = await _activityApi.sendAddActivityRequest(description: description);

    switch (createResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: createResponse.description,
          trace: createResponse.trace,
        );

      case SuccessNetworkResponse():
        return SuccessResult(data: null, message: "Activity created");
    }
  }

  @override
  Future<TaskResult<void>> deleteActivity({required int activityId}) async {
    AppLog.I.i(_tag, "deleteActivity(activityId: $activityId)");

    var deleteResponse = await _activityApi.sendDeleteActivityRequest(
      activityId: activityId,
    );

    switch (deleteResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: deleteResponse.description,
          trace: deleteResponse.trace,
        );
      case SuccessNetworkResponse():
        return SuccessResult(
          data: null,
          message: "Activity deleted",
        );
    }
  }

  @override
  Future<TaskResult<List<Activity>>> getActivities({
    List<int>? ids,
    String? likeDescription,
    String? equalDescription,
    required int page,
    required int pageSize,
    String? order,
  }) async {
    AppLog.I.i(
      _tag,
      "getActivities(ids: $ids, like: $likeDescription, equal: $equalDescription, page: $page, pageSize: $pageSize, order: $order)",
    );

    var getActivityResponse = await _activityApi.sendGetActivityRequest(
      ids: ids,
      likeDescription: likeDescription,
      equalDescription: equalDescription,
      page: page,
      pageSize: pageSize,
      order: order,
    );

    switch (getActivityResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: getActivityResponse.description,
          trace: getActivityResponse.trace,
        );
      case SuccessNetworkResponse():
        var data = (getActivityResponse.data as List<dynamic>)
            .map((e) => RemoteActivity.fromJson(e).toDomain)
            .toList();

        return SuccessResult(
          message: "${data.length} activities found",
          data: data,
        );
    }
  }

  @override
  Future<TaskResult<void>> updateActivity({
    required int activityId,
    String? description,
  }) async {
    AppLog.I.i(_tag, "updateActivity(activityId: $activityId, description: $description)");

    var updateActivityResponse = await _activityApi.sendUpdateActivityRequest(
      activityId: activityId,
      description: description,
    );

    switch (updateActivityResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: updateActivityResponse.description,
          trace: updateActivityResponse.trace,
        );
      case SuccessNetworkResponse():
        return SuccessResult(data: null, message: "Activity updated");
    }
  }
}