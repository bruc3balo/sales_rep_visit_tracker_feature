import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/update_activity_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/edit_activity/model/edit_activity_models.dart';

class EditActivityViewModel extends ChangeNotifier {
  final UpdateActivityUseCase _updateActivityUseCase;
  final Activity _activity;
  late EditActivityState _state = InitialEditActivityState(
    activity: _activity,
  );

  EditActivityViewModel({
    required UpdateActivityUseCase updateActivityUseCase,
    required Activity activity
  }) : _updateActivityUseCase = updateActivityUseCase, _activity = activity;


  EditActivityState get state => _state;

  Future<void> editActivity(String description) async {
    if(_state is! InitialEditActivityState) return;

    try {
      _state = LoadingEditActivityState();
      notifyListeners();

      var result = await _updateActivityUseCase.execute(
        activityId: _activity.id,
        description: description,
      );


      switch(result) {

        case ErrorResult<Activity>():
          GlobalToastMessage().add(ErrorMessage(message: result.error));
          _state = InitialEditActivityState(activity: _activity);
          break;
        case SuccessResult<Activity>():
          GlobalToastMessage().add(SuccessMessage(message: result.message));
          _state = SuccessEditActivityState(activity: result.data);
          break;
      }

    } finally {
      notifyListeners();
    }
  }

}