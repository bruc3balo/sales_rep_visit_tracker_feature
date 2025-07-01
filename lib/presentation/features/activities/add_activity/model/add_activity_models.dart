import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';

sealed class AddActivityState {}

final class InitialAddActivityState extends AddActivityState {}

final class LoadingAddActivityState extends AddActivityState {}

final class SuccessAddActivityState extends AddActivityState {
  final Activity activity;

  SuccessAddActivityState({required this.activity});
}
