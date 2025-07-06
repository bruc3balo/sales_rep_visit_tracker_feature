import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class DeleteActivityUseCase {
  final RemoteActivityRepository _remoteActivityRepository;
  final LocalActivityRepository _localActivityRepository;

  DeleteActivityUseCase({
    required RemoteActivityRepository remoteActivityRepository,
    required LocalActivityRepository localActivityRepository,
  })  : _remoteActivityRepository = remoteActivityRepository,
        _localActivityRepository = localActivityRepository;

  Future<TaskResult<void>> execute({required int activityId}) async {
    AppLog.I.i("DeleteActivityUseCase", "Deleting activity with ID: $activityId");

    var deleteResult = await _remoteActivityRepository.deleteActivity(
      activityId: activityId,
    );

    switch (deleteResult) {
      case ErrorResult<void>():
        AppLog.I.i("DeleteActivityUseCase", "Failed to delete activity remotely: ${deleteResult.error}");
        return ErrorResult(
          error: deleteResult.error,
          failure: deleteResult.failure,
          trace: deleteResult.trace,
        );

      case SuccessResult<void>():
        AppLog.I.i("DeleteActivityUseCase", "Successfully deleted activity remotely. Removing from local storage...");
        _localActivityRepository.deleteLocalActivity(activityId: activityId);
        return deleteResult;
    }
  }
}