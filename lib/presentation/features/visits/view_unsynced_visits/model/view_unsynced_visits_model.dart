sealed class UnsyncedVisitsState {}

class InitialUnsyncedVisitState extends UnsyncedVisitsState {}

class LoadingUnsyncedVisitState extends UnsyncedVisitsState {}

class DisplayingUnsyncedVisitState extends UnsyncedVisitsState {}

class SyncingVisitState extends UnsyncedVisitsState {}

class FinishedSyncingVisitState extends UnsyncedVisitsState {
  final Map<String, int> results;

  FinishedSyncingVisitState({required this.results});
}