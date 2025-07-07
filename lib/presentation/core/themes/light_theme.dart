
import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/themes/shared_theme.dart';

import 'package:flutter/material.dart';

ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kSeedColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: kSeedColor,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: kSeedColor,
      ),
    ),
    inputDecorationTheme: getDefaultInputDecoration(Brightness.light),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: defaultButtonTheme.style?.copyWith(
        backgroundColor: const WidgetStatePropertyAll(kSeedColor),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kSeedColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kSeedColor,
        side: const BorderSide(color: kSeedColor),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      //inputDecorationTheme: getDefaultInputDecoration(Brightness.light),
      textStyle: const TextStyle(fontSize: 14),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.white),
        elevation: WidgetStatePropertyAll(4),
      ),
    ),
    iconTheme: const IconThemeData(color: kSeedColor),
    cardTheme: CardTheme(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: TextStyle(
        color: kSeedColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(fontSize: 14),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: kSeedColor,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(kSeedColor),
      trackColor: WidgetStatePropertyAll(kSeedColor.withAlpha(5)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: kSeedColor,
      thumbColor: kSeedColor,
      overlayColor: kSeedColor.withAlpha(2),
      inactiveTrackColor: Colors.grey[300],
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
      labelLarge: TextStyle(fontSize: 12),
    ),
    pageTransitionsTheme: pageTransitionsTheme,
  );
}