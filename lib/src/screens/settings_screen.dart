import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Settings placeholder'),
          ],
        ),
      ),
    );
  }
}
