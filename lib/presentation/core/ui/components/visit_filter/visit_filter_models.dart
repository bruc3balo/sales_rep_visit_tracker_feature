import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

enum VisitOrderBy {
  visitDate(label: "Visit date"),
  status(label: "Visit status");

  final String label;

  const VisitOrderBy({required this.label});
}

enum VisitSortBy {
  ascending,
  descending;

  String get label => name.capitalize;
}

extension SupabaseOrderTranslator on VisitOrderBy {
  String get order => switch (this) {
        VisitOrderBy.visitDate => "visit_date",
        VisitOrderBy.status => "status",
      };
}

extension SupabaseSortTranslator on VisitSortBy {
  String get sort => switch (this) {
        VisitSortBy.ascending => "asc",
        VisitSortBy.descending => "desc",
      };
}

class VisitFilterState {
  final DateTime? fromDateInclusive;
  final DateTime? toDateInclusive;
  final List<ActivityRef> activities;
  final CustomerRef? customer;
  final VisitOrderBy orderBy;
  final VisitSortBy sortBy;
  final VisitStatus? visitStatus;

  VisitFilterState({
    this.fromDateInclusive,
    this.toDateInclusive,
    this.activities = const [],
    this.customer,
    this.sortBy = VisitSortBy.descending,
    this.orderBy = VisitOrderBy.visitDate,
    this.visitStatus,
  });

  VisitFilterState changeVisitStatus({
    VisitStatus? visitStatus,
  }) {
    return VisitFilterState(
      fromDateInclusive: fromDateInclusive,
      toDateInclusive: toDateInclusive,
      activities: activities,
      customer: customer,
      sortBy: sortBy ,
      visitStatus: visitStatus,
    );
  }

  VisitFilterState copyWith({
    DateTime? fromDateInclusive,
    DateTime? toDateInclusive,
    List<ActivityRef>? activities,
    CustomerRef? customer,
    VisitOrderBy? orderBy,
    VisitSortBy? sortBy,
  }) {
    return VisitFilterState(
      fromDateInclusive: fromDateInclusive ?? this.fromDateInclusive,
      toDateInclusive: toDateInclusive ?? this.toDateInclusive,
      activities: activities ?? this.activities,
      customer: customer ?? this.customer,
      sortBy: sortBy ?? this.sortBy,
      orderBy: orderBy ?? this.orderBy,
      visitStatus: visitStatus,
    );
  }
}
