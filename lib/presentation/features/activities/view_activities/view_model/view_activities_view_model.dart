import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/connectivity/connectivity_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/delete_activity_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/view_local_activities_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/view_remote_activities_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/view_activities/model/view_activities_models.dart';

class ViewActivitiesViewModel extends ChangeNotifier {
  final ViewRemoteActivitiesUseCase _remoteActivitiesUseCase;
  final ViewLocalActivitiesUseCase _localActivitiesUseCase;
  final ConnectivityService _connectivityService;
  final DeleteActivityUseCase _deleteActivityUseCase;
  late final StreamSubscription<Activity> _activityUpdatesSubscription;

  int _remotePage = 0;
  int _localPage = 0;
  static final _tag = "ViewActivitiesViewModel";
  static final int _pageSize = 20;
  final SplayTreeSet<Activity> _activities = SplayTreeSet();

  ViewActivitiesState _itemsState = LoadedViewActivitiesState();
  DeleteActivityState _deleteState = InitialDeleteActivityState();

  ViewActivitiesViewModel({
    required ViewRemoteActivitiesUseCase remoteActivitiesUseCase,
    required ViewLocalActivitiesUseCase localActivitiesUseCase,
    required DeleteActivityUseCase deleteActivityUseCase,
    required ConnectivityService connectivityService,
  })  : _remoteActivitiesUseCase = remoteActivitiesUseCase,
        _localActivitiesUseCase = localActivitiesUseCase,
        _deleteActivityUseCase = deleteActivityUseCase,
        _connectivityService = connectivityService {
    loadMoreItems();
    _subscribeToActivityUpdates();
  }

  ViewActivitiesState get itemsState => _itemsState;

  DeleteActivityState get deleteState => _deleteState;

  List<Activity> get activities => UnmodifiableListView(_activities);

  Future<void> loadMoreItems() async {
    bool hasConnection = await _connectivityService.hasInternetConnection();
    if (hasConnection) {
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
        page: _remotePage,
        pageSize: _pageSize,
        order: "created_at.desc",
      );

      switch (activityResult) {
        case ErrorResult<List<Activity>>():
          GlobalToastMessage().add(ErrorMessage(message: activityResult.error));
          break;
        case SuccessResult<List<Activity>>():
          _activities.addAll(activityResult.data);
          if (activityResult.data.length >= _pageSize) _remotePage++;
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
        page: _localPage,
        pageSize: _pageSize,
      );

      switch (activityResult) {
        case ErrorResult<List<Activity>>():
          GlobalToastMessage().add(ErrorMessage(message: activityResult.error));

          break;
        case SuccessResult<List<Activity>>():
          _activities.addAll(activityResult.data);
          if (activityResult.data.length >= _pageSize) _localPage++;
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

      switch (result) {
        case ErrorResult<void>():
          GlobalToastMessage().add(ErrorMessage(message: result.error));
          break;

        case SuccessResult<void>():
          _activities.remove(activity);
          GlobalToastMessage().add(SuccessMessage(message: result.message));
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

  void _subscribeToActivityUpdates() {
    AppLog.I.d(_tag, "Subscribing to local activity updates");
    _activityUpdatesSubscription = _localActivitiesUseCase.activityUpdateStream.listen((activity) {
      _activities.removeWhere((e) => e.id == activity.id);
      _activities.add(activity);
      notifyListeners();
    });
  }

  void _unSubscribeFromActivityUpdates() {
    AppLog.I.d(_tag, "Unsubscribing from local activity updates");
    _activityUpdatesSubscription.cancel();
  }

  @override
  void dispose() {
    _unSubscribeFromActivityUpdates();
    super.dispose();
  }
}
