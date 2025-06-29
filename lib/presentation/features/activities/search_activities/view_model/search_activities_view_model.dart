import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/model/search_activities_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/model/search_customers_models.dart';

class SearchActivitiesViewModel extends ChangeNotifier {
  final ActivityRepository _activityRepository;
  final StreamController<ToastMessage> _toastMessage = StreamController.broadcast();
  SearchActivityState _state = LoadedActivitySearchState(searchResults: LinkedHashSet());

  SearchActivitiesViewModel({
    required ActivityRepository activityRepository,
  }) : _activityRepository = activityRepository;

  SearchActivityState get state => _state;

  Future<void> searchActivities({
    required String activityDescription,
    int page = 0,
    int pageSize = 20,
  }) async {
    if (_state is! LoadedActivitySearchState) return;

    try {
      _state = LoadingActivitySearchState();
      notifyListeners();

      var getActivityResult = await _activityRepository.getActivities(
        likeDescription: activityDescription,
        page: page,
        pageSize: pageSize,
      );

      switch(getActivityResult) {

        case ErrorResult<List<Activity>>():
          _toastMessage.add(ErrorMessage(message: getActivityResult.error));
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
