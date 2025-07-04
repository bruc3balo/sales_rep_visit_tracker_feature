import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/remote/remote_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

// Activity
extension ActivityLocalMapper on Activity {
  LocalActivity get toLocal => LocalActivity(
        id: id,
        description: description,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

extension ActivityDomainMapper on LocalActivity {
  Activity get toDomain => Activity(
        id: id,
        description: description,
        createdAt: createdAt,
      );
}

// Customer
extension CustomerLocalMapper on Customer {
  LocalCustomer get toLocal => LocalCustomer(
        id: id,
        name: name,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

extension CustomerDomainMapper on LocalCustomer {
  Customer get toDomain => Customer(
        id: id,
        name: name,
        createdAt: createdAt,
      );
}

//Statistics
extension StatisticsDomainMapper on LocalVisitStatistics {
  VisitStatisticsModel get toDomain => VisitStatisticsModel(
    data: {for(var v in statistics.entries) VisitStatus.findByCapitalizedString(v.key)! : v.value},
    calculatedAt: createdAt,
  );
}

extension StatisticsLocalMapper on VisitStatisticsModel {
  LocalVisitStatistics get toLocal => LocalVisitStatistics(
    statistics: {for(var v in data.entries) v.key.name.capitalize : v.value},
    createdAt: calculatedAt,
  );
}


