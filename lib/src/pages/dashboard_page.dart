import 'package:flutter/material.dart';
import 'page_template.dart';
import '../ui/ui.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Dashboard',
      subtitle: 'Overview: progress, recent activity, quick actions',
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            4,
            (i) => SizedBox(
              width: 260,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Card ${i + 1}', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      const Text('Summary metrics and quick actions go here'),
                      const SizedBox(height: 8),
                      PrimaryButton(onPressed: () {}, child: const Text('Open')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
