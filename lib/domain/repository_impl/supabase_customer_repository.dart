import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_remote_mapper/domain_remote_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/remote/remote_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/customer/customer_supabase_api.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class SupabaseCustomerRepository implements CustomerRepository {

  final CustomerSupabaseApi _customerApi;

  SupabaseCustomerRepository({
    required CustomerSupabaseApi customerApi,
  }) : _customerApi = customerApi;

  @override
  Future<TaskResult<Customer>> createCustomer({
    required String name
  }) async {

    //Check duplicates
    var duplicateResponse = await _customerApi.sendFindCustomersByNameRequest(
        name: name
    );

    switch(duplicateResponse) {

      case FailNetworkResponse():
        return ErrorResult(
          error: duplicateResponse.description,
          trace: duplicateResponse.trace,
        );
      case SuccessNetworkResponse():
        var data = (duplicateResponse.data as List<dynamic>);
        bool duplicateCustomer = data.isEmpty;
        if (duplicateCustomer) {
          return ErrorResult(
            error: "Customer with name exists",
          );
        }
    }

    //Create customer
    var createResponse = await _customerApi.sendAddCustomerRequest(name: name);
    switch(createResponse) {

      case FailNetworkResponse():
        return ErrorResult(
          error: createResponse.description,
          trace: createResponse.trace,
        );
      case SuccessNetworkResponse():

        var fetchCreatedCustomer = await _customerApi.sendFindCustomersByNameRequest(
            name: name,
        );

        switch(fetchCreatedCustomer) {

          case FailNetworkResponse():
            // TODO: Handle this case.
            throw UnimplementedError();
          case SuccessNetworkResponse():
            // TODO: Handle this case.
            throw UnimplementedError();
        }
    }
  }

  @override
  Future<TaskResult<void>> deleteCustomerById({required int customerId}) async {
    var deleteResponse = await _customerApi.sendDeleteCustomerRequest(
      customerId: customerId
    );

    switch (deleteResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: deleteResponse.description,
          trace: deleteResponse.trace,
        );
      case SuccessNetworkResponse():
        return SuccessResult(
            message: "Customer deleted"
        );
    }
  }

  @override
  Future<TaskResult<List<Customer>>> getCustomers({
    required int page,
    required int pageSize,
    required String order,
  }) async {
    var searchCustomerResponse = await _customerApi.sendGetCustomersRequest(
        page: page, pageSize: pageSize, order: order,
    );

    switch(searchCustomerResponse) {

      case FailNetworkResponse():
        return ErrorResult(
          error: searchCustomerResponse.description,
          trace: searchCustomerResponse.trace,
        );
      case SuccessNetworkResponse():
        var data = (searchCustomerResponse.data as List<dynamic>)
            .map((json) => RemoteCustomer.fromJson(json).toDomain).toList();

        return SuccessResult(
          data: data,
          message: "${data.length} customers found",
        );
    }
  }

  @override
  Future<TaskResult<List<Customer>>> searchCustomerByName({
    required String name,
    required int page,
    required int pageSize,
    required String order,
  }) async {
    var searchCustomerResponse = await _customerApi.sendSearchCustomersByNameRequest(
        page: page, pageSize: pageSize, order: order, name: name
    );

    switch(searchCustomerResponse) {

      case FailNetworkResponse():
        return ErrorResult(
          error: searchCustomerResponse.description,
          trace: searchCustomerResponse.trace,
        );
      case SuccessNetworkResponse():
        var data = (searchCustomerResponse.data as List<dynamic>)
            .map((json) => RemoteCustomer.fromJson(json).toDomain).toList();

        return SuccessResult(
          data: data,
          message: "${data.length} customers found",
        );
    }
  }

  @override
  Future<TaskResult<Customer>> updateCustomer({required Customer customer}) async {
    var updateCustomerResponse = await _customerApi.sendUpdateCustomerRequest(
      customerId: customer.id,
      name: customer.name,
    );

    switch (updateCustomerResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: updateCustomerResponse.description,
          trace: updateCustomerResponse.trace,
        );
      case SuccessNetworkResponse():
        var data = RemoteCustomer
            .fromJson(updateCustomerResponse.data)
            .toDomain;

        return SuccessResult(
          message: "Activity updated",
          data: data,
        );
    }
  }
}
