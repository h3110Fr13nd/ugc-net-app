import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/composite_question.dart';
import '../services/question_service.dart';
import '../widgets/composite_question_card.dart';

class RandomQuestionsPage extends StatefulWidget {
  const RandomQuestionsPage({super.key});

  @override
  State<RandomQuestionsPage> createState() => _RandomQuestionsPageState();
}

class _RandomQuestionsPageState extends State<RandomQuestionsPage> {
  List<CompositeQuestion> _questions = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRandomQuestions();
  }

  Future<void> _loadRandomQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final questionService = QuestionService();
      // Load questions without any taxonomy filter to get random questions
      // The API will return questions in database order, which is effectively random
      final questions = await questionService.listQuestions(
        limit: 20, // Load 20 random questions
      );

      if (mounted) {
        setState(() {
          _questions = questions;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadRandomQuestions,
            tooltip: 'Load new questions',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRandomQuestions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Center(
        child: Text('No questions available'),
      );
    }

    return ListView.builder(
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final question = _questions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Taxonomy breadcrumbs
              if (question.metadata['taxonomy_paths'] != null)
                _buildTaxonomyBreadcrumbs(question),
              
              // Question card
              CompositeQuestionCard(
                question: question,
                onAnswerSubmit: (selectedOptions) {
                  // Handle answer submission
                  final appState = context.read<MyAppState>();
                  appState.submitCurrentAttempt(selectedOptions);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaxonomyBreadcrumbs(CompositeQuestion question) {
    final taxonomyPaths = question.metadata['taxonomy_paths'];
    if (taxonomyPaths == null || taxonomyPaths is! List || taxonomyPaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Topics',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...taxonomyPaths.take(2).map((path) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• ${path.toString().replaceAll(' > ', ' › ')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )),
          if (taxonomyPaths.length > 2)
            Text(
              '+${taxonomyPaths.length - 2} more',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
