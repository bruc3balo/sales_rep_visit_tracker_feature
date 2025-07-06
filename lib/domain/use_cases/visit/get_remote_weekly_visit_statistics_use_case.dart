import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_visit_statistics_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class GetRemoteWeeklyVisitStatisticsUseCase {
  final RemoteVisitRepository _visitRepository;

  GetRemoteWeeklyVisitStatisticsUseCase({
    required RemoteVisitRepository visitRepository,
  }) : _visitRepository = visitRepository;

  Future<TaskResult<Last7DaysStatistics>> execute() async {
    AppLog.I.i("GetRemoteWeeklyVisitStatisticsUseCase", "Fetching weekly visit statistics...");
    int page = 0;
    final int pageSize = 500;

    var visitList = <Visit>[];
    bool hasNextPage = true;

    do {
      AppLog.I.d("GetRemoteWeeklyVisitStatisticsUseCase", "Fetching page $page");
      var visitResponse = await _visitRepository.getVisits(
        page: page++,
        pageSize: pageSize,
        fromDateInclusive: DateTime.now().subtract(const Duration(days: 7)),
        toDateInclusive: DateTime.now(),
      );

      switch (visitResponse) {
        case ErrorResult<List<Visit>>():
          AppLog.I.e(
            "GetRemoteWeeklyVisitStatisticsUseCase",
            "Failed to fetch visits",
            trace: visitResponse.trace,
          );
          return ErrorResult(
            error: visitResponse.error,
            trace: visitResponse.trace,
          );
        case SuccessResult<List<Visit>>():
          AppLog.I.d(
            "GetRemoteWeeklyVisitStatisticsUseCase",
            "Fetched ${visitResponse.data.length} visits",
          );
          visitList.addAll(visitResponse.data);
          hasNextPage = visitResponse.data.length >= pageSize;
          break;
      }
    } while (hasNextPage);

    AppLog.I.i(
      "GetRemoteWeeklyVisitStatisticsUseCase",
      "Finished fetching. Total visits: ${visitList.length}",
    );

    return SuccessResult(
      data: Last7DaysStatistics(visits: visitList),
      message: "${visitList.length} visits since last week",
    );
  }
}