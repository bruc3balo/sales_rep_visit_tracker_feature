import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/sync_status.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/model_mapper.dart';

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
    required dynamic key,
    DateTime? visitDate,
    VisitStatus? status,
    String? location,
    String? notes,
    List<int>? activityIdsDone,
    int? customerIdVisited,
  }) async {
    AppLog.I.i(_tag, "Starting update for visit with key=$key");

    var visitStatus = VisitSyncStatus();
    if (visitStatus.isSyncing) {
      AppLog.I.w(_tag, "Update rejected: Sync is in progress");
      return ErrorResult(error: "Cannot update while syncing");
    }

    var unsyncedVisitFound = await _localUnsyncedVisitRepository.findByKey(key: key);

    switch (unsyncedVisitFound) {
      case ErrorResult<UnSyncedLocalVisit?>():
        AppLog.I.e(_tag, "Failed to find visit by hash", trace: unsyncedVisitFound.trace);
        return ErrorResult(
          error: unsyncedVisitFound.error,
          trace: unsyncedVisitFound.trace,
        );
      case SuccessResult<UnSyncedLocalVisit?>():
        var originalUnsyncedVisit = unsyncedVisitFound.data;
        if (originalUnsyncedVisit == null) {
          AppLog.I.w(_tag, "Visit already synced for key=$key");
          return ErrorResult(error: "Visit has already been synced");
        }

        DateTime updatedVisitDate = visitDate ?? originalUnsyncedVisit.visitDate;
        String updatedStatus = status?.name.capitalize ?? originalUnsyncedVisit.status;
        String updatedLocation = location ?? originalUnsyncedVisit.location;
        String updatedNotes = notes ?? originalUnsyncedVisit.notes;
        List<int> updatedActivityIdsDone = activityIdsDone ?? originalUnsyncedVisit.activityIdsDone;
        int updatedCustomerIdVisited = customerIdVisited ?? originalUnsyncedVisit.customerIdVisited;

        var updatedHash = generateHash(
          customerIdVisited: updatedCustomerIdVisited,
          visitDate: updatedVisitDate,
          status: updatedStatus,
          location: updatedLocation,
          notes: updatedNotes,
          activityIdsDone: updatedActivityIdsDone,
        );

        var duplicateCheck = await _localUnsyncedVisitRepository.findByHash(hash: updatedHash);
        switch (duplicateCheck) {
          case ErrorResult<UnSyncedLocalVisit?>():
            return ErrorResult(
              error: duplicateCheck.error,
              trace: duplicateCheck.trace,
            );
          case SuccessResult<UnSyncedLocalVisit?>():
            var duplicateVisit = duplicateCheck.data;
            if (duplicateVisit != null) {
              return ErrorResult(
                error: "Similar visit found with existing details",
                failure: FailureType.illegalState,
              );
            }
            break;
        }

        AppLog.I.d(_tag, "Updating fields for visit key=$key");

        var updatedUnsyncedVisit = originalUnsyncedVisit.copyWith(
          status: updatedStatus,
          location: updatedLocation,
          notes: updatedNotes,
          activityIdsDone: updatedActivityIdsDone,
          customerIdVisited: updatedCustomerIdVisited,
          hash: updatedHash.value,
        );

        AppLog.I.d(_tag, "Updating hash from (${originalUnsyncedVisit.hash}) to (${updatedUnsyncedVisit.hash})");


        var localSaveResult = await _localUnsyncedVisitRepository.setUnsyncedVisit(
          visit: updatedUnsyncedVisit,
        );
        switch (localSaveResult) {
          case ErrorResult<void>():
            AppLog.I.e(_tag, "Failed to persist updated visit hash=${updatedHash.value}", trace: localSaveResult.trace);
            return ErrorResult(
              error: localSaveResult.error,
              trace: localSaveResult.trace,
            );

          case SuccessResult<void>():
            AppLog.I.i(_tag, "Persisted updated visit hash=${updatedHash.value}");

            CustomerRef? customerRef;
            var localCustomerResult = await _localCustomerRepository.getLocalCustomersByIds(
              customerIds: [updatedUnsyncedVisit.customerIdVisited],
            );

            switch (localCustomerResult) {
              case ErrorResult<Map<int, Customer>>():
                AppLog.I.w(_tag, "Could not resolve customer for visit hash=${updatedHash.value}");
                break;
              case SuccessResult<Map<int, Customer>>():
                var c = localCustomerResult.data.values.first;
                customerRef = c.toRef;
                break;
            }

            late Map<int, ActivityRef> activityRef;
            var localActivityRefs = await _localActivityRepository.getLocalActivities(
              activityIds: updatedUnsyncedVisit.activityIdsDone,
            );

            switch (localActivityRefs) {
              case ErrorResult<Map<int, Activity>>():
                AppLog.I.w(_tag, "Could not resolve activities for visit hash=${updatedHash.value}");
                break;
              case SuccessResult<Map<int, Activity>>():
                var aMap = localActivityRefs.data;
                activityRef = {
                  for (var a in aMap.values) a.id: a.toRef,
                };
                break;
            }

            AppLog.I.i(_tag, "Visit updated successfully for hash=${updatedHash.value}");

            return SuccessResult(
              data: UnsyncedVisitAggregate(
                key: key,
                hash: updatedHash,
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
