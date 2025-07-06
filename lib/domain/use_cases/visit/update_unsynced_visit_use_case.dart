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
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class UpdateUnsyncedVisitUseCase {
  static const _tag = "UpdateUnsyncedVisitUseCase";

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
    AppLog.I.i(_tag, "Starting update for visit with hash=${hash.value}");

    var visitStatus = VisitSyncStatus();
    if (visitStatus.isSyncing) {
      AppLog.I.w(_tag, "Update rejected: Sync is in progress");
      return ErrorResult(error: "Cannot update while syncing");
    }

    var unsyncedVisitFound = await _localUnsyncedVisitRepository.findByHash(hash: hash);

    switch (unsyncedVisitFound) {
      case ErrorResult<UnSyncedLocalVisit?>():
        AppLog.I.e(_tag, "Failed to find visit by hash", trace: unsyncedVisitFound.trace);
        return ErrorResult(
          error: unsyncedVisitFound.error,
          trace: unsyncedVisitFound.trace,
        );
      case SuccessResult<UnSyncedLocalVisit?>():
        var updatedUnsyncedVisit = unsyncedVisitFound.data;
        if (updatedUnsyncedVisit == null) {
          AppLog.I.w(_tag, "Visit already synced for hash=${hash.value}");
          return ErrorResult(error: "Visit has already been synced");
        }

        AppLog.I.d(_tag, "Updating fields for visit hash=${hash.value}");

        updatedUnsyncedVisit.visitDate = visitDate ?? updatedUnsyncedVisit.visitDate;
        updatedUnsyncedVisit.status = status?.name.capitalize ?? updatedUnsyncedVisit.status;
        updatedUnsyncedVisit.location = location ?? updatedUnsyncedVisit.location;
        updatedUnsyncedVisit.notes = notes ?? updatedUnsyncedVisit.notes;
        updatedUnsyncedVisit.activityIdsDone = activityIdsDone ?? updatedUnsyncedVisit.activityIdsDone;
        updatedUnsyncedVisit.customerIdVisited = customerIdVisited ?? updatedUnsyncedVisit.customerIdVisited;

        var localSaveResult = await _localUnsyncedVisitRepository.setUnsyncedVisit(visit: updatedUnsyncedVisit);
        switch (localSaveResult) {
          case ErrorResult<void>():
            AppLog.I.e(_tag, "Failed to persist updated visit hash=${hash.value}", trace: localSaveResult.trace);
            return ErrorResult(
              error: localSaveResult.error,
              trace: localSaveResult.trace,
            );

          case SuccessResult<void>():
            AppLog.I.i(_tag, "Persisted updated visit hash=${hash.value}");

            CustomerRef? customerRef;
            var localCustomerResult = await _localCustomerRepository.getLocalCustomersByIds(
              customerIds: [updatedUnsyncedVisit.customerIdVisited],
            );

            switch (localCustomerResult) {
              case ErrorResult<Map<int, Customer>>():
                AppLog.I.w(_tag, "Could not resolve customer for visit hash=${hash.value}");
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
                AppLog.I.w(_tag, "Could not resolve activities for visit hash=${hash.value}");
                break;
              case SuccessResult<Map<int, Activity>>():
                var aMap = localActivityRefs.data;
                activityRef = {
                  for (var a in aMap.values) a.id: ActivityRef(a.id, a.description),
                };
                break;
            }

            AppLog.I.i(_tag, "Visit updated successfully for hash=${hash.value}");

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
