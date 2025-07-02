import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/add_customer/model/add_customer_models.dart';

class AddCustomerViewModel extends ChangeNotifier {
  final RemoteCustomerRepository _remoteCustomerRepository;
  final StreamController<ToastMessage> _toastStream = StreamController.broadcast();
  AddCustomerState _state = InitialAddCustomerState();

  AddCustomerViewModel({
    required RemoteCustomerRepository remoteCustomerRepository
  }) : _remoteCustomerRepository = remoteCustomerRepository;


  AddCustomerState get state => _state;


  Future<void> addCustomer(String name) async {
    if(_state is! InitialAddCustomerState) return;

    try {
      _state = LoadingAddCustomerState();
      notifyListeners();

      var result = await _remoteCustomerRepository.createCustomer(
        name: name,
      );


      switch(result) {

        case ErrorResult<Customer>():
          _toastStream.add(ErrorMessage(message: result.error));
          _state = InitialAddCustomerState();
          break;
        case SuccessResult<Customer>():
          _toastStream.add(SuccessMessage(message: result.message));
          _state = SuccessAddCustomerState(customer: result.data);
          break;
      }


    } finally {
      notifyListeners();
    }
  }
}