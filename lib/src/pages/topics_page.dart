import 'package:flutter/material.dart';
import 'page_template.dart';
import '../ui/ui.dart';

class TopicsPage extends StatelessWidget {
  const TopicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Topics / Subjects / Chapters',
      subtitle: 'Taxonomy and topic management',
      children: [
        Wrap(
          spacing: 8,
          children: List.generate(6, (i) => Chip(label: Text('Topic ${i + 1}'))),
        ),
        const SizedBox(height: 12),
        PrimaryButton(onPressed: () {}, child: const Text('Add topic')),
      ],
    );
  }
}
