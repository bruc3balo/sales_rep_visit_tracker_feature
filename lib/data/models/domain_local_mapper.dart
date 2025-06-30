import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/remote/remote_models.dart';

extension ActivityLocalMapper on Activity {
  LocalActivity get toLocal => LocalActivity(
    id: id, 
    description: description,
    updatedAt: DateTime.now(),
  );
}

extension CustomerLocalMapper on Customer {
  LocalCustomer get toLocal => LocalCustomer(
    id: id, 
    name: name, 
    updatedAt: DateTime.now(),
  );
}

