import 'package:sales_rep_visit_tracker_feature/data/services/networking/network_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';

class CustomerSupabaseApi {
  final NetworkService _networkService;
  final String _baseUrl;
  final String _apiKey;

  CustomerSupabaseApi({
    required NetworkService networkService,
    required String baseUrl,
    required String apiKey,
  })  : _networkService = networkService,
        _apiKey = apiKey,
        _baseUrl = "$baseUrl/customers";

  Future<NetworkResponse> sendAddCustomerRequest({
    required String name,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl),
      method: HttpMethod.post,
      data: {
        "name": name,
        "created_at": DateTime.now().toIso8601String(),
      },
      headers: {
        "apiKey" : _apiKey
      },
    );
    return await _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendGetCustomersRequest({
    List<int>? ids,
    String? likeName,
    String? equalName,
    required int page,
    required int pageSize,
    String? order,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl).replace(
        queryParameters: {
          if (likeName != null) "name": 'ilike.*$likeName*',
          if (equalName != null) "name": 'eq.$equalName',
          "limit": pageSize.toString(),
          "offset": (page * pageSize).toString(),
          if (order != null) "order": order,
          if (ids != null) "id": "in.(${ids.join(",")})",
        },
      ),
      headers: {
        "apiKey" : _apiKey
      },
      method: HttpMethod.get,
    );
    return await _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendDeleteCustomerRequest({
    required int customerId,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl).replace(
        queryParameters: {"id": "eq.$customerId"},
      ),
      headers: {
        "apiKey" : _apiKey
      },
      method: HttpMethod.delete,
    );
    return await _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendUpdateCustomerRequest({
    required int customerId,
    String? name,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl).replace(
        queryParameters: {"id": "eq.$customerId"},
      ),
      headers: {
        "apiKey" : _apiKey
      },
      method: HttpMethod.patch,
      data: {
        if (name != null) "name": name,
      },
    );
    return await _networkService.sendJsonRequest(request: request);
  }
}
