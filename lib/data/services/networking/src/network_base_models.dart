import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';

enum HttpMethod { delete, get, patch, post }

class NetworkRequest {
  final Uri uri;
  final HttpMethod method;
  final Map<String, String> headers;
  final Object? data;
  final int retryCount;

  NetworkRequest({
    required this.uri,
    required this.method,
    this.headers = const {},
    this.data,
    this.retryCount = 1,
  });
}

sealed class NetworkResponse {}

final class FailNetworkResponse extends NetworkResponse {
  final int? statusCode;
  final String description;
  final StackTrace? trace;
  final FailureType failureType;
  final dynamic data;

  FailNetworkResponse({
    this.statusCode,
    this.description = " Something went wrong",
    this.failureType = FailureType.unknown,
    this.trace,
    this.data,
  });
}

final class SuccessNetworkResponse extends NetworkResponse {
  final int statusCode;
  final dynamic data;

  SuccessNetworkResponse({
    required this.statusCode,
    this.data,
  });
}
