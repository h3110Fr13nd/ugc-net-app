import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/composite_question.dart';
import '../models/app_state.dart';
import '../services/question_service.dart';
import '../services/answer_submission_service.dart';
import '../widgets/composite_question_card.dart';
import '../widgets/explanation_sheet.dart';

class PracticeSessionPage extends StatefulWidget {
  final String? taxonomyId;
  final String title;
  final String? filterStatus; // 'unattempted' or null for all

  const PracticeSessionPage({
    super.key,
    this.taxonomyId,
    required this.title,
    this.filterStatus,
  });

  @override
  State<PracticeSessionPage> createState() => _PracticeSessionPageState();
}

class _PracticeSessionPageState extends State<PracticeSessionPage> {
  final _questionService = QuestionService();
  final _pageController = PageController();
  
  List<CompositeQuestion> _questions = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _currentPage = 1;
  int _currentQuestionIndex = 0;
  DateTime? _pageStartTime;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _pageStartTime = DateTime.now();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _loadingMore = true);
    } else {
      setState(() => _loading = true);
    }

    try {
      final newQuestions = await _questionService.listQuestions(
        page: _currentPage,
        pageSize: 10,
        taxonomyId: widget.taxonomyId,
        status: widget.filterStatus,
        includeUserAttempt: true,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _questions.addAll(newQuestions);
          } else {
            _questions = newQuestions;
          }
          _loading = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading questions: $e')),
        );
      }
    }
  }

  void _onPageChanged(int index) {
    // Record time for previous page
    if (_pageStartTime != null && index > _currentQuestionIndex) {
      final duration = DateTime.now().difference(_pageStartTime!).inSeconds;
      if (_currentQuestionIndex < _questions.length) {
        _recordView(_questions[_currentQuestionIndex], duration);
      }
    }
    
    setState(() {
      _currentQuestionIndex = index;
      _pageStartTime = DateTime.now();
    });

    // Load more if near end
    if (index >= _questions.length - 2 && !_loadingMore) {
      _currentPage++;
      _loadQuestions(loadMore: true);
    }
  }

  Future<void> _recordView(CompositeQuestion question, int durationSeconds) async {
    if (durationSeconds < 1) return;
    try {
      await _questionService.recordView(question.id, durationSeconds);
    } catch (e) {
      print('Failed to record view: $e');
    }
  }

  Future<void> _submitAnswer(CompositeQuestion question, List<String> selectedOptionIds) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final duration = DateTime.now().difference(_pageStartTime ?? DateTime.now()).inSeconds;
    final appState = Provider.of<MyAppState>(context, listen: false);
    final userId = appState.user?['id'] as String?;

    if (userId == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }
    
    try {
      // Create standalone attempt
      final attemptId = await AnswerSubmissionService.createAttempt(
        quizId: null,
        userId: userId,
      );

      final wsService = await AnswerSubmissionService.submitAnswer(
        attemptId: attemptId,
        questionId: question.id,
        userId: userId,
        answer: selectedOptionIds,
        durationSeconds: duration,
      );

      // Reset timer for next interaction on same question (if any)
      _pageStartTime = DateTime.now();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show explanation sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => ExplanationSheet(wsService: wsService),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting answer: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No questions found.'),
                      if (widget.filterStatus == 'unattempted')
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Go back'),
                          ),
                        ),
                    ],
                  ),
                )
              : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: _onPageChanged,
                  itemCount: _questions.length + (_loadingMore ? 1 : 0),
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
                            CompositeQuestionCard(
                              question: question,
                              isInteractive: true,
                              onAnswerSubmit: (selectedIds) => _submitAnswer(question, selectedIds),
                            ),
                            
                            // Previous Attempt Banner
                            if (question.userAttempt != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.history, color: Colors.amber),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Previously attempted on ${_formatDate(DateTime.parse(question.userAttempt!['started_at']))}',
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                            if (question.userAttempt!['score'] != null)
                                              Text(
                                                'Score: ${(question.userAttempt!['score'] * 100).toStringAsFixed(0)}%',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
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
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}
