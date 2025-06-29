sealed class ToastMessage {
  final String message;
  ToastMessage({required this.message});
}

class InfoMessage extends ToastMessage {
  InfoMessage({required super.message});
}

class ErrorMessage extends ToastMessage {
  ErrorMessage({required super.message});
}

class SuccessMessage extends ToastMessage {
  SuccessMessage({required super.message});
}
