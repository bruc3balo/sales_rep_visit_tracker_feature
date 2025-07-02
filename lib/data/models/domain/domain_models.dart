import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';

class Customer {
  final int id;
  final String name;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}

class Activity {
  final int id;
  final String description;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.description,
    required this.createdAt,
  });
}

class Visit {
  final int id;
  final int customerId;
  final DateTime visitDate;
  final String status;
  final String location;
  final String notes;
  final List<int> activitiesDone;
  final DateTime? createdAt;

  Visit({
    required this.id,
    required this.customerId,
    required this.visitDate,
    required this.status,
    required this.location,
    required this.notes,
    required this.activitiesDone,
    required this.createdAt,
  });
}

enum VisitStatus {
  completed,
  pending,
  cancelled;


  static VisitStatus? findByCapitalizedString(String s) {
    return VisitStatus.values.where((e) => e.name.capitalize == s).firstOrNull;
  }
}