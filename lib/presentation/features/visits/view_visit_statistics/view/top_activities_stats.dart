import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class TopActivitiesStats extends StatelessWidget {
  const TopActivitiesStats({
    required this.stats,
    required this.n,
    super.key,
  });

  final TopActivityStatistics stats;
  final int n;

  List<MapEntry<Activity, int>> topNList() {
  final topN = stats.statistics.entries
      .map((entry) => MapEntry(entry.key, entry.value.length))
      .toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return topN.take(n).toList();
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: topNList().toList().asMap().entries.map((entry) {
        final itemNumber = entry.key + 1;
        final e = entry.value;
        return ListTile(
          leading: Text(itemNumber.toString()),
          title: Text(e.key.description),
          trailing: CircleAvatar(
            child: Text(e.value.toString()),
          ),
        );
      }).toList(),
    );
  }

}