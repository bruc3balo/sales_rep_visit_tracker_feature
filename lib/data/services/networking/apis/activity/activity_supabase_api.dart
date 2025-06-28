import 'package:sales_rep_visit_tracker_feature/data/services/networking/network_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';

class ActivitySupabaseApi {
  final NetworkService _networkService;
  final String _baseUrl;

  ActivitySupabaseApi({
    required NetworkService networkService,
    required String baseUrl,
  })  : _networkService = networkService,
        _baseUrl = "$baseUrl/activities";

  Future<NetworkResponse> sendAddActivityRequest({
    required String description,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl),
      method: HttpMethod.post,
      data: {
        "description": description,
        "created_at": DateTime.now(),
      },
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendGetActivityRequest({
    required int page,
    required int pageSize,
    String? likeDescription,
    String? equalDescription,
    String? order,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl)
        ..replace(
          queryParameters: {
            "limit": pageSize,
            "offset": page * pageSize,
            if (likeDescription != null) "description": 'ilike.*$likeDescription*',
            if (equalDescription != null) "description": 'eq.$equalDescription',
            if (order != null) "order": order,
          },
        ),
      method: HttpMethod.get,
    );
    return _networkService.sendJsonRequest(request: request);
  }


  Future<NetworkResponse> sendDeleteActivityRequest({
    required int activityId,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl)
        ..replace(
          queryParameters: {"id": "eq.$activityId"},
        ),
      method: HttpMethod.delete,
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendUpdateActivityRequest({
    required int activityId,
    required String description,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl)
        ..replace(
          queryParameters: {"id": "eq.$activityId"},
        ),
      method: HttpMethod.patch,
      data: {"description": description},
    );
    return _networkService.sendJsonRequest(request: request);
  }
}
