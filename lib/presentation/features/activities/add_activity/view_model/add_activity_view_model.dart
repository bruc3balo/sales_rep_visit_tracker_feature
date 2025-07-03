import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/create_activity_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/add_activity/model/add_activity_models.dart';

class AddActivityViewModel extends ChangeNotifier {
  final CreateActivityUseCase _createActivityUseCase;
  AddActivityState _state = InitialAddActivityState();

  AddActivityViewModel({
    required CreateActivityUseCase createActivityUseCase
  }) : _createActivityUseCase = createActivityUseCase;


  AddActivityState get state => _state;


  Future<void> addActivity(String description) async {
    if(_state is! InitialAddActivityState) return;

    try {
      _state = LoadingAddActivityState();
      notifyListeners();

      var result = await _createActivityUseCase.execute(
        description: description,
      );

      switch(result) {

        case ErrorResult<Activity>():
          GlobalToastMessage().add(ErrorMessage(message: result.error));
          _state = InitialAddActivityState();
         break;
        case SuccessResult<Activity>():
          GlobalToastMessage().add(SuccessMessage(message: result.message));
          _state = SuccessAddActivityState(activity: result.data);
          break;
      }


    } finally {
      notifyListeners();
    }
  }
}