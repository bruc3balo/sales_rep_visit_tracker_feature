import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/visit_list_of_past_visits_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/visit_filter/model/visit_filter_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visits/model/view_visits_models.dart';

class ViewVisitsViewModel extends ChangeNotifier {
  final VisitListOfPastVisitsUseCase _pastVisitsUseCase;
  int _page = 0;
  final LinkedHashSet<VisitAggregate> _visits = LinkedHashSet(
    equals: (a, b) => a.visit.id == b.visit.id,
    hashCode: (v) => v.visit.id.hashCode,
  );
  ViewVisitsState _itemsState = LoadedViewVisitsState();
  VisitFilterState _filterState = VisitFilterState();

  ViewVisitsViewModel({
    required VisitListOfPastVisitsUseCase pastVisitsUseCase,
  }) : _pastVisitsUseCase = pastVisitsUseCase {
    loadMoreItems();
  }

  ViewVisitsState get itemsState => _itemsState;

  VisitFilterState get filterState => _filterState;

  List<VisitAggregate> get visits => UnmodifiableListView(_visits);

  void updateFilter(VisitFilterState updatedFilter) {
    _filterState = updatedFilter;
    refresh();
  }

  Future<void> loadMoreItems() async {
    if (_itemsState is LoadingViewVisitsState) return;

    try {
      _itemsState = LoadingViewVisitsState();
      notifyListeners();


      var visitsResult = await _pastVisitsUseCase.execute(
        page: _page,
        pageSize: 20,
        customerId: _filterState.customer?.id,
        order: "${_filterState.orderBy.order}.${_filterState.sortBy.sort}",
        fromDateInclusive: _filterState.fromDateInclusive,
        toDateInclusive: _filterState.toDateInclusive,
        activityIdsDone: _filterState.activities.isEmpty ? null : _filterState.activities.map((e) => e.id).toList(),
        status: _filterState.visitStatus,
      );

      switch (visitsResult) {
        case ErrorResult<List<VisitAggregate>>():
          if (visitsResult.failure == FailureType.network && _visits.isEmpty) {
            _itemsState = OfflineViewVisitsState();
            GlobalToastMessage().add(ErrorMessage(message: "Network error"));
          } else {
            _itemsState = LoadedViewVisitsState();
            GlobalToastMessage().add(ErrorMessage(message: visitsResult.error));
          }

          break;
        case SuccessResult<List<VisitAggregate>>():
          _visits.addAll(visitsResult.data);
          if (visitsResult.data.isNotEmpty) _page++;
          _itemsState = LoadedViewVisitsState();

          break;
      }
    } finally {
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
