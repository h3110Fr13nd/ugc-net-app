import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../widgets/app_scaffold.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return AppScaffold(
      title: 'Stats',
      child: FutureBuilder(
        future: appState.fetchStats(), // accessing directly for mock; consider exposing via method
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data as Map<String, dynamic>? ?? {};
          final total = data['total'] ?? 0;
          final correct = data['correct'] ?? 0;
          final topicCorrect = data['topicCorrect'] as Map<String, dynamic>? ?? {};

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total attempts: $total'),
              Text('Correct: $correct'),
              const SizedBox(height: 12),
              Text('Topic performance:'),
              ...topicCorrect.keys.map((k) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Text('$k: ${topicCorrect[k]} correct'),
                  ))
            ],
          );
        },
      ),
    );
  }
}
