import 'package:flutter/material.dart';
import 'page_template.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Analytics & Reports',
      subtitle: 'Dashboards and exports for instructors/admins',
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            3,
            (i) => SizedBox(
              width: 300,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text('Panel ${i + 1}', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      const SizedBox(height: 120, child: Placeholder()),
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
