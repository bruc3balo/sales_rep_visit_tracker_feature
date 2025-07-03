import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/count_visit_statistics_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/model/view_visit_statistics_models.dart';

class ViewVisitStatisticsViewModel extends ChangeNotifier {
  final CountVisitStatisticsUseCase _countVisitStatisticsUseCase;
  VisitStatisticsState _state = LoadedVisitStatistics();
  VisitStatisticsModel? _stats;

  ViewVisitStatisticsViewModel({
    required CountVisitStatisticsUseCase countVisitStatisticsUseCase,
  }) : _countVisitStatisticsUseCase = countVisitStatisticsUseCase;

  VisitStatisticsState get state => _state;

  VisitStatisticsModel? get stats => _stats;

  Future<void> calculateStatistics() async {
    if (_state is! LoadedVisitStatistics) return;

    try {
      _state = LoadingVisitStatistics();
      notifyListeners();

      var statsResults = await _countVisitStatisticsUseCase.execute();
      switch (statsResults) {
        case ErrorResult<VisitStatisticsModel>():
          GlobalToastMessage().add(ErrorMessage(message: statsResults.error));
          break;
        case SuccessResult<VisitStatisticsModel>():
          _stats = statsResults.data;
          break;
      }
    } finally {
      _state = LoadedVisitStatistics();
      notifyListeners();
    }
  }
}
