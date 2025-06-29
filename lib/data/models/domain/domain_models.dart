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

  String get capitalize => "${name[0].toUpperCase()}${name.substring(1)}";

  static VisitStatus? findByCapitalizedString(String s) {
    return VisitStatus.values.where((e) => e.capitalize == s).firstOrNull;
  }
}