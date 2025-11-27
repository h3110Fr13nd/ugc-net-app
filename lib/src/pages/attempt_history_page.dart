import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/quiz_attempt_service.dart';
import 'attempt_result_page.dart';
import 'page_template.dart';

class AttemptHistoryPage extends StatefulWidget {
  const AttemptHistoryPage({super.key});

  @override
  State<AttemptHistoryPage> createState() => _AttemptHistoryPageState();
}

class _AttemptHistoryPageState extends State<AttemptHistoryPage> {
  final _quizAttemptService = QuizAttemptService();
  List<dynamic>? _attempts;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _quizAttemptService.getAttemptHistory();
      if (mounted) {
        setState(() {
          _attempts = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
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

  String _formatDuration(int? seconds) {
    if (seconds == null) return '-';
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${minutes}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Attempt History',
      subtitle: 'Review your past practice sessions',
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
        else if (_attempts == null || _attempts!.isEmpty)
          const Center(child: Text('No attempts found.'))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attempts!.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final attempt = _attempts![index];
              final status = attempt['status'] ?? 'unknown';
              final score = attempt['score'];
              final maxScore = attempt['max_score'];
              final date = attempt['started_at'];
              final duration = attempt['duration_seconds'];

              Color statusColor = Colors.grey;
              if (status == 'completed') statusColor = Colors.green;
              if (status == 'in_progress') statusColor = Colors.orange;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(
                    status == 'completed' ? Icons.check : Icons.access_time,
                    color: statusColor,
                  ),
                ),
                title: Text(_formatDate(date)),
                subtitle: Text(
                  '${status.toUpperCase().replaceAll('_', ' ')} • ${_formatDuration(duration)}',
                ),
                trailing: score != null
                    ? Text(
                        '${double.parse(score.toString()).toStringAsFixed(1)} / ${double.parse(maxScore.toString()).toStringAsFixed(1)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              );
            },
          ),
      ],
    );
  }
}
