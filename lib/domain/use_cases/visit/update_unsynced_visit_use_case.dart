import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/sync_status.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class UpdateUnsyncedVisitUseCase {
  final LocalUnsyncedVisitRepository _localUnsyncedVisitRepository;
  final LocalActivityRepository _localActivityRepository;
  final LocalCustomerRepository _localCustomerRepository;

  UpdateUnsyncedVisitUseCase({
    required LocalUnsyncedVisitRepository localUnsyncedVisitRepository,
    required LocalActivityRepository localActivityRepository,
    required LocalCustomerRepository localCustomerRepository,
  })  : _localUnsyncedVisitRepository = localUnsyncedVisitRepository,
        _localActivityRepository = localActivityRepository,
        _localCustomerRepository = localCustomerRepository;

  Future<TaskResult<UnsyncedVisitAggregate>> execute({
    required LocalVisitHash hash,
    DateTime? visitDate,
    VisitStatus? status,
    String? location,
    String? notes,
    List<int>? activityIdsDone,
    int? customerIdVisited,
  }) async {
    var visitStatus = VisitSyncStatus();
    if (visitStatus.isSyncing) return ErrorResult(error: "Cannot update while syncing");

    var unsyncedVisitFound = await _localUnsyncedVisitRepository.findByHash(
      hash: hash,
    );

    switch (unsyncedVisitFound) {
      case ErrorResult<UnSyncedLocalVisit?>():
        return ErrorResult(
          error: unsyncedVisitFound.error,
          trace: unsyncedVisitFound.trace,
        );
      case SuccessResult<UnSyncedLocalVisit?>():
        var updatedUnsyncedVisit = unsyncedVisitFound.data;
        if (updatedUnsyncedVisit == null) {
          return ErrorResult(
            error: "Visit has already been synced",
          );
        }

        //Update visit
        updatedUnsyncedVisit.visitDate = visitDate ?? updatedUnsyncedVisit.visitDate;
        updatedUnsyncedVisit.status = status?.name.capitalize ?? updatedUnsyncedVisit.status;
        updatedUnsyncedVisit.location = location ?? updatedUnsyncedVisit.location;
        updatedUnsyncedVisit.notes = notes ?? updatedUnsyncedVisit.notes;
        updatedUnsyncedVisit.activityIdsDone = activityIdsDone ?? updatedUnsyncedVisit.activityIdsDone;
        updatedUnsyncedVisit.customerIdVisited = customerIdVisited ?? updatedUnsyncedVisit.customerIdVisited;

        var localSaveResult = await _localUnsyncedVisitRepository.setUnsyncedVisit(
          visit: updatedUnsyncedVisit,
        );
        switch (localSaveResult) {
          case ErrorResult<void>():
            return ErrorResult(
              error: localSaveResult.error,
              trace: localSaveResult.trace,
            );

          case SuccessResult<void>():
            CustomerRef? customerRef;
            var localCustomerResult = await _localCustomerRepository.getLocalCustomersByIds(
              customerIds: [updatedUnsyncedVisit.customerIdVisited],
            );

            switch (localCustomerResult) {
              case ErrorResult<Map<int, Customer>>():
                break;
              case SuccessResult<Map<int, Customer>>():
                var c = localCustomerResult.data.values.first;
                customerRef = CustomerRef(c.id, c.name);
                break;
            }

            late Map<int, ActivityRef> activityRef;
            var localActivityRefs = await _localActivityRepository.getLocalActivities(
              activityIds: updatedUnsyncedVisit.activityIdsDone,
            );

            switch (localActivityRefs) {
              case ErrorResult<Map<int, Activity>>():
                break;
              case SuccessResult<Map<int, Activity>>():
                var aMap = localActivityRefs.data;
                activityRef = {for (var a in aMap.values) a.id: ActivityRef(a.id, a.description)};
                break;
            }

            return SuccessResult(
              data: UnsyncedVisitAggregate(
                hash: hash,
                visitDate: updatedUnsyncedVisit.visitDate,
                status: VisitStatus.findByCapitalizedString(updatedUnsyncedVisit.status)!,
                location: updatedUnsyncedVisit.location,
                notes: updatedUnsyncedVisit.notes,
                createdAt: updatedUnsyncedVisit.createdAt,
                activityMap: activityRef,
                customer: customerRef,
              ),
              message: "Unsynced visit updated",
            );
        }
    }
  }
}
