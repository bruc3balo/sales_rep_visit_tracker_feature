import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/update_customer_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/edit_customer/model/edit_customer_model.dart';

class EditCustomerViewModel extends ChangeNotifier {
  final UpdateCustomerUseCase _updateCustomerUseCase;
  final Customer _customer;
  late EditCustomerState _state = InitialEditCustomerState(
    customer: _customer,
  );

  EditCustomerViewModel({
    required UpdateCustomerUseCase updateCustomerUseCase,
    required Customer customer,
  })  : _updateCustomerUseCase = updateCustomerUseCase,
        _customer = customer;

  EditCustomerState get state => _state;

  Future<void> editCustomer(String name) async {
    if (_state is! InitialEditCustomerState) return;

    try {
      _state = LoadingEditCustomerState();
      notifyListeners();

      var result = await _updateCustomerUseCase.execute(
        customerId: _customer.id,
        name: name,
      );

      switch (result) {
        case ErrorResult<Customer>():
          GlobalToastMessage().add(ErrorMessage(message: result.error));
          _state = InitialEditCustomerState(customer: _customer);
          break;
        case SuccessResult<Customer>():
          GlobalToastMessage().add(SuccessMessage(message: result.message));
          _state = SuccessEditCustomerState(customer: result.data);
          break;
      }
    } finally {
      notifyListeners();
    }
  }
}