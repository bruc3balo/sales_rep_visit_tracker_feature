import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/model/search_customers_models.dart';

class SearchCustomersViewModel extends ChangeNotifier {
  final RemoteCustomerRepository _customerRepository;
  final StreamController<ToastMessage> _toastMessage = StreamController.broadcast();
  SearchCustomerState _state = LoadedCustomersSearchState(searchResults: LinkedHashSet());

  SearchCustomersViewModel({
    required RemoteCustomerRepository customerRepository,
  }) : _customerRepository = customerRepository;

  SearchCustomerState get state => _state;

  Future<void> searchCustomers({
    required String customerName,
    int page = 0,
    int pageSize = 20,
  }) async {
    if (_state is! LoadedCustomersSearchState) return;

    try {
      _state = LoadingCustomersSearchState();
      notifyListeners();

      var getCustomerResult = await _customerRepository.getCustomers(
        likeName: customerName,
        page: page,
        pageSize: pageSize,
      );

      switch(getCustomerResult) {

        case ErrorResult<List<Customer>>():
          _toastMessage.add(ErrorMessage(message: getCustomerResult.error));
          _state = LoadedCustomersSearchState(searchResults: LinkedHashSet());
          break;
        case SuccessResult<List<Customer>>():
          _state = LoadedCustomersSearchState(searchResults: LinkedHashSet.from(getCustomerResult.data));
          break;
      }

    } finally {
      notifyListeners();
    }
  }
}
