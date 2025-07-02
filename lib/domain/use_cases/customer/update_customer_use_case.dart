
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class UpdateCustomerUseCase {
  final RemoteCustomerRepository _remoteActivityRepository;
  final LocalCustomerRepository _local;

  UpdateCustomerUseCase({
    required RemoteActivityRepository remoteActivityRepository,
    required LocalActivityRepository localActivityRepository,
  }) : _remoteActivityRepository = remoteActivityRepository,
        _localActivityRepository = localActivityRepository;


  Future<TaskResult<Activity>> execute({
    required int activityId,
    required String description
  }) async {

    var createResult = await _remoteActivityRepository.updateActivity(
      activityId: activityId,
      description: description
    );

    switch(createResult) {

      case ErrorResult<void>():
        return ErrorResult(
            error: createResult.error,
            failure: createResult.failure,
            trace: createResult.trace,
        );
      case SuccessResult<void>():
        var fetchUpdatedActivity = await _remoteActivityRepository.getActivities(
          ids: [activityId],
          pageSize: 1,
          page: 0,
        );
        switch (fetchUpdatedActivity) {
          case ErrorResult<List<Activity>>():
            return ErrorResult(
              error: fetchUpdatedActivity.error,
              trace: fetchUpdatedActivity.trace,
              failure: fetchUpdatedActivity.failure,
            );

          case SuccessResult<List<Activity>>():
            var data = fetchUpdatedActivity.data.first;

            //Cache activity async
            _localActivityRepository.setLocalActivity(activity: data.toLocal);

            return SuccessResult(data: data, message: "Activity updated");

        }
    }



  }
}