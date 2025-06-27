

import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/remote/remote_models.dart';

extension ActivityDomainMapper on RemoteActivity {
  Activity get toDomain => Activity(id: id, description: description, createdAt: createdAt);
}

extension ActivityRemoteMapper on Activity {
  RemoteActivity get toRemote => RemoteActivity(id: id, description: description, createdAt: createdAt);
}