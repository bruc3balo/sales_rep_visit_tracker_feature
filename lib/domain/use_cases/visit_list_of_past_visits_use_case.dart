import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class VisitListOfPastVisitsUseCase {
  final VisitRepository _visitRepository;
  final ActivityRepository _activityRepository;

  VisitListOfPastVisitsUseCase({
    required VisitRepository visitRepository,
    required ActivityRepository activityRepository,
  })  : _visitRepository = visitRepository,
        _activityRepository = activityRepository;

  Future<TaskResult<List<VisitAggregate>>> execute({
    required int page,
    required int pageSize,
    DateTime? fromDateInclusive,
    DateTime? toDateInclusive,
    List<int>? activityIdsDone,
    VisitStatus? status,
    String? order,
  }) async {
    var result = await _visitRepository.getVisits(
      page: page,
      pageSize: pageSize,
      fromDateInclusive: fromDateInclusive,
      toDateInclusive: toDateInclusive,
      activityIdsDone: activityIdsDone,
      status: status,
      order: order,
    );

    switch (result) {
      case ErrorResult<List<Visit>>():
        return ErrorResult(
          error: result.error,
          trace: result.trace,
        );
      case SuccessResult<List<Visit>>():
        var visits = result.data;

        var ids = visits.expand((e) => e.activitiesDone).toList();
        var getActivitiesResponse = await _activityRepository.getActivities(
          page: 0,
          pageSize: 100,
          ids: ids,
        );

        switch (getActivitiesResponse) {
          case ErrorResult<List<Activity>>():
            return ErrorResult(
              error: getActivitiesResponse.error,
              trace: getActivitiesResponse.trace,
            );
          case SuccessResult<List<Activity>>():
            var activityMap = {for (var a in getActivitiesResponse.data) a.id: a};

            var data = visits.map((v) {
              return VisitAggregate(
                visit: v,
                activityMap: {
                  for (var aId in v.activitiesDone)
                    if (activityMap.containsKey(aId)) aId: activityMap[aId]!
                },
              );
            }).toList();

            return SuccessResult(
              message: "${data.length} visits found",
              data: data,
            );
        }
    }
  }
}
