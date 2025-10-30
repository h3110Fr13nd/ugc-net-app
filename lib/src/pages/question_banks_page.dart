import 'package:flutter/material.dart';
import 'page_template.dart';
import '../ui/ui.dart';

class QuestionBanksPage extends StatelessWidget {
  const QuestionBanksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Question Banks',
      subtitle: 'Search and import reusable questions',
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, idx) => Card(
            child: ListTile(
              title: Text('Bank ${idx + 1}'),
              subtitle: const Text('Contains curated questions for topics'),
              trailing: PrimaryButton(onPressed: () {}, child: const Text('Import')),
            ),
          ),
        ),
      ],
    );
  }
}
