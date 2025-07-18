import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/connectivity/connectivity_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/delete_customer_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/view_local_customers_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/view_remote_customers_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/view_customers/model/view_customers_model.dart';

class ViewCustomersViewModel extends ChangeNotifier {
  final ViewRemoteCustomersUseCase _remoteCustomersUseCase;
  final ViewLocalCustomersUseCase _localCustomersUseCase;
  final DeleteCustomerUseCase _deleteCustomerUseCase;
  final ConnectivityService _connectivityService;
  late final StreamSubscription<Customer> _customerSubscription;

  int _localPage = 0;
  int _remotePage = 0;
  static final int _pageSize = 20;
  static final _tag = "ViewCustomersViewModel";
  final SplayTreeSet<Customer> _customers = SplayTreeSet();
  ViewCustomersState _itemsState = LoadedViewCustomerState();
  DeleteCustomerState _deleteState = InitialDeleteCustomerState();

  ViewCustomersViewModel({
    required ViewRemoteCustomersUseCase viewRemoteCustomersUseCase,
    required ViewLocalCustomersUseCase viewLocalCustomersUseCase,
    required DeleteCustomerUseCase deleteCustomerUseCase,
    required ConnectivityService connectivityService,
  })  : _remoteCustomersUseCase = viewRemoteCustomersUseCase,
        _localCustomersUseCase = viewLocalCustomersUseCase,
        _connectivityService = connectivityService,
        _deleteCustomerUseCase = deleteCustomerUseCase {
    loadMoreItems();
    _subscribeToCustomerUpdates();
  }

  ViewCustomersState get itemsState => _itemsState;

  DeleteCustomerState get deleteState => _deleteState;

  List<Customer> get customers => UnmodifiableListView(_customers);

  Future<void> loadMoreItems() async {
    bool hasConnectivity = await _connectivityService.hasInternetConnection();
    if (hasConnectivity) {
      await _loadMoreRemoteItems();
    } else {
      await _loadMoreLocalItems();
    }
  }

  Future<void> _loadMoreRemoteItems() async {
    if (_itemsState is! LoadedViewCustomerState) return;

    try {
      _itemsState = LoadingViewCustomerState();
      notifyListeners();

      var customerResult = await _remoteCustomersUseCase.execute(
        page: _remotePage,
        pageSize: _pageSize,
        order: "created_at.desc",
      );

      switch (customerResult) {
        case ErrorResult<List<Customer>>():
          GlobalToastMessage().add(ErrorMessage(message: customerResult.error));
          break;
        case SuccessResult<List<Customer>>():
          _customers.addAll(customerResult.data);
          if (customerResult.data.length >= _pageSize) _remotePage++;
          break;
      }
    } finally {
      _itemsState = LoadedViewCustomerState();
      notifyListeners();
    }
  }

  Future<void> _loadMoreLocalItems() async {
    if (_itemsState is! LoadedViewCustomerState) return;

    try {
      _itemsState = LoadingViewCustomerState();
      notifyListeners();

      var customerResult = await _localCustomersUseCase.execute(
        page: _localPage,
        pageSize: _pageSize,
      );

      switch (customerResult) {
        case ErrorResult<List<Customer>>():
          GlobalToastMessage().add(ErrorMessage(message: customerResult.error));
          break;
        case SuccessResult<List<Customer>>():
          _customers.addAll(customerResult.data);
          if (customerResult.data.length >= _pageSize) _localPage++;
          break;
      }
    } finally {
      _itemsState = LoadedViewCustomerState();
      notifyListeners();
    }
  }

  void updateItem(Customer customer) {
    _customers.removeWhere((a) => a.id == customer.id);
    _customers.add(customer);
    notifyListeners();
  }

  Future<void> deleteCustomer({
    required Customer customer,
  }) async {
    if (_deleteState is LoadingDeleteCustomerState) return;

    try {
      _deleteState = LoadingDeleteCustomerState(customer: customer);
      notifyListeners();

      var result = await _deleteCustomerUseCase.execute(
        customerId: customer.id,
      );

      switch (result) {
        case ErrorResult<void>():
          GlobalToastMessage().add(ErrorMessage(message: result.error));
          break;

        case SuccessResult<void>():
          _customers.remove(customer);
          GlobalToastMessage().add(SuccessMessage(message: result.message));
          break;
      }
    } finally {
      _deleteState = InitialDeleteCustomerState();
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_itemsState is! LoadedViewCustomerState) return;
    _localPage = 0;
    _remotePage = 0;
    _customers.clear();
    loadMoreItems();
  }

  void _subscribeToCustomerUpdates() {
    AppLog.I.d(_tag, "Subscribing to local customer updates");
    _customerSubscription = _localCustomersUseCase.customerSetStream.listen((customer) {
      _customers.removeWhere((c) => c.id == customer.id);
      _customers.add(customer);
      notifyListeners();
    });
  }

  void _unSubscribeFromCustomerUpdates() {
    AppLog.I.d(_tag, "Unsubscribing from local customer updates");
    _customerSubscription.cancel();
  }

  @override
  void dispose() {
    _unSubscribeFromCustomerUpdates();
    super.dispose();
  }
}
