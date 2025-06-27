import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

abstract class CustomerRepository {

  Future<TaskResult<Customer>> createCustomer({required String name});

  Future<TaskResult<List<Customer>>> getCustomers({
    required int page,
    required int pageSize,
  });

  Future<TaskResult<List<Customer>>> searchCustomerByName({
    required String name,
    required int page,
    required int pageSize,
  });

  Future<TaskResult<Customer>> updateCustomer({required Customer customer});

  Future<TaskResult<void>> deleteCustomerById({required int customerId});

}