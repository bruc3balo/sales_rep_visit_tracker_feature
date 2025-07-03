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
  SearchActivityState _state = LoadedActivitySearchState(searchResults: LinkedHashSet());

  SearchActivitiesViewModel({
    required SearchRemoteActivitiesUseCase searchRemoteActivitiesUseCase,
    required SearchLocalActivitiesUseCase searchLocalActivitiesUseCase,
    required ConnectivityService connectivityService,
  }) : _searchRemoteActivityUseCase = searchRemoteActivitiesUseCase,
       _searchLocalActivitiesUseCase = searchLocalActivitiesUseCase,
       _connectivityService = connectivityService {
    searchActivities();
  }

  SearchActivityState get state => _state;

  Future<void> searchActivities({
    String? activityDescription,
    int page = 0,
    int pageSize = 20,
  }) async {
    bool hasConnectivity = await _connectivityService.hasInternetConnection();
    if(hasConnectivity) {
      await _searchRemoteActivities(
        activityDescription: activityDescription,
        page: page,
        pageSize: pageSize,
      );
    } else {
      await _searchLocalActivities(
          activityDescription: activityDescription,
          page: page,
          pageSize: pageSize
      );
    }

  }

  Future<void> _searchRemoteActivities({
    String? activityDescription,
    int page = 0,
    int pageSize = 20,
  }) async {
    if (_state is! LoadedActivitySearchState) return;

    try {
      _state = LoadingActivitySearchState();
      notifyListeners();

      var getActivityResult = await _searchRemoteActivityUseCase.execute(
        likeDescription: activityDescription,
        page: page,
        pageSize: pageSize,
      );

      switch(getActivityResult) {

        case ErrorResult<List<Activity>>():
          GlobalToastMessage().add(ErrorMessage(message: getActivityResult.error));
          _state = LoadedActivitySearchState(searchResults: LinkedHashSet());
          break;
        case SuccessResult<List<Activity>>():
          _state = LoadedActivitySearchState(searchResults: LinkedHashSet.from(getActivityResult.data));
          break;
      }

    } finally {
      notifyListeners();
    }

  }

  Future<void> _searchLocalActivities({
    String? activityDescription,
    int page = 0,
    int pageSize = 20,
  }) async {
    if (_state is! LoadedActivitySearchState) return;

    try {
      _state = LoadingActivitySearchState();
      notifyListeners();

      var getActivityResult = await _searchLocalActivitiesUseCase.execute(
        likeDescription: activityDescription,
        page: page,
        pageSize: pageSize,
      );

      switch(getActivityResult) {

        case ErrorResult<List<Activity>>():
          GlobalToastMessage().add(ErrorMessage(message: getActivityResult.error));
          _state = LoadedActivitySearchState(searchResults: LinkedHashSet());
          break;
        case SuccessResult<List<Activity>>():
          _state = LoadedActivitySearchState(searchResults: LinkedHashSet.from(getActivityResult.data));
          break;
      }

    } finally {
      notifyListeners();
    }

  }
}
