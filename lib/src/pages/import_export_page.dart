import 'package:flutter/material.dart';
import 'page_template.dart';

class ImportExportPage extends StatelessWidget {
  const ImportExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Import & Export',
      subtitle: 'Wizards for importing and exporting quizzes/questions/media',
      children: [
        Row(
          children: [
            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.upload_file), label: const Text('Import')),
            const SizedBox(width: 12),
            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('Export')),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Support CSV, JSON and presigned-media flows.'),
      ],
    );
  }
}
