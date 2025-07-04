import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

abstract class LocalVisitStatisticsCrud {

  Future<TaskResult<void>> setStatistics({
    required LocalVisitStatistics stats,
  });

  Future<TaskResult<LocalVisitStatistics?>> getStatistics();
}
