import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';

part 'local_models.g.dart';

@HiveType(typeId: 0)
class UnSyncedLocalVisit {

  @HiveField(0)
  final String key;

  @HiveField(1)
  final String hash;

  @HiveField(2)
  final int customerIdVisited;

  @HiveField(3)
  final DateTime visitDate;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final String location;

  @HiveField(6)
  final String notes;

  @HiveField(7)
  final List<int> activityIdsDone;

  @HiveField(8)
  final DateTime createdAt;

  UnSyncedLocalVisit({
    required this.key,
    required this.hash,
    required this.customerIdVisited,
    required this.visitDate,
    required this.status,
    required this.location,
    required this.notes,
    required this.activityIdsDone,
    required this.createdAt,
  });

  UnSyncedLocalVisit copyWith({
    String? hash,
    int? customerIdVisited,
    DateTime? visitDate,
    String? status,
    String? location,
    String? notes,
    List<int>? activityIdsDone,
  }) {
    return UnSyncedLocalVisit(
      key: key,
      hash: hash ?? this.hash,
      customerIdVisited: customerIdVisited ?? this.customerIdVisited,
      visitDate: visitDate ?? this.visitDate,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      activityIdsDone: activityIdsDone ?? this.activityIdsDone,
      createdAt: createdAt,
    );
  }
}

LocalVisitHash generateHash({
  required int customerIdVisited,
  required DateTime visitDate,
  required String status,
  required String location,
  required String notes,
  required List<int> activityIdsDone,
}) {
  return LocalVisitHash(
    value: sha256
        .convert(
      utf8.encode(
        {
          'customerIdVisited': customerIdVisited,
          'visitDate': visitDate,
          'status': status,
          'location': location,
          'notes': notes,
          'activityIdsDone': activityIdsDone,
        }.toString(),
      ),
    )
        .toString(),
  );
}

@HiveType(typeId: 1)
class LocalActivity {
  @HiveField(0)
  final int id;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  LocalActivity({
    required this.id,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });
}

@HiveType(typeId: 2)
class LocalCustomer  {

  @HiveField(0)
  final int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  LocalCustomer({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
}

@HiveType(typeId: 3)
class LocalVisitStatistics {

  @HiveField(0)
  final Map<String, int> statistics;

  @HiveField(1)
  final DateTime createdAt;

  LocalVisitStatistics({
    required this.statistics,
    required this.createdAt,
  });
}
