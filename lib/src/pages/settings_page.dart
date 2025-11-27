import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: 'Settings', subtitle: 'Application preferences'),
          const SizedBox(height: 12),
          ThemeToggle(),
          const SizedBox(height: 8),
          const Text('Other settings will appear here'),
        ],
      ),
    );
  }
}
