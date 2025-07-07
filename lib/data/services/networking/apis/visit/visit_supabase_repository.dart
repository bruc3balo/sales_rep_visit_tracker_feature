import 'package:sales_rep_visit_tracker_feature/data/services/networking/network_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';

class SupabaseVisitApi {
  final NetworkService _networkService;
  final String _baseUrl;
  final String _apiKey;

  SupabaseVisitApi({
    required NetworkService networkService,
    required String baseUrl,
    required String apiKey,
  })  : _networkService = networkService,
        _apiKey = apiKey,
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
      headers: {"apiKey": _apiKey},
      data: {
        "customer_id": customerId,
        "visit_date": visitDate.toIso8601String(),
        "status": status,
        "location": location,
        "notes": notes,
        "activities_done": activityIdsDone,
        "created_at": createdAt.toIso8601String(),
      },
    );
    return await _networkService.sendJsonRequest(request: request);
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
    final parts = <String>[];

    if (visitId != null) parts.add("id=eq.$visitId");
    if (customerId != null) parts.add("customer_id=eq.$customerId");
    if (activityIdsDone != null) parts.add("activities_done=cs.{${activityIdsDone.join(",")}}");
    if (status != null) parts.add("status=eq.$status");
    if (fromDateInclusive != null) parts.add("visit_date=gte.${Uri.encodeComponent(fromDateInclusive.toIso8601String())}");
    if (toDateInclusive != null) parts.add("visit_date=lte.${Uri.encodeComponent(toDateInclusive.toIso8601String())}");
    parts.add("limit=$pageSize");
    parts.add("offset=${page * pageSize}");
    if (order != null) parts.add("order=${Uri.encodeComponent(order)}");
    String uri = parts.join("&");

    NetworkRequest request = NetworkRequest(
      uri: Uri.parse("$_baseUrl?$uri"),
      headers: {"apiKey": _apiKey},
      method: HttpMethod.get,
    );
    return await _networkService.sendJsonRequest(request: request);
  }

  Future<NetworkResponse> sendDeleteVisitRequest({
    required int visitId,
  }) async {
    NetworkRequest request = NetworkRequest(
      uri: Uri.parse("$_baseUrl?id=eq.$visitId"),
      headers: {"apiKey": _apiKey},
      method: HttpMethod.delete,
    );
    return await _networkService.sendJsonRequest(request: request);
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
      headers: {"apiKey": _apiKey},
      data: {
        if (customerId != null) "customer_id": customerId,
        if (visitDate != null) "visit_date": visitDate.toIso8601String(),
        if (status != null) "status": status,
        if (location != null) "location": location,
        if (notes != null) "notes": notes,
        if (activityIdsDone != null) "activities_done": activityIdsDone,
      },
    );
    return await _networkService.sendJsonRequest(request: request);
  }
}
