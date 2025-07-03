import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';

import 'package:flutter/cupertino.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/delete_unsynced_visit_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/sync_unsynced_local_visits_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/view_unsynced_local_visits_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_unsynced_visits/model/view_unsynced_visits_model.dart';

class ViewUnsyncedVisitsViewModel extends ChangeNotifier {
  final ViewUnsyncedLocalVisitsUseCase _viewUnsyncedLocalVisitsUseCase;
  final DeleteUnsyncedVisitUseCase _deleteUnsyncedVisitUseCase;
  final SyncUnsyncedLocalVisitsUseCase _syncUnsyncedLocalVisitsUseCase;
  final SplayTreeSet<UnsyncedVisitAggregate> _visits = SplayTreeSet(
        (a, b) => -a.visitDate.compareTo(b.visitDate),
  );

  UnsyncedVisitsState _state = DisplayingUnsyncedVisitState();
  int _page = 0;

  ViewUnsyncedVisitsViewModel({
    required DeleteUnsyncedVisitUseCase deleteUnsyncedVisitUseCase,
    required ViewUnsyncedLocalVisitsUseCase viewUnsyncedLocalVisitsUseCase,
    required SyncUnsyncedLocalVisitsUseCase syncUnsyncedLocalVisitsUseCase,
  })
      : _viewUnsyncedLocalVisitsUseCase = viewUnsyncedLocalVisitsUseCase,
        _deleteUnsyncedVisitUseCase = deleteUnsyncedVisitUseCase,
        _syncUnsyncedLocalVisitsUseCase = syncUnsyncedLocalVisitsUseCase {
    loadMoreItems();
  }

  UnsyncedVisitsState get state => _state;

  List<UnsyncedVisitAggregate> get unsyncedVisits => UnmodifiableListView(_visits);


  Future<void> delete(UnsyncedVisitAggregate visit) async {
    if (_state is! DisplayingUnsyncedVisitState) return;

    try {
      _state = LoadingUnsyncedVisitState(visit: visit);
      notifyListeners();

      var result = await _deleteUnsyncedVisitUseCase.execute(hash: visit.hash);
      switch(result) {

        case ErrorResult<void>():
          GlobalToastMessage().add(ErrorMessage(message: result.error));
          break;
        case SuccessResult<void>():
          _visits.remove(visit);
          GlobalToastMessage().add(SuccessMessage(message: result.message));
          break;
      }
    } finally {
      _state = DisplayingUnsyncedVisitState();
      notifyListeners();
    }
  }

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
          GlobalToastMessage().add(ErrorMessage(message: syncResult.error));
          loadMoreItems();
          break;
        case SuccessResult<Map<UnSyncedLocalVisit, SyncStatus>>():
          var results = groupBy(syncResult.data.entries, (e) => e.value);
          var summary = results.entries.map((e) => "${e.key.name} - ${e.value.length}").join(", ");
          _state = (results[SyncStatus.fail]?.isEmpty ?? true) ? FinishedSyncingVisitState(results: summary) : DisplayingUnsyncedVisitState();
          GlobalToastMessage().add(SuccessMessage(message: summary));
          results[SyncStatus.success]?.forEach((v) => _visits.removeWhere((e) => e.hash.value == v.key.hash));
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
          GlobalToastMessage().add(ErrorMessage(message: unsyncedVisitResult.error));
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
