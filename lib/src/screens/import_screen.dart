import 'package:flutter/material.dart';

import '../ui/ui.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Import',
      child: Column(
        children: [
          const Text('Import questions via CSV will be supported in backend-enabled mode.'),
          const SizedBox(height: 12),
          PrimaryButton(
            onPressed: () {},
            child: const Text('Select CSV (mock)'),
          )
        ],
      ),
    );
  }
}
