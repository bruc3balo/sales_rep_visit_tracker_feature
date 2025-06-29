import 'dart:collection';

import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';

sealed class SearchActivityState {}

class LoadingActivitySearchState extends SearchActivityState {}

class LoadedActivitySearchState extends SearchActivityState {
  final LinkedHashSet<Activity> searchResults;

  LoadedActivitySearchState({required this.searchResults});
}