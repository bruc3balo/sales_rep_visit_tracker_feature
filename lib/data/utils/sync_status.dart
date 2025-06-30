class VisitSyncStatus {
  
  //Singleton
  VisitSyncStatus._();
  static final VisitSyncStatus _instance = VisitSyncStatus._();
  
  //Always return _instance
  factory VisitSyncStatus() => _instance;

  //Variable
  static bool _offlineSyncing = false;
  
  // Accessors
  bool get isSyncing => _offlineSyncing;
  set syncing(bool newSyncStatus) => _offlineSyncing = newSyncStatus;
  
}
