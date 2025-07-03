import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

abstract class LocalCustomerRepository {

  Future<TaskResult<void>> setLocalCustomer({required Customer customer});

  Future<TaskResult<void>> setLocalCustomers({required List<Customer> customer});

  Future<TaskResult<List<Customer>>> getLocalCustomers({
    required int page,
    required int pageSize,
  });

  Future<TaskResult<Map<int, Customer>>> getLocalCustomersByIds({
    required List<int> customerIds,
  });

  Future<TaskResult<void>> deleteLocalCustomer({required int customerId});

  Future<TaskResult<void>> clearLocalCustomers();

  Future<TaskResult<List<Customer>>> searchLocalCustomers({
    required int page,
    required int pageSize,
    required String likeName,
  });

}