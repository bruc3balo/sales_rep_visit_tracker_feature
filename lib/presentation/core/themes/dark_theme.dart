import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/themes/shared_theme.dart';

ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: kSeedColor,
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
    inputDecorationTheme: getDefaultInputDecoration(Brightness.dark),
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
        side: BorderSide(color: kSeedColor),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      //inputDecorationTheme: getDefaultInputDecoration(Brightness.dark),
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
        color: kSeedColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(fontSize: 14, color: Colors.black),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: kSeedColor,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(kSeedColor),
      trackColor: WidgetStatePropertyAll(kSeedColor.withOpacity(0.4)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: kSeedColor,
      thumbColor: kSeedColor,
      overlayColor: kSeedColor.withOpacity(0.3),
      inactiveTrackColor: Colors.grey[700],
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
      labelLarge: TextStyle(fontSize: 12, color: Colors.white70),
    ),
    pageTransitionsTheme: pageTransitionsTheme,
  );
}
