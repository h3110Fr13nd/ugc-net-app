import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../ui/ui.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return AppShell(
      title: 'Stats',
      child: FutureBuilder(
        future: appState.fetchStats(), // accessing directly for mock; consider exposing via method
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          final total = data?['total'] ?? 0;
          final correct = data?['correct'] ?? 0;
          Map<String, dynamic> topicCorrect = {};
          final tc = data?['topicCorrect'];
          if (tc is Map<String, dynamic>) topicCorrect = tc;

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
