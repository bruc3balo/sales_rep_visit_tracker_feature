import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/connectivity/connectivity_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/search_local_activities_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/activity/search_remote_activities_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/model/search_activities_models.dart';

class SearchActivitiesViewModel extends ChangeNotifier {
  final SearchRemoteActivitiesUseCase _searchRemoteActivityUseCase;
  final SearchLocalActivitiesUseCase _searchLocalActivitiesUseCase;
  final ConnectivityService _connectivityService;
  final SplayTreeSet<Activity> _activities = SplayTreeSet(
    (a, b) => a.id.compareTo(b.id),
  );
  int _remotePage = 0;
  int _localPage = 0;
  String? _lastQuery;

  SearchActivityState _state = LoadedActivitySearchState();

  SearchActivitiesViewModel({
    required SearchRemoteActivitiesUseCase searchRemoteActivitiesUseCase,
    required SearchLocalActivitiesUseCase searchLocalActivitiesUseCase,
    required ConnectivityService connectivityService,
  })  : _searchRemoteActivityUseCase = searchRemoteActivitiesUseCase,
        _searchLocalActivitiesUseCase = searchLocalActivitiesUseCase,
        _connectivityService = connectivityService {
    searchActivities();
  }

  SearchActivityState get state => _state;

  List<Activity> get activities => UnmodifiableListView(_activities);

  Future<void> searchActivities({
    String? activityDescription,
    int pageSize = 20,
  }) async {
    if (_lastQuery != null && _lastQuery != activityDescription) {
      _localPage = 0;
      _remotePage = 0;
    } else if (activityDescription != null && activityDescription != _lastQuery) {
      _localPage = 0;
      _remotePage = 0;
    }

    _lastQuery = activityDescription;

    bool hasConnectivity = await _connectivityService.hasInternetConnection();
    if (hasConnectivity) {
      await _searchRemoteActivities(
        activityDescription: activityDescription,
        pageSize: pageSize,
      );
    } else {
      await _searchLocalActivities(
        activityDescription: activityDescription,
        pageSize: pageSize,
      );
    }
  }

  Future<void> _searchRemoteActivities({
    String? activityDescription,
    int pageSize = 20,
  }) async {
    if (_state is! LoadedActivitySearchState) return;

    try {
      _state = LoadingActivitySearchState();
      notifyListeners();

      var getActivityResult = await _searchRemoteActivityUseCase.execute(
        likeDescription: activityDescription,
        page: _remotePage,
        pageSize: pageSize,
      );

      switch (getActivityResult) {
        case ErrorResult<List<Activity>>():
          GlobalToastMessage().add(ErrorMessage(message: getActivityResult.error));
          _state = LoadedActivitySearchState(searchResults: LinkedHashSet());
          break;
        case SuccessResult<List<Activity>>():
          if(getActivityResult.data.length == pageSize) _remotePage++;
          _activities.addAll(getActivityResult.data);
          _state = LoadedActivitySearchState(searchResults: LinkedHashSet.from(getActivityResult.data));
          break;
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> _searchLocalActivities({
    String? activityDescription,
    int pageSize = 20,
  }) async {
    if (_state is! LoadedActivitySearchState) return;

    try {
      _state = LoadingActivitySearchState();
      notifyListeners();

      var getActivityResult = await _searchLocalActivitiesUseCase.execute(
        likeDescription: activityDescription,
        page: _localPage,
        pageSize: pageSize,
      );

      switch (getActivityResult) {
        case ErrorResult<List<Activity>>():
          print(getActivityResult.trace.toString());
          GlobalToastMessage().add(ErrorMessage(message: getActivityResult.error));
          _state = LoadedActivitySearchState();
          break;
        case SuccessResult<List<Activity>>():
          if(getActivityResult.data.length == pageSize) _localPage++;
          _activities.addAll(getActivityResult.data);
          _state = LoadedActivitySearchState(searchResults: LinkedHashSet.from(getActivityResult.data));
          break;
      }
    } finally {
      notifyListeners();
    }
  }
}
