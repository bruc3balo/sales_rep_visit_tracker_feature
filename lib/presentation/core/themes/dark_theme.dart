import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/themes/shared_theme.dart';

ThemeData get darkTheme {
  const seedColor = Colors.deepPurple;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.black,
      elevation: 0,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    inputDecorationTheme: defaultInputDecoration,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: defaultButtonTheme.style?.copyWith(
        backgroundColor: const WidgetStatePropertyAll(seedColor),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: seedColor.shade200,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: seedColor.shade200,
        side: BorderSide(color: seedColor.shade200),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: defaultInputDecoration,
      textStyle: const TextStyle(fontSize: 14, color: Colors.white),
      menuStyle: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(Colors.black),
        elevation: const WidgetStatePropertyAll(4),
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    cardTheme: CardTheme(
      elevation: 2,
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[700],
      thickness: 1,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: TextStyle(
        color: seedColor.shade200,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(fontSize: 14, color: Colors.white),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: seedColor,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(seedColor),
      trackColor: WidgetStatePropertyAll(seedColor.withOpacity(0.4)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: seedColor.shade300,
      thumbColor: seedColor,
      overlayColor: seedColor.withOpacity(0.3),
      inactiveTrackColor: Colors.grey[700],
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
      labelLarge: TextStyle(fontSize: 12, color: Colors.white70),
    ),
  );
}