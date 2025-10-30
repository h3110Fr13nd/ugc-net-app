import 'package:flutter/material.dart';
import 'page_template.dart';

class AttemptReviewPage extends StatelessWidget {
  const AttemptReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Attempt Review',
      subtitle: 'Graded results and per-question feedback',
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, idx) => Card(
            child: ListTile(
              title: Text('Question ${idx + 1}'),
              subtitle: const Text('Feedback and grading'),
            ),
          ),
        ),
      ],
    );
  }
}
