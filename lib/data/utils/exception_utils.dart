import 'package:dio/dio.dart';

enum FailureType {
  localDatabase,
  network,
  networkServer,
  illegalState,
  interrupt,
  unknown
}

extension DioFailureType on DioExceptionType {
  FailureType get failureType => switch(this) {
    DioExceptionType.connectionTimeout => FailureType.network,
    DioExceptionType.sendTimeout => FailureType.network,
    DioExceptionType.receiveTimeout => FailureType.network,
    DioExceptionType.badCertificate => FailureType.networkServer,
    DioExceptionType.badResponse => FailureType.networkServer,
    DioExceptionType.cancel => FailureType.interrupt,
    DioExceptionType.connectionError => FailureType.network,
    DioExceptionType.unknown => FailureType.unknown,
  };
}


extension Retry on DioExceptionType {
  bool get shouldRetry => switch(this) {
    DioExceptionType.connectionTimeout => true,
    DioExceptionType.sendTimeout => true,
    DioExceptionType.receiveTimeout => true,
    DioExceptionType.badCertificate => false,
    DioExceptionType.badResponse => false,
    DioExceptionType.cancel => true,
    DioExceptionType.connectionError => true,
    DioExceptionType.unknown => true,
  };
}