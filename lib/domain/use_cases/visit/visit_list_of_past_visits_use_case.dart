import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class VisitListOfPastVisitsUseCase {
  final RemoteVisitRepository _visitRepository;
  final RemoteActivityRepository _activityRepository;
  final RemoteCustomerRepository _customerRepository;

  static const _tag = 'VisitListOfPastVisitsUseCase';

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
    int? customerId,
    DateTime? fromDateInclusive,
    DateTime? toDateInclusive,
    List<int>? activityIdsDone,
    VisitStatus? status,
    String? order,
  }) async {
    AppLog.I.i(_tag, 'Fetching visits: page=$page, size=$pageSize, customer=$customerId');

    var result = await _visitRepository.getVisits(
      customerId: customerId,
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
        AppLog.I.e(_tag, 'Error fetching visits', error: result.error, trace: result.trace);
        return ErrorResult(
          error: result.error,
          trace: result.trace,
          failure: result.failure,
        );

      case SuccessResult<List<Visit>>():
        var visits = result.data;
        AppLog.I.i(_tag, '${visits.length} visits fetched');

        var activityIds = visits.expand((e) => e.activitiesDone).toSet().toList();
        AppLog.I.i(_tag, 'Resolving ${activityIds.length} activity IDs');

        var getActivitiesResponse = await _activityRepository.getActivities(
          page: 0,
          pageSize: pageSize * 100,
          ids: activityIds,
        );

        switch (getActivitiesResponse) {
          case ErrorResult<List<Activity>>():
            AppLog.I.e(_tag, 'Error resolving activities', error: getActivitiesResponse.error, trace: getActivitiesResponse.trace);
            return ErrorResult(
              error: getActivitiesResponse.error,
              trace: getActivitiesResponse.trace,
            );

          case SuccessResult<List<Activity>>():
            var activityMap = {
              for (var a in getActivitiesResponse.data) a.id: a
            };
            AppLog.I.i(_tag, '${activityMap.length} activities resolved');

            var customerIds = visits.map((e) => e.customerId).toSet().toList();
            AppLog.I.i(_tag, 'Resolving ${customerIds.length} customer IDs');

            var getCustomersResponse = await _customerRepository.getCustomers(
              page: 0,
              pageSize: pageSize,
              ids: customerIds,
            );

            switch (getCustomersResponse) {
              case ErrorResult<List<Customer>>():
                AppLog.I.e(_tag, 'Error resolving customers', error: getCustomersResponse.error, trace: getCustomersResponse.trace);
                return ErrorResult(
                  error: getCustomersResponse.error,
                  trace: getCustomersResponse.trace,
                );

              case SuccessResult<List<Customer>>():
                var customerMap = {
                  for (var a in getCustomersResponse.data) a.id: a
                };
                AppLog.I.i(_tag, '${customerMap.length} customers resolved');

                var data = visits.map((v) {
                  var resolvedActivities = {
                    for (var aId in v.activitiesDone)
                      if (activityMap.containsKey(aId)) aId: activityMap[aId]!
                  };

                  if (resolvedActivities.length != v.activitiesDone.length) {
                    AppLog.I.w(_tag, 'Some activities not resolved for visit ID ${v.id}');
                  }

                  return VisitAggregate(
                    visit: v,
                    activityMap: resolvedActivities,
                    customer: customerMap[v.customerId],
                  );
                }).toList();

                AppLog.I.i(_tag, '${data.length} VisitAggregates prepared');
                return SuccessResult(
                  message: "${data.length} visits found",
                  data: data,
                );
            }
        }
    }
  }
}