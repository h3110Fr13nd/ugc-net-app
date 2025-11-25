import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/composite_question.dart';
import '../services/question_service.dart';
import '../services/answer_submission_service.dart';
import '../widgets/explanation_sheet.dart';
import '../widgets/composite_question_card.dart';

class RandomQuestionsPage extends StatefulWidget {
  const RandomQuestionsPage({super.key});

  @override
  State<RandomQuestionsPage> createState() => _RandomQuestionsPageState();
}

class _RandomQuestionsPageState extends State<RandomQuestionsPage> {
  List<CompositeQuestion> _questions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  bool _unattemptedOnly = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadRandomQuestions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreQuestions();
      }
    }
  }

  Future<void> _loadRandomQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final questionService = QuestionService();
      final questions = await questionService.listQuestions(
        page: _currentPage, 
        pageSize: _pageSize,
        status: _unattemptedOnly ? 'unattempted' : null,
        randomize: true,
        includeUserAttempt: true,
      );

      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
          _hasMore = questions.length >= _pageSize;
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

  Future<void> _loadMoreQuestions() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final questionService = QuestionService();
      final newQuestions = await questionService.listQuestions(
        page: _currentPage + 1,
        pageSize: _pageSize,
        status: _unattemptedOnly ? 'unattempted' : null,
        randomize: true,
        includeUserAttempt: true,
      );

      if (mounted) {
        setState(() {
          _questions.addAll(newQuestions);
          _currentPage++;
          _isLoadingMore = false;
          _hasMore = newQuestions.length >= _pageSize;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
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
            icon: Icon(_unattemptedOnly ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () {
              setState(() {
                _unattemptedOnly = !_unattemptedOnly;
              });
              _loadRandomQuestions();
            },
            tooltip: _unattemptedOnly ? 'Show all questions' : 'Show unattempted only',
          ),
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
      controller: _scrollController,
      itemCount: _questions.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _questions.length) {
          // Loading indicator at the bottom
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
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
                // If user has attempted, we might want to show it as disabled or pre-filled
                // But CompositeQuestionCard might not support that yet.
                // For now, we rely on the card's internal state if it was just answered,
                // but for reloaded questions, we need to pass the attempt.
                // TODO: Update CompositeQuestionCard to accept initial attempt state.
                // For now, we just handle new submissions.
                onAnswerSubmit: (selectedOptions) {
                  _submitAnswer(question, selectedOptions);
                },
              ),
              
              // Show previous attempt info if available
              if (question.userAttempt != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You attempted this on ${DateTime.parse(question.userAttempt!['started_at']).toLocal().toString().split('.')[0]}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                             // Show explanation
                             // We need to construct a dummy wsService or similar to show ExplanationSheet
                             // Or better, fetch the full attempt result.
                             // For now, just show a simple dialog or re-open explanation if possible.
                             // Since we don't have the full grading details in the list response (only basic attempt info),
                             // we might need to fetch it.
                             // But let's try to show what we have.
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('Review feature coming soon!')),
                             );
                          },
                          child: const Text('Review'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaxonomyBreadcrumbs(CompositeQuestion question) {
    final taxonomyPathsRaw = question.metadata['taxonomy_paths'];
    if (taxonomyPathsRaw == null) {
      return const SizedBox.shrink();
    }
    
    // Convert to List<String> - handle ListJsonObject by converting via JSON
    final List<String> taxonomyPaths = [];
    try {
      // Convert to JSON and back to get a proper List
      final jsonStr = taxonomyPathsRaw.toString();
      // If it's already a string representation like "[item1, item2]", parse it
      // Otherwise, just treat each element
      if (taxonomyPathsRaw is List) {
        for (var item in taxonomyPathsRaw) {
          taxonomyPaths.add(item.toString());
        }
      } else {
        // For ListJsonObject, convert to string and extract items
        // The toString() should give us something like "[item1, item2]"
        final str = jsonStr.substring(1, jsonStr.length - 1); // Remove [ and ]
        if (str.isNotEmpty) {
          taxonomyPaths.add(str); // For now, just add the whole string as one path
        }
      }
    } catch (e) {
      print('DEBUG Failed to convert taxonomy paths: $e');
      return const SizedBox.shrink();
    }
    
    if (taxonomyPaths.isEmpty) {
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

  Future<void> _submitAnswer(CompositeQuestion question, List<String> selectedOptions) async {
    try {
      final appState = context.read<MyAppState>();
      final userId = appState.user?['id'];
      
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated. Please log in.')),
        );
        return;
      }

      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Creating attempt...'),
              ],
            ),
          ),
        ),
      );

      // Create a standalone attempt (no quiz_id)
      final attemptId = await AnswerSubmissionService.createAttempt(
        quizId: null,  // Standalone attempt for random questions
        userId: userId,
      );
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      debugPrint('✓ Created standalone attempt: $attemptId for question: ${question.id}');

      // Now submit the answer via WebSocket
      final wsService = await AnswerSubmissionService.submitAnswer(
        attemptId: attemptId,
        questionId: question.id,
        userId: userId,
        answer: selectedOptions.isNotEmpty ? selectedOptions.first : '',
      );

      // Show explanation sheet
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => ExplanationSheet(
          wsService: wsService,
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

