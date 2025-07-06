import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class SearchLocalActivitiesUseCase {
  final LocalActivityRepository _localActivityRepository;

  SearchLocalActivitiesUseCase({
    required LocalActivityRepository localActivityRepository,
  }) : _localActivityRepository = localActivityRepository;

  Future<TaskResult<List<Activity>>> execute({
    String? likeDescription,
    required int page,
    required int pageSize,
  }) async {
    AppLog.I.i(
      "SearchLocalActivitiesUseCase",
      likeDescription == null
          ? "Fetching local activities (page: $page, size: $pageSize)"
          : "Searching local activities with filter: '$likeDescription' (page: $page, size: $pageSize)",
    );

    if (likeDescription == null) {
      final result = await _localActivityRepository.fetchLocalActivities(
        page: page,
        pageSize: pageSize,
      );
      AppLog.I.i("SearchLocalActivitiesUseCase", "Fetch result: $result");
      return result;
    }

    final result = await _localActivityRepository.searchLocalActivities(
      page: page,
      pageSize: pageSize,
      likeDescription: likeDescription,
    );
    AppLog.I.i("SearchLocalActivitiesUseCase", "Search result: $result");
    return result;
  }
}