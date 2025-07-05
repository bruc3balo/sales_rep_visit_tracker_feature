import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/model/view_visit_statistics_models.dart';

class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({
    super.key,
    required this.stats,
  });

  final TopActivityStatistics stats;

  Map<Activity, List<Visit>> get statistics => stats.statistics;

  @override
  Widget build(BuildContext context) {
    final dayLabels = DayOfWeek.values.map((d) => d.shortLabel);

    // Step 1: Build heatmap matrix per activity
    final matrix = <Activity, Map<int, int>>{};
    for (final entry in statistics.entries) {
      final activity = entry.key;
      final visits = entry.value;
      final counts = groupBy(visits, (v) => v.visitDate.weekday).map((day, visits) => MapEntry(day, visits.length));
      matrix[activity] = counts;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Activity')),
          ...dayLabels.map((d) => DataColumn(label: Text(d))),
        ],
        rows: matrix.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value.key;
          final dayCounts = entry.value.value;

          final isEven = index.isEven;
          final rowColor = isEven ? WidgetStateProperty.all(Colors.grey.shade300) : null;

          return DataRow(
            color: rowColor,
            cells: [
              DataCell(Text(activity.description)),
              ...List.generate(
                7,
                    (i) {
                  final day = i + 1;
                  final count = dayCounts[day] ?? 0;
                  final color = _heatColor(count);
                  return DataCell(
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: color,
                      child: count > 0
                          ? Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12))
                          : const SizedBox.shrink(),
                    ),
                  );
                },
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Color scale based on count
  Color _heatColor(int count) {
    if (count >= 5) return Colors.red;
    if (count >= 3) return Colors.orange;
    if (count >= 1) return Colors.green;
    return Colors.grey.shade200;
  }
}
