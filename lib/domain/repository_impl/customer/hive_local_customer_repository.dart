import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_customer_crud.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class HiveLocalCustomerRepository extends LocalCustomerRepository {
  final LocalCustomerCrud _localCustomerCrud;

  HiveLocalCustomerRepository({
    required LocalCustomerCrud localCustomerCrud,
  }) : _localCustomerCrud = localCustomerCrud;

  @override
  Future<TaskResult<void>> clearLocalCustomers() {
    return _localCustomerCrud.clearAllLocalCustomers();
  }

  @override
  Future<TaskResult<List<LocalCustomer>>> getLocalCustomers({
    required int page,
    required int pageSize,
  }) {
    return _localCustomerCrud.getLocalCustomers(page: page, pageSize: pageSize);
  }

  @override
  Future<TaskResult<Map<int, LocalCustomer>>> getLocalCustomersByIds({
    required List<int> customerIds,
  }) {
    return _localCustomerCrud.getLocalCustomerByIds(ids: customerIds);
  }

  @override
  Future<TaskResult<void>> setLocalCustomer({
    required LocalCustomer customer,
  }) {
    return _localCustomerCrud.setLocalCustomer(customer: customer);
  }



}