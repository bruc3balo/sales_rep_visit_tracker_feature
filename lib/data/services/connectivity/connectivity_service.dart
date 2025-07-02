abstract class ConnectivityService {
  Future<bool> hasInternetConnection();
  Stream<bool> get onConnectionChange;
  bool? get lastResult;
}