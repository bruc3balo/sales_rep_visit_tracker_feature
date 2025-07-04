import 'dart:collection';

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
   DateTime? fromDateInclusive;
   DateTime? toDateInclusive;
   LinkedHashSet<ActivityRef> activities = LinkedHashSet();
   CustomerRef? customer;
   VisitOrderBy orderBy;
   VisitSortBy sortBy;
   VisitStatus? visitStatus;

  VisitFilterState({
    this.fromDateInclusive,
    this.toDateInclusive,
    this.customer,
    this.sortBy = VisitSortBy.descending,
    this.orderBy = VisitOrderBy.visitDate,
    this.visitStatus,
  });

   VisitFilterState copy() {
     return VisitFilterState(
       fromDateInclusive: fromDateInclusive,
       toDateInclusive: toDateInclusive,
       customer: customer,
       sortBy: sortBy,
       orderBy: orderBy,
       visitStatus: visitStatus,
     )..activities = LinkedHashSet.of(activities);
   }
}
