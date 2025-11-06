import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.grey[50],
    primary: Colors.black,//white
    secondary: Colors.grey.shade200,
      onPrimary: Colors.grey
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900,
    primary: Colors.white,//grey.shade800
    secondary: Colors.grey.shade700,
      onPrimary: Colors.white
  ),
);
