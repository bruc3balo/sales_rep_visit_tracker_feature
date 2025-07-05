import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/view/activity_heatmap_stats.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/view/today_visit_stats.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/view/top_customers_stats.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/view/visit_pie_chart.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/model/view_visit_statistics_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/view/weekly_line_chart_stats.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/view/weekly_visit_bar_chart_stats.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/view_model/view_visit_statistics_view_model.dart';

class ViewVisitStatisticsScreen extends StatelessWidget {
  ViewVisitStatisticsScreen({
    required this.statisticsViewModel,
    this.maxHeight = 200,
    super.key,
  });

  final ViewVisitStatisticsViewModel statisticsViewModel;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: statisticsViewModel,
      builder: (_, __) {
        var statisticsList = statisticsViewModel.statistics;
        var currentStatistic = statisticsViewModel.statisticType;
        final PageController statsPageController = PageController(
          initialPage: currentStatistic.index,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(currentStatistic.label),
          ),
          body: PageView.builder(
            controller: statsPageController,
            itemCount: statisticsList.length,
            onPageChanged: (index) {
              statisticsViewModel.changeStatisticType(statisticsViewModel.statistics[index]);
            },
            itemBuilder: (_, i) {
              var statType = statisticsViewModel.statistics[i];

              switch (statType) {
                case StatisticType.totalStatusDistribution:
                  return VisitStatusStatistics(
                    state: statisticsViewModel.visitStatusState,
                    calculateRemoteStatistics: statisticsViewModel.calculateRemoteVisitStatusStatistics,
                  );

                case StatisticType.last7DaysVisits:
                  return Last7DaysStatistics(
                    state: statisticsViewModel.weeklyStatusState,
                    calculateRemoteStatistics: statisticsViewModel.calculateWeeklyVisitStatusStatistics,
                  );

                case StatisticType.weeklyStatusVisits:
                  return Last7DaysLineStatistics(
                    state: statisticsViewModel.weeklyStatusState,
                    calculateRemoteStatistics: statisticsViewModel.calculateWeeklyVisitStatusStatistics,
                  );

                case StatisticType.top5Customers:
                  return TopNCustomerStatistics(
                    topN: statisticsViewModel.topN,
                    state: statisticsViewModel.topNCustomersState,
                    calculateRemoteStatistics: statisticsViewModel.calculateCompletedVisitsStatistics,
                  );

                case StatisticType.activityHeatMap:
                  return ActivityHeatMapStatistics(
                    state: statisticsViewModel.topNCustomersState,
                    calculateRemoteStatistics: statisticsViewModel.calculateCompletedVisitsStatistics,
                  );

                case StatisticType.todayVisits:
                  return TodayVisitsStatistics(
                    state: statisticsViewModel.dailyStatusState,
                    calculateRemoteStatistics: statisticsViewModel.calculateDailyVisitStatusStatistics,
                  );
              }
            },
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: IconButton(
                  onPressed: () {
                    var index = statisticsList.indexOf(currentStatistic) - 1;
                    if (index < 0) return;

                    var previous = statisticsViewModel.statistics[index];
                    statisticsViewModel.changeStatisticType(previous);
                    statsPageController.animateToPage(
                      index,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: Icon(Icons.arrow_back),
                ),
                title: DotsIndicator(
                  dotsCount: statisticsList.length,
                  position: currentStatistic.index.toDouble(),
                  decorator: DotsDecorator(
                    shapes: statisticsList.map((e) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))).toList(),
                    activeShapes: statisticsList.map((e) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))).toList(),
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    var index = statisticsList.indexOf(currentStatistic) + 1;
                    if (index >= statisticsList.length) return;

                    var next = statisticsViewModel.statistics[index];
                    statisticsViewModel.changeStatisticType(next);
                    statsPageController.animateToPage(
                      index,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: Icon(Icons.arrow_forward),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class VisitStatusStatistics extends StatelessWidget {
  const VisitStatusStatistics({
    required this.state,
    required this.calculateRemoteStatistics,
    super.key,
  });

  final VisitStatisticsState state;
  final Function() calculateRemoteStatistics;

  @override
  Widget build(BuildContext context) {
    var state = this.state;

    switch (state) {
      case LoadingVisitStatistics():
        return InfiniteLoader();

      case LoadedVisitStatistics():
        var stats = state.stats;
        if (stats == null) {
          return IconButton(
            onPressed: calculateRemoteStatistics,
            icon: Icon(Icons.refresh),
          );
        }

        return Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: VisitStatisticsPieChart(
                statisticsModel: stats,
              ),
            ),
            ListTile(
              title: Text("Total visits"),
              subtitle: Text(stats.total.toString()),
            ),
            ListTile(
              title: Text("Last Calculated"),
              subtitle: Text(stats.calculatedAt.humanReadable),
              trailing: IconButton(
                onPressed: calculateRemoteStatistics,
                icon: Icon(Icons.refresh),
              ),
            ),
          ],
        );
    }
  }
}

class Last7DaysStatistics extends StatelessWidget {
  const Last7DaysStatistics({
    required this.state,
    required this.calculateRemoteStatistics,
    super.key,
  });

  final WeeklyStatisticsState state;
  final Function() calculateRemoteStatistics;

