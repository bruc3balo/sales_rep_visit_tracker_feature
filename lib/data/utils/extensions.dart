extension CapitalizeString on String {
  String get capitalize {
      if(isEmpty) return this;
      if(length == 1) return toUpperCase();
      return "${this[0].toUpperCase()}${substring(1)}";
  }
}