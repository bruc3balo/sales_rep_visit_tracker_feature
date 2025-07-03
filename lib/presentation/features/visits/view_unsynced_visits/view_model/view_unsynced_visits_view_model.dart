import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';

import 'package:flutter/cupertino.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/sync_unsynced_local_visits_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/view_unsynced_local_visits_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_unsynced_visits/model/view_unsynced_visits_model.dart';

class ViewUnsyncedVisitsViewModel extends ChangeNotifier {
  final ViewUnsyncedLocalVisitsUseCase _viewUnsyncedLocalVisitsUseCase;
  final SyncUnsyncedLocalVisitsUseCase _syncUnsyncedLocalVisitsUseCase;
  final SplayTreeSet<UnsyncedVisitAggregate> _visits = SplayTreeSet(
    (a, b) => -a.visitDate.compareTo(b.visitDate),
  );
  final StreamController<ToastMessage> _toastStream = StreamController.broadcast();

  UnsyncedVisitsState _state = DisplayingUnsyncedVisitState();
  int _page = 0;

  ViewUnsyncedVisitsViewModel({
    required ViewUnsyncedLocalVisitsUseCase viewUnsyncedLocalVisitsUseCase,
    required SyncUnsyncedLocalVisitsUseCase syncUnsyncedLocalVisitsUseCase,
  })  : _viewUnsyncedLocalVisitsUseCase = viewUnsyncedLocalVisitsUseCase,
        _syncUnsyncedLocalVisitsUseCase = syncUnsyncedLocalVisitsUseCase {
    loadMoreItems();
  }

  UnsyncedVisitsState get state => _state;
  Stream<ToastMessage> get toastStream => _toastStream.stream;

  List<UnsyncedVisitAggregate> get unsyncedVisits => UnmodifiableListView(_visits);

  Future<void> sync() async {
    if (_state is! DisplayingUnsyncedVisitState) return;

    try {
      _state = SyncingVisitState();
      notifyListeners();

      var syncResult = await _syncUnsyncedLocalVisitsUseCase.execute();
      switch (syncResult) {
        case ErrorResult<Map<UnSyncedLocalVisit, SyncStatus>>():
          print("Sync error ${syncResult.error}");
          _state = DisplayingUnsyncedVisitState();
          _toastStream.add(ErrorMessage(message: syncResult.error));
          loadMoreItems();
          break;
        case SuccessResult<Map<UnSyncedLocalVisit, SyncStatus>>():
          var results = groupBy(syncResult.data.entries, (e) => e.value);
          var summary = results.entries.map((e) => "${e.key.name} - ${e.value.length}").join(", ");
          _state = (results[SyncStatus.fail]?.isEmpty ?? true) ? FinishedSyncingVisitState(results: summary) : DisplayingUnsyncedVisitState();
          _toastStream.add(SuccessMessage(message: summary));
          results[SyncStatus.success]?.forEach(_visits.remove);
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
          _toastStream.add(ErrorMessage(message: unsyncedVisitResult.error));
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
