
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

extension ActivityAggregation on Activity {
  ActivityRef get toRef => ActivityRef(id, description);
}

extension CustomerAggregation on Customer {
  CustomerRef get toRef => CustomerRef(id, name);
}