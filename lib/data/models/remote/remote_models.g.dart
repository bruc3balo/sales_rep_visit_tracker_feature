// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoteCustomer _$RemoteCustomerFromJson(Map<String, dynamic> json) =>
    RemoteCustomer(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RemoteCustomerToJson(RemoteCustomer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.createdAt.toIso8601String(),
    };

RemoteActivity _$RemoteActivityFromJson(Map<String, dynamic> json) =>
    RemoteActivity(
      id: (json['id'] as num).toInt(),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RemoteActivityToJson(RemoteActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
    };

RemoteVisit _$RemoteVisitFromJson(Map<String, dynamic> json) => RemoteVisit(
      id: (json['id'] as num).toInt(),
      customerId: (json['customer_id'] as num).toInt(),
      visitDate: DateTime.parse(json['visit_date'] as String),
      status: json['status'] as String,
      location: json['location'] as String,
      notes: json['notes'] as String,
      activitiesDone: (json['activities_done'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RemoteVisitToJson(RemoteVisit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'visit_date': instance.visitDate.toIso8601String(),
      'status': instance.status,
      'location': instance.location,
      'notes': instance.notes,
      'activities_done': instance.activitiesDone,
      'created_at': instance.createdAt.toIso8601String(),
    };
