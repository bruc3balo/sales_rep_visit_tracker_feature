import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';

sealed class EditCustomerState {}

final class InitialEditCustomerState extends EditCustomerState {
  final Customer customer;

  InitialEditCustomerState({
    required this.customer,
  });
}

final class LoadingEditCustomerState extends EditCustomerState {}

final class SuccessEditCustomerState extends EditCustomerState {
  final Customer customer;

  SuccessEditCustomerState({required this.customer});
}