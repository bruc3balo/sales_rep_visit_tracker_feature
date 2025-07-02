import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class SearchLocalActivitiesUseCase {

  final LocalActivityRepository _localActivityRepository;

  SearchLocalActivitiesUseCase({
    required LocalActivityRepository localActivityRepository,
  }) : _localActivityRepository = localActivityRepository;



  Future<TaskResult<List<Activity>>> execute({
    required String likeDescription,
    required int page,
    required int pageSize,
}) async {

    var searchResult = await _localActivityRepository.searchLocalActivities(
      page: page,
      pageSize: pageSize,
      likeDescription: likeDescription,
    );

    switch(searchResult) {
      case ErrorResult<List<LocalActivity>>():
        return ErrorResult(
          error: searchResult.error,
          trace: searchResult.trace,
          failure: searchResult.failure,
        );

      case SuccessResult<List<LocalActivity>>():
        var data = searchResult.data.map((d) => d.toDomain).toList();
        return SuccessResult(
          data: data,
          message: "${data.length} local results found"
        );
    }
  }

}