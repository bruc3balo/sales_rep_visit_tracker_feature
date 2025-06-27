import 'package:sales_rep_visit_tracker_feature/data/services/networking/network_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';

class CustomerSupabaseApi {
  final NetworkService _networkService;
  final String _baseUrl;

  CustomerSupabaseApi({
    required NetworkService networkService,
    required String baseUrl,
  })  : _networkService = networkService,
        _baseUrl = "$baseUrl/customers";

  Future<NetworkResponse> sendAddCustomerRequest({
    required String name,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl),
      method: HttpMethod.post,
      data: {
        "name": name,
        "created_at": DateTime.now(),
      },
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendGetCustomersRequest({
    required int page,
    required int pageSize,
    required String order,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl),
      method: HttpMethod.get,
      data: {
        "limit": pageSize,
        "offset": page * pageSize,
        "order": order,
      },
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendSearchCustomersByNameRequest({
    required int page,
    required int pageSize,
    required String order,
    required String name,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl),
      method: HttpMethod.get,
      data: {
        "limit": pageSize,
        "offset": page * pageSize,
        "order": order,
        "name": 'ilike.*$name*',
      },
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendFindCustomersByNameRequest({
    required String name,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl),
      method: HttpMethod.get,
      data: {
        "name": 'eq.*$name*',
      },
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendDeleteCustomerRequest({
    required int customerId,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse("$_baseUrl?id=eq.$customerId"),
      method: HttpMethod.delete,
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendUpdateCustomerRequest({
    required int customerId,
    required String name,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse("$_baseUrl?id=eq.$customerId"),
      method: HttpMethod.patch,
      data: {
        "description": name,
      },
    );
    return _networkService.sendJsonRequest(request: request);
  }
}
