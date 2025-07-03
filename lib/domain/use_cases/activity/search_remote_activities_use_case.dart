import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class SearchRemoteActivitiesUseCase {

  final RemoteActivityRepository _remoteActivityRepository;
  final LocalActivityRepository _localActivityRepository;

  SearchRemoteActivitiesUseCase({
    required RemoteActivityRepository remoteActivityRepository,
    required LocalActivityRepository localActivityRepository,
  }) : _remoteActivityRepository = remoteActivityRepository,
        _localActivityRepository = localActivityRepository;



  Future<TaskResult<List<Activity>>> execute({
    String? likeDescription,
    required int page,
    required int pageSize,
}) async {

    var searchResult = await _remoteActivityRepository.getActivities(
      page: page,
      pageSize: pageSize,
      likeDescription: likeDescription,
    );

    //cache activities async
    if(searchResult is SuccessResult<List<Activity>>) {
      _localActivityRepository.setLocalActivities(
        activities: searchResult.data,
      );
    }

    return searchResult;
  }

}