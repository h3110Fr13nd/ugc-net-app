import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Colors.deepPurple;

  static ThemeData light() => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light),
        useMaterial3: true,
      );

  static ThemeData dark() => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
        brightness: Brightness.dark,
        useMaterial3: true,
      );
}
