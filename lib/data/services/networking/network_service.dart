import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';

abstract class NetworkService {
  Future<NetworkResponse> sendJsonRequest({
    required NetworkRequest request,
  });
}
