import 'package:flutter/material.dart';

export 'src/app.dart' show MyApp;

import 'src/app.dart' as _app;

void main() {
  runApp(const _app.MyApp());
}
