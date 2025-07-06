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

class DeleteUnsyncedVisitUseCase {
  final LocalUnsyncedVisitRepository _localUnsyncedVisitRepository;

  DeleteUnsyncedVisitUseCase({
    required LocalUnsyncedVisitRepository localUnsyncedVisitRepository,
  }) : _localUnsyncedVisitRepository = localUnsyncedVisitRepository;

  Future<TaskResult<void>> execute({
    required LocalVisitHash hash,
  }) async {
    AppLog.I.i("DeleteUnsyncedVisitUseCase", "Deleting unsynced visit with hash: ${hash.value}");
    final result = await _localUnsyncedVisitRepository.removeUnsyncedVisitByHash(
      hash: hash,
    );

    switch (result) {
      case ErrorResult<void>():
        AppLog.I.e("DeleteUnsyncedVisitUseCase", "Failed to delete unsynced visit", trace: result.trace);
        return result;
      case SuccessResult<void>():
        AppLog.I.i("DeleteUnsyncedVisitUseCase", "Successfully deleted unsynced visit with hash: ${hash.value}");
        return result;
    }
  }
}