import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';

sealed class EditActivityState {}

final class InitialEditActivityState extends EditActivityState {
  final Activity activity;

  InitialEditActivityState({
    required this.activity,
  });
}

final class LoadingEditActivityState extends EditActivityState {}

final class SuccessEditActivityState extends EditActivityState {
  final Activity activity;

  SuccessEditActivityState({required this.activity});
}