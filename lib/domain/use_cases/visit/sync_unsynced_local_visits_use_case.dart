import 'dart:async';

import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/connectivity/connectivity_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/sync_status.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class SyncUnsyncedLocalVisitsUseCase {
  final RemoteVisitRepository _remoteVisitRepository;
  final LocalUnsyncedVisitRepository _localUnsyncedVisitRepository;
  final ConnectivityService _connectivityService;
  late final StreamSubscription<bool> _connectivitySubscription;

  final String _tag = "SyncUnsyncedLocalVisitsUseCase";

  SyncUnsyncedLocalVisitsUseCase({
    required RemoteVisitRepository remoteVisitRepository,
    required LocalUnsyncedVisitRepository localUnsyncedVisitRepository,
    required ConnectivityService connectivityService,
  })  : _remoteVisitRepository = remoteVisitRepository,
        _localUnsyncedVisitRepository = localUnsyncedVisitRepository,
        _connectivityService = connectivityService {
    _syncOnConnection();
  }

  Future<TaskResult<Map<UnSyncedLocalVisit, SyncStatus>>> execute() async {
    AppLog.I.i(_tag, "Starting sync of unsynced visits");

    var visitStatus = VisitSyncStatus();
    if (visitStatus.isSyncing) {
      AppLog.I.w(_tag, "Sync is already in progress");
      return ErrorResult(error: "Sync currently ongoing");
    }

    int page = 0;
    final int pageSize = 10;
    Map<UnSyncedLocalVisit, SyncStatus> resultCount = {};
    bool foundPageSizeResults = false;

    try {
      visitStatus.syncing = true;

      do {
        AppLog.I.d(_tag, "Fetching unsynced visits: page $page");

        var visitResult = await _localUnsyncedVisitRepository.getUnsyncedVisits(
          page: page,
          pageSize: pageSize,
        );

        switch (visitResult) {
          case ErrorResult<List<UnSyncedLocalVisit>>():
            AppLog.I.e(_tag, "Failed to fetch unsynced visits", trace: visitResult.trace);
            return ErrorResult(
              error: visitResult.error,
              trace: visitResult.trace,
              failure: visitResult.failure,
            );

          case SuccessResult<List<UnSyncedLocalVisit>>():
            AppLog.I.d(_tag, "Fetched ${visitResult.data.length} unsynced visits");

            foundPageSizeResults = visitResult.data.length >= pageSize;
            var syncResults = visitResult.data.map((v) async {
              AppLog.I.d(_tag, "Syncing visit hash=${v.hash}");

              return await _remoteVisitRepository.createVisit(
                customerIdVisited: v.customerIdVisited,
                visitDate: v.visitDate,
                status: VisitStatus.findByCapitalizedString(v.status)!,
                location: v.location,
                notes: v.notes,
                activityIdsDone: v.activityIdsDone,
                createdAt: v.createdAt,
              ).then((createOnlineVisitResult) {
                switch (createOnlineVisitResult) {
                  case ErrorResult<void>():
                    AppLog.I.e(_tag, "Failed to sync visit hash=${v.hash}");
                    resultCount.putIfAbsent(v, () => SyncStatus.fail);
                    break;
                  case SuccessResult<void>():
                    _localUnsyncedVisitRepository.removeUnsyncedVisit(visit: v);
                    AppLog.I.i(_tag, "Successfully synced visit hash=${v.hash}");
                    resultCount.putIfAbsent(v, () => SyncStatus.success);
                    break;
                }
              });
            });
            await Future.wait(syncResults);
            break;
        }

        page++;
      } while (foundPageSizeResults);

      AppLog.I.i(_tag, "Completed syncing visits");

      return SuccessResult(
        data: resultCount,
        message: resultCount.toString(),
      );
    } catch (e, trace) {
      AppLog.I.e(_tag, "Unexpected error during sync", trace: trace);
      return ErrorResult(
        error: e.toString(),
        trace: trace,
      );
    } finally {
      visitStatus.syncing = false;
    }
  }

  void _syncOnConnection() {
    _connectivitySubscription = _connectivityService.onConnectionChange.listen((hasConnectivity) {
      if (!hasConnectivity) {
        AppLog.I.w(_tag, "No connectivity, cannot sync");
        return;
      }

      AppLog.I.i(_tag, "Connectivity restored, attempting sync");
      execute();
    });
  }

  Future<void> dispose() async {
    AppLog.I.d(_tag, "Disposing connectivity subscription");
    await _connectivitySubscription.cancel();
  }
}
