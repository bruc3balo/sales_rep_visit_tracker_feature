import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';

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

class UnsyncedVisitAggregate {
  final dynamic key;
  final LocalVisitHash hash;
  final DateTime visitDate;
  final VisitStatus status;
  final String location;
  final String notes;
  final DateTime? createdAt;
  final Map<int, ActivityRef> activityMap;
  final CustomerRef? customer;

  UnsyncedVisitAggregate({
    required this.key,
    required this.hash,
    required this.visitDate,
    required this.status,
    required this.location,
    required this.notes,
    required this.createdAt,
    required this.activityMap,
    required this.customer,
  });
}

class ActivityRef {
  final int id;
  final String description;

  ActivityRef(this.id, this.description);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityRef && other.id == id && other.description == description;
  }

  @override
  int get hashCode => id.hashCode ^ description.hashCode;
}

class CustomerRef {
  final int id;
  final String name;

  CustomerRef(this.id, this.name);
}

class VisitStatisticsModel {
  final Map<VisitStatus, int> data;
  final DateTime calculatedAt;

  VisitStatisticsModel({
    required this.data,
    required this.calculatedAt,
  });

  int get total => data.values.fold(0, (prev, curr) => prev + curr);

  double getPercentage(VisitStatus status) {
    int statusCount = getCount(status);
    return (statusCount * 100) / total;
  }

  int getCount(VisitStatus status) {
    return data[status] ?? 0;
  }
}

enum SyncStatus { success, fail }

class CompletedVisitStatistics {
  final TopCustomerStatistics customer;
  final TopActivityStatistics activity;

  CompletedVisitStatistics({
    required this.customer,
    required this.activity,
  });
}

class TopCustomerStatistics {
  final Map<Customer, int> statistics;

  TopCustomerStatistics({required this.statistics});
}

class TopActivityStatistics {
  final Map<Activity, List<Visit>> statistics;

  TopActivityStatistics({required this.statistics});
}


class Last7DaysStatistics {
  final List<Visit> visits;

  Last7DaysStatistics({required this.visits});
}

class TodayStatistics {
  final List<Visit> visits;

  TodayStatistics({required this.visits});
}