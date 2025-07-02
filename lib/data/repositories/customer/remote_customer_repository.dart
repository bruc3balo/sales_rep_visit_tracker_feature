import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

abstract class RemoteCustomerRepository {

  Future<TaskResult<void>> createCustomer({required String name});

  Future<TaskResult<List<Customer>>> getCustomers({
    List<int>? ids,
    String? equalName,
    String? likeName,
    required int page,
    required int pageSize,
    String? order,
  });

  Future<TaskResult<void>> updateCustomer({
    required int customerId,
    String? name,
  });

  Future<TaskResult<void>> deleteCustomerById({required int customerId});

}
