import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

abstract class LocalVisitStatisticsRepository {
  Future<TaskResult<VisitStatisticsModel?>> fetchLocalStatistics();

  Future<TaskResult<void>> setLocalStatistics({
    required VisitStatisticsModel statistics,
  });
}
