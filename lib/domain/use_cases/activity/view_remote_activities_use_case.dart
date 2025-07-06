import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class ViewRemoteActivitiesUseCase {
  final RemoteActivityRepository _remoteActivityRepository;
  final LocalActivityRepository _localActivityRepository;

  ViewRemoteActivitiesUseCase({
    required RemoteActivityRepository remoteActivityRepository,
    required LocalActivityRepository localActivityRepository,
  })  : _remoteActivityRepository = remoteActivityRepository,
        _localActivityRepository = localActivityRepository;

  Future<TaskResult<List<Activity>>> execute({
    List<int>? ids,
    String? likeDescription,
    String? equalDescription,
    required int page,
    required int pageSize,
    String? order,
  }) async {
    AppLog.I.i(
      "ViewRemoteActivitiesUseCase",
      "Fetching remote activities | ids=$ids | like='$likeDescription' | equal='$equalDescription' | page=$page | pageSize=$pageSize | order=$order",
    );

    var getActivitiesResult = await _remoteActivityRepository.getActivities(
      ids: ids,
      page: page,
      pageSize: pageSize,
      likeDescription: likeDescription,
      equalDescription: equalDescription,
      order: order,
    );

    switch (getActivitiesResult) {
      case ErrorResult<List<Activity>>():
        AppLog.I.e(
          "ViewRemoteActivitiesUseCase",
          "Failed to fetch remote activities: ${getActivitiesResult.error}",
          trace: getActivitiesResult.trace,
        );
        break;
      case SuccessResult<List<Activity>>():
        AppLog.I.i(
          "ViewRemoteActivitiesUseCase",
          "Fetched ${getActivitiesResult.data.length} remote activities. Caching locally...",
        );
        _localActivityRepository.setLocalActivities(
          activities: getActivitiesResult.data,
        );
        break;
    }

    return getActivitiesResult;
  }
}