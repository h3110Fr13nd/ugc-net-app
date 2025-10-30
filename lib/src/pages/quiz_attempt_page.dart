import 'package:flutter/material.dart';
import 'page_template.dart';
import '../ui/ui.dart';

class QuizAttemptPage extends StatelessWidget {
  const QuizAttemptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Quiz Attempt',
      subtitle: 'Student-taking interface with autosave',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Question 1', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('Question content placeholder'),
                const SizedBox(height: 12),
                PrimaryButton(onPressed: () {}, child: const Text('Save answer')),
              ],
            ),
          ),
        )
      ],
    );
  }
}
