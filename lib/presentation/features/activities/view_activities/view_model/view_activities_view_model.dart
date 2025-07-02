import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/model/view_activities_models.dart';

class ViewActivitiesViewModel extends ChangeNotifier {
  final RemoteActivityRepository _activityRepository;
  int _page = 0;
  final SplayTreeSet<Activity> _activities = SplayTreeSet(
    (a, b) => a.id.compareTo(b.id),
  );
  final StreamController<ToastMessage> _toastController = StreamController.broadcast();
  ViewActivitiesState _itemsState = LoadedViewActivitiesState();
  DeleteActivityState _deleteState = InitialDeleteActivityState();

  ViewActivitiesViewModel({
    required RemoteActivityRepository activityRepository,
  }) : _activityRepository = activityRepository {
    loadMoreItems();
  }

  ViewActivitiesState get itemsState => _itemsState;

  DeleteActivityState get deleteState => _deleteState;


  List<Activity> get activities => UnmodifiableListView(_activities);

  Future<void> loadMoreItems() async {
    if (_itemsState is! LoadedViewActivitiesState) return;

    try {
      _itemsState = LoadingViewActivitiesState();
      notifyListeners();

      var activityResult = await _activityRepository.getActivities(page: _page, pageSize: 20, order: "created_at.desc");

      switch (activityResult) {
        case ErrorResult<List<Activity>>():
          _toastController.add(ErrorMessage(message: activityResult.error));
          break;
        case SuccessResult<List<Activity>>():
          _activities.addAll(activityResult.data);
          if(activityResult.data.isNotEmpty) _page++;
          break;
      }
    } finally {
      _itemsState = LoadedViewActivitiesState();
      notifyListeners();
    }
  }


  Future<void> deleteActivity({
    required Activity activity,
  }) async {
    if (_deleteState is LoadingDeleteActivityState) return;

    try {
      _deleteState = LoadingDeleteActivityState(activity: activity);
      notifyListeners();

      var result = await _activityRepository.deleteActivity(
          activityId: activity.id,
      );

      switch(result) {

        case ErrorResult<void>():
          _toastController.add(ErrorMessage(message: result.error));
          break;

        case SuccessResult<void>():
          _activities.remove(activity);
          _toastController.add(SuccessMessage(message: result.message));
          break;
      }

    } finally {
      _deleteState = InitialDeleteActivityState();
      notifyListeners();
    }

  }

  Future<void> refresh() async {
    if (_itemsState is! LoadedViewActivitiesState) return;
    _page = 0;
    _activities.clear();
    loadMoreItems();
  }
}
