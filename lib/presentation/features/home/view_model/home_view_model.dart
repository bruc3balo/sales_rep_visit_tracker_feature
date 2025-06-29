import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/home/model/home_models.dart';

class HomeViewModel extends ChangeNotifier {
  HomePages _currentPage = HomePages.visits;
  final List<HomePages> homePages = UnmodifiableListView(HomePages.values);

  HomePages get currentPage => _currentPage;

  void changePage(int pageIndex) {
    if(homePages[pageIndex] == _currentPage) return;
    _currentPage = homePages[pageIndex];
    notifyListeners();
  }
}
