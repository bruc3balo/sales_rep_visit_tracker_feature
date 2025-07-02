import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/sync_status.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class UpdateUnsyncedVisitUseCase {
  
  final LocalUnsyncedVisitRepository _localUnsyncedVisitRepository;

  UpdateUnsyncedVisitUseCase({required LocalUnsyncedVisitRepository localUnsyncedVisitRepository}) : _localUnsyncedVisitRepository = localUnsyncedVisitRepository;


  Future<TaskResult<void>> execute({
    required UnSyncedLocalVisit updatedVisit
}) async {
    var visitStatus = VisitSyncStatus();
    if(visitStatus.isSyncing) return ErrorResult(error: "Cannot update while syncing");

    var unsyncedVisitFound = await _localUnsyncedVisitRepository.containsUnsyncedVisitKey(
      key: LocalVisitKey(value: updatedVisit.key.toString()),
    );

    switch(unsyncedVisitFound) {

      case ErrorResult<bool>():
        return ErrorResult(
          error: unsyncedVisitFound.error,
          trace: unsyncedVisitFound.trace,
        );
      case SuccessResult<bool>():
        if(!unsyncedVisitFound.data) return ErrorResult(error: "Visit has already been synced");

        var localSaveResult = await _localUnsyncedVisitRepository.setUnsyncedVisit(visit: updatedVisit);
        switch(localSaveResult) {

          case ErrorResult<void>():
            return ErrorResult(
              error: localSaveResult.error,
              trace: localSaveResult.trace,
            );
          case SuccessResult<void>():
            return SuccessResult(data: null, message: "Unsynced visit updated");

        }

    }
  }
}