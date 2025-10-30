import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    return SwitchListTile(
      title: const Text('Dark mode'),
      value: appState.darkMode,
      onChanged: (_) => appState.toggleTheme(),
    );
  }
}
