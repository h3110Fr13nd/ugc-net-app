import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../models/app_state.dart';
import 'option_tile.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  const QuestionCard({super.key, required this.question});

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  String? _selected;
  bool _submitted = false;
  String? _feedback;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<MyAppState>();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.question.topic, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Text(widget.question.text, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...widget.question.options.map((o) => OptionTile(
                  text: o,
                  selected: _selected,
                  onTap: _submitted
                      ? null
                      : () {
                          setState(() => _selected = o);
                        },
                )),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: (_selected == null || _submitted)
                      ? null
                      : () async {
                          setState(() => _submitted = true);
                          final res = await appState.submitCurrentAttempt(_selected!);
                          setState(() => _feedback = res['explanation'] as String?);
                        },
                  child: const Text('Submit'),
                )
              ],
            ),
            if (_feedback != null) ...[
              const SizedBox(height: 12),
              Text(_feedback!, style: Theme.of(context).textTheme.bodyMedium),
            ]
          ],
        ),
      ),
    );
  }
}
