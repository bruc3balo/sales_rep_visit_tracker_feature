import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class ViewRemoteActivitiesUseCase {

  final RemoteActivityRepository _remoteActivityRepository;
  final LocalActivityRepository _localActivityRepository;

  ViewRemoteActivitiesUseCase({
    required RemoteActivityRepository remoteActivityRepository,
    required LocalActivityRepository localActivityRepository
  }) : _remoteActivityRepository = remoteActivityRepository,
        _localActivityRepository = localActivityRepository;


  Future<TaskResult<List<Activity>>> execute({
    List<int>? ids,
    String? likeDescription,
    String? equalDescription,
    required int page,
    required int pageSize,
    String? order,
}) async {

    var getActivitiesResult = await _remoteActivityRepository.getActivities(
      ids: ids,
      page: page,
      pageSize: pageSize,
      likeDescription: likeDescription,
      equalDescription: equalDescription,
      order: order,
    );

    //Cache activities async
    if(getActivitiesResult is SuccessResult<List<Activity>>) {
        _localActivityRepository.setLocalActivities(
            activities: getActivitiesResult.data,
        );
    }

    return getActivitiesResult;
  }

}