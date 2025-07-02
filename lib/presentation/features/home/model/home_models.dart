import 'package:flutter/material.dart';

enum HomePages {
  visits(
    iconData: Icons.history_outlined,
    label: "Visits",
  ),
  activities(
    iconData: Icons.run_circle_outlined,
    label: "Activities",
  ),
  customers(
    iconData: Icons.group_outlined,
    label: "Customers",
  );

  const HomePages({
    required this.iconData,
    required this.label,
  });

  final IconData iconData;
  final String label;
}


sealed class CountHomeVisitsState {}

final class LoadingCountVisitState extends CountHomeVisitsState {}

final class LoadedCountVisitState extends CountHomeVisitsState {
  final int? unSyncedVisitCount;

  LoadedCountVisitState({required this.unSyncedVisitCount});
}