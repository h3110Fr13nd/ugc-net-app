import 'package:flutter/material.dart';
import '../models/composite_question.dart';
import '../widgets/composite_question_card.dart';
import '../services/composite_question_service.dart';
import '../services/api_client.dart';
import 'question_editor_page.dart';

/// Demo page to show composite questions functionality
class CompositeQuestionsDemo extends StatefulWidget {
  const CompositeQuestionsDemo({super.key});

  @override
  State<CompositeQuestionsDemo> createState() => _CompositeQuestionsDemoState();
}

class _CompositeQuestionsDemoState extends State<CompositeQuestionsDemo> {
  final _service = CompositeQuestionService(ApiClient());
  List<CompositeQuestion> _questions = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final questions = await _service.listQuestions();
      setState(() {
        _questions = questions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _createSampleQuestion() async {
    try {
      await _service.createSimpleTextQuestion(
        questionText: 'What is the capital of France?',
        optionTexts: ['Paris', 'London', 'Berlin', 'Madrid'],
        correctOptionIndex: 0,
        title: 'Geography Sample',
        difficulty: 2,
      );
      _loadQuestions(); // Reload list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample question created!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Composite Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuestions,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const QuestionEditorPage(),
                ),
              ).then((_) => _loadQuestions());
            },
            tooltip: 'Create Question',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createSampleQuestion,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Create Sample'),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadQuestions,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No questions yet', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Create a sample question to get started'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _createSampleQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Create Sample Question'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final question = _questions[index];
        return CompositeQuestionCard(
          question: question,
          onAnswerSubmit: (selectedIds) {
            // Find correct answer(s)
            final correctIds = question.options
                .where((o) => o.isCorrect)
                .map((o) => o.id)
                .toSet();
            final isCorrect = selectedIds.toSet().containsAll(correctIds) &&
                correctIds.containsAll(selectedIds);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isCorrect ? '✓ Correct!' : '✗ Incorrect'),
                backgroundColor: isCorrect ? Colors.green : Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }
}
