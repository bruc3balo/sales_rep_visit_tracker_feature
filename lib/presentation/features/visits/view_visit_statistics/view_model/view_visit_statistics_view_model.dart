import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/count_visit_statistics_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/get_local_visit_statistics_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/get_remote_daily_visit_statistics_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/get_remote_weekly_visit_statistics_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/get_top_n_completed_visit_statistics_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/model/view_visit_statistics_models.dart';

class ViewVisitStatisticsViewModel extends ChangeNotifier {
  final GetTopCustomersVisitStatisticsUseCase _getTopCustomersVisitStatisticsUseCase;
  final GetRemoteDailyVisitStatisticsUseCase _getRemoteDailyVisitStatisticsUseCase;
  final GetRemoteWeeklyVisitStatisticsUseCase _getRemoteWeeklyVisitStatisticsUseCase;
  final GetLocalVisitStatisticsUseCase _getLocalVisitStatisticsUseCase;
  final CountVisitStatisticsUseCase _countVisitStatisticsUseCase;

  StatisticType _statisticType = StatisticType.values.first;

  VisitStatisticsState _visitStatusState = LoadedVisitStatistics();
  WeeklyStatisticsState _weeklyStatusState = LoadedWeeklyStatistics();
  DailyStatisticsState _dailyStatusState = LoadedDailyStatistics();
  CompletedVisitStatisticsState _topNCustomersState = LoadedCompletedStatistics();

  //Stats
  int get topN => 5;

  ViewVisitStatisticsViewModel({
    required GetTopCustomersVisitStatisticsUseCase getTopCustomersVisitStatisticsUseCase,
    required GetRemoteDailyVisitStatisticsUseCase getRemoteDailyVisitStatisticsUseCase,
    required GetRemoteWeeklyVisitStatisticsUseCase getRemoteWeeklyVisitStatisticsUseCase,
    required GetLocalVisitStatisticsUseCase getLocalVisitStatisticsUseCase,
    required CountVisitStatisticsUseCase countVisitStatisticsUseCase,
  })  : _countVisitStatisticsUseCase = countVisitStatisticsUseCase,
        _getTopCustomersVisitStatisticsUseCase = getTopCustomersVisitStatisticsUseCase,
        _getLocalVisitStatisticsUseCase = getLocalVisitStatisticsUseCase,
        _getRemoteDailyVisitStatisticsUseCase = getRemoteDailyVisitStatisticsUseCase,
        _getRemoteWeeklyVisitStatisticsUseCase = getRemoteWeeklyVisitStatisticsUseCase {
    Future.wait([
      getLocalVisitStatusStatistics(),
      calculateWeeklyVisitStatusStatistics(),
      calculateCompletedVisitsStatistics(),
      calculateDailyVisitStatusStatistics(),
    ]);
  }

  DailyStatisticsState get dailyStatusState => _dailyStatusState;

  WeeklyStatisticsState get weeklyStatusState => _weeklyStatusState;

  VisitStatisticsState get visitStatusState => _visitStatusState;

  CompletedVisitStatisticsState get topNCustomersState => _topNCustomersState;

  StatisticType get statisticType => _statisticType;

  List<StatisticType> get statistics => StatisticType.values;

  void changeStatisticType(StatisticType type) {
    if (_statisticType == type) return;
    _statisticType = type;
    notifyListeners();
  }

  Future<void> getLocalVisitStatusStatistics() async {
    if (_visitStatusState is! LoadedVisitStatistics) return;

    try {
      _visitStatusState = LoadingVisitStatistics();
      notifyListeners();

      var statsResults = await _getLocalVisitStatisticsUseCase.execute();
      switch (statsResults) {
        case ErrorResult<VisitStatisticsModel?>():
          _visitStatusState = LoadedVisitStatistics();
          GlobalToastMessage().add(ErrorMessage(message: statsResults.error));
          break;
        case SuccessResult<VisitStatisticsModel?>():
          _visitStatusState = LoadedVisitStatistics(stats: statsResults.data);
          if(statsResults.data == null) calculateRemoteVisitStatusStatistics();
          break;
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> calculateRemoteVisitStatusStatistics() async {
    if (_visitStatusState is! LoadedVisitStatistics) return;

    try {
      _visitStatusState = LoadingVisitStatistics();
      notifyListeners();

      var statsResults = await _countVisitStatisticsUseCase.execute();
      switch (statsResults) {
        case ErrorResult<VisitStatisticsModel>():
          GlobalToastMessage().add(ErrorMessage(message: statsResults.error));
          _visitStatusState = LoadedVisitStatistics();
          break;
        case SuccessResult<VisitStatisticsModel>():
          _visitStatusState = LoadedVisitStatistics(stats: statsResults.data);
          break;
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> calculateWeeklyVisitStatusStatistics() async {
    if (_weeklyStatusState is! LoadedWeeklyStatistics) return;

    try {
      _weeklyStatusState = LoadingWeeklyStatistics();
      notifyListeners();

      var statsResults = await _getRemoteWeeklyVisitStatisticsUseCase.execute();
      switch (statsResults) {
        case ErrorResult<Last7DaysStatistics>():
          GlobalToastMessage().add(ErrorMessage(message: statsResults.error));
          _weeklyStatusState = LoadedWeeklyStatistics();
          break;
        case SuccessResult<Last7DaysStatistics>():
          _weeklyStatusState = LoadedWeeklyStatistics(stats: statsResults.data);

          break;
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> calculateDailyVisitStatusStatistics() async {
    if (_dailyStatusState is! LoadedDailyStatistics) return;

    try {
      _dailyStatusState = LoadingDailyStatistics();
      notifyListeners();

      var statsResults = await _getRemoteDailyVisitStatisticsUseCase.execute();
      switch (statsResults) {
        case ErrorResult<TodayStatistics>():
          GlobalToastMessage().add(ErrorMessage(message: statsResults.error));
          _dailyStatusState = LoadedDailyStatistics();
          break;
        case SuccessResult<TodayStatistics>():
          _dailyStatusState = LoadedDailyStatistics(stats: statsResults.data);

          break;
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> calculateCompletedVisitsStatistics() async {
    if (_topNCustomersState is! LoadedCompletedStatistics) return;

    try {
      _topNCustomersState = LoadingCompletedStatistics();
      notifyListeners();

      var statsResults = await _getTopCustomersVisitStatisticsUseCase.execute(topN);
      switch (statsResults) {
        case ErrorResult<CompletedVisitStatistics>():
          GlobalToastMessage().add(ErrorMessage(message: statsResults.error));
          _topNCustomersState = LoadedCompletedStatistics();
          break;
        case SuccessResult<CompletedVisitStatistics>():
          _topNCustomersState = LoadedCompletedStatistics(stats: statsResults.data);
          break;
      }
    } finally {
      notifyListeners();
    }
  }
}
