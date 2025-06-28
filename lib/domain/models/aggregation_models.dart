import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';

class VisitAggregate {
  final Visit visit;
  final Map<int, Activity> activityMap;

  VisitAggregate({
    required this.visit,
    required this.activityMap,
  });
}

class VisitStatisticsModel {
  final Map<VisitStatus, int> data;

  VisitStatisticsModel({
    required this.data,
  });

}
