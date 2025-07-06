import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class CreateActivityUseCase {
  final RemoteActivityRepository _remoteActivityRepository;
  final LocalActivityRepository _localActivityRepository;

  CreateActivityUseCase({
    required RemoteActivityRepository remoteActivityRepository,
    required LocalActivityRepository localActivityRepository,
  })  : _remoteActivityRepository = remoteActivityRepository,
        _localActivityRepository = localActivityRepository;

  Future<TaskResult<Activity>> execute({required String description}) async {
    AppLog.I.i("CreateActivityUseCase", "Executing create activity with description: $description");

    var createResult = await _remoteActivityRepository.createActivity(
      description: description,
    );

    switch (createResult) {
      case ErrorResult<void>():
        AppLog.I.i("CreateActivityUseCase", "Create activity failed: ${createResult.error}");
        return ErrorResult(
          error: createResult.error,
          failure: createResult.failure,
          trace: createResult.trace,
        );

      case SuccessResult<void>():
        AppLog.I.i("CreateActivityUseCase", "Activity created remotely, now fetching activity to confirm");

        var fetchCreatedActivity = await _remoteActivityRepository.getActivities(
          equalDescription: description,
          pageSize: 1,
          page: 0,
        );

        switch (fetchCreatedActivity) {
          case ErrorResult<List<Activity>>():
            AppLog.I.i("CreateActivityUseCase", "Failed to fetch newly created activity: ${fetchCreatedActivity.error}");
            return ErrorResult(
              error: fetchCreatedActivity.error,
              trace: fetchCreatedActivity.trace,
              failure: fetchCreatedActivity.failure,
            );

          case SuccessResult<List<Activity>>():
            var data = fetchCreatedActivity.data.first;
            AppLog.I.i("CreateActivityUseCase", "Fetched and caching activity: ${data.id} - ${data.description}");

            // Cache activity async
            _localActivityRepository.setLocalActivity(activity: data);

            return SuccessResult(data: data, message: "Activity created");
        }
    }
  }
}