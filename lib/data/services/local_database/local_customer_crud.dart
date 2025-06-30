
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

abstract class LocalCustomerCrud {

  Future<TaskResult<void>> setLocalCustomer({
    required LocalCustomer customer,
  });

  Future<TaskResult<List<LocalCustomer>>> getLocalCustomers({
    required int page,
    required int pageSize,
  });

  Future<TaskResult<Map<int, LocalCustomer>>> getLocalCustomerByIds({
    required List<int> ids,
  });

  Future<TaskResult<void>> clearAllLocalCustomers();

}