import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/view_customers/model/view_customers_model.dart';

class ViewCustomersViewModel extends ChangeNotifier {
  final RemoteCustomerRepository _customerRepository;
  int _page = 0;
  final SplayTreeSet<Customer> _customers = SplayTreeSet(
    (a, b) => a.id.compareTo(b.id),
  );
  final StreamController<ToastMessage> _toastController = StreamController.broadcast();
  ViewCustomersState _itemsState = LoadedViewCustomerState();

  ViewCustomersViewModel({
    required RemoteCustomerRepository customerRepository,
  }) : _customerRepository = customerRepository {
    loadMoreItems();
  }

  ViewCustomersState get itemsState => _itemsState;

  List<Customer> get customers => UnmodifiableListView(_customers);

  Future<void> loadMoreItems() async {
    if (_itemsState is! LoadedViewCustomerState) return;

    try {
      _itemsState = LoadingViewCustomerState();
      notifyListeners();

      var customerResult = await _customerRepository.getCustomers(page: _page, pageSize: 20, order: "created_at.desc");

      switch (customerResult) {
        case ErrorResult<List<Customer>>():
          _toastController.add(ErrorMessage(message: customerResult.error));
          break;
        case SuccessResult<List<Customer>>():
          _customers.addAll(customerResult.data);
          if (customerResult.data.isNotEmpty) _page++;
          break;
      }
    } finally {
      _itemsState = LoadedViewCustomerState();
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_itemsState is! LoadedViewCustomerState) return;
    _page = 0;
    _customers.clear();
    loadMoreItems();
  }
}
