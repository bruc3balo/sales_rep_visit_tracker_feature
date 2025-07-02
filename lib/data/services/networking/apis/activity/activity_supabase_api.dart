import 'package:sales_rep_visit_tracker_feature/data/services/networking/network_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';

class ActivitySupabaseApi {
  final NetworkService _networkService;
  final String _baseUrl;
  final String _apiKey;

  ActivitySupabaseApi({
    required NetworkService networkService,
    required String baseUrl,
    required String apiKey,
  })  : _networkService = networkService,
        _apiKey = apiKey,
        _baseUrl = "$baseUrl/activities";

  Future<NetworkResponse> sendAddActivityRequest({
    required String description,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl),
      method: HttpMethod.post,
      headers: {
        "apiKey" : _apiKey
      },
      data: {
        "description": description,
        "created_at": DateTime.now().toIso8601String(),
      },
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendGetActivityRequest({
    List<int>? ids,
    required int page,
    required int pageSize,
    String? likeDescription,
    String? equalDescription,
    String? order,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl).replace(
        queryParameters: {
          "limit": pageSize.toString(),
          "offset": (page * pageSize).toString(),
          if (likeDescription != null) "description": 'ilike.*$likeDescription*',
          if (equalDescription != null) "description": 'eq.$equalDescription',
          if (order != null) "order": order,
          if (ids != null) "id": "in.(${ids.join(",")})",
        },
      ),
      headers: {
        "apiKey" : _apiKey
      },
      method: HttpMethod.get,
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendDeleteActivityRequest({
    required int activityId,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl).replace(
        queryParameters: {"id": "eq.$activityId"},
      ),
      headers: {
        "apiKey" : _apiKey
      },
      method: HttpMethod.delete,
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendUpdateActivityRequest({
    required int activityId,
    String? description,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl).replace(
        queryParameters: {"id": "eq.$activityId"},
      ),
      method: HttpMethod.patch,
      headers: {
        "apiKey" : _apiKey
      },
      data: {
       if(description != null) "description": description
      },
    );
    return _networkService.sendJsonRequest(request: request);
  }
}
