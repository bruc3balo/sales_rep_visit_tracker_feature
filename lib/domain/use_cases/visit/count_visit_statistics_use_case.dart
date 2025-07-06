import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_visit_statistics_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class CountVisitStatisticsUseCase {
  final RemoteVisitRepository _visitRepository;
  final LocalVisitStatisticsRepository _localVisitStatisticsRepository;

  CountVisitStatisticsUseCase({
    required RemoteVisitRepository visitRepository,
    required LocalVisitStatisticsRepository localVisitStatisticsRepository,
  })  : _visitRepository = visitRepository,
        _localVisitStatisticsRepository = localVisitStatisticsRepository;

  Future<TaskResult<VisitStatisticsModel>> execute() async {
    AppLog.I.i("CountVisitStatisticsUseCase", "Start calculating visit statistics");
    final Map<VisitStatus, int> statisticsMap = {};

    int page = 0;
    final int pageSize = 500;
    var visitList = <Visit>[];

    do {
      AppLog.I.i("CountVisitStatisticsUseCase", "Fetching page $page...");
      var visitResponse = await _visitRepository.getVisits(
        page: page++,
        pageSize: pageSize,
      );

      switch (visitResponse) {
        case ErrorResult<List<Visit>>():
          AppLog.I.e("CountVisitStatisticsUseCase", "Failed fetching visits on page ${page - 1}: ${visitResponse.error}", trace: visitResponse.trace);
          return ErrorResult(
            error: visitResponse.error,
            trace: visitResponse.trace,
          );
        case SuccessResult<List<Visit>>():
          AppLog.I.i("CountVisitStatisticsUseCase", "Fetched ${visitResponse.data.length} visits");
          visitList = visitResponse.data;
          for (var v in visitList) {
            var s = VisitStatus.findByCapitalizedString(v.status);
            if (s == null) continue;
            statisticsMap.update(s, (s) => s + 1, ifAbsent: () => 1);
          }
      }
    } while (visitList.isNotEmpty);

    var statistics = VisitStatisticsModel(
      data: statisticsMap,
      calculatedAt: DateTime.now(),
    );

    _localVisitStatisticsRepository.setLocalStatistics(statistics: statistics);
    AppLog.I.i("CountVisitStatisticsUseCase", "Completed. Statistics: $statisticsMap");

    return SuccessResult(
      message: "Statistics fetched with $page pages",
      data: statistics,
    );
  }
}