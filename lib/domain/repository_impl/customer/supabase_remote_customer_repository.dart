import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_remote_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/remote/remote_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/customer/customer_supabase_api.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class SupabaseCustomerRepository implements RemoteCustomerRepository {
  final CustomerSupabaseApi _customerApi;

  SupabaseCustomerRepository({
    required CustomerSupabaseApi customerApi,
  }) : _customerApi = customerApi;

  static const _tag = "SupabaseCustomerRepository";

  @override
  Future<TaskResult<void>> createCustomer({required String name}) async {
    AppLog.I.i(_tag, "createCustomer(name: $name)");

    var duplicateResponse = await _customerApi.sendGetCustomersRequest(
      equalName: name,
      page: 0,
      pageSize: 1,
    );

    switch (duplicateResponse) {
      case FailNetworkResponse():
        AppLog.I.e(_tag, "Duplicate check failed", error: duplicateResponse.description, trace: duplicateResponse.trace);
        return ErrorResult(
          error: duplicateResponse.description,
          trace: duplicateResponse.trace,
        );
      case SuccessNetworkResponse():
        var data = (duplicateResponse.data as List<dynamic>);
        bool duplicateCustomer = data.isNotEmpty;
        AppLog.I.i(_tag, "Duplicate check result: $duplicateCustomer");

        if (duplicateCustomer) {
          return ErrorResult(error: "Customer with name exists");
        }
    }

    var createResponse = await _customerApi.sendAddCustomerRequest(name: name);

    switch (createResponse) {
      case FailNetworkResponse():
        AppLog.I.e(_tag, "Create failed", error: createResponse.description, trace: createResponse.trace);
        return ErrorResult(
          error: createResponse.description,
          trace: createResponse.trace,
        );
      case SuccessNetworkResponse():
        AppLog.I.i(_tag, "Customer created");
        return SuccessResult(data: null, message: "Customer created");
    }
  }

  @override
  Future<TaskResult<void>> deleteCustomerById({required int customerId}) async {
    AppLog.I.i(_tag, "deleteCustomerById(id: $customerId)");

    var deleteResponse = await _customerApi.sendDeleteCustomerRequest(customerId: customerId);

    switch (deleteResponse) {
      case FailNetworkResponse():
        AppLog.I.e(_tag, "Delete failed", error: deleteResponse.description, trace: deleteResponse.trace);
        return ErrorResult(
          error: deleteResponse.description,
          trace: deleteResponse.trace,
        );
      case SuccessNetworkResponse():
        AppLog.I.i(_tag, "Customer deleted");
        return SuccessResult(data: null, message: "Customer deleted");
    }
  }

  @override
  Future<TaskResult<List<Customer>>> getCustomers({
    List<int>? ids,
    String? equalName,
    String? likeName,
    required int page,
    required int pageSize,
    String? order,
  }) async {
    AppLog.I.i(_tag, "getCustomers(page: $page, pageSize: $pageSize, ids: $ids, like: $likeName, equal: $equalName, order: $order)");

    var searchCustomerResponse = await _customerApi.sendGetCustomersRequest(
      ids: ids,
      equalName: equalName,
      likeName: likeName,
      page: page,
      pageSize: pageSize,
      order: order,
    );

    switch (searchCustomerResponse) {
      case FailNetworkResponse():
        AppLog.I.e(_tag, "Fetch failed", error: searchCustomerResponse.description, trace: searchCustomerResponse.trace);
        return ErrorResult(
          error: searchCustomerResponse.description,
          trace: searchCustomerResponse.trace,
        );
      case SuccessNetworkResponse():
        var data = (searchCustomerResponse.data as List<dynamic>)
            .map((json) => RemoteCustomer.fromJson(json).toDomain)
            .toList();

        AppLog.I.i(_tag, "Fetched ${data.length} customers");
        return SuccessResult(
          data: data,
          message: "${data.length} customers found",
        );
    }
  }

  @override
  Future<TaskResult<void>> updateCustomer({
    required int customerId,
    String? name,
  }) async {
    AppLog.I.i(_tag, "updateCustomer(id: $customerId, name: $name)");

    var updateCustomerResponse = await _customerApi.sendUpdateCustomerRequest(
      customerId: customerId,
      name: name,
    );

    switch (updateCustomerResponse) {
      case FailNetworkResponse():
        AppLog.I.e(_tag, "Update failed", error: updateCustomerResponse.description, trace: updateCustomerResponse.trace);
        return ErrorResult(
          error: updateCustomerResponse.description,
          trace: updateCustomerResponse.trace,
        );
      case SuccessNetworkResponse():
        AppLog.I.i(_tag, "Customer updated");
        return SuccessResult(data: null, message: "Customer updated");
    }
  }
}