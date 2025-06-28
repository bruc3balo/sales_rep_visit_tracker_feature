import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

abstract class VisitRepository {

  Future<TaskResult<void>> createVisit({
    required int customerIdVisited,
    required DateTime visitDate,
    required VisitStatus status,
    required String location,
    required String notes,
    required List<int> activityIdsDone,
  });

  Future<TaskResult<List<Visit>>> getVisits({
    int? customerId,
    DateTime? fromDateInclusive,
    DateTime? toDateInclusive,
    List<int>? activityIdsDone,
    VisitStatus? status,
    required int page,
    required int pageSize,
    String? order,
  });

  Future<TaskResult<Visit>> updateVisit({
    required int visitId,
    int? customerId,
    DateTime? visitDate,
    VisitStatus? status,
    String? location,
    String? notes,
    List<int>? activityIdsDone,
  });

  Future<TaskResult<void>> deleteVisitById({required int visitId});
}