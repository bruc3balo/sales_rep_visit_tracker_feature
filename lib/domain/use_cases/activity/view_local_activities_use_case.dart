import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class ViewLocalActivitiesUseCase {
  final LocalActivityRepository _localActivityRepository;

  ViewLocalActivitiesUseCase({
    required LocalActivityRepository localActivityRepository,
  }) : _localActivityRepository = localActivityRepository;


  Stream<Activity> get activityUpdateStream => _localActivityRepository.onActivitySetStream;

  Future<TaskResult<List<Activity>>> execute({
    required int page,
    required int pageSize,
  }) async {
    AppLog.I.i(
      "ViewLocalActivitiesUseCase",
      "Fetching local activities page=$page pageSize=$pageSize",
    );

    var result = await _localActivityRepository.fetchLocalActivities(
      page: page,
      pageSize: pageSize,
    );

    switch (result) {
      case ErrorResult<List<Activity>>():
        AppLog.I.e(
          "ViewLocalActivitiesUseCase",
          "Failed to fetch local activities: ${result.error}",
          trace: result.trace,
        );
        break;
      case SuccessResult<List<Activity>>():
        AppLog.I.i(
          "ViewLocalActivitiesUseCase",
          "Fetched ${result.data.length} local activities",
        );
        break;
    }

    return result;
  }
}