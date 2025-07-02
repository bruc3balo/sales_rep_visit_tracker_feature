import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class VisitListOfPastVisitsUseCase {
  final RemoteVisitRepository _visitRepository;
  final RemoteActivityRepository _activityRepository;
  final RemoteCustomerRepository _customerRepository;

  VisitListOfPastVisitsUseCase({
    required RemoteVisitRepository visitRepository,
    required RemoteActivityRepository activityRepository,
    required RemoteCustomerRepository customerRepository,
  })  : _visitRepository = visitRepository,
        _activityRepository = activityRepository,
        _customerRepository = customerRepository;

  Future<TaskResult<List<VisitAggregate>>> execute({
    required int page,
    required int pageSize,
    DateTime? fromDateInclusive,
    DateTime? toDateInclusive,
    List<int>? activityIdsDone,
    VisitStatus? status,
    String? order,
  }) async {
    var result = await _visitRepository.getVisits(
      page: page,
      pageSize: pageSize,
      fromDateInclusive: fromDateInclusive,
      toDateInclusive: toDateInclusive,
      activityIdsDone: activityIdsDone,
      status: status,
      order: order,
    );

    switch (result) {
      case ErrorResult<List<Visit>>():
        return ErrorResult(
          error: result.error,
          trace: result.trace,
        );
      case SuccessResult<List<Visit>>():
        var visits = result.data;

        var activityIds = visits.expand((e) => e.activitiesDone).toSet().toList();
        var getActivitiesResponse = await _activityRepository.getActivities(
          page: 0,
          pageSize: pageSize * 100,
          ids: activityIds,
        );

        switch (getActivitiesResponse) {
          case ErrorResult<List<Activity>>():
            return ErrorResult(
              error: getActivitiesResponse.error,
              trace: getActivitiesResponse.trace,
            );
          case SuccessResult<List<Activity>>():
            var activityMap = {for (var a in getActivitiesResponse.data) a.id: a};

            var customerIds = visits.map((e) => e.customerId).toSet().toList();

            var getCustomersResponse = await _customerRepository.getCustomers(
              page: 0,
              pageSize: pageSize,
              ids: customerIds,
            );

            switch(getCustomersResponse) {

              case ErrorResult<List<Customer>>():
                return ErrorResult(
                  error: getCustomersResponse.error,
                  trace: getCustomersResponse.trace,
                );
              case SuccessResult<List<Customer>>():

                var customerMap = {for (var a in getCustomersResponse.data) a.id: a};

                var data = visits.map((v) {
                  return VisitAggregate(
                    visit: v,
                    activityMap: {
                      for (var aId in v.activitiesDone)
                        if (activityMap.containsKey(aId)) aId: activityMap[aId]!
                    },
                    customer: customerMap[v.customerId],
                  );
                }).toList();

                return SuccessResult(
                  message: "${data.length} visits found",
                  data: data,
                );
            }
        }
    }
  }
}
