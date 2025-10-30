import 'package:flutter/material.dart';
import 'page_template.dart';

class QuestionPartEditorPage extends StatelessWidget {
  const QuestionPartEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Question Part Editor',
      subtitle: 'Edit a single question part (text / media / code)',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Part editor placeholder'),
                SizedBox(height: 8),
                Text('Support for text, code block, or media attachments will go here.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
