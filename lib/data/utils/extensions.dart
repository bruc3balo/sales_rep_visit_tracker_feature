import 'dart:math';

extension CapitalizeString on String {
  String get capitalize {
    if (isEmpty) return this;
    if (length == 1) return toUpperCase();
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension Paging on List {
  List<T> toPage<T>({
    required int page,
    required int pageSize,
  }) {
    final startIndex = page * pageSize;
    if (startIndex >= length) return [];

    var endIndex = startIndex + pageSize;
    endIndex = min(endIndex, length);
    return sublist(startIndex, endIndex) as List<T>;
  }
}
