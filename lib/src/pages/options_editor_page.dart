import 'package:flutter/material.dart';
import 'page_template.dart';
import '../ui/ui.dart';

class OptionsEditorPage extends StatelessWidget {
  const OptionsEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Options Editor',
      subtitle: 'Manage MCQ options and partial scoring',
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          itemBuilder: (context, idx) => Card(
            child: ListTile(
              leading: Checkbox(value: false, onChanged: (_) {}),
              title: Text('Option ${idx + 1}'),
              subtitle: const Text('Option details / partial score'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        PrimaryButton(onPressed: () {}, child: const Text('Add option')),
      ],
    );
  }
}
