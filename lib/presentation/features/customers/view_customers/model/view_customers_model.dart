import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';

// ViewCustomersState
sealed class ViewCustomersState {}
class LoadingViewCustomerState extends ViewCustomersState {}
class LoadedViewCustomerState extends ViewCustomersState {}

// DeleteCustomerState
sealed class DeleteCustomerState {}
class InitialDeleteCustomerState extends DeleteCustomerState {}
class LoadingDeleteCustomerState extends DeleteCustomerState {
  final Customer customer;

  LoadingDeleteCustomerState({required this.customer});
}
