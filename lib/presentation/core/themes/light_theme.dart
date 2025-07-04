
import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/themes/shared_theme.dart';

ThemeData get lightTheme {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    appBarTheme: AppBarTheme(
      centerTitle: true,
    ),
    inputDecorationTheme: defaultInputDecoration,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: defaultButtonTheme.style?.copyWith(
        backgroundColor: WidgetStatePropertyAll(Colors.deepPurple),
        foregroundColor: WidgetStatePropertyAll(Colors.white),
      )
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: defaultInputDecoration,
    ),
  );
}