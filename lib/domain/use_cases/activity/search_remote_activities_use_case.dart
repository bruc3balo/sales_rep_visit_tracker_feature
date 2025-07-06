import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class SearchRemoteActivitiesUseCase {
  final RemoteActivityRepository _remoteActivityRepository;
  final LocalActivityRepository _localActivityRepository;

  SearchRemoteActivitiesUseCase({
    required RemoteActivityRepository remoteActivityRepository,
    required LocalActivityRepository localActivityRepository,
  })  : _remoteActivityRepository = remoteActivityRepository,
        _localActivityRepository = localActivityRepository;

  Future<TaskResult<List<Activity>>> execute({
    String? likeDescription,
    required int page,
    required int pageSize,
  }) async {
    AppLog.I.i(
      "SearchRemoteActivitiesUseCase",
      "Searching remote activities ${likeDescription != null ? "with '$likeDescription'" : ""} (page: $page, size: $pageSize)",
    );

    var searchResult = await _remoteActivityRepository.getActivities(
      page: page,
      pageSize: pageSize,
      likeDescription: likeDescription,
    );

    if (searchResult is SuccessResult<List<Activity>>) {
      AppLog.I.i("SearchRemoteActivitiesUseCase", "Found ${searchResult.data.length} remote activities. Caching locally...");
      _localActivityRepository.setLocalActivities(
        activities: searchResult.data,
      );
    } else if (searchResult is ErrorResult<List<Activity>>) {
      AppLog.I.e(
        "SearchRemoteActivitiesUseCase",
        "Failed to fetch remote activities: ${searchResult.error}",
        trace: searchResult.trace,
      );
    }

    return searchResult;
  }
}