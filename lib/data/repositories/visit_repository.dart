import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

abstract class VisitRepository {

  Future<TaskResult<Visit>> createVisit({
    required int customerIdVisited,
    required DateTime visitDate,
    required VisitStatus status,
    required String location,
    required String notes,
    required List<int> activityIdsDone,
  });

  Future<TaskResult<List<Visit>>> getCustomers({
    required int page,
    required int pageSize,
  });

  Future<TaskResult<List<Visit>>> getCustomerVisits({
    required String customerId,
    required int page,
    required int pageSize,
  });

  //TODO: Add filters for data, status, activities

  Future<TaskResult<Visit>> updateVisit({required Visit visit});

  Future<TaskResult<void>> deleteVisitById({required int visitId});
}