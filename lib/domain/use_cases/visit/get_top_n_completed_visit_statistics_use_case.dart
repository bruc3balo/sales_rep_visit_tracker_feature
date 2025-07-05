import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:collection/collection.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class GetTopCustomersVisitStatisticsUseCase {
  final RemoteVisitRepository _visitRepository;
  final RemoteCustomerRepository _remoteCustomerRepository;
  final RemoteActivityRepository _remoteActivityRepository;

  GetTopCustomersVisitStatisticsUseCase({
    required RemoteVisitRepository visitRepository,
    required RemoteCustomerRepository remoteCustomerRepository,
    required RemoteActivityRepository remoteActivityRepository,
  })  : _visitRepository = visitRepository,
        _remoteCustomerRepository = remoteCustomerRepository,
        _remoteActivityRepository = remoteActivityRepository;

  Future<TaskResult<CompletedVisitStatistics>> execute(int noOfCustomers) async {
    int page = 0;
    final int pageSize = 500;

    var visitList = <Visit>[];
    bool hasNextPage = true;

    late TopCustomerStatistics customerStatistics;
    late TopActivityStatistics activityStatistics;

    do {
      var visitResponse = await _visitRepository.getVisits(
        page: page++,
        pageSize: pageSize,
        status: VisitStatus.completed,
      );

      switch (visitResponse) {
        case ErrorResult<List<Visit>>():
          return ErrorResult(
            error: visitResponse.error,
            trace: visitResponse.trace,
          );
        case SuccessResult<List<Visit>>():
          visitList.addAll(visitResponse.data);
          hasNextPage = visitResponse.data.length >= pageSize;
          break;
      }
    } while (hasNextPage);

    final customerVisitsMap = groupBy(visitList, (v) => v.customerId);
    final sortedGroups = customerVisitsMap.entries.toList()..sort((a, b) => b.value.length.compareTo(a.value.length));

    final topNCustomers = sortedGroups.take(noOfCustomers).map((e) => e.key).toList();

    var customerResult = await _remoteCustomerRepository.getCustomers(
      ids: topNCustomers,
      page: 0,
      pageSize: noOfCustomers,
    );

    switch (customerResult) {
      case ErrorResult<List<Customer>>():
        return ErrorResult(
          error: customerResult.error,
          trace: customerResult.trace,
        );
      case SuccessResult<List<Customer>>():
        var customerMap = {for (var c in customerResult.data) c.id: c};
        customerStatistics = TopCustomerStatistics(
          statistics: {for (var a in topNCustomers) customerMap[a]!: (customerVisitsMap[a]?.length ?? 0)},
        );
    }

    final visitsByActivity = groupBy(
      visitList.expand((v) => v.activitiesDone.map((id) => MapEntry(id, v))),
      (entry) => entry.key,
    ).map((k, v) => MapEntry(k, v.map((e) => e.value).toList()));

    var activitiesResult = await _remoteActivityRepository.getActivities(
      ids: visitsByActivity.keys.toList(),
      page: 0,
      pageSize: visitsByActivity.keys.length,
    );

    switch (activitiesResult) {
      case ErrorResult<List<Activity>>():
        return ErrorResult(
          error: activitiesResult.error,
          trace: activitiesResult.trace,
        );
      case SuccessResult<List<Activity>>():
        var activityMap = {for (var a in activitiesResult.data) a.id: a};
        activityStatistics = TopActivityStatistics(
          statistics: {for (var a in visitsByActivity.entries.where((a) => activityMap.containsKey(a.key))) activityMap[a.key]!: a.value},
        );
        break;
    }

    var data = CompletedVisitStatistics(
      customer: customerStatistics,
      activity: activityStatistics,
    );

    return SuccessResult(
      data: data,
      message: "Top $noOfCustomers completed statistics fetched successfully",
    );
  }
}
