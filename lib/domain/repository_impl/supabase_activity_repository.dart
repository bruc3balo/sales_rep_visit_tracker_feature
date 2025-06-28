import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_remote_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/remote/remote_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/activity/activity_supabase_api.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class SupabaseActivityRepository implements ActivityRepository {
  final ActivitySupabaseApi _activityApi;

  SupabaseActivityRepository({required ActivitySupabaseApi activityApi}) : _activityApi = activityApi;

  @override
  Future<TaskResult<Activity>> createActivity({required String description}) async {
    //Check if similar activity exists
    var duplicateCheckResponse = await _activityApi.sendGetActivityRequest(equalDescription: description, page: 0, pageSize: 1);

    switch (duplicateCheckResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: duplicateCheckResponse.description,
          trace: duplicateCheckResponse.trace,
        );

      case SuccessNetworkResponse():
        var data = (duplicateCheckResponse.data as List<dynamic>);
        bool duplicateActivity = data.isEmpty;
        if (duplicateActivity) {
          return ErrorResult(
            error: "Activity with description exists",
          );
        }
    }

    //Create new activity
    var createResponse = await _activityApi.sendAddActivityRequest(description: description);

    switch (createResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: createResponse.description,
          trace: createResponse.trace,
        );

      case SuccessNetworkResponse():
        var fetchCreatedActivity = await _activityApi.sendGetActivityRequest(
          equalDescription: description,
          pageSize: 1,
          page: 0,
        );
        switch (fetchCreatedActivity) {
          case FailNetworkResponse():
            return ErrorResult(
              error: fetchCreatedActivity.description,
              trace: fetchCreatedActivity.trace,
            );

          case SuccessNetworkResponse():
            //Cache activity by id
            var data = (fetchCreatedActivity.data as List<dynamic>).map((e) => RemoteActivity.fromJson(e)).first;
            return SuccessResult(data: data.toDomain, message: "Activity created");
        }
    }
  }

  @override
  Future<TaskResult<void>> deleteActivity({
    required int activityId,
  }) async {
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
        return SuccessResult(message: "Activity deleted");
    }
  }

  @override
  Future<TaskResult<List<Activity>>> getActivities({
    String? likeDescription,
    String? equalDescription,
    required int page,
    required int pageSize,
    String? order,
  }) async {
    var getActivityResponse = await _activityApi.sendGetActivityRequest(
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
        var data = (getActivityResponse.data as List<dynamic>).map((e) => RemoteActivity.fromJson(e).toDomain).toList();

        return SuccessResult(
          message: "${data.length} activities found",
          data: data,
        );
    }
  }

  @override
  Future<TaskResult<Activity>> updateActivity({
    required Activity activity,
  }) async {
    var updateActivityResponse = await _activityApi.sendUpdateActivityRequest(
      activityId: activity.id,
      description: activity.description,
    );

    switch (updateActivityResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: updateActivityResponse.description,
          trace: updateActivityResponse.trace,
        );
      case SuccessNetworkResponse():
        var data = RemoteActivity.fromJson(updateActivityResponse.data).toDomain;

        return SuccessResult(
          message: "Activity updated",
          data: data,
        );
    }
  }
}
