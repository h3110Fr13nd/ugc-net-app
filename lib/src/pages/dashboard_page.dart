import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../widgets/widgets.dart';
import '../widgets/action_card.dart';
import '../widgets/stat_card.dart';
import 'practice_session_page.dart';
import 'attempt_history_page.dart';
import 'attempt_result_page.dart';
import '../services/quiz_attempt_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _quizAttemptService = QuizAttemptService();
  List<dynamic>? _recentAttempts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentActivity();
  }

  Future<void> _loadRecentActivity() async {
    try {
      final history = await _quizAttemptService.getAttemptHistory(limit: 3);
      if (mounted) {
        setState(() {
          _recentAttempts = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading recent activity: $e');
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown Date';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat.yMMMd().add_jm().format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<MyAppState>();

    return AppShell(
      title: 'Dashboard',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Stats',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StatCard(label: 'Total Attempts', value: '0'),
                        StatCard(label: 'Accuracy', value: '-'),
                        StatCard(label: 'Streak', value: '0'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ActionCard(
                  icon: Icons.play_arrow,
                  label: 'Practice All',
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PracticeSessionPage(
                        title: 'Global Practice',
                        taxonomyId: null,
                      ),
                    ),
                  ),
                ),
                ActionCard(
                  icon: Icons.category,
                  label: 'Browse Topics',
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/pages/topics'),
                ),
                ActionCard(
                  icon: Icons.edit,
                  label: 'Question Editor',
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, '/pages/question_editor'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/pages/history'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_recentAttempts == null || _recentAttempts!.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No recent activity. Start practicing to see your progress here!',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentAttempts!.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final attempt = _recentAttempts![index];
                  final status = attempt['status'] ?? 'unknown';
                  final score = attempt['score'];
                  final maxScore = attempt['max_score'];
                  final date = attempt['started_at'];

                  Color statusColor = Colors.grey;
                  if (status == 'completed') statusColor = Colors.green;
                  if (status == 'in_progress') statusColor = Colors.orange;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.1),
                        child: Icon(
                          status == 'completed' ? Icons.check : Icons.access_time,
                          color: statusColor,
                        ),
                      ),
                      title: Text(_formatDate(date)),
                      subtitle: Text(status.toUpperCase().replaceAll('_', ' ')),
                      trailing: score != null
                          ? Text(
                              '${double.parse(score.toString()).toStringAsFixed(1)} / ${double.parse(maxScore.toString()).toStringAsFixed(1)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttemptResultPage(attemptId: attempt['id']),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
