import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class TodaysVisitsLineChart extends StatelessWidget {
  const TodaysVisitsLineChart({
    super.key,
    required this.stats,
  });

  final TodayStatistics stats;

  Map<int, int> buildVisitStatsByHour(List<Visit> visits) {
    final visitsByHour = <int, int>{};

    for (final visit in visits) {
      final hour = visit.visitDate.hour;
      visitsByHour[hour] = (visitsByHour[hour] ?? 0) + 1;
    }

    // Fill all 24 hours to ensure smooth line
    return { for (var h in List.generate(TimeOfDay.hoursPerDay, (i) => i)) h : visitsByHour[h] ?? 0 };
  }

  @override
  Widget build(BuildContext context) {
    final stats = buildVisitStatsByHour(this.stats.visits);
    final spots = stats.entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();

    final maxY = stats.values.fold(0, (a, b) => a > b ? a : b).toDouble() + 1;

    return AspectRatio(
      aspectRatio: 1.8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 23,
            minY: 0,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 3,
                color: Colors.teal,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.teal.withOpacity(0.2),
                ),
              ),
            ],
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, _) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 3,
                  getTitlesWidget: (value, _) {
                    final hour = value.toInt();
                    if (hour < 0 || hour > 23) return const SizedBox();
                    return Text(
                      '$hour:00',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
          ),
        ),
      ),
    );
  }
}
