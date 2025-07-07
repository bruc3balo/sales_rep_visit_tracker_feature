import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';

import 'package:flutter/cupertino.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/sync_status.dart';
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
  late final StreamSubscription<bool> _syncSubscription;
  late final StreamSubscription<UnsyncedVisitAggregate> _updatedVisitSubscription;
  final SplayTreeSet<UnsyncedVisitAggregate> _visits = SplayTreeSet(
    (a, b) => -a.visitDate.compareTo(b.visitDate),
  );

  UnsyncedVisitsState _state = DisplayingUnsyncedVisitState();
  int _page = 0;
  static final int _pageSize = 20;

  ViewUnsyncedVisitsViewModel({
    required DeleteUnsyncedVisitUseCase deleteUnsyncedVisitUseCase,
    required ViewUnsyncedLocalVisitsUseCase viewUnsyncedLocalVisitsUseCase,
    required SyncUnsyncedLocalVisitsUseCase syncUnsyncedLocalVisitsUseCase,
  })  : _viewUnsyncedLocalVisitsUseCase = viewUnsyncedLocalVisitsUseCase,
        _deleteUnsyncedVisitUseCase = deleteUnsyncedVisitUseCase {
    loadMoreItems();
    _subscribeToStreamStatus();
    _subscribeToUpdateVisitStream();
  }

  UnsyncedVisitsState get state => _state;

  List<UnsyncedVisitAggregate> get unsyncedVisits => UnmodifiableListView(_visits);

  Future<void> delete(UnsyncedVisitAggregate visit) async {
    if (_state is! DisplayingUnsyncedVisitState) return;

    try {
      _state = LoadingUnsyncedVisitState(visit: visit);
      notifyListeners();

      var result = await _deleteUnsyncedVisitUseCase.execute(hash: visit.hash);
      switch (result) {
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

  Future<void> loadMoreItems() async {
    if (_state is! DisplayingUnsyncedVisitState) return;

    try {
      _state = LoadingUnsyncedVisitState();
      notifyListeners();

      var unsyncedVisitResult = await _viewUnsyncedLocalVisitsUseCase.execute(
        page: _page,
        pageSize: _pageSize,
      );

      switch (unsyncedVisitResult) {
        case ErrorResult<List<UnsyncedVisitAggregate>>():
          GlobalToastMessage().add(ErrorMessage(message: unsyncedVisitResult.error));
          break;
        case SuccessResult<List<UnsyncedVisitAggregate>>():
          _visits.addAll(unsyncedVisitResult.data);
          if (unsyncedVisitResult.data.length >= _pageSize) _page++;
          break;
      }
    } finally {
      _state = DisplayingUnsyncedVisitState();
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_state is SyncingVisitState) return;
    _page = 0;
    _visits.clear();
    loadMoreItems();
  }

  void _subscribeToStreamStatus() {
    //Event based, are triggered
    _syncSubscription = VisitSyncStatus().syncStream.listen((syncing) {
      //Start sync triggered
      if (syncing) {
        _state = SyncingVisitState();
        notifyListeners();
        return;
      }

      _state = DisplayingUnsyncedVisitState();
      refresh();
      notifyListeners();
    });
  }

  void _subscribeToUpdateVisitStream() {

    //Event based, are triggered
    AppLog.I.i("ViewUnsyncedVisitsViewModel", "Subscribed to update visit stream");
    _updatedVisitSubscription = _viewUnsyncedLocalVisitsUseCase.onUpdatedLocalVisitStream.listen((updatedVisit) {
      AppLog.I.i("ViewUnsyncedVisitsViewModel", "Visit updated ${updatedVisit.customer?.name}");
      _visits.removeWhere((v) => v.key == updatedVisit.key);
      _visits.add(updatedVisit);
      notifyListeners();
      AppLog.I.i("ViewUnsyncedVisitsViewModel", "Visit updated res  ${_visits.where((e) => e.key == updatedVisit.key).firstOrNull?.customer?.name}");

    });
  }

  void _unsubscribeFromUpdateVisitStream() =>  _updatedVisitSubscription.cancel();

  void _unsubscribeFromStreamStatus() => _syncSubscription.cancel();

  @override
  void dispose() {
    _unsubscribeFromUpdateVisitStream();
    _unsubscribeFromStreamStatus();
    super.dispose();
  }
}
