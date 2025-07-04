import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/remote/remote_models.dart';

extension RemoteActivityDomainMapper on RemoteActivity {
  Activity get toDomain => Activity(id: id, description: description, createdAt: createdAt);
}

extension CustomerDomainMapper on RemoteCustomer {
  Customer get toDomain => Customer(id: id, name: name, createdAt: createdAt);
}

extension VisitDomainMapper on RemoteVisit {
  Visit get toDomain => Visit(
        id: id,
        customerId: customerId,
        visitDate: visitDate,
        status: status,
        location: location,
        notes: notes,
        activitiesDone: activitiesDone.map((e) => int.parse(e)).toList(),
        createdAt: createdAt,
      );
}

