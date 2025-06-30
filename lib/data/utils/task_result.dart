import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';

sealed class TaskResult<T> {}

final class ErrorResult<T> extends TaskResult<T> {
  final String error;
  final StackTrace? trace;
  final FailureType? failure;

  ErrorResult({
    required this.error,
    this.trace,
    this.failure = FailureType.unknown,
  });
}

final class SuccessResult<T> extends TaskResult<T> {
  final T data;
  final String message;

  SuccessResult({
    required this.data,
    this.message = "Success",
  });
}
