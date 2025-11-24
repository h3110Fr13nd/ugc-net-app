import 'package:flutter/material.dart';
import '../models/taxonomy_node.dart';
import '../models/composite_question.dart';

import '../services/question_service.dart';
import '../services/answer_submission_service.dart';
import '../widgets/composite_question_card.dart';
import '../widgets/explanation_sheet.dart';

class TaxonomyNodePage extends StatefulWidget {
  final TaxonomyNode node;

  const TaxonomyNodePage({super.key, required this.node});

  @override
  State<TaxonomyNodePage> createState() => _TaxonomyNodePageState();
}

class _TaxonomyNodePageState extends State<TaxonomyNodePage> {
  final _questionService = QuestionService();
  
  List<TaxonomyNode> _children = [];
  List<CompositeQuestion> _questions = [];
  bool _loading = true;
  String? _error;
  
  // Pagination state
  final ScrollController _scrollController = ScrollController();
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreQuestions();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Use children from the node itself as they should be populated
      final children = widget.node.children;
      
      // Load initial questions (page 1)
      // Clear cache first to ensure fresh data on enter
      _questionService.clearTaxonomyCache(widget.node.id);
      final questions = await _questionService.loadNextPageForTaxonomy(widget.node.id);

      if (mounted) {
        setState(() {
          _children = children;
          _questions = questions;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }
  
  Future<void> _loadMoreQuestions() async {
    if (_loadingMore || !_questionService.hasMoreCachedForTaxonomy(widget.node.id)) return;
    
    setState(() {
      _loadingMore = true;
    });
    
    try {
      final newQuestions = await _questionService.loadNextPageForTaxonomy(widget.node.id);
      if (mounted) {
        setState(() {
          _questions.addAll(newQuestions);
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Just stop loading more on error, maybe show snackbar
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _submitAnswer(CompositeQuestion question, List<String> selectedOptions) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Use placeholder attempt ID for practice mode
    const attemptId = "00000000-0000-0000-0000-000000000000"; 

    try {
      // Submit answer via WebSocket
      final wsService = await AnswerSubmissionService.submitAnswer(
        attemptId: attemptId,
        questionId: question.id,
        answer: selectedOptions,
      );
      
      if (mounted) {
        Navigator.pop(context); // Close loading

        // Show explanation sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => ExplanationSheet(wsService: wsService),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.node.name),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Container(
                        constraints: const BoxConstraints(minHeight: 240),
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.red.shade100,
                        child: Center(
                          child: Text(
                            'Error: $_error',
                            style: TextStyle(color: Colors.red.shade900),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    
                    if (_children.isNotEmpty) ...[
                      Text(
                        'Sub-topics',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _children.map((child) => ActionChip(
                          label: Text(child.name),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaxonomyNodePage(node: child),
                              ),
                            );
                          },
                        )).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    Text(
                      'Questions (${_questions.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    
                    if (_questions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(child: Text('No questions found for this topic.')),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _questions.length + (_loadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _questions.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final q = _questions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: CompositeQuestionCard(
                              question: q,
                              isInteractive: true,
                              onAnswerSubmit: (selectedIds) => _submitAnswer(q, selectedIds),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
