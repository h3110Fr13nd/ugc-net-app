import 'package:flutter/material.dart';

export 'src/app.dart' show MyApp;

import 'src/app.dart' as app;
import 'src/models/app_state.dart';
import 'src/services/token_manager.dart';

Future<void> main() async {
  // Ensure plugin services are initialized before calling any plugins (e.g. SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  // Create the application state before runApp so plugins are safe to use in state init
  final initialState = MyAppState();
  // Wire global token provider so ApiClient can pick up access tokens when created without DI
  TokenManager.tokenProvider = () async => initialState.accessToken;

  runApp(app.MyApp(initialState: initialState));
}
