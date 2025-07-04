import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';

class VisitStatisticsPieChart extends StatefulWidget {
  const VisitStatisticsPieChart({
    required this.statisticsModel,
    super.key,
  });

  final VisitStatisticsModel statisticsModel;

  @override
  State<StatefulWidget> createState() => VisitStatisticsPieChartState();
}

class VisitStatisticsPieChartState extends State<VisitStatisticsPieChart> {
  ValueNotifier<VisitStatus?> touchedNotifier = ValueNotifier(null);

  VisitStatisticsModel get statisticsModel => widget.statisticsModel;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 28,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: ValueListenableBuilder(
                valueListenable: touchedNotifier,
                builder: (_, touched, __) {
                  return PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                              touchedNotifier.value = null;
                              return;
                            }
                            touchedNotifier.value = VisitStatus.values[pieTouchResponse.touchedSection!.touchedSectionIndex];
                          });
                        },
                      ),
                      startDegreeOffset: 0,
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 1,
                      centerSpaceRadius: 20,
                      sections: VisitStatus.values.map((e) {
                          double? value = statisticsModel.data[e]?.toDouble();
                          double percentageValue = (value ?? 0) / statisticsModel.total * 100;
                          final isTouched = touched == e;
                          return PieChartSectionData(
                            color: e.color,
                            value: value,
                            title: "${e.name.capitalize} ($value)",
                            titleStyle: Theme.of(context).textTheme.titleSmall,
                            showTitle: true,
                            badgeWidget: Text("${percentageValue.toStringAsFixed(0)} %"),
                            radius: 120,
                            titlePositionPercentageOffset: 0.60,
                            badgePositionPercentageOffset: 0.20,
                            borderSide: isTouched
                                ? const BorderSide(
                                    color: Colors.white,
                                    width: 6,
                                  )
                                : BorderSide(
                                    color: Colors.white.withValues(alpha: 0),
                                  ),
                          );
                        },
                      ).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
