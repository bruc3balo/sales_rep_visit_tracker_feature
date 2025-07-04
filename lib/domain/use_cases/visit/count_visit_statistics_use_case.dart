import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_visit_statistics_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class CountVisitStatisticsUseCase {
  final RemoteVisitRepository _visitRepository;
  final LocalVisitStatisticsRepository _localVisitStatisticsRepository;

  CountVisitStatisticsUseCase({
    required RemoteVisitRepository visitRepository,
    required LocalVisitStatisticsRepository localVisitStatisticsRepository,
  })  : _visitRepository = visitRepository,
        _localVisitStatisticsRepository = localVisitStatisticsRepository;

  Future<TaskResult<VisitStatisticsModel>> execute() async {
    final Map<VisitStatus, int> statisticsMap = {};

    int page = 0;
    final int pageSize = 500;

    var visitList = <Visit>[];

    do {
      var visitResponse = await _visitRepository.getVisits(
        page: page++,
        pageSize: pageSize,
      );

      switch (visitResponse) {
        case ErrorResult<List<Visit>>():
          return ErrorResult(
            error: visitResponse.error,
            trace: visitResponse.trace,
          );
        case SuccessResult<List<Visit>>():
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

    //Cache statistics async
    _localVisitStatisticsRepository.setLocalStatistics(statistics: statistics);

    return SuccessResult(
      message: "Statistics fetched with $page pages",
      data: statistics,
    );
  }
}
