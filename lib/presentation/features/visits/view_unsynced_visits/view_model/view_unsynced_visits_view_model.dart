import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/sync_unsynced_local_visits_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/view_unsynced_local_visits_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_unsynced_visits/model/view_unsynced_visits_model.dart';

class ViewUnsyncedVisitsViewModel extends ChangeNotifier {
  final ViewUnsyncedLocalVisitsUseCase _viewUnsyncedLocalVisitsUseCase;
  final SyncUnsyncedLocalVisitsUseCase _syncUnsyncedLocalVisitsUseCase;
  final SplayTreeSet<UnsyncedVisitAggregate> _visits = SplayTreeSet(
        (a, b) => -a.visitDate.compareTo(b.visitDate),
  );
  final StreamController<ToastMessage> _toastController = StreamController.broadcast();

  UnsyncedVisitsState _state = InitialUnsyncedVisitState();
  int _page = 0;

  ViewUnsyncedVisitsViewModel({
    required ViewUnsyncedLocalVisitsUseCase viewUnsyncedLocalVisitsUseCase,
    required SyncUnsyncedLocalVisitsUseCase syncUnsyncedLocalVisitsUseCase,
  }) : _viewUnsyncedLocalVisitsUseCase = viewUnsyncedLocalVisitsUseCase,
        _syncUnsyncedLocalVisitsUseCase = syncUnsyncedLocalVisitsUseCase;

  UnsyncedVisitsState get state => _state;

  Future<void> sync() async {
    if (_state is! DisplayingUnsyncedVisitState) return;

    try {
      _state = SyncingVisitState();
      notifyListeners();

      var syncResult = await _syncUnsyncedLocalVisitsUseCase.execute();
      switch(syncResult) {

        case ErrorResult<Map<String, int>>():
          _state = DisplayingUnsyncedVisitState();
          _toastController.add(ErrorMessage(message: syncResult.error));
          break;
        case SuccessResult<Map<String, int>>():
          _toastController.add(SuccessMessage(message: syncResult.message));
          _state = FinishedSyncingVisitState(results: syncResult.data);
          _visits.clear();
          _page = 0;
          break;
      }

    } finally {
      notifyListeners();
    }
  }

  Future<void> loadMoreItems() async {
    if (_state is! DisplayingUnsyncedVisitState) return;

    try {
      _state = LoadingUnsyncedVisitState();
      notifyListeners();

      var unsyncedVisitResult = await _viewUnsyncedLocalVisitsUseCase.execute(
        page: _page,
        pageSize: 20,
      );

      switch (unsyncedVisitResult) {
        case ErrorResult<List<UnsyncedVisitAggregate>>():
          _toastController.add(ErrorMessage(message: unsyncedVisitResult.error));
          break;
        case SuccessResult<List<UnsyncedVisitAggregate>>():
          _visits.addAll(unsyncedVisitResult.data);
          if (unsyncedVisitResult.data.isNotEmpty) _page++;
          break;
      }
    } finally {
      _state = DisplayingUnsyncedVisitState();
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_state is! DisplayingUnsyncedVisitState) return;
    _page = 0;
    _visits.clear();
    loadMoreItems();
  }

}