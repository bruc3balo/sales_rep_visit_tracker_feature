import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
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
  Future<TaskResult<List<Customer>>> getLocalCustomers({
    required int page,
    required int pageSize,
  }) async {
    var results = await _localCustomerCrud.getLocalCustomers(
      page: page,
      pageSize: pageSize,
    );

    switch(results) {

      case ErrorResult<List<LocalCustomer>>():
        return ErrorResult(
          error: results.error,
          trace: results.trace,
          failure: results.failure,
        );
      case SuccessResult<List<LocalCustomer>>():
        var data = results.data.map((e) =>e.toDomain).toList();
        return SuccessResult(data: data, message: results.message);
    }
  }

  @override
  Future<TaskResult<Map<int, Customer>>> getLocalCustomersByIds({
    required List<int> customerIds,
  }) async {
    var results = await _localCustomerCrud.getLocalCustomerByIds(
        ids: customerIds,
    );

    switch(results) {

      case ErrorResult<Map<int, LocalCustomer>>():
        return ErrorResult(
          error: results.error,
          failure: results.failure,
          trace: results.trace,
        );
      case SuccessResult<Map<int, LocalCustomer>>():
        var data = {for(var c in results.data.entries) c.key : c.value.toDomain};
        return SuccessResult(data: data, message: results.message);
    }
  }

  @override
  Future<TaskResult<void>> setLocalCustomer({
    required LocalCustomer customer,
  }) async {
    return await _localCustomerCrud.setLocalCustomer(customer: customer);
  }

  @override
  Future<TaskResult<void>> deleteLocalCustomer({required int customerId}) async {
    return await _localCustomerCrud.deleteLocalCustomer(customerId: customerId);
  }

  @override
  Future<TaskResult<List<Customer>>> searchLocalCustomers({
    required int page,
    required int pageSize,
    required String likeName,
  }) async {

    var results = await _localCustomerCrud.searchLocalCustomers(
      page: page,
      pageSize: pageSize,
      likeName: likeName,
    );

    switch(results) {

      case ErrorResult<List<LocalCustomer>>():
        return ErrorResult(
          error: results.error,
          failure: results.failure,
          trace: results.trace,
        );
      case SuccessResult<List<LocalCustomer>>():
        var data = results.data.map((e) => e.toDomain).toList();
        return SuccessResult(data: data);
    }

  }

  @override
  Future<TaskResult<void>> setLocalCustomers({
    required List<LocalCustomer> customer,
  }) async {
    return await _localCustomerCrud.setLocalCustomers(
        customers: customer,
    );
  }



}