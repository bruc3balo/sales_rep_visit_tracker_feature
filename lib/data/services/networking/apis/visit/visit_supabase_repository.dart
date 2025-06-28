import 'package:sales_rep_visit_tracker_feature/data/services/networking/network_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';

class SupabaseVisitApi {
  final NetworkService _networkService;
  final String _baseUrl;

  SupabaseVisitApi({
    required NetworkService networkService,
    required String baseUrl,
  })  : _networkService = networkService,
        _baseUrl = "$baseUrl/visits";

  Future<NetworkResponse> sendAddVisitRequest({
    required int customerId,
    required DateTime visitDate,
    required String status,
    required String location,
    required String notes,
    required List<int> activityIdsDone,
    required DateTime createdAt,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl),
      method: HttpMethod.post,
      data: {
        "customer_id": customerId,
        "visit_date": visitDate,
        "status": status,
        "location": location,
        "notes": notes,
        "activities_done": activityIdsDone,
        "created_at": createdAt,
      },
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendGetVisitsRequest({
    int? visitId,
    int? customerId,
    DateTime? fromDateInclusive,
    DateTime? toDateInclusive,
    List<int>? activityIdsDone,
    String? status,
    required int page,
    required int pageSize,
    String? order,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse(_baseUrl)
        ..replace(
          queryParameters: {
            if (visitId != null) "id": "eq.$visitId",
            if (customerId != null) "customer_id": "eq.$customerId",
            if (activityIdsDone != null) "activities_done": "contains.$activityIdsDone",
            if (status != null) "status": "eq.$status",
            if (fromDateInclusive != null) "visit_date": "gte.$fromDateInclusive",
            if (toDateInclusive != null) "visit_date": "lte.$toDateInclusive",
            "limit": pageSize,
            "offset": page * pageSize,
            if (order != null) "order": order,
          },
        ),
      method: HttpMethod.get,
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendDeleteVisitRequest({
    required int visitId,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse("$_baseUrl?id=eq.$visitId"),
      method: HttpMethod.delete,
    );
    return _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendUpdateVisitRequest({
    required int visitId,
    int? customerId,
    DateTime? visitDate,
    String? status,
    String? location,
    String? notes,
    List<int>? activityIdsDone,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse("$_baseUrl?id=eq.$visitId"),
      method: HttpMethod.patch,
      data: {
        if (customerId != null) "customer_id": customerId,
        if (visitDate != null) "visit_date": visitDate,
        if (status != null) "status": status,
        if (location != null) "location": location,
        if (notes != null) "notes": notes,
        if (activityIdsDone != null) "activities_done": activityIdsDone,
      },
    );
    return _networkService.sendJsonRequest(request: request);
  }
}
