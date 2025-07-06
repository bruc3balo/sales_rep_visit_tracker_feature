import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class UpdateActivityUseCase {
  final RemoteActivityRepository _remoteActivityRepository;
  final LocalActivityRepository _localActivityRepository;

  UpdateActivityUseCase({
    required RemoteActivityRepository remoteActivityRepository,
    required LocalActivityRepository localActivityRepository,
  })  : _remoteActivityRepository = remoteActivityRepository,
        _localActivityRepository = localActivityRepository;

  Future<TaskResult<Activity>> execute({
    required int activityId,
    required String description,
  }) async {
    AppLog.I.i(
      "UpdateActivityUseCase",
      "Updating activity (id: $activityId) with new description: $description",
    );

    var createResult = await _remoteActivityRepository.updateActivity(
      activityId: activityId,
      description: description,
    );

    switch (createResult) {
      case ErrorResult<void>():
        AppLog.I.e(
          "UpdateActivityUseCase",
          "Failed to update activity (id: $activityId): ${createResult.error}",
          trace: createResult.trace,
        );
        return ErrorResult(
          error: createResult.error,
          failure: createResult.failure,
          trace: createResult.trace,
        );

      case SuccessResult<void>():
        AppLog.I.i(
          "UpdateActivityUseCase",
          "Successfully updated activity (id: $activityId), fetching latest version...",
        );

        var fetchUpdatedActivity = await _remoteActivityRepository.getActivities(
          ids: [activityId],
          pageSize: 1,
          page: 0,
        );

        switch (fetchUpdatedActivity) {
          case ErrorResult<List<Activity>>():
            AppLog.I.e(
              "UpdateActivityUseCase",
              "Failed to fetch updated activity (id: $activityId): ${fetchUpdatedActivity.error}",
              trace: fetchUpdatedActivity.trace,
            );
            return ErrorResult(
              error: fetchUpdatedActivity.error,
              trace: fetchUpdatedActivity.trace,
              failure: fetchUpdatedActivity.failure,
            );

          case SuccessResult<List<Activity>>():
            var data = fetchUpdatedActivity.data.first;
            AppLog.I.i(
              "UpdateActivityUseCase",
              "Fetched updated activity (id: $activityId), caching locally...",
            );

            _localActivityRepository.setLocalActivity(activity: data);

            return SuccessResult(data: data, message: "Activity updated");
        }
    }
  }
}