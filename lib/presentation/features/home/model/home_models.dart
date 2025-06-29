import 'package:flutter/material.dart';

enum HomePages {
  visits(
    iconData: Icons.history,
    label: "Visits",
  ),
  activities(
    iconData: Icons.task,
    label: "Activities",
  ),
  customers(
    iconData: Icons.group,
    label: "Customers"
  );

  const HomePages({
    required this.iconData,
    required this.label,
  });

  final IconData iconData;
  final String label;
}
