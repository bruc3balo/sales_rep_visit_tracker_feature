import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_remote_mapper.dart';
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
  Future<TaskResult<Customer>> createCustomer({required String name}) async {
    //Check duplicates
    var duplicateResponse = await _customerApi.sendGetCustomersRequest(
      equalName: name,
      page: 0,
      pageSize: 1,
    );

    switch (duplicateResponse) {
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
    switch (createResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: createResponse.description,
          trace: createResponse.trace,
        );
      case SuccessNetworkResponse():
        var fetchCreatedCustomer = await _customerApi.sendGetCustomersRequest(equalName: name, pageSize: 1, page: 0);

        switch (fetchCreatedCustomer) {
          case FailNetworkResponse():
            return ErrorResult(
              error: fetchCreatedCustomer.description,
              trace: fetchCreatedCustomer.trace,
            );
          case SuccessNetworkResponse():
            //Cache customer by id
            var data = (fetchCreatedCustomer.data as List<dynamic>).map((e) => RemoteCustomer.fromJson(e)).first;
            return SuccessResult(data: data.toDomain, message: "Customer created");
        }
    }
  }

  @override
  Future<TaskResult<void>> deleteCustomerById({required int customerId}) async {
    var deleteResponse = await _customerApi.sendDeleteCustomerRequest(customerId: customerId);

    switch (deleteResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: deleteResponse.description,
          trace: deleteResponse.trace,
        );
      case SuccessNetworkResponse():
        return SuccessResult(
          data: null,
          message: "Customer deleted",
        );
    }
  }

  @override
  Future<TaskResult<List<Customer>>> getCustomers({
    String? equalName,
    String? likeName,
    required int page,
    required int pageSize,
    String? order,
  }) async {
    var searchCustomerResponse = await _customerApi.sendGetCustomersRequest(
      equalName: equalName,
      likeName: likeName,
      page: page,
      pageSize: pageSize,
      order: order,
    );

    switch (searchCustomerResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: searchCustomerResponse.description,
          trace: searchCustomerResponse.trace,
        );
      case SuccessNetworkResponse():
        var data = (searchCustomerResponse.data as List<dynamic>).map((json) => RemoteCustomer.fromJson(json).toDomain).toList();

        return SuccessResult(
          data: data,
          message: "${data.length} customers found",
        );
    }
  }

  @override
  Future<TaskResult<Customer>> updateCustomer({
    required int customerId,
    String? name,
  }) async {
    var updateCustomerResponse = await _customerApi.sendUpdateCustomerRequest(
      customerId: customerId,
      name: name,
    );

    switch (updateCustomerResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: updateCustomerResponse.description,
          trace: updateCustomerResponse.trace,
        );
      case SuccessNetworkResponse():
        var data = RemoteCustomer.fromJson(updateCustomerResponse.data).toDomain;

        return SuccessResult(
          message: "Customer updated",
          data: data,
        );
    }
  }
}
