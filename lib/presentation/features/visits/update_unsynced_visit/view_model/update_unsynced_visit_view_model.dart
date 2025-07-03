import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/delete_unsynced_visit_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/update_unsynced_visit_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/update_unsynced_visit/model/update_unsynced_visit_models.dart';

class UpdateUnsyncedVisitViewModel extends ChangeNotifier {
  final UpdateUnsyncedVisitUseCase _updateUnsyncedVisitUseCase;
  late UpdateUnsyncedVisitState _state = LoadedUpdateUnsyncedVisitState(visit: _visit);
  UnsyncedVisitAggregate _visit;

  UpdateUnsyncedVisitViewModel({
    required UpdateUnsyncedVisitUseCase updateUnsyncedVisitUseCase,
    required UnsyncedVisitAggregate visit,
  })  : _updateUnsyncedVisitUseCase = updateUnsyncedVisitUseCase,
        _visit = visit;

  UpdateUnsyncedVisitState get state => _state;

  UnsyncedVisitAggregate get visit => _visit;


  Future<void> update({
    DateTime? visitDate,
    VisitStatus? status,
    String? location,
    String? notes,
    List<int>? activityIdsDone,
    int? customerId,
  }) async {
    if (_state is! LoadedUpdateUnsyncedVisitState) return;

    try {
      _state = LoadingUpdateUnsyncedVisitState();
      notifyListeners();

      var results = await _updateUnsyncedVisitUseCase.execute(
        hash: _visit.hash,
        visitDate: visitDate,
        status: status,
        location: location,
        notes: notes,
        activityIdsDone: activityIdsDone,
        customerIdVisited: customerId,
      );

      switch (results) {
        case ErrorResult<UnsyncedVisitAggregate>():
          GlobalToastMessage().add(ErrorMessage(message: results.error));
          break;
        case SuccessResult<UnsyncedVisitAggregate>():
          _visit = results.data;
          GlobalToastMessage().add(SuccessMessage(message: results.message));
          break;
      }
    } finally {
      _state = LoadedUpdateUnsyncedVisitState(visit: _visit);
      notifyListeners();
    }
  }
}
