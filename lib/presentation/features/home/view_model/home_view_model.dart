import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/sync_status.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/count_unsynced_visit_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/home/model/home_models.dart';

class HomeViewModel extends ChangeNotifier {
  final CountUnsyncedVisitsUseCase _countUnsyncedVisitsUseCase;
  final List<HomePages> homePages = UnmodifiableListView(HomePages.values);
  late final StreamSubscription<void> _countUpdatedSubscription;
  late final StreamSubscription<bool> _syncSubscription;

  HomePages _currentPage = HomePages.visits;
  CountHomeVisitsState _visitCountState = LoadedCountVisitState(
      unSyncedVisitCount: null,
  );

  HomeViewModel({
    required CountUnsyncedVisitsUseCase countUnsyncedVisitsUseCase
  }) : _countUnsyncedVisitsUseCase = countUnsyncedVisitsUseCase {
    initializeViewModel();
  }


  HomePages get currentPage => _currentPage;
  CountHomeVisitsState get visitCountState => _visitCountState;

  void initializeViewModel() {
    _countUnsyncedVisits();
    _countUpdatedSubscription = _countUnsyncedVisitsUseCase.onUpdatedStream.listen((_) async => await _countUnsyncedVisits());
    _syncSubscription = VisitSyncStatus().syncStream.listen((isSyncing) {
      if(isSyncing) return;
      _countUnsyncedVisits();
    });
  }

  void changePage(int pageIndex) {
    _countUnsyncedVisits();
    if(homePages[pageIndex] == _currentPage) return;
    _currentPage = homePages[pageIndex];
    notifyListeners();
  }

  Future<void> _countUnsyncedVisits() async {
    if(_visitCountState is! LoadedCountVisitState) return;

    try {
      _visitCountState = LoadingCountVisitState();
      notifyListeners();

      var countResult = await _countUnsyncedVisitsUseCase.execute();
      switch(countResult) {

        case ErrorResult<int>():
          GlobalToastMessage().add(ErrorMessage(message: countResult.error));
          _visitCountState = LoadedCountVisitState(
            unSyncedVisitCount: null,
          );
          break;

        case SuccessResult<int>():
          _visitCountState = LoadedCountVisitState(
            unSyncedVisitCount: countResult.data,
          );
          break;
      }

    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _countUpdatedSubscription.cancel();
    _syncSubscription.cancel();
    super.dispose();
  }

}