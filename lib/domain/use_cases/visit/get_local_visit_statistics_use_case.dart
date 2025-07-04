import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_visit_statistics_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class GetLocalVisitStatisticsUseCase {
  final LocalVisitStatisticsRepository _localVisitStatisticsRepository;

  GetLocalVisitStatisticsUseCase({
    required LocalVisitStatisticsRepository localVisitStatisticsRepository,
  }) : _localVisitStatisticsRepository = localVisitStatisticsRepository;

  Future<TaskResult<VisitStatisticsModel?>> execute() async {
    return await _localVisitStatisticsRepository.fetchLocalStatistics();
  }
}
