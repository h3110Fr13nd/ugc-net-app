import 'package:flutter/material.dart';
import 'page_template.dart';

class SettingsTenantPage extends StatelessWidget {
  const SettingsTenantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Settings & Tenant',
      subtitle: 'App settings, OAuth providers and tenant management',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme'),
                const SizedBox(height: 8),
                Row(children: [ElevatedButton(onPressed: () {}, child: const Text('Toggle theme'))]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
