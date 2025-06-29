import 'package:flutter/cupertino.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/home/view/home_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/splash/view/splash_screen.dart';

enum AppRoutes {
  splashScreen("/"),
  home("/home");

  final String path;

  const AppRoutes(this.path);
}


extension RoutePage on AppRoutes {
  Widget getPage(BuildContext context) {
    return switch(this) {
      AppRoutes.splashScreen => SplashScreen(),
      AppRoutes.home => HomeScreen(),
    };
  }
}