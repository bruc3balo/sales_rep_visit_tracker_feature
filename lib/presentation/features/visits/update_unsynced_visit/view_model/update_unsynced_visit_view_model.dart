import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/update_unsynced_visit_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/update_unsynced_visit/model/update_unsynced_visit_models.dart';

class UpdateUnsyncedVisitViewModel extends ChangeNotifier {
  final UpdateUnsyncedVisitUseCase _updateUnsyncedVisitUseCase;
  late UpdateUnsyncedVisitState _state;

  UpdateUnsyncedVisitViewModel({
    required UpdateUnsyncedVisitUseCase updateUnsyncedVisitUseCase,
    required UnsyncedVisitAggregate visit,
  })  : _updateUnsyncedVisitUseCase = updateUnsyncedVisitUseCase,
        _state = LoadedUpdateUnsyncedVisitState(visit: visit);

  UpdateUnsyncedVisitState get state => _state;

  Future<void> update({
    DateTime? visitDate,
    VisitStatus? status,
    String? location,
    String? notes,
    List<int>? activityIdsDone,
    int? customerId,
  }) async {
    if (_state is! LoadedUpdateUnsyncedVisitState) return;

    var state = _state as LoadedUpdateUnsyncedVisitState;
    var previousVisit = state.visit;

    try {
      _state = LoadingUpdateUnsyncedVisitState();
      notifyListeners();

      var results = await _updateUnsyncedVisitUseCase.execute(
        key: previousVisit.key,
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
          _state = LoadedUpdateUnsyncedVisitState(visit: previousVisit);
          break;
        case SuccessResult<UnsyncedVisitAggregate>():
          GlobalToastMessage().add(SuccessMessage(message: results.data.customer?.name ?? 'No customer'));
          _state = LoadedUpdateUnsyncedVisitState(visit: results.data);
          break;
      }
    } finally {
      notifyListeners();
    }
  }
}
