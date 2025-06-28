import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/remote/remote_models.dart';

extension ActivityDomainMapper on RemoteActivity {
  Activity get toDomain => Activity(id: id, description: description, createdAt: createdAt);
}

extension ActivityRemoteMapper on Activity {
  RemoteActivity get toRemote => RemoteActivity(id: id, description: description, createdAt: createdAt);
}

extension CustomerDomainMapper on RemoteCustomer {
  Customer get toDomain => Customer(id: id, name: name, createdAt: createdAt);
}

extension CustomerRemoteMapper on Customer {
  RemoteCustomer get toRemote => RemoteCustomer(id: id, name: name, createdAt: createdAt);
}

extension VisitDomainMapper on RemoteVisit {
  Visit get toDomain => Visit(
        id: id,
        customerId: customerId,
        visitDate: visitDate,
        status: status,
        location: location,
        notes: notes,
        activitiesDone: activitiesDone,
        createdAt: createdAt,
      );
}

extension VisitRemoteMapper on Visit {
  RemoteVisit get toRemote => RemoteVisit(
        id: id,
        customerId: customerId,
        visitDate: visitDate,
        status: status,
        location: location,
        notes: notes,
        activitiesDone: activitiesDone,
        createdAt: createdAt,
      );
}
