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
    String? likeName,
    String? equalName,
    required int page,
    required int pageSize,
    String? order,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl)
        ..replace(
          queryParameters: {
            if (likeName != null) "name": 'ilike.*$likeName*',
            if (equalName != null) "name": 'eq.$likeName',
            "limit": pageSize,
            "offset": page * pageSize,
            if (order != null) "order": order,
          },
        ),
      method: HttpMethod.get,
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendDeleteCustomerRequest({
    required int customerId,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl)
        ..replace(
          queryParameters: {"id": "eq.$customerId"},
        ),
      method: HttpMethod.delete,
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendUpdateCustomerRequest({
    required int customerId,
    String? name,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl)
        ..replace(
          queryParameters: {"id": "eq.$customerId"},
        ),
      method: HttpMethod.patch,
      data: {
        if (name != null) "description": name,
      },
    );
    return _networkService.sendJsonRequest(request: request);
  }
}
