import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Import',
      child: Column(
        children: [
          Text('Import questions via CSV will be supported in backend-enabled mode.'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Select CSV (mock)'),
          )
        ],
      ),
    );
  }
}
