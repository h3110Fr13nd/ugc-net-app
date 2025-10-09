import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../widgets/app_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return AppScaffold(
      title: 'Home',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('A random idea:'),
            const SizedBox(height: 8),
            Text(
              appState.current.asLowerCase,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => appState.next(),
              child: const Text('Next idea'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              child: const Text('Settings'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/practice'),
                  child: const Text('Practice'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/import'),
                  child: const Text('Import'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/stats'),
                  child: const Text('Stats'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
