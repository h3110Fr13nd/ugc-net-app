import 'package:flutter/material.dart';
import 'page_template.dart';
import '../ui/ui.dart';

class QuizEditorPage extends StatelessWidget {
  const QuizEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Quiz Editor',
      subtitle: 'Compose and version quizzes',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Title input placeholder'),
                const SizedBox(height: 8),
                TextField(decoration: const InputDecoration(labelText: 'Quiz title')),
                const SizedBox(height: 8),
                TextField(decoration: const InputDecoration(labelText: 'Short description')),
                const SizedBox(height: 12),
                PrimaryButton(onPressed: () {}, child: const Text('Save draft')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
