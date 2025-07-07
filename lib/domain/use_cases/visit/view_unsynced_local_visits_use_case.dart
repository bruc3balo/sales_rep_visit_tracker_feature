import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/model_mapper.dart';

class ViewUnsyncedLocalVisitsUseCase {
  final LocalUnsyncedVisitRepository _localUnsyncedVisitRepository;
  final LocalActivityRepository _localActivityRepository;
  final LocalCustomerRepository _localCustomerRepository;

  static const _tag = 'ViewUnsyncedLocalVisitsUseCase';


  Stream<UnsyncedVisitAggregate> get onUpdatedLocalVisitStream async* {
    await for (final v in _localUnsyncedVisitRepository.unsyncedVisitUpdatedStream) {
      if (v == null) continue;
      final result = await resolveVisit([v]);
      for(var r in result) {
        yield r;
      }
    }
  }

  ViewUnsyncedLocalVisitsUseCase({
    required LocalUnsyncedVisitRepository localUnsyncedVisitRepository,
    required LocalActivityRepository localActivityRepository,
    required LocalCustomerRepository localCustomerRepository,
  })  : _localUnsyncedVisitRepository = localUnsyncedVisitRepository,
        _localActivityRepository = localActivityRepository,
        _localCustomerRepository = localCustomerRepository;

  Future<TaskResult<List<UnsyncedVisitAggregate>>> execute({
    required int page,
    required int pageSize,
  }) async {
    AppLog.I.i(_tag, 'Fetching unsynced visits (page: $page, size: $pageSize)');
    var localResult = await _localUnsyncedVisitRepository.getUnsyncedVisits(
      page: page,
      pageSize: pageSize,
    );

    switch (localResult) {
      case ErrorResult<List<UnSyncedLocalVisit>>():
        AppLog.I.e(
          _tag,
          'Failed to fetch unsynced visits',
          error: localResult.error,
          trace: localResult.trace,
        );
        return ErrorResult(
          error: localResult.error,
          trace: localResult.trace,
          failure: localResult.failure,
        );

      case SuccessResult<List<UnSyncedLocalVisit>>():
        AppLog.I.i(_tag, 'Fetched ${localResult.data.length} unsynced visits');

        var visitAggregate = await resolveVisit(localResult.data);
        AppLog.I.i(_tag, 'Prepared ${visitAggregate.length} UnsyncedVisitAggregates');
        return SuccessResult(
          data: visitAggregate,
          message: "${visitAggregate.length} unsynced visits found",
        );
    }
  }


  Future<List<UnsyncedVisitAggregate>> resolveVisit(List<UnSyncedLocalVisit> data) async {
    final Map<int, Customer> resolvedCustomerMap = {};
    final Map<int, Activity> resolvedActivityMap = {};

    var customerIdsToRevolve = data.map((e) => e.customerIdVisited).toList();
    var customerIdResult = await _localCustomerRepository.getLocalCustomersByIds(
      customerIds: customerIdsToRevolve,
    );

    if (customerIdResult is SuccessResult<Map<int, Customer>>) {
      resolvedCustomerMap.addAll(customerIdResult.data);
      AppLog.I.i(_tag, 'Resolved ${resolvedCustomerMap.length} customers');
    } else {
      AppLog.I.w(_tag, 'Failed to resolve customer references');
    }

    var resolveActivitiesFuture = data.expand((e) => e.activityIdsDone).toList();
    var activityIdResult = await _localActivityRepository.getLocalActivities(
      activityIds: resolveActivitiesFuture,
    );

    if (activityIdResult is SuccessResult<Map<int, Activity>>) {
      resolvedActivityMap.addAll(activityIdResult.data);
      AppLog.I.i(_tag, 'Resolved ${resolvedActivityMap.length} activities');
    } else {
      AppLog.I.w(_tag, 'Failed to resolve activity references');
    }

    return data.map((v) {
      var resolvedVActivities = v.activityIdsDone
          .where((a) => resolvedActivityMap.containsKey(a))
          .map((a) => resolvedActivityMap[a]!);

      var customer = resolvedCustomerMap[v.customerIdVisited];
      var customerRef = customer?.toRef;

      return UnsyncedVisitAggregate(
        key: v.key,
        hash: LocalVisitHash(value: v.hash),
        visitDate: v.visitDate,
        status: VisitStatus.findByCapitalizedString(v.status)!,
        location: v.location,
        notes: v.notes,
        activityMap: {
          for (var a in resolvedVActivities) a.id: a.toRef
        },
        createdAt: v.createdAt,
        customer: customerRef,
      );
    }).toList();
  }
}