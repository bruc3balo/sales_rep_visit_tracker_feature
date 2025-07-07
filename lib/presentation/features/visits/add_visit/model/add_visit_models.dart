import 'dart:convert';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';

// AddVisitState
sealed class AddVisitState {}
class DraftingAddVisitState extends AddVisitState {}
class LoadingAddVisitState extends AddVisitState {}
class SuccessAddingVisitState extends AddVisitState {}

// AddVisitForm
class AddVisitForm {
  final Customer? customer;
  final DateTime? visitDate;
  final VisitStatus? status;
  final String? location;
  final String? notes;
  final List<Activity> activities;

  AddVisitForm({
    this.customer,
    this.visitDate,
    this.status,
    this.location,
    this.notes,
    this.activities = const [],
  });

  Map<String, dynamic> toJson() => {
    'customer': customer?.toJson(),
    'visitDate': visitDate?.toIso8601String(),
    'status': status?.name,
    'location': location,
    'notes': notes,
    'activities': activities.map((a) => a.toJson()).toList(),
  };

  factory AddVisitForm.fromJson(Map<String, dynamic> json) {
    return AddVisitForm(
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
      visitDate: json['visitDate'] != null
          ? DateTime.tryParse(json['visitDate'])
          : null,
      status: json['status'] != null
          ? VisitStatus.values.byName(json['status'])
          : null,
      location: json['location'],
      notes: json['notes'],
      activities: (json['activities'] as List?)
          ?.map((e) => Activity.fromJson(e))
          .toList() ??
          [],
    );
  }

  AddVisitForm copyWith({
    Customer? customer,
    DateTime? visitDate,
    VisitStatus? status,
    String? location,
    String? notes,
    List<Activity>? activities,
  }) {
    return AddVisitForm(
      customer: customer ?? this.customer,
      visitDate: visitDate ?? this.visitDate,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      activities: activities ?? this.activities,
    );
  }

  @override
  String toString() => jsonEncode(toJson());

  factory AddVisitForm.fromString(String str) =>
      AddVisitForm.fromJson(jsonDecode(str));
}
