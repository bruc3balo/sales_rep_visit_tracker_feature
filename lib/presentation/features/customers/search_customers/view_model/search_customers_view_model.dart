import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/connectivity/connectivity_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/search_local_customers_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/search_remote_customer_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/model/search_customers_models.dart';

class SearchCustomersViewModel extends ChangeNotifier {
  final SearchRemoteCustomerUseCase _searchRemoteCustomerUseCase;
  final SearchLocalCustomersUseCase _searchLocalCustomersUseCase;
  final ConnectivityService _connectivityService;
  final SplayTreeSet<Customer> _customers = SplayTreeSet(
    (a, b) => a.id.compareTo(b.id),
  );
  int _localPage = 0;
  int _remotePage = 0;
  static final int _pageSize = 20;
  String? _lastQuery;
  SearchCustomerState _state = LoadedCustomersSearchState();

  SearchCustomersViewModel({
    required SearchRemoteCustomerUseCase searchRemoteCustomerUseCase,
    required SearchLocalCustomersUseCase searchLocalCustomersUseCase,
    required ConnectivityService connectivityService,
  })  : _searchRemoteCustomerUseCase = searchRemoteCustomerUseCase,
        _searchLocalCustomersUseCase = searchLocalCustomersUseCase,
        _connectivityService = connectivityService;

  SearchCustomerState get state => _state;

  List<Customer> get customers => UnmodifiableListView(_customers);

  Future<void> searchCustomers({
    String? customerName,
  }) async {
    if (_lastQuery != null && _lastQuery != customerName) {
      _localPage = 0;
      _remotePage = 0;
    } else if (customerName != null && customerName != _lastQuery) {
      _localPage = 0;
      _remotePage = 0;
    }

    _lastQuery = customerName;

    bool hasConnectivity = await _connectivityService.hasInternetConnection();
    if (hasConnectivity) {
      await _searchRemoteCustomers(
        customerName: customerName,
      );
    } else {
      await _searchLocalCustomers(
        customerName: customerName,
      );
    }
  }

  Future<void> _searchLocalCustomers({
    String? customerName,
  }) async {
    if (_state is! LoadedCustomersSearchState) return;

    try {
      _state = LoadingCustomersSearchState();
      notifyListeners();

      var getCustomerResult = await _searchLocalCustomersUseCase.execute(
        likeName: customerName,
        page: _localPage,
        pageSize: _pageSize,
      );

      switch (getCustomerResult) {
        case ErrorResult<List<Customer>>():
          GlobalToastMessage().add(ErrorMessage(message: getCustomerResult.error));
          _state = LoadedCustomersSearchState();
          break;
        case SuccessResult<List<Customer>>():
          if(getCustomerResult.data.length >= _pageSize) _localPage++;
          _customers.addAll(getCustomerResult.data);
          _state = LoadedCustomersSearchState(searchResults: LinkedHashSet.from(getCustomerResult.data));
          break;
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> _searchRemoteCustomers({
    String? customerName,
  }) async {
    if (_state is! LoadedCustomersSearchState) return;

    try {
      _state = LoadingCustomersSearchState();
      notifyListeners();

      var getCustomerResult = await _searchRemoteCustomerUseCase.execute(
        likeName: customerName,
        page: _remotePage,
        pageSize: _pageSize,
      );

      switch (getCustomerResult) {
        case ErrorResult<List<Customer>>():
          GlobalToastMessage().add(ErrorMessage(message: getCustomerResult.error));
          _state = LoadedCustomersSearchState();
          break;
        case SuccessResult<List<Customer>>():
          if(getCustomerResult.data.length >= _pageSize) _remotePage++;
          _customers.addAll(getCustomerResult.data);
          _state = LoadedCustomersSearchState(searchResults: LinkedHashSet.from(getCustomerResult.data));
          break;
      }
    } finally {
      notifyListeners();
    }
  }
}
