import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';


/// States
// ViewActivitiesState
sealed class ViewActivitiesState {}
class LoadingViewActivitiesState extends ViewActivitiesState {}
class LoadedViewActivitiesState extends ViewActivitiesState {}

// DeleteActivityState
sealed class DeleteActivityState {}
class InitialDeleteActivityState extends DeleteActivityState {}
class LoadingDeleteActivityState extends DeleteActivityState {
  final Activity activity;

  LoadingDeleteActivityState({required this.activity});
}

enum ActivityTileMenuItem {
  edit,
  delete;
}