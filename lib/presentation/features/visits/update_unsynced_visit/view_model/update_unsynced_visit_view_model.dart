import 'dart:async';

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
  UpdateUnsyncedVisitState _state = InitialUpdateUnsyncedVisitState();
  UnsyncedVisitAggregate _originalVisit;

  UpdateUnsyncedVisitViewModel({
    required UpdateUnsyncedVisitUseCase updateUnsyncedVisitUseCase,
    required UnsyncedVisitAggregate visit,
  })  : _updateUnsyncedVisitUseCase = updateUnsyncedVisitUseCase,
        _originalVisit = visit;

  UpdateUnsyncedVisitState get state => _state;
  UnsyncedVisitAggregate get originalVisit => _originalVisit;

  Future<void> update({
    required DateTime visitDate,
    required VisitStatus status,
    required String location,
    required String notes,
    required List<int> activityIdsDone,
    required int customerId,
  }) async {
    if (_state is! InitialUpdateUnsyncedVisitState) return;

    try {
      _state = LoadingUpdateUnsyncedVisitState();
      notifyListeners();

      var results = await _updateUnsyncedVisitUseCase.execute(
        key: _originalVisit.key,
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
          _state = InitialUpdateUnsyncedVisitState();
          break;
        case SuccessResult<UnsyncedVisitAggregate>():
          _state = CompletedUpdateUnsyncedVisitState();
          break;
      }
    } finally {
      notifyListeners();
    }
  }
}
