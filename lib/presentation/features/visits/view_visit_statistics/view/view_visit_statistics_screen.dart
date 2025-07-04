import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/pie_chart.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Visit statistics"),
      ),
      body: Center(
        child: ListenableBuilder(
          listenable: statisticsViewModel,
          builder: (_, __) {
            var stats = statisticsViewModel.stats;
            switch (statisticsViewModel.state) {
              case LoadingVisitStatistics():
                return InfiniteLoader();

              case LoadedVisitStatistics():
                if (stats == null) {
                  return IconButton(
                    onPressed: statisticsViewModel.calculateRemoteStatistics,
                    icon: Icon(Icons.refresh),
                  );
                }

                return Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    VisitStatisticsPieChart(
                      statisticsModel: stats,
                    ),

                    ListTile(
                      title: Text("Total visits"),
                      subtitle: Text(stats.total.toString()),
                    ),

                    ListTile(
                      title: Text("Last Calculated"),
                      subtitle: Text(stats.calculatedAt.humanReadable),
                      trailing: IconButton(
                        onPressed: statisticsViewModel.calculateRemoteStatistics,
                        icon: Icon(Icons.refresh),
                      ),
                    ),

                  ],
                );
            }
          },
        ),
      ),
    );
  }
}
