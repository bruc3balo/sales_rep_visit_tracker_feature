import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';

part 'local_models.g.dart';

@HiveType(typeId: 0)
class UnSyncedLocalVisit extends HiveObject {

  @HiveField(1)
  String hash;

  @HiveField(2)
  int customerIdVisited;

  @HiveField(3)
  DateTime visitDate;

  @HiveField(4)
  String status;

  @HiveField(5)
  String location;

  @HiveField(6)
  String notes;

  @HiveField(7)
  List<int> activityIdsDone;

  @HiveField(8)
  final DateTime createdAt;


  UnSyncedLocalVisit({
    required this.hash,
    required this.customerIdVisited,
    required this.visitDate,
    required this.status,
    required this.location,
    required this.notes,
    required this.activityIdsDone,
    required this.createdAt,
  });
}

LocalVisitHash generateHash({
  required int customerIdVisited,
  required DateTime visitDate,
  required String status,
  required String location,
  required String notes,
  required List<int> activityIdsDone,
}) =>
    LocalVisitHash(
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

@HiveType(typeId: 1)
class LocalActivity extends HiveObject {
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
class LocalCustomer extends HiveObject {
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
