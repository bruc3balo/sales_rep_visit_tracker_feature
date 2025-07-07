
import 'dart:async';

class VisitSyncStatus {
  
  VisitSyncStatus._();
  static final VisitSyncStatus _instance = VisitSyncStatus._();
  final StreamController<bool> _syncStatusController = StreamController.broadcast();
  
  factory VisitSyncStatus() => _instance;

  static bool _offlineSyncing = false;
  
  bool get isSyncing => _offlineSyncing;
  Stream<bool> get syncStream => _syncStatusController.stream;
  set syncing(bool newSyncStatus) {
    _offlineSyncing = newSyncStatus;
    _syncStatusController.add(_offlineSyncing);
  }
  
}

