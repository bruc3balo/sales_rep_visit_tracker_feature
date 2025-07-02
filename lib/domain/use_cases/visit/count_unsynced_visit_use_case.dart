import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class CountUnsyncedVisitsUseCase {
  final LocalUnsyncedVisitRepository _localUnsyncedVisitRepository;

  CountUnsyncedVisitsUseCase({
    required LocalUnsyncedVisitRepository localUnsyncedVisitRepository
  }) : _localUnsyncedVisitRepository = localUnsyncedVisitRepository;

 

  Future<TaskResult<int>> execute() async {
    return await _localUnsyncedVisitRepository.countUnsyncedVisits();
  }

}
