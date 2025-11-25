import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'page_template.dart';
import '../ui/ui.dart';
import '../models/app_state.dart';
import '../services/answer_submission_service.dart';
import '../services/websocket_service.dart';
import 'dart:async';

class QuizAttemptPage extends StatefulWidget {
  final String quizId;
  final String quizTitle;

  const QuizAttemptPage({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<QuizAttemptPage> createState() => _QuizAttemptPageState();
}

class _QuizAttemptPageState extends State<QuizAttemptPage> {
  String? attemptId;
  bool isCreatingAttempt = false;
  String? error;
  String? currentQuestionId;
  String userAnswer = '';
  bool isSubmittingAnswer = false;
  double? score;
  List<Map<String, dynamic>> explanationBlocks = [];
  bool explanationComplete = false;
  WebSocketService? currentWsService;
  StreamSubscription? wsSubscription;

  @override
  void initState() {
    super.initState();
    _createAttempt();
  }

  Future<void> _createAttempt() async {
    setState(() => isCreatingAttempt = true);
    
    try {
      final appState = context.read<MyAppState>();
      final userId = appState.user?['id'] as String?;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      attemptId = await AnswerSubmissionService.createAttempt(
        quizId: widget.quizId,
        userId: userId,
      );
      
      setState(() => isCreatingAttempt = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quiz started! Attempt: $attemptId')),
        );
      }
    } catch (e) {
      setState(() {
        error = 'Failed to start quiz: $e';
        isCreatingAttempt = false;
      });
      debugPrint('Error creating attempt: $e');
    }
  }

  Future<void> _submitAnswer() async {
    if (attemptId == null || currentQuestionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz not initialized')),
      );
      return;
    }

    if (userAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an answer')),
      );
      return;
    }

    setState(() {
      isSubmittingAnswer = true;
      explanationBlocks = [];
      explanationComplete = false;
      score = null;
    });

    try {
      final appState = context.read<MyAppState>();
      final userId = appState.user?['id'] as String?;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Submit answer and get WebSocket service
      currentWsService = await AnswerSubmissionService.submitAnswer(
        attemptId: attemptId!,
        questionId: currentQuestionId!,
        userId: userId,
        answer: userAnswer,
      );

      // Listen to WebSocket messages
      wsSubscription = currentWsService!.messages.listen(
        (message) {
          _handleWebSocketMessage(message);
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          setState(() {
            this.error = 'Error: $error';
            isSubmittingAnswer = false;
          });
        },
        onDone: () {
          debugPrint('WebSocket closed');
          setState(() => isSubmittingAnswer = false);
        },
      );
    } catch (e) {
      debugPrint('Error submitting answer: $e');
      setState(() {
        error = 'Failed to submit answer: $e';
        isSubmittingAnswer = false;
      });
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    debugPrint('Received WS message: ${message['type']}');
    
    setState(() {
      switch (message['type']) {
        case 'explanation_start':
          debugPrint('Explanation streaming started');
          break;
          
        case 'explanation_block':
          final block = message['block'] as Map<String, dynamic>;
          explanationBlocks.add(block);
          debugPrint('Added explanation block: ${block['content']?.substring(0, 50)}...');
          break;
          
        case 'explanation_end':
          debugPrint('Explanation complete');
          explanationComplete = true;
          break;
          
        case 'result':
          score = (message['score'] as num?)?.toDouble();
          debugPrint('✓ Answer saved with score: $score');
          break;
          
        case 'error':
          error = message['error'] as String?;
          debugPrint('✗ Error: $error');
          break;
      }
    });
  }

  void _loadNextQuestion() {
    // TODO: Load next question from quiz
    setState(() {
      userAnswer = '';
      currentQuestionId = null;
      explanationBlocks = [];
      explanationComplete = false;
      score = null;
      error = null;
    });
  }

  @override
  void dispose() {
    wsSubscription?.cancel();
    currentWsService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Quiz: ${widget.quizTitle}',
      subtitle: 'Answer questions and get instant AI feedback',
      children: [
        if (error != null)
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(error!),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    onPressed: _createAttempt,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (isCreatingAttempt)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    'Starting quiz...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else if (attemptId == null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Quiz not initialized', style: Theme.of(context).textTheme.bodyMedium),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quiz info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Attempt ID: $attemptId',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text('Status: In Progress',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Question card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Question 1', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      const Text('What is the capital of France?'),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Your answer',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => userAnswer = value,
                        enabled: !isSubmittingAnswer,
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        onPressed: isSubmittingAnswer ? null : _submitAnswer,
                        child: Text(isSubmittingAnswer ? 'Submitting...' : 'Submit Answer'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Explanation display
              if (explanationBlocks.isNotEmpty || isSubmittingAnswer)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Explanation', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        if (isSubmittingAnswer && explanationBlocks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: LinearProgressIndicator(),
                          )
                        else
                          ...explanationBlocks.map((block) {
                            final content = block['content'] as String? ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(content),
                            );
                          }),
                        if (score != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Score: ${(score! * 100).toStringAsFixed(0)}%',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: score! >= 0.8 ? Colors.green : Colors.orange,
                                  ),
                                ),
                                if (!isSubmittingAnswer && explanationComplete)
                                  PrimaryButton(
                                    onPressed: _loadNextQuestion,
                                    child: const Text('Next Question'),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
