

import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

enum VisitFilters {
  fromDate(label: "Start date"),
  toDate(label: "End date"),
  activity(label: "Activity"),
  customer(label: "Customer"),
  status(label: "Status"),
  order(label: "Order");

  final String label;

  const VisitFilters({required this.label});
}

class ActiveFilters {
  final VisitFilters type;
  final dynamic value;

  ActiveFilters({
    required this.type,
    required this.value,
  });
}

class VisitFilterState {
  final Map<VisitFilters, List<dynamic>> filters = {};

  VisitFilterState();

  void setOrder(bool ascending) {
    filters[VisitFilters.order] = [ascending ? "asc" : "desc"];
  }

  void setStatus(VisitStatus? status) {
    if (status == null) {
      filters[VisitFilters.status]?.clear();
    } else {
      filters[VisitFilters.status] = [status];
    }
  }

  void setFromDate(DateTime? fromDate) {
    if (fromDate == null) {
      filters[VisitFilters.fromDate]?.clear();
    } else {
      filters[VisitFilters.fromDate] = [fromDate];
    }
  }

  void setToDate(DateTime? toDate) {
    if (toDate == null) {
      filters[VisitFilters.toDate]?.clear();
    } else {
      filters[VisitFilters.toDate] = [toDate];
    }
  }

  void addActivity(ActivityRef activity) {
    List<ActivityRef> activities = (filters[VisitFilters.activity] as List<ActivityRef>?) ?? [];
    activities.add(activity);
    filters[VisitFilters.activity] = List.from(activities);
  }

  void removeActivity(ActivityRef activity) {
    List<ActivityRef> activities = (filters[VisitFilters.activity] as List<ActivityRef>?) ?? [];
    activities.removeWhere((a) => a.id == activity.id);
    filters[VisitFilters.activity] = List.from(activities);
  }

  void addCustomer(CustomerRef customer) {
    List<CustomerRef> customers = (filters[VisitFilters.customer] as List<CustomerRef>?) ?? [];
    customers.add(customer);
    filters[VisitFilters.customer] = List.from(customers);
  }

  void removeCustomer(CustomerRef customer) {
    List<CustomerRef> customers = (filters[VisitFilters.customer] as List<CustomerRef>?) ?? [];
    customers.removeWhere((a) => a.id == customer.id);
    filters[VisitFilters.customer] = List.from(customers);
  }

  List<ActiveFilters> get activeFilters {
    List<ActiveFilters> f = [];
    if (filters[VisitFilters.order] != null) {
      f.add(ActiveFilters(type: VisitFilters.order, value: filters[VisitFilters.order]));
    }
    if (filters[VisitFilters.status] != null) {
      f.add(ActiveFilters(type: VisitFilters.status, value: filters[VisitFilters.status]));
    }
    if (filters[VisitFilters.fromDate] != null) {
      f.add(ActiveFilters(type: VisitFilters.fromDate, value: filters[VisitFilters.fromDate]));
    }
    if (filters[VisitFilters.toDate] != null) {
      f.add(ActiveFilters(type: VisitFilters.toDate, value: filters[VisitFilters.toDate]));
    }
    if (filters[VisitFilters.activity] != null) {
      for (var a in (filters[VisitFilters.activity] as List<ActivityRef>)) {
        f.add(ActiveFilters(type: VisitFilters.activity, value: a));
      }
    }
    return f;
  }
}