import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../widgets/question_card.dart';
import '../ui/ui.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return AppShell(
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
                  const Expanded(child: Center(child: Text('No questions loaded'))),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PrimaryButton(
                      onPressed: () => appState.loadQuestions(limit: 10),
                      child: const Text('Load 10 Questions'),
                    ),
                    PrimaryButton(
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
