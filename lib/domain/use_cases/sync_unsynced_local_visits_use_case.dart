import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/sync_status.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class SyncUnsyncedLocalVisitsUseCase {

  final RemoteVisitRepository _remoteVisitRepository;
  final LocalUnsyncedVisitRepository _localUnsyncedVisitRepository;


  SyncUnsyncedLocalVisitsUseCase({
    required RemoteVisitRepository remoteVisitRepository,
    required LocalUnsyncedVisitRepository localUnsyncedVisitRepository,
  }) : _remoteVisitRepository = remoteVisitRepository,
        _localUnsyncedVisitRepository = localUnsyncedVisitRepository;


  Future<TaskResult<Map<String, int>>> execute() async {
    var visitStatus = VisitSyncStatus();
    if(visitStatus.isSyncing) return ErrorResult(error: "Sync currently ongoing");

    int page = 0;
    Map<String, int> resultCount = {};
    bool foundResults = false;

    try {
      visitStatus.syncing = true;

      do {
        var visitResult = await _localUnsyncedVisitRepository.getUnsyncedVisits(
          page: page, pageSize: 10,
        );

        switch(visitResult) {

          case ErrorResult<List<UnSyncedLocalVisit>>():
            continue;

          case SuccessResult<List<UnSyncedLocalVisit>>():
            foundResults = visitResult.data.isNotEmpty;
            var syncResults = visitResult.data.map((v) {
              return _remoteVisitRepository.createVisit(
                customerIdVisited: v.customerIdVisited,
                visitDate: v.visitDate,
                status: VisitStatus.findByCapitalizedString(v.status)!,
                location: v.location,
                notes: v.notes,
                activityIdsDone: v.activityIdsDone,
                createdAt: v.createdAt,
              ).then((createOnlineVisitResult) {
                switch(createOnlineVisitResult) {
                  case ErrorResult<void>():
                    resultCount.update("fail", (c) => c + 1, ifAbsent: () => 1);
                    break;
                  case SuccessResult<void>():
                    _localUnsyncedVisitRepository.removeUnsyncedVisit(visit: v);
                    resultCount.update("success", (c) => c + 1, ifAbsent: () => 1);
                    break;
                }
              });
            });
            await Future.wait(syncResults);
            break;
        }

        page++;
      } while(foundResults);

      return SuccessResult(
          data: resultCount,
          message: resultCount.toString()
      );
    } catch(e, trace) {
      return ErrorResult(
        error: e.toString(),
        trace: trace,
      );
    } finally {
      visitStatus.syncing = false;
    }
  }


}