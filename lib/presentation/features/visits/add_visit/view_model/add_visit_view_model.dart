import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/add_a_new_visit_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/add_visit/model/add_visit_models.dart';

class AddVisitViewModel extends ChangeNotifier {
  final AddANewVisitUseCase _addANewVisitUseCase;
  final StreamController<ToastMessage> _toastStream = StreamController.broadcast();
  AddVisitState _state = InitialAddVisitState();

  AddVisitViewModel({
    required AddANewVisitUseCase addANewVisitUseCase,
  }) : _addANewVisitUseCase = addANewVisitUseCase;

  AddVisitState get state => _state;

  Future<void> addNewVisit({
    required Customer customer,
    required DateTime visitDate,
    required VisitStatus status,
    required String location,
    required String notes,
    required List<Activity> activities,
  }) async {
    if (_state is! InitialAddVisitState) return;

    try {
      _state = LoadingAddVisitState();
      notifyListeners();

      var addResult = await _addANewVisitUseCase.execute(
        customer: customer,
        visitDate: visitDate,
        status: status,
        location: location,
        notes: notes,
        activitiesDone: activities,
      );

      switch(addResult) {
        case ErrorResult<void>():
          _state = InitialAddVisitState();
          _toastStream.add(ErrorMessage(message: addResult.error));
          break;
        case SuccessResult<void>():
          _state = SuccessAddingVisitState();
          _toastStream.add(SuccessMessage(message: addResult.message));
          break;
      }

    } finally {
      notifyListeners();
    }
  }
}
