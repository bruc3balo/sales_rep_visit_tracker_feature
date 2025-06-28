import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class AddANewVisitUseCase {
  final VisitRepository _visitRepository;

  AddANewVisitUseCase({
    required VisitRepository visitRepository,
  }) : _visitRepository = visitRepository;

  Future<TaskResult<void>> execute({
    required int customerId,
    required DateTime visitDate,
    required VisitStatus status,
    required String location,
    required String notes,
    required List<int> activitiesDoneIds,
  }) async {
    return _visitRepository.createVisit(
      customerIdVisited: customerId,
      visitDate: visitDate,
      status: status,
      location: location,
      notes: notes,
      activityIdsDone: activitiesDoneIds,
    );
  }
}
