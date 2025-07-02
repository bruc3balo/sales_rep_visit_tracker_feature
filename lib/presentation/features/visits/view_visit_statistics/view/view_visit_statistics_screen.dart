import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/components.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/model/view_visit_statistics_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/view_visit_statistics/view_model/view_visit_statistics_view_model.dart';

class ViewVisitStatisticsScreen extends StatelessWidget {
  const ViewVisitStatisticsScreen({
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
        var stats = statisticsViewModel.stats;

        switch (statisticsViewModel.state) {
          case LoadingVisitStatistics():
            return InfiniteLoader();

          case LoadedVisitStatistics():
            if (stats == null) {
              return IconButton(
                onPressed: statisticsViewModel.calculateStatistics,
                icon: Icon(Icons.refresh),
              );
            }

            return Container(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GridView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 50),
                    children: stats.data.entries
                        .map(
                          (e) => Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(e.key.name.capitalize),
                                Text(e.value.toString()),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  IconButton(
                    onPressed: statisticsViewModel.calculateStatistics,
                    icon: Icon(Icons.refresh),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}
