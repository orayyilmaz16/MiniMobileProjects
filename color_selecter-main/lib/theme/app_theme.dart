import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: false, // Material 2 görünümü için
    primarySwatch: Colors.teal,

    appBarTheme: const AppBarTheme(
      color: Colors.tealAccent,
      elevation: 20,
      iconTheme: IconThemeData(color: Colors.black),
    ),
  );
}
