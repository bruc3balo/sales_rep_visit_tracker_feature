import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/connectivity/connectivity_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/delete_activity_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/view_local_activities_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/view_remote_activities_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/model/view_activities_models.dart';

class ViewActivitiesViewModel extends ChangeNotifier {
  final ViewRemoteActivitiesUseCase _remoteActivitiesUseCase;
  final ViewLocalActivitiesUseCase _localActivitiesUseCase;
  final ConnectivityService _connectivityService;
  final DeleteActivityUseCase _deleteActivityUseCase;

  int _remotePage = 0;
  int _localPage = 0;
  final SplayTreeSet<Activity> _activities = SplayTreeSet(
    (a, b) => a.id.compareTo(b.id),
  );
  final StreamController<ToastMessage> _toastController = StreamController.broadcast();
  ViewActivitiesState _itemsState = LoadedViewActivitiesState();
  DeleteActivityState _deleteState = InitialDeleteActivityState();

  ViewActivitiesViewModel({
    required ViewRemoteActivitiesUseCase remoteActivitiesUseCase,
    required ViewLocalActivitiesUseCase localActivitiesUseCase,
    required DeleteActivityUseCase deleteActivityUseCase,
    required ConnectivityService connectivityService,
  }) : _remoteActivitiesUseCase = remoteActivitiesUseCase,
        _localActivitiesUseCase = localActivitiesUseCase,
        _deleteActivityUseCase = deleteActivityUseCase,
        _connectivityService = connectivityService {
    loadMoreItems();
  }

  ViewActivitiesState get itemsState => _itemsState;

  DeleteActivityState get deleteState => _deleteState;
  
  List<Activity> get activities => UnmodifiableListView(_activities);

  Future<void> loadMoreItems() async {
    bool hasConnection = await _connectivityService.hasInternetConnection();
    if(hasConnection) {
      _loadMoreRemoteItems();
    } else {
      _loadMoreLocalItems();
    }
  }

  Future<void> _loadMoreRemoteItems() async {
    if (_itemsState is! LoadedViewActivitiesState) return;

    try {
      _itemsState = LoadingViewActivitiesState();
      notifyListeners();

      var activityResult = await _remoteActivitiesUseCase.execute(
          page: _remotePage, pageSize: 20, order: "created_at.desc"
      );

      switch (activityResult) {
        case ErrorResult<List<Activity>>():
          _toastController.add(ErrorMessage(message: activityResult.error));

          if(FailureType.noInternet == activityResult.failure) {
            _remotePage = 0;
          }

          break;
        case SuccessResult<List<Activity>>():
          _activities.addAll(activityResult.data);
          if(activityResult.data.isNotEmpty) _remotePage++;
          break;
      }
    } finally {
      _itemsState = LoadedViewActivitiesState();
      notifyListeners();
    }
  }

  Future<void> _loadMoreLocalItems() async {
    if (_itemsState is! LoadedViewActivitiesState) return;

    try {
      _itemsState = LoadingViewActivitiesState();
      notifyListeners();

      var activityResult = await _localActivitiesUseCase.execute(
          page: _localPage, pageSize: 20,
      );

      switch (activityResult) {
        case ErrorResult<List<Activity>>():
          _toastController.add(ErrorMessage(message: activityResult.error));

          break;
        case SuccessResult<List<Activity>>():
          _activities.addAll(activityResult.data);
          if(activityResult.data.isNotEmpty) _localPage++;
          break;
      }
    } finally {
      _itemsState = LoadedViewActivitiesState();
      notifyListeners();
    }
  }

  void updateItem(Activity activity) {
    _activities.removeWhere((a) => a.id == activity.id);
    _activities.add(activity);
    notifyListeners();
  }

  Future<void> deleteActivity({
    required Activity activity,
  }) async {
    if (_deleteState is LoadingDeleteActivityState) return;

    try {
      _deleteState = LoadingDeleteActivityState(activity: activity);
      notifyListeners();

      var result = await _deleteActivityUseCase.execute(
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
    _localPage = 0;
    _remotePage = 0;
    _activities.clear();
    loadMoreItems();
  }

}
