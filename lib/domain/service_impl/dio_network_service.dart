import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/network_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';

class DioNetworkService implements NetworkService {
  static const _tag = "DioNetworkService";

  @override
  Future<NetworkResponse> sendJsonRequest({
    required NetworkRequest request,
  }) async {
    AppLog.I.i(_tag, "Sending request to ${request.uri} with method ${request.method.name}");

    final Dio dio = Dio(
      BaseOptions(
        headers: request.headers,
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: kDebugMode,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => AppLog.I.d(_tag, obj),
      ),
    );

    int requestCountTry = 0;

    while (requestCountTry <= request.retryCount) {
      bool isLastTry = requestCountTry == request.retryCount;
      AppLog.I.i(_tag, "Attempt ${requestCountTry + 1}/${request.retryCount + 1}");

      try {
        Response response = await switch (request.method) {
          HttpMethod.delete => dio.deleteUri(
            request.uri,
            data: jsonEncode(request.data),
          ),
          HttpMethod.get => dio.getUri(request.uri),
          HttpMethod.patch => dio.patchUri(request.uri, data: jsonEncode(request.data)),
          HttpMethod.post => dio.postUri(request.uri, data: jsonEncode(request.data)),
        };

        int? statusCode = response.statusCode;
        if (statusCode == null) {
          AppLog.I.e(_tag, "No status code received", error: response.data);
          return FailNetworkResponse(description: "Failed to get status code", data: response.data);
        }

        AppLog.I.i(_tag, "Request succeeded with status $statusCode");
        return SuccessNetworkResponse(
          statusCode: statusCode,
          data: response.data,
        );
      } on SocketException catch (e, trace) {
        AppLog.I.e(_tag, "SocketException (likely network issue): ${e.message}", error: e, trace: trace);
        return FailNetworkResponse(
          description: e.message,
          trace: trace,
          failureType: FailureType.network,
        );
      } on DioException catch (e, trace) {
        AppLog.I.w(_tag, "DioException occurred: ${e.message} (retry=${!isLastTry})");

        if (isLastTry || !e.type.shouldRetry) {
          AppLog.I.e(_tag, "Final attempt failed. Returning FailNetworkResponse", error: e, trace: trace);
          return FailNetworkResponse(
            statusCode: e.response?.statusCode,
            description: e.message ?? e.error.toString(),
            trace: trace,
            failureType: e.type.failureType,
            data: e.response?.data,
          );
        }

        requestCountTry++;
        AppLog.I.i(_tag, "Retrying...");
      } catch(e, trace) {
        return FailNetworkResponse(
          description: e.toString(),
          trace: trace,
        );
      }
    }

    AppLog.I.e(_tag, "Exceeded maximum retries. Returning fallback failure.");
    return FailNetworkResponse(description: "Failed to send request");
  }
}