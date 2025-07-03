import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/network_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';

class DioNetworkService implements NetworkService {
  @override
  Future<NetworkResponse> sendJsonRequest({
    required NetworkRequest request,
  }) async {
    final Dio dio = Dio(
      BaseOptions(
        headers: request.headers,
      ),
    );

    dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );

    int requestCountTry = 0;

    while (requestCountTry <= request.retryCount) {
      bool isLastTry = requestCountTry == request.retryCount;

      try {
        var response = await switch (request.method) {
          HttpMethod.delete => dio.deleteUri(
              request.uri,
              data: jsonEncode(request.data),
            ),
          HttpMethod.get => dio.getUri(
              request.uri,
            ),
          HttpMethod.patch => dio.patchUri(request.uri, data: jsonEncode(request.data)),
          HttpMethod.post => dio.postUri(request.uri, data: jsonEncode(request.data)),
        };

        int? statusCode = response.statusCode;
        if (statusCode == null) {
          return FailNetworkResponse(description: "Failed to get status code", data: response.data);
        }

        return SuccessNetworkResponse(
          statusCode: statusCode,
          data: response.data,
        );
      } on SocketException catch(e, trace) {
        return FailNetworkResponse(
          description: e.message,
          trace: trace,
          failureType: FailureType.network,
        );
      } on DioException catch (e, trace) {
        if (isLastTry) {
          return FailNetworkResponse(
            statusCode: e.response?.statusCode,
            description: e.message ?? e.error.toString(),
            trace: trace,
            data: e.response?.data,
          );
        }
        requestCountTry++;
      }
    }

    return FailNetworkResponse(description: "Failed to send request");
  }
}
