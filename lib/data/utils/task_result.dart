sealed class TaskResult<T> {}

final class ErrorResult<T> extends TaskResult<T> {
  final String error;
  final StackTrace? trace;

  ErrorResult({
    required this.error,
    this.trace,
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
