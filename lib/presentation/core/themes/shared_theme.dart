import 'package:flutter/material.dart';

const Color kSeedColor = Colors.deepPurple;

InputDecorationTheme getDefaultInputDecoration(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  return InputDecorationTheme(
    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black),
    fillColor: isDark ? Colors.grey[800] : Colors.grey[300],
    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(10))),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(10))),
    disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(10))),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 1.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.cyan, width: 1.0),
    ),
    alignLabelWithHint: true,
    filled: true,
  );
}

ElevatedButtonThemeData get defaultButtonTheme {
  return ElevatedButtonThemeData(
    style: ButtonStyle(
      fixedSize: WidgetStatePropertyAll(Size(150, 40)),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 30)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    ),
  );
}


const PageTransitionsTheme pageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
);
