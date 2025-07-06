import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_visit_statistics_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_visit_statistics_crud.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class HiveLocalVisitStatisticsRepository extends LocalVisitStatisticsRepository {
  final LocalVisitStatisticsCrud _statisticsCrud;
  static const _tag = "HiveLocalVisitStatisticsRepository";

  HiveLocalVisitStatisticsRepository({
    required LocalVisitStatisticsCrud statisticsCrud,
  }) : _statisticsCrud = statisticsCrud;

  @override
  Future<TaskResult<VisitStatisticsModel?>> fetchLocalStatistics() async {
    AppLog.I.i(_tag, "fetchLocalStatistics()");
    var results = await _statisticsCrud.getStatistics();
    switch (results) {
      case ErrorResult<LocalVisitStatistics?>():
        AppLog.I.e(_tag, "Failed to fetch statistics", error: results.error, trace: results.trace);
        return ErrorResult(
          error: results.error,
          failure: results.failure,
          trace: results.trace,
        );
      case SuccessResult<LocalVisitStatistics?>():
        AppLog.I.i(_tag, "Fetched statistics successfully");
        return SuccessResult(
          data: results.data?.toDomain,
          message: results.message,
        );
    }
  }

  @override
  Future<TaskResult<void>> setLocalStatistics({
    required VisitStatisticsModel statistics,
  }) async {
    AppLog.I.i(_tag, "setLocalStatistics(stats: $statistics)");
    return await _statisticsCrud.setStatistics(stats: statistics.toLocal);
  }
}