import 'package:flutter/material.dart';
import 'page_template.dart';
import '../widgets/widgets.dart';

class QuizDetailPage extends StatelessWidget {
  const QuizDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Quiz Detail',
      subtitle: 'Quiz metadata, preview and start',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('Long description and settings for the quiz.'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    PrimaryButton(onPressed: () {}, child: const Text('Start')),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: () {}, child: const Text('Edit')),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
