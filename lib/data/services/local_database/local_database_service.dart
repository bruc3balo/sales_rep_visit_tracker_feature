import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_customer_crud.dart';

import 'local_activity_crud.dart';
import 'local_unsynced_local_visit_crud.dart';

abstract class LocalDatabaseService implements LocalUnSyncedLocalVisitCrud, LocalActivityCrud, LocalCustomerCrud {



}

