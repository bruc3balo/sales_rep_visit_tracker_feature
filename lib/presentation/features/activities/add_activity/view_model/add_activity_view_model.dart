import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/add_activity/model/add_activity_models.dart';

class AddActivityViewModel extends ChangeNotifier {
  final RemoteActivityRepository _remoteActivityRepository;
  final StreamController<ToastMessage> _toastStream = StreamController.broadcast();
  AddActivityState _state = InitialAddActivityState();

  AddActivityViewModel({
    required RemoteActivityRepository remoteActivityRepository
  }) : _remoteActivityRepository = remoteActivityRepository;


  AddActivityState get state => _state;


  Future<void> addActivity(String description) async {
    if(_state is! InitialAddActivityState) return;

    try {
      _state = LoadingAddActivityState();
      notifyListeners();

      var result = await _remoteActivityRepository.createActivity(
        description: description,
      );

      print('$result');

      switch(result) {

        case ErrorResult<Activity>():
          _toastStream.add(ErrorMessage(message: result.error));
          _state = InitialAddActivityState();
         break;
        case SuccessResult<Activity>():
          _toastStream.add(SuccessMessage(message: result.message));
          _state = SuccessAddActivityState(activity: result.data);
          break;
      }


    } finally {
      notifyListeners();
    }
  }
}