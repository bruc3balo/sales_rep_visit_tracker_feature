import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit_list_of_past_visits_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/model/view_visits_models.dart';

class ViewVisitsViewModel extends ChangeNotifier {
  final VisitListOfPastVisitsUseCase _pastVisitsUseCase;
  int _page = 0;
  final SplayTreeSet<VisitAggregate> _visits = SplayTreeSet(
    (a, b) => a.visit.id.compareTo(b.visit.id),
  );
  final StreamController<ToastMessage> _toastController = StreamController.broadcast();
  ViewVisitsState _itemsState = LoadedViewVisitsState();

  ViewVisitsViewModel({
    required VisitListOfPastVisitsUseCase pastVisitsUseCase,
  }) : _pastVisitsUseCase = pastVisitsUseCase {
    loadMoreItems();
  }

  ViewVisitsState get itemsState => _itemsState;

  List<VisitAggregate> get visits => UnmodifiableListView(_visits);

  Future<void> loadMoreItems() async {
    if (_itemsState is! LoadedViewVisitsState) return;

    try {
      _itemsState = LoadingViewVisitsState();
      notifyListeners();

      var visitsResult = await _pastVisitsUseCase.execute(
        page: _page,
        pageSize: 20,
        order: "visit_date.desc",
      );

      switch (visitsResult) {
        case ErrorResult<List<VisitAggregate>>():
          _toastController.add(ErrorMessage(message: visitsResult.error));
          break;
        case SuccessResult<List<VisitAggregate>>():
          _visits.addAll(visitsResult.data);
          if (visitsResult.data.isNotEmpty) _page++;
          break;
      }
    } finally {
      _itemsState = LoadedViewVisitsState();
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_itemsState is! LoadedViewVisitsState) return;
    _page = 0;
    _visits.clear();
    loadMoreItems();
  }
}
