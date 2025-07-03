import 'dart:async';

import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/connectivity/connectivity_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/sync_status.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class SyncUnsyncedLocalVisitsUseCase {
  final RemoteVisitRepository _remoteVisitRepository;
  final LocalUnsyncedVisitRepository _localUnsyncedVisitRepository;
  final ConnectivityService _connectivityService;
  late final StreamSubscription<bool> _connectivitySubscription;

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
    var visitStatus = VisitSyncStatus();
    if (visitStatus.isSyncing) return ErrorResult(error: "Sync currently ongoing");

    int page = 0;
    final int pageSize = 10;
    Map<UnSyncedLocalVisit, SyncStatus> resultCount = {};
    bool foundPageSizeResults = false;

    try {
      visitStatus.syncing = true;

      do {
        var visitResult = await _localUnsyncedVisitRepository.getUnsyncedVisits(
          page: page,
          pageSize: pageSize,
        );

        print(" ==> Syncing ${visitResult.toString()}");

        switch (visitResult) {
          case ErrorResult<List<UnSyncedLocalVisit>>():
            return ErrorResult(
              error: visitResult.error,
              trace: visitResult.trace,
              failure: visitResult.failure,
            );

          case SuccessResult<List<UnSyncedLocalVisit>>():
            foundPageSizeResults = visitResult.data.length == pageSize;
            var syncResults = visitResult.data.map((v) async {
              return await _remoteVisitRepository
                  .createVisit(
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
                    resultCount.putIfAbsent(v, () => SyncStatus.fail);
                    break;
                  case SuccessResult<void>():
                    _localUnsyncedVisitRepository.removeUnsyncedVisit(visit: v);
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

      return SuccessResult(
          data: resultCount,
          message: resultCount.toString(),
      );
    } catch (e, trace) {
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
      if(!hasConnectivity) {
        print("No sync connectivity");
        return;
      }

      print("Has sync connectivity");
      execute();
    });
  }

  Future<void> dispose() async {
    await _connectivitySubscription.cancel();
  }

}
