import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/model/view_visit_statistics_models.dart';

class WeeklyVisitsLineChart extends StatelessWidget {
  const WeeklyVisitsLineChart({
    super.key,
    required this.visits,
  });

  final List<Visit> visits;

  @override
  Widget build(BuildContext context) {
    final visitsByStatus = groupBy(visits, (v) => v.status);
    double maxY = 0;
    final List<LineChartBarData> lineBars = visitsByStatus.entries.map((entry) {
      final status = entry.key;
      final visitStatus = VisitStatus.findByCapitalizedString(status);
      final groupedByWeekday = groupBy(entry.value, (v) => v.visitDate.weekday);

      final spots = List.generate(7, (index) {
        final weekday = index + 1;
        final count = groupedByWeekday[weekday]?.length ?? 0;
        maxY = maxY < count ? count.toDouble() : maxY;
        return FlSpot(weekday.toDouble(), count.toDouble());
      });

      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: visitStatus?.color,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          color: visitStatus?.color.withAlpha(5),
        ),
      );
    }).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...VisitStatus.values.map(
          (s) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Flex(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                direction: Axis.horizontal,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(s.name.capitalize),
                  ),
                  Expanded(
                    child: Divider(
                      color: s.color,
                      thickness: 2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        AspectRatio(
          aspectRatio: 1.2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                maxY: maxY + 1,
                minY: 0,
                lineBarsData: lineBars,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(
                      "Day of week",
                      style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.secondary),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final weekday = value.toInt();
                        bool isThisWeek = weekday <= DateTime.now().weekday;
                        return Text(
                          DayOfWeek.findByDay(weekday)?.shortLabel ?? '',
                          style: TextStyle(fontSize: 10, color: isThisWeek ? Colors.green : Colors.grey),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(
                      "Visit count",
                      style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.secondary),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
