class VisitSyncStatus {
  
  VisitSyncStatus._();
  static final VisitSyncStatus _instance = VisitSyncStatus._();
  
  factory VisitSyncStatus() => _instance;

  static bool _offlineSyncing = false;
  
  bool get isSyncing => _offlineSyncing;
  set syncing(bool newSyncStatus) => _offlineSyncing = newSyncStatus;
  
}
