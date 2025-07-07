import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/model/view_visit_statistics_models.dart';

class WeeklyVisitsBarChart extends StatelessWidget {
  const WeeklyVisitsBarChart({
    super.key,
    required this.visits,
  });

  final List<Visit> visits;

  @override
  Widget build(BuildContext context) {
    final grouped = groupBy(visits, (v) => v.visitDate.weekday);

    final barGroups = DayOfWeek.values.map((day) {
      var weekday = day.weekday;
      var dayVisitCount = grouped[weekday]?.length ?? 0;
      return BarChartGroupData(
        x: weekday,
        barRods: [
          BarChartRodData(
            toY: dayVisitCount.toDouble(),
            color: Colors.deepPurple,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    final maxCount = grouped.values.map((v) => v.length).fold(0, (a, b) => a > b ? a : b);

    return AspectRatio(
      aspectRatio: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxCount.toDouble(),
            barGroups: barGroups,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                axisNameWidget: Text(
                  "Visit count",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                axisNameSize: 22,
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) => Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Text(
                  "Day of week",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                axisNameSize: 22,
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final weekday = value.toInt();
                    bool isThisWeek = weekday <= DateTime.now().weekday;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DayOfWeek.findByDay(weekday)?.shortLabel ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isThisWeek ? FontWeight.bold : FontWeight.normal,
                          color: isThisWeek ? Colors.green : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: false),
          ),
        ),
      ),
    );
  }
}
