import 'package:flutter/material.dart';
import '../services/quiz_attempt_service.dart';
import '../models/composite_question.dart';
import '../widgets/composite_question_card.dart';
import 'page_template.dart';

class AttemptResultPage extends StatefulWidget {
  final String attemptId;

  const AttemptResultPage({super.key, required this.attemptId});

  @override
  State<AttemptResultPage> createState() => _AttemptResultPageState();
}

class _AttemptResultPageState extends State<AttemptResultPage> {
  final _quizAttemptService = QuizAttemptService();
  Map<String, dynamic>? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    try {
      final result = await _quizAttemptService.getAttemptResults(widget.attemptId);
      if (mounted) {
        setState(() {
          _result = result;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    if (_result == null) {
      return const Scaffold(body: Center(child: Text('No result found')));
    }

    final score = _result!['score'];
    final maxScore = _result!['max_score'];
    final questions = _result!['questions'] as List<dynamic>;

    final scoreVal = double.tryParse(score?.toString() ?? '0') ?? 0.0;
    final maxScoreVal = double.tryParse(maxScore?.toString() ?? '0') ?? 0.0;

    return PageTemplate(
      title: 'Attempt Result',
      subtitle: 'Score: ${scoreVal.toStringAsFixed(1)} / ${maxScoreVal.toStringAsFixed(1)}',
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: questions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            final qData = questions[index];
            
            // Map to CompositeQuestion
            // Note: The backend returns a flattened structure for questions in the result.
            // We need to reconstruct it to match CompositeQuestion.fromJson expectations
            // or manually map it.
            
            final question = CompositeQuestion(
              id: qData['question_id'] ?? '',
              title: qData['question_title'],
              description: qData['question_description'],
              explanation: qData['question_explanation'],
              // Map answer type from backend response
              answerType: _mapAnswerType(qData['question_answer_type']), 
              parts: (qData['question_parts'] as List<dynamic>?)
                  ?.map((e) => QuestionPart.fromJson(e as Map<String, dynamic>))
                  .toList() ?? [],
              options: (qData['options'] as List<dynamic>?)
                  ?.map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
                  .toList() ?? [],
              createdAt: DateTime.now(), // Not critical for display
              updatedAt: DateTime.now(),
            );

            // Construct user attempt map for the card
            final userAttempt = {
              'parts': qData['parts'],
              'score': qData['score'],
              'max_score': qData['max_score'],
            };

            return CompositeQuestionCard(
              question: question,
              isInteractive: false,
              isReviewMode: true,
              userAttempt: userAttempt,
            );
          },
        ),
      ],
    );
  }

  AnswerType _mapAnswerType(String? type) {
    if (type == null) return AnswerType.options;
    switch (type.toLowerCase()) {
      case 'text':
        return AnswerType.text;
      case 'numeric':
      case 'integer':
        return AnswerType.numeric; // Assuming numeric covers integer for now
      case 'options':
      default:
        return AnswerType.options;
    }
  }
}

