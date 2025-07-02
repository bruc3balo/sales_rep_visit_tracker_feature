import 'package:flutter/cupertino.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/connectivity/connectivity_service.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityPlusConnectionService implements ConnectivityService {

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker = InternetConnectionChecker();
  final StreamController<bool> _connectionStatusStreamController = StreamController.broadcast();

  bool lastResultNotifier = false;

  static final ConnectivityPlusConnectionService _instance = ConnectivityPlusConnectionService._();
  factory ConnectivityPlusConnectionService() => _instance;


  ConnectivityPlusConnectionService._();

  @override
  Stream<bool> get onConnectionChange => _connectionStatusStreamController.stream;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Future<void> initialize() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) async {
      bool isConnected = await _internetChecker.hasConnection;
      _connectionStatusStreamController.add(isConnected);
    });
  }

  @override
  Future<bool> hasInternetConnection() async {
    var results = await _connectivity.checkConnectivity();
    if (ConnectivityResult.none == results.lastOrNull) return false;

    bool hasConnection = await _internetChecker.hasConnection;
    lastResultNotifier = hasConnection;
    return hasConnection;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusStreamController.close();
  }

  @override
  bool get lastResult => lastResultNotifier;
}