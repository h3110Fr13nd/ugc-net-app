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
  final PageController _pageController = PageController();
  
  // Time tracking
  DateTime? _pageStartTime;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRandomQuestions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    // Record view for the previous question
    if (_pageStartTime != null && _currentQuestionIndex < _questions.length) {
       final duration = DateTime.now().difference(_pageStartTime!).inSeconds;
       final prevQuestion = _questions[_currentQuestionIndex];
       _recordView(prevQuestion, duration);
    }
    
    setState(() {
      _currentQuestionIndex = index;
      _pageStartTime = DateTime.now();
    });

    // Load more if near end
    if (index >= _questions.length - 3) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreQuestions();
      }
    }
  }

  Future<void> _recordView(CompositeQuestion question, int duration) async {
     // Don't record if duration is too short (e.g. < 1s) to avoid noise from fast scrolling
     if (duration < 1) return;
     try {
       await QuestionService().recordView(question.id, duration);
     } catch (e) {
       debugPrint('Error recording view: $e');
     }
  }

  Future<void> _loadRandomQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMore = true;
      _questions = [];
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
          if (_questions.isNotEmpty) {
            _pageStartTime = DateTime.now();
            _currentQuestionIndex = 0;
          }
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

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      onPageChanged: _onPageChanged,
      itemCount: _questions.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _questions.length) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final question = _questions[index];
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Taxonomy breadcrumbs
                if (question.metadata['taxonomy_paths'] != null)
                  _buildTaxonomyBreadcrumbs(question),
                
                const SizedBox(height: 16),

                // Question card
                CompositeQuestionCard(
                  question: question,
                  onAnswerSubmit: (selectedOptions) {
                    _submitAnswer(question, selectedOptions);
                  },
                ),
                
                // Show previous attempt info if available
                if (question.userAttempt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Attempted on ${DateTime.parse(question.userAttempt!['started_at']).toLocal().toString().split('.')[0]}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                if (question.userAttempt!['score'] != null)
                                  Text(
                                    'Score: ${(question.userAttempt!['score'] * 100).toStringAsFixed(0)}%',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                               // TODO: Implement full review by fetching grading details
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Detailed review coming soon!')),
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
    
    final List<String> taxonomyPaths = [];
    try {
      final jsonStr = taxonomyPathsRaw.toString();
      if (taxonomyPathsRaw is List) {
        for (var item in taxonomyPathsRaw) {
          taxonomyPaths.add(item.toString());
        }
      } else {
        final str = jsonStr.substring(1, jsonStr.length - 1);
        if (str.isNotEmpty) {
          taxonomyPaths.add(str);
        }
      }
    } catch (e) {
      debugPrint('DEBUG Failed to convert taxonomy paths: $e');
      return const SizedBox.shrink();
    }
    
    if (taxonomyPaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
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

      // Calculate duration
      int duration = 0;
      if (_pageStartTime != null) {
        duration = DateTime.now().difference(_pageStartTime!).inSeconds;
      }

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

      final attemptId = await AnswerSubmissionService.createAttempt(
        quizId: null,
        userId: userId,
      );
      
      if (!mounted) return;
      Navigator.pop(context);

      debugPrint('✓ Created standalone attempt: $attemptId for question: ${question.id}');

      final wsService = await AnswerSubmissionService.submitAnswer(
        attemptId: attemptId,
        questionId: question.id,
        userId: userId,
        answer: selectedOptions.isNotEmpty ? selectedOptions.first : '',
        durationSeconds: duration, // Pass duration
      );

      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => ExplanationSheet(
          wsService: wsService,
        ),
      );
      
      // Update local state to show attempt immediately?
      // Ideally we should reload the question or update the object.
      // For now, we rely on the user swiping back/forth or reloading.
      
    } catch (e) {
      if (mounted) {
        // Check if dialog is open
        if (Navigator.canPop(context)) {
             // This is risky if dialog wasn't open, but we are inside try block after showDialog
             // Better to just show snackbar
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

