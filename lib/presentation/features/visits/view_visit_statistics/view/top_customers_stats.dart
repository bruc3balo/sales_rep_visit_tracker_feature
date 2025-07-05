import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class TopCustomersStats extends StatelessWidget {
  const TopCustomersStats({
    required this.stats,
    super.key,
  });

  final TopCustomerStatistics stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stats.statistics.entries.toList().asMap().entries.map((entry) {
        final index = entry.key + 1; // 1-based index
        final e = entry.value;

        return ListTile(
          leading: Text(index.toString()),
          title: Text(e.key.name),
          trailing: CircleAvatar(
            child: Text(e.value.toString()),
          ),
        );
      }).toList(),
    );
  }
}
