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
    return ValueListenableBuilder(
      valueListenable: touchedNotifier,
      builder: (_, touched, __) {
        return Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Flex(
                direction: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: VisitStatus.values.map((v) {
                  bool isTouched = touched == v;
                  return GestureDetector(
                    onTap: () {
                      touchedNotifier.value = v;
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          v.name.capitalize,
                          style: isTouched ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.titleSmall,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: v.color,
                            child: Text(
                              statisticsModel.getCount(v).toString(),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                          touchedNotifier.value = null;
                          return;
                        }
                        touchedNotifier.value = VisitStatus.values[pieTouchResponse.touchedSection!.touchedSectionIndex];
                      },
                    ),
                    startDegreeOffset: 0,
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 1,
                    centerSpaceRadius: 20,
                    sections: VisitStatus.values.map(
                      (e) {
                        double value = statisticsModel.getCount(e).toDouble();
                        double percentage = statisticsModel.getPercentage(e);
                        final isTouched = touched == e;
                        return PieChartSectionData(
                          color: e.color,
                          value: value,
                          title: "${e.name.capitalize} (${percentage.toStringAsFixed(0)}%)",
                          titleStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                          ),
                          showTitle: true,
                          radius: 100,
                          titlePositionPercentageOffset: 0.55,
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
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
