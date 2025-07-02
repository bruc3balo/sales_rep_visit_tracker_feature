import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class ViewLocalActivitiesUseCase {

  final LocalActivityRepository _localActivityRepository;

  ViewLocalActivitiesUseCase({
    required LocalActivityRepository localActivityRepository
  }) : _localActivityRepository = localActivityRepository;


  Future<TaskResult<List<Activity>>> execute({
    required int page,
    required int pageSize,
}) async {
    var localResult = await _localActivityRepository.fetchLocalActivities(
      page: page,
      pageSize: pageSize,
    );

    switch(localResult) {

      case ErrorResult<List<LocalActivity>>():
        return ErrorResult(
            error: localResult.error,
            trace: localResult.trace,
            failure: localResult.failure,
        );
      case SuccessResult<List<LocalActivity>>():
        var data = localResult.data.map((e) => e.toDomain).toList();
        return SuccessResult(data: data, message: "${data.length} offline activities loaded");
    }
  }

}