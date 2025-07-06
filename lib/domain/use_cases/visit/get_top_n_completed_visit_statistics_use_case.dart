import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:collection/collection.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

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
    AppLog.I.i("GetTopCustomersVisitStatisticsUseCase", "Fetching top $noOfCustomers customers by completed visits");

    int page = 0;
    final int pageSize = 500;

    var visitList = <Visit>[];
    bool hasNextPage = true;

    late TopCustomerStatistics customerStatistics;
    late TopActivityStatistics activityStatistics;

    do {
      AppLog.I.d("GetTopCustomersVisitStatisticsUseCase", "Fetching visits, page: $page");
      var visitResponse = await _visitRepository.getVisits(
        page: page++,
        pageSize: pageSize,
        status: VisitStatus.completed,
      );

      switch (visitResponse) {
        case ErrorResult<List<Visit>>():
          AppLog.I.e(
            "GetTopCustomersVisitStatisticsUseCase",
            "Failed to fetch visits",
            trace: visitResponse.trace,
          );
          return ErrorResult(
            error: visitResponse.error,
            trace: visitResponse.trace,
          );
        case SuccessResult<List<Visit>>():
          AppLog.I.d(
            "GetTopCustomersVisitStatisticsUseCase",
            "Fetched ${visitResponse.data.length} visits",
          );
          visitList.addAll(visitResponse.data);
          hasNextPage = visitResponse.data.length >= pageSize;
          break;
      }
    } while (hasNextPage);

    final customerVisitsMap = groupBy(visitList, (v) => v.customerId);
    final sortedGroups = customerVisitsMap.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    final topNCustomers = sortedGroups.take(noOfCustomers).map((e) => e.key).toList();
    AppLog.I.d("GetTopCustomersVisitStatisticsUseCase", "Top customer IDs: $topNCustomers");

    var customerResult = await _remoteCustomerRepository.getCustomers(
      ids: topNCustomers,
      page: 0,
      pageSize: noOfCustomers,
    );

    switch (customerResult) {
      case ErrorResult<List<Customer>>():
        AppLog.I.e(
          "GetTopCustomersVisitStatisticsUseCase",
          "Failed to fetch customer details",
          trace: customerResult.trace,
        );
        return ErrorResult(
          error: customerResult.error,
          trace: customerResult.trace,
        );
      case SuccessResult<List<Customer>>():
        AppLog.I.d(
          "GetTopCustomersVisitStatisticsUseCase",
          "Fetched ${customerResult.data.length} customer records",
        );
        var customerMap = {for (var c in customerResult.data) c.id: c};
        customerStatistics = TopCustomerStatistics(
          statistics: {for (var a in topNCustomers) customerMap[a]!: (customerVisitsMap[a]?.length ?? 0)},
        );
    }

    final visitsByActivity = groupBy(
      visitList.expand((v) => v.activitiesDone.map((id) => MapEntry(id, v))),
          (entry) => entry.key,
    ).map((k, v) => MapEntry(k, v.map((e) => e.value).toList()));

    AppLog.I.d("GetTopCustomersVisitStatisticsUseCase", "Activity IDs to fetch: ${visitsByActivity.keys}");

    var activitiesResult = await _remoteActivityRepository.getActivities(
      ids: visitsByActivity.keys.toList(),
      page: 0,
      pageSize: visitsByActivity.keys.length,
    );

    switch (activitiesResult) {
      case ErrorResult<List<Activity>>():
        AppLog.I.e(
          "GetTopCustomersVisitStatisticsUseCase",
          "Failed to fetch activity details",
          trace: activitiesResult.trace,
        );
        return ErrorResult(
          error: activitiesResult.error,
          trace: activitiesResult.trace,
        );
      case SuccessResult<List<Activity>>():
        AppLog.I.d(
          "GetTopCustomersVisitStatisticsUseCase",
          "Fetched ${activitiesResult.data.length} activity records",
        );
        var activityMap = {for (var a in activitiesResult.data) a.id: a};
        activityStatistics = TopActivityStatistics(
          statistics: {
            for (var a in visitsByActivity.entries.where((a) => activityMap.containsKey(a.key)))
              activityMap[a.key]!: a.value
          },
        );
        break;
    }

    var data = CompletedVisitStatistics(
      customer: customerStatistics,
      activity: activityStatistics,
    );

    AppLog.I.i(
      "GetTopCustomersVisitStatisticsUseCase",
      "Successfully compiled statistics for top $noOfCustomers customers",
    );

    return SuccessResult(
      data: data,
      message: "Top $noOfCustomers completed statistics fetched successfully",
    );
  }
}