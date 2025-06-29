import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';

class VisitAggregate {
  final Visit visit;
  final Map<int, Activity> activityMap;
  final Customer? customer;

  VisitAggregate({
    required this.visit,
    required this.activityMap,
    required this.customer,
  });
}

class VisitStatisticsModel {
  final Map<VisitStatus, int> data;
  final DateTime calculatedAt = DateTime.now();

  VisitStatisticsModel({
    required this.data,
  });

}