  @override
  Widget build(BuildContext context) {
    var state = this.state;
    switch (state) {
      case LoadingWeeklyStatistics():
        return InfiniteLoader();

      case LoadedWeeklyStatistics():

        var stats = state.stats?.visits ?? [];

        if (stats.isEmpty) {
          return IconButton(
            onPressed: calculateRemoteStatistics,
            icon: Icon(Icons.refresh),
          );
        }

        return Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: WeeklyVisitsBarChart(
                visits: stats,
              ),
            ),
            ListTile(
              title: Text("Total visits for last 7 days"),
              subtitle: Text(stats.length.toString()),
            ),
            ListTile(
              title: Text("Last Calculated"),
              subtitle: Text(DateTime.now().humanReadable),
              trailing: IconButton(
                onPressed: calculateRemoteStatistics,
                icon: Icon(Icons.refresh),
              ),
            ),
          ],
        );
    }
  }
}

class Last7DaysLineStatistics extends StatelessWidget {
  const Last7DaysLineStatistics({
    required this.state,
    required this.calculateRemoteStatistics,
    super.key,
  });

  final WeeklyStatisticsState state;
  final Function() calculateRemoteStatistics;

  @override
  Widget build(BuildContext context) {
    var state = this.state;
    switch (state) {
      case LoadingWeeklyStatistics():
        return InfiniteLoader();

      case LoadedWeeklyStatistics():
        var stats = state.stats?.visits ?? [];

        if (stats.isEmpty) {
          return IconButton(
            onPressed: calculateRemoteStatistics,
            icon: Icon(Icons.refresh),
          );
        }

        return Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: WeeklyVisitsLineChart(
                visits: stats,
              ),
            ),
            ListTile(
              title: Text("Total visits for last 7 days"),
              subtitle: Text(stats.length.toString()),
            ),
            ListTile(
              title: Text("Last Calculated"),
              subtitle: Text(DateTime.now().humanReadable),
              trailing: IconButton(
                onPressed: calculateRemoteStatistics,
                icon: Icon(Icons.refresh),
              ),
            ),
          ],
        );
    }
  }
}

class TopNCustomerStatistics extends StatelessWidget {
  const TopNCustomerStatistics({
    required this.topN,
    required this.state,
    required this.calculateRemoteStatistics,
    super.key,
  });

  final int topN;
  final CompletedVisitStatisticsState state;
  final Function() calculateRemoteStatistics;

  @override
  Widget build(BuildContext context) {
    var state = this.state;
    switch (state) {
      case LoadingCompletedStatistics():
        return InfiniteLoader();

      case LoadedCompletedStatistics():
        var stats = state.stats;

        if (stats == null) {
          return IconButton(
            onPressed: calculateRemoteStatistics,
            icon: Icon(Icons.refresh),
          );
        }

        return Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TopCustomersStats(
                stats: stats.customer,
              ),
            ),
            ListTile(
              title: Text("Last Calculated"),
              subtitle: Text(DateTime.now().humanReadable),
              trailing: IconButton(
                onPressed: calculateRemoteStatistics,
                icon: Icon(Icons.refresh),
              ),
            ),
          ],
        );
    }
  }
}

class ActivityHeatMapStatistics extends StatelessWidget {
  const ActivityHeatMapStatistics({
    required this.state,
    required this.calculateRemoteStatistics,
    super.key,
  });

  final CompletedVisitStatisticsState state;
  final Function() calculateRemoteStatistics;

  @override
  Widget build(BuildContext context) {
    var state = this.state;
    switch (state) {
      case LoadingCompletedStatistics():
        return InfiniteLoader();

      case LoadedCompletedStatistics():
        var stats = state.stats;
        if (stats == null) {
          return IconButton(
            onPressed: calculateRemoteStatistics,
            icon: Icon(Icons.refresh),
          );
        }

        return Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ActivityHeatmap(
                stats: stats.activity,
              ),
            ),
            ListTile(
              title: Text("Last Calculated"),
              subtitle: Text(DateTime.now().humanReadable),
              trailing: IconButton(
                onPressed: calculateRemoteStatistics,
                icon: Icon(Icons.refresh),
              ),
            ),
          ],
        );
    }
  }
}

class TodayVisitsStatistics extends StatelessWidget {
  const TodayVisitsStatistics({
    required this.state,
    required this.calculateRemoteStatistics,
    super.key,
  });

  final DailyStatisticsState state;
  final Function() calculateRemoteStatistics;

  @override
  Widget build(BuildContext context) {
    var state = this.state;
    switch (state) {
      case LoadingDailyStatistics():
        return InfiniteLoader();

      case LoadedDailyStatistics():
        var stats = state.stats;
        if (stats == null) {
          return IconButton(
            onPressed: calculateRemoteStatistics,
            icon: Icon(Icons.refresh),
          );
        }

        return Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TodaysVisitsLineChart(
                stats: stats,
              ),
            ),
            ListTile(
              title: Text("Last Calculated"),
              subtitle: Text(DateTime.now().humanReadable),
              trailing: IconButton(
                onPressed: calculateRemoteStatistics,
                icon: Icon(Icons.refresh),
              ),
            ),
          ],
        );
    }
  }
}
