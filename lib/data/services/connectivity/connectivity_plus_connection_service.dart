import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/connectivity/connectivity_service.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class ConnectivityPlusConnectionService implements ConnectivityService {

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker = InternetConnectionChecker();
  final StreamController<bool> _connectionStatusStreamController = StreamController.broadcast();

  bool _lastResult = false;
  bool _initialCheck = true;

  static final ConnectivityPlusConnectionService _instance = ConnectivityPlusConnectionService._();
  factory ConnectivityPlusConnectionService() => _instance;


  ConnectivityPlusConnectionService._();

  static final _tag = "ConnectivityPlusConnectionService";

  @override
  Stream<bool> get onConnectionChange => _connectionStatusStreamController.stream;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Future<void> initialize() async {
    AppLog.I.i(_tag, "Subscribe to connectivity");
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) async {
      _lastResult = await _internetChecker.hasConnection;
      AppLog.I.i(_tag, _lastResult ? "Connected" : "No internet connection");

      if(_initialCheck) {
        _initialCheck = false;
        return;
      }
      _connectionStatusStreamController.add(_lastResult);
    });
  }

  @override
  Future<bool> hasInternetConnection() async {
    AppLog.I.i(_tag, "Checking for connectivity");
    var results = await _connectivity.checkConnectivity();
    AppLog.I.i(_tag, "Connectivity results : ${results.join(",")}");

    var desiredSet = HashSet.from([ConnectivityResult.mobile, ConnectivityResult.wifi]);
    var internetResults = results.where((e) => desiredSet.contains(e)).toList();
    if(internetResults.isEmpty) return false;


    bool hasConnection = await _internetChecker.hasConnection;
    _lastResult = hasConnection;
    return hasConnection;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusStreamController.close();
  }

  @override
  bool get lastResult => _lastResult;
}