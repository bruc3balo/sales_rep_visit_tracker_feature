import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';

sealed class AddCustomerState {}

final class InitialAddCustomerState extends AddCustomerState {}

final class LoadingAddCustomerState extends AddCustomerState {}

final class SuccessAddCustomerState extends AddCustomerState {
  final Customer customer;

  SuccessAddCustomerState({required this.customer});
}
