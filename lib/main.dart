import 'package:flutter/material.dart';

void main() {
  runApp(const SalesRepVisitTrackerApplication());
}

class SalesRepVisitTrackerApplication extends StatelessWidget {
  const SalesRepVisitTrackerApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visit Tracker',
    );
  }
}