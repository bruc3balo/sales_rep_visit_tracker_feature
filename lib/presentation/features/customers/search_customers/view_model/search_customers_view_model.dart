import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/connectivity/connectivity_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/search_local_customers_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/search_remote_customer_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/model/search_customers_models.dart';

class SearchCustomersViewModel extends ChangeNotifier {
  final SearchRemoteCustomerUseCase _searchRemoteCustomerUseCase;
  final SearchLocalCustomersUseCase _searchLocalCustomersUseCase;
  final ConnectivityService _connectivityService;
  final StreamController<ToastMessage> _toastMessage = StreamController.broadcast();
  SearchCustomerState _state = LoadedCustomersSearchState(searchResults: LinkedHashSet());

  SearchCustomersViewModel({
    required SearchRemoteCustomerUseCase searchRemoteCustomerUseCase,
    required SearchLocalCustomersUseCase searchLocalCustomersUseCase,
    required ConnectivityService connectivityService,
  })  : _searchRemoteCustomerUseCase = searchRemoteCustomerUseCase,
        _searchLocalCustomersUseCase = searchLocalCustomersUseCase,
        _connectivityService = connectivityService {
    searchCustomers();
  }

  SearchCustomerState get state => _state;

  Future<void> searchCustomers({
    String? customerName,
    int page = 0,
    int pageSize = 20,
  }) async {
    bool hasConnectivity = await _connectivityService.hasInternetConnection();
    if (hasConnectivity) {
      await _searchRemoteCustomers(
        customerName: customerName,
        page: page,
        pageSize: pageSize,
      );
    } else {
      await _searchLocalCustomers(
        customerName: customerName,
        page: page,
        pageSize: pageSize,
      );
    }
  }

  Future<void> _searchLocalCustomers({
    String? customerName,
    int page = 0,
    int pageSize = 20,
  }) async {
    if (_state is! LoadedCustomersSearchState) return;

    try {
      _state = LoadingCustomersSearchState();
      notifyListeners();

      var getCustomerResult = await _searchLocalCustomersUseCase.execute(
        likeName: customerName,
        page: page,
        pageSize: pageSize,
      );

      switch (getCustomerResult) {
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

  Future<void> _searchRemoteCustomers({
    String? customerName,
    int page = 0,
    int pageSize = 20,
  }) async {
    if (_state is! LoadedCustomersSearchState) return;

    try {
      _state = LoadingCustomersSearchState();
      notifyListeners();

      var getCustomerResult = await _searchRemoteCustomerUseCase.execute(
        likeName: customerName,
        page: page,
        pageSize: pageSize,
      );

      switch (getCustomerResult) {
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
