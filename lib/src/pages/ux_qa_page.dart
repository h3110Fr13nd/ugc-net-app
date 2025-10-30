import 'package:flutter/material.dart';
import 'page_template.dart';
import '../ui/ui.dart';

class UxQaChecklistPage extends StatelessWidget {
  const UxQaChecklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      'Responsiveness',
      'Accessibility',
      'Form validation',
      'Keyboard navigation',
    ];
    return PageTemplate(
      title: 'UX & QA Checklist',
      subtitle: 'Acceptance criteria and QA tests',
      children: [
        ...items.map((t) => CheckboxListTile(value: false, onChanged: (_) {}, title: Text(t))),
        const SizedBox(height: 8),
        PrimaryButton(onPressed: () {}, child: const Text('Run checks')),
      ],
    );
  }
}
