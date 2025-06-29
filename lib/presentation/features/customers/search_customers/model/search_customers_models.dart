import 'dart:collection';

import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';

sealed class SearchCustomerState {}

class LoadingCustomersSearchState extends SearchCustomerState {}

class LoadedCustomersSearchState extends SearchCustomerState {
  final LinkedHashSet<Customer> searchResults;

  LoadedCustomersSearchState({required this.searchResults});
}