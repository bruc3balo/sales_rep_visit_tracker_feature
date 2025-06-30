import 'package:flutter/material.dart';

InputDecorationTheme get defaultInputDecoration {
  return InputDecorationTheme(
    labelStyle: TextStyle(
      color: Colors.black,
    ),
    border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(10))
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10))
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(10))
    ),
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.all(Radius.circular(10))
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
          color: Colors.red,
          width: 1.0
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
          color: Colors.cyan,
          width: 1.0
      ),
    ),
    alignLabelWithHint: true,
    fillColor: Colors.grey.shade300,
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

Container wrappedContainer({
  required Widget child,
}) {
  return Container(
      padding: EdgeInsets.all(14.0),
      decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: child
  );
}