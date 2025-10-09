import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../widgets/question_card.dart';
import '../widgets/app_scaffold.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return AppScaffold(
      title: 'Practice',
      child: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (appState.currentQuestion != null)
                  Expanded(
                    child: QuestionCard(question: appState.currentQuestion!),
                  )
                else
                  Expanded(child: Center(child: Text('No questions loaded'))),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => appState.loadQuestions(limit: 10),
                      child: const Text('Load 10 Questions'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/stats'),
                      child: const Text('View Stats'),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
