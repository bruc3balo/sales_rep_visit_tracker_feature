import 'package:json_annotation/json_annotation.dart';

part 'remote_models.g.dart';

@JsonSerializable()
class RemoteCustomer {
  final int id;

  final String name;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  RemoteCustomer({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory RemoteCustomer.fromJson(Map<String, dynamic> json) =>
      _$RemoteCustomerFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteCustomerToJson(this);
}

@JsonSerializable()
class RemoteActivity {
  final int id;

  final String description;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  RemoteActivity({
    required this.id,
    required this.description,
    required this.createdAt,
  });

  factory RemoteActivity.fromJson(Map<String, dynamic> json) =>
      _$RemoteActivityFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteActivityToJson(this);
}

@JsonSerializable()
class RemoteVisit {
  final int id;

  @JsonKey(name: 'customer_id')
  final int customerId;

  @JsonKey(name: 'visit_date')
  final DateTime visitDate;

  final String status;

  final String location;

  final String notes;

  @JsonKey(name: 'activities_done')
  final List<String> activitiesDone;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  RemoteVisit({
    required this.id,
    required this.customerId,
    required this.visitDate,
    required this.status,
    required this.location,
    required this.notes,
    required this.activitiesDone,
    required this.createdAt,
  });

  factory RemoteVisit.fromJson(Map<String, dynamic> json) => _$RemoteVisitFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteVisitToJson(this);
}