import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';

class Customer implements Comparable<Customer>{
  final int id;
  final String name;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  int compareTo(Customer other) {
    final createdAtComparison = createdAt.compareTo(other.createdAt);
    if (createdAtComparison != 0) return createdAtComparison;
    return id.compareTo(other.id);
  }
}

class Activity implements Comparable<Activity>{
  final int id;
  final String description;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.description,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Activity &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              createdAt == other.createdAt;

  @override
  int get hashCode => id.hashCode ^ createdAt.hashCode;

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  int compareTo(Activity other) {
    final createdAtComparison = createdAt.compareTo(other.createdAt);
    if (createdAtComparison != 0) return createdAtComparison;
    return id.compareTo(other.id);
  }
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