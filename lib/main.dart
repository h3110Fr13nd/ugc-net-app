import 'package:flutter/material.dart';

export 'src/app.dart' show MyApp;

import 'src/app.dart' as app;
import 'src/models/app_state.dart';

Future<void> main() async {
  // Ensure plugin services are initialized before calling any plugins (e.g. SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  // Create the application state before runApp so plugins are safe to use in state init
  final initialState = MyAppState();

  runApp(app.MyApp(initialState: initialState));
}
