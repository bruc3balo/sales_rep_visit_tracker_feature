import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_visit_statistics_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class GetRemoteDailyVisitStatisticsUseCase {
  final RemoteVisitRepository _visitRepository;

  GetRemoteDailyVisitStatisticsUseCase({
    required RemoteVisitRepository visitRepository,
  }) : _visitRepository = visitRepository;

  Future<TaskResult<TodayStatistics>> execute() async {
    AppLog.I.i("GetRemoteDailyVisitStatisticsUseCase", "Fetching today's visit statistics...");
    int page = 0;
    final int pageSize = 1000;

    var visitList = <Visit>[];
    bool hasNextPage = true;

    do {
      AppLog.I.d("GetRemoteDailyVisitStatisticsUseCase", "Fetching page $page");
      var visitResponse = await _visitRepository.getVisits(
        page: page++,
        pageSize: pageSize,
        fromDateInclusive: DateTime.now().copyWith(hour: 0),
        toDateInclusive: DateTime.now().copyWith(hour: 24),
      );

      switch (visitResponse) {
        case ErrorResult<List<Visit>>():
          AppLog.I.e("GetRemoteDailyVisitStatisticsUseCase", "Failed to fetch visits", trace: visitResponse.trace);
          return ErrorResult(
            error: visitResponse.error,
            trace: visitResponse.trace,
          );
        case SuccessResult<List<Visit>>():
          AppLog.I.d("GetRemoteDailyVisitStatisticsUseCase", "Fetched ${visitResponse.data.length} visits");
          visitList.addAll(visitResponse.data);
          hasNextPage = visitResponse.data.length >= pageSize;
          break;
      }
    } while (hasNextPage);

    AppLog.I.i("GetRemoteDailyVisitStatisticsUseCase", "Finished fetching. Total visits: ${visitList.length}");
    return SuccessResult(
      data: TodayStatistics(visits: visitList),
      message: "${visitList.length} visits today",
    );
  }
}