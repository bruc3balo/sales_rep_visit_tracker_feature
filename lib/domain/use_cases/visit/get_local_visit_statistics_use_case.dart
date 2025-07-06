import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_visit_statistics_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class GetLocalVisitStatisticsUseCase {
  final LocalVisitStatisticsRepository _localVisitStatisticsRepository;

  GetLocalVisitStatisticsUseCase({
    required LocalVisitStatisticsRepository localVisitStatisticsRepository,
  }) : _localVisitStatisticsRepository = localVisitStatisticsRepository;

  Future<TaskResult<VisitStatisticsModel?>> execute() async {
    AppLog.I.i("GetLocalVisitStatisticsUseCase", "Fetching local visit statistics...");
    final result = await _localVisitStatisticsRepository.fetchLocalStatistics();

    switch (result) {
      case ErrorResult<VisitStatisticsModel?>():
        AppLog.I.e("GetLocalVisitStatisticsUseCase", "Failed to fetch local statistics", trace: result.trace);
        return result;
      case SuccessResult<VisitStatisticsModel?>():
        AppLog.I.i("GetLocalVisitStatisticsUseCase", "Successfully fetched local statistics at ${result.data?.calculatedAt}");
        return result;
    }
  }
}