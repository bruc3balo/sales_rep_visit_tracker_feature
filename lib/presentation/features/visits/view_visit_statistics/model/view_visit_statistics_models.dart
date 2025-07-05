import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

// VisitStatisticsState
sealed class VisitStatisticsState {}

class LoadingVisitStatistics extends VisitStatisticsState {}

class LoadedVisitStatistics extends VisitStatisticsState {
  final VisitStatisticsModel? stats;

  LoadedVisitStatistics({ this.stats});
}

// WeeklyStatistics
sealed class WeeklyStatisticsState {}

class LoadingWeeklyStatistics extends WeeklyStatisticsState {}

class LoadedWeeklyStatistics extends WeeklyStatisticsState {
  final Last7DaysStatistics? stats;

  LoadedWeeklyStatistics({ this.stats});
}

// DailyStatistics
sealed class DailyStatisticsState {}

class LoadingDailyStatistics extends DailyStatisticsState {}

class LoadedDailyStatistics extends DailyStatisticsState {
  final TodayStatistics? stats;

  LoadedDailyStatistics({ this.stats});
}

// TopNCustomersState
sealed class CompletedVisitStatisticsState {}

class LoadingCompletedStatistics extends CompletedVisitStatisticsState {}

class LoadedCompletedStatistics extends CompletedVisitStatisticsState {
  final CompletedVisitStatistics? stats;

  LoadedCompletedStatistics({ this.stats});
}

// StatisticType
enum StatisticType {
  last7DaysVisits(label: "Last 7 days visits"),
  weeklyStatusVisits(label: "Last 7 days status visits"),
  totalStatusDistribution(label: "Total status distribution"),
  top5Customers(label: "Top 5 customers"),
  activityHeatMap(label: "Activity heat map"),
  todayVisits(label: "Today's visits");

  final String label;

  const StatisticType({
    required this.label,
  });
}

// DayOfWeek
enum DayOfWeek {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  final int weekday;

  const DayOfWeek(this.weekday);

  String get label => name.capitalize;

  String get shortLabel => name.capitalize.substring(0, 3);

  static DayOfWeek? findByDay(int day) {
    return DayOfWeek.values.firstWhere(
      (d) => d.weekday == day,
      orElse: () => throw ArgumentError('Invalid day: $day'),
    );
  }

  static const int daysPerWeek = 7;
}
