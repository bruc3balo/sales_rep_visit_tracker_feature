
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class DeleteActivityUseCase {
  final RemoteActivityRepository _remoteActivityRepository;
  final LocalActivityRepository _localActivityRepository;

  DeleteActivityUseCase({
    required RemoteActivityRepository remoteActivityRepository,
    required LocalActivityRepository localActivityRepository,
  }) : _remoteActivityRepository = remoteActivityRepository,
        _localActivityRepository = localActivityRepository;


  Future<TaskResult<void>> execute({required int activityId}) async {

    var deleteResult = await _remoteActivityRepository.deleteActivity(
      activityId: activityId,
    );

    switch(deleteResult) {

      case ErrorResult<void>():
        return ErrorResult(
            error: deleteResult.error,
            failure: deleteResult.failure,
            trace: deleteResult.trace,
        );
      case SuccessResult<void>():
        _localActivityRepository.deleteLocalActivity(activityId: activityId);
        return deleteResult;
    }

  }
}