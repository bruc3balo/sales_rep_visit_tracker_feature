import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/edit_activity/model/edit_activity_models.dart';

class EditActivityViewModel extends ChangeNotifier {
  final RemoteActivityRepository _remoteActivityRepository;
  final Activity _activity;
  final StreamController<ToastMessage> _toastStream = StreamController.broadcast();
  late EditActivityState _state = InitialEditActivityState(
    activity: _activity,
  );

  EditActivityViewModel({
    required RemoteActivityRepository remoteActivityRepository,
    required Activity activity
  }) : _remoteActivityRepository = remoteActivityRepository, _activity = activity;


  EditActivityState get state => _state;


  Future<void> editActivity(String description) async {
    if(_state is! InitialEditActivityState) return;

    try {
      _state = LoadingEditActivityState();
      notifyListeners();

      var result = await _remoteActivityRepository.updateActivity(
        activityId: _activity.id,
        description: description,
      );


      switch(result) {

        case ErrorResult<Activity>():
          _toastStream.add(ErrorMessage(message: result.error));
          _state = InitialEditActivityState(activity: _activity);
          break;
        case SuccessResult<Activity>():
          _toastStream.add(SuccessMessage(message: result.message));
          _state = SuccessEditActivityState(activity: result.data);
          break;
      }

    } finally {
      notifyListeners();
    }
  }
}