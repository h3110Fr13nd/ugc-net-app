import 'package:flutter/material.dart';
import 'page_template.dart';
import '../ui/ui.dart';

class VersioningHistoryPage extends StatelessWidget {
  const VersioningHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Versioning & History',
      subtitle: 'Snapshots and restore actions',
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, idx) => Card(
            child: ListTile(
              title: Text('Snapshot ${idx + 1}'),
              subtitle: const Text('Created by user · metadata'),
              trailing: PrimaryButton(onPressed: () {}, child: const Text('Restore')),
            ),
          ),
        ),
      ],
    );
  }
}
