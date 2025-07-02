import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class ViewUnsyncedLocalVisitsUseCase {

  final LocalUnsyncedVisitRepository _localUnsyncedVisitRepository;
  final LocalActivityRepository _localActivityRepository;
  final LocalCustomerRepository _localCustomerRepository;

  ViewUnsyncedLocalVisitsUseCase({
    required LocalUnsyncedVisitRepository localUnsyncedVisitRepository,
    required LocalActivityRepository localActivityRepository,
    required LocalCustomerRepository localCustomerRepository
  }) : _localUnsyncedVisitRepository = localUnsyncedVisitRepository,
        _localActivityRepository = localActivityRepository,
        _localCustomerRepository = localCustomerRepository;


  Future<TaskResult<List<UnsyncedVisitAggregate>>> execute({
    required int page,
    required int pageSize,
  }) async {

    var localResult = await _localUnsyncedVisitRepository.getUnsyncedVisits(
        page: page,
        pageSize: pageSize
    );

    switch(localResult) {

      case ErrorResult<List<UnSyncedLocalVisit>>():
        return ErrorResult(
            error: localResult.error,
            trace: localResult.trace,
            failure: localResult.failure,
        );
      case SuccessResult<List<UnSyncedLocalVisit>>():

        final Map<int, LocalCustomer> resolvedCustomerMap = {};
        final Map<int, LocalActivity> resolvedActivityMap = {};

        //Customers
        var customerIdsToRevolve = localResult.data.map((e) => e.customerIdVisited).toList();
        var customerIdResult = await _localCustomerRepository.getLocalCustomersByIds(
            customerIds: customerIdsToRevolve
        );

       if (customerIdResult is SuccessResult<Map<int, LocalCustomer>>) {
          resolvedCustomerMap.addAll(customerIdResult.data);
        }

        //Activities
        var resolveActivitiesFuture = localResult.data.expand((e) => e.activityIdsDone).toList();
        var activityIdResult = await _localActivityRepository.getLocalActivities(
            activityIds: resolveActivitiesFuture,
        );

       if (activityIdResult is SuccessResult<Map<int, LocalActivity>>) {
          resolvedActivityMap.addAll(activityIdResult.data);
        }

        // Aggregate
        var visitAggregate = localResult.data.map((v) {

          var resolvedVActivities = v.activityIdsDone
              .where((a) => resolvedActivityMap.containsKey(a))
              .map((a) => resolvedActivityMap[a]!);


          var customer = resolvedCustomerMap[v.customerIdVisited];

          var customerRef = customer != null
          ? CustomerRef(customer.id, customer.name) : null;

          return UnsyncedVisitAggregate(
            visitDate: v.visitDate,
            status: VisitStatus.findByCapitalizedString(v.status)!,
            location: v.location,
            notes: v.notes,
            activityMap: {
              for(var a in resolvedVActivities) a.id : ActivityRef(a.id, a.description)
            },
            createdAt: v.createdAt,
            customer: customerRef,
          );

        }).toList();
        return SuccessResult(data: visitAggregate, message: "${visitAggregate.length} unsynced visits found");
    }
  }

}