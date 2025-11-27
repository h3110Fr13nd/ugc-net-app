import 'package:flutter/material.dart';
import '../models/composite_question.dart';
import 'package:intl/intl.dart';
import '../services/question_service.dart';
import '../pages/attempt_result_page.dart';
import 'part_renderer.dart';

/// Widget to display a composite question with all its parts and options
class CompositeQuestionCard extends StatefulWidget {
  final CompositeQuestion question;
  final Function(List<String> selectedOptionIds)? onAnswerSubmit;
  final bool isInteractive;
  final Map<String, dynamic>? userAttempt; // For review mode
  final bool isReviewMode;

  const CompositeQuestionCard({
    super.key,
    required this.question,
    this.onAnswerSubmit,
    this.isInteractive = true,
    this.userAttempt,
    this.isReviewMode = false,
  });

  @override
  State<CompositeQuestionCard> createState() => _CompositeQuestionCardState();
}

class _CompositeQuestionCardState extends State<CompositeQuestionCard> {
  final Set<String> _selectedOptions = {};
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    if (widget.isReviewMode && widget.userAttempt != null) {
      _submitted = true;
      // Populate selected options from attempt
      final parts = widget.userAttempt!['parts'] as List<dynamic>?;
      if (parts != null) {
        for (var p in parts) {
          final selectedIds = p['selected_option_ids'] as List<dynamic>?;
          if (selectedIds != null) {
            for (var id in selectedIds) {
              _selectedOptions.add(id.toString());
            }
          }
        }
      }
    }
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _QuestionHistorySheet(questionId: widget.question.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate score for review mode
    double? score;
    double? maxScore;
    if (widget.isReviewMode && widget.userAttempt != null) {
      score = double.tryParse(widget.userAttempt!['score']?.toString() ?? '0');
      maxScore = double.tryParse(widget.userAttempt!['max_score']?.toString() ?? '0');
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and metadata
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.question.title != null)
                        Text(
                          widget.question.title!,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.isReviewMode && score != null && maxScore != null)
                     Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     decoration: BoxDecoration(
                       color: (maxScore! > 0 && (score! - maxScore).abs() < 0.01) ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(16),
                       border: Border.all(color: (maxScore > 0 && (score - maxScore).abs() < 0.01) ? Colors.green : Colors.red),
                     ),
                     child: Text(
                       '${score.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(1)}',
                       style: TextStyle(
                         fontWeight: FontWeight.bold,
                         color: (maxScore > 0 && (score - maxScore).abs() < 0.01) ? Colors.green[700] : Colors.red[700],
                       ),
                     ),
                   )
                else
                  IconButton(
                    icon: const Icon(Icons.history),
                    tooltip: 'View History',
                    onPressed: () => _showHistory(context),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Difficulty and time estimate badges
            Wrap(
              spacing: 8,
              children: [
                if (widget.question.difficulty != null)
                  Chip(
                    label: Text('Difficulty: ${widget.question.difficulty}'),
                    visualDensity: VisualDensity.compact,
                  ),
                if (widget.question.estimatedTimeSeconds != null)
                  Chip(
                    label: Text('~${widget.question.estimatedTimeSeconds! ~/ 60} min'),
                    visualDensity: VisualDensity.compact,
                  ),
                Chip(
                  label: Text(widget.question.answerType.name.toUpperCase()),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Question parts
            if (widget.question.parts.isNotEmpty) ...[
              PartsListRenderer(
                questionParts: widget.question.parts,
                spacing: 12,
              ),
              const SizedBox(height: 16),
            ],

            // Description
            if (widget.question.description != null && widget.question.description!.isNotEmpty) ...[
              Text(
                widget.question.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Options (if answer type is options)
            if (widget.question.answerType == AnswerType.options && widget.question.options.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Options:',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...widget.question.options.map((option) => _buildOption(context, option)),
            ],

            // Text input (if answer type is text)
            if (widget.question.answerType == AnswerType.text) ...[
              const Divider(),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Your answer',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled: widget.isInteractive && !_submitted && !widget.isReviewMode,
                controller: widget.isReviewMode && widget.userAttempt != null 
                    ? TextEditingController(text: _getTextResponse()) 
                    : null,
              ),
            ],

            // Submit button
            if (widget.isInteractive && widget.onAnswerSubmit != null && !widget.isReviewMode) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_submitted)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _submitted = false;
                          _selectedOptions.clear();
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitted || _selectedOptions.isEmpty
                        ? null
                        : () {
                            setState(() => _submitted = true);
                            widget.onAnswerSubmit!(_selectedOptions.toList());
                          },
                    child: const Text('Submit Answer'),
                  ),
                ],
              ),
            ],

            // Explanation Section (Review Mode Only)
            if (widget.isReviewMode && widget.question.explanation != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Explanation',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Text(widget.question.explanation!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTextResponse() {
    if (widget.userAttempt == null) return '';
    final parts = widget.userAttempt!['parts'] as List<dynamic>?;
    if (parts != null && parts.isNotEmpty) {
      return parts[0]['text_response']?.toString() ?? '';
    }
    return '';
  }

  Widget _buildOption(BuildContext context, QuestionOption option) {
    final isSelected = _selectedOptions.contains(option.id);
    final theme = Theme.of(context);
    
    // Review mode styling
    Color? cardColor;
    Color? borderColor;
    IconData? statusIcon;
    Color? statusColor;

    if (widget.isReviewMode) {
      if (option.isCorrect) {
        cardColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
      } else if (isSelected) {
        cardColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
      }
      
      if (isSelected && option.isCorrect) {
         // Correctly selected
         cardColor = Colors.green.withOpacity(0.2);
      }
    } else {
      if (isSelected) cardColor = theme.colorScheme.primaryContainer;
    }

    return Card(
      color: cardColor,
      shape: borderColor != null ? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ) : null,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: widget.isInteractive && !_submitted && !widget.isReviewMode
            ? () {
                setState(() {
                  if (isSelected) {
                    _selectedOptions.remove(option.id);
                  } else {
                    final allowMultiple = widget.question.metadata['allow_multiple'] == true;
                    if (!allowMultiple) {
                      _selectedOptions.clear();
                    }
                    _selectedOptions.add(option.id);
                  }
                });
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Option label (A, B, C, D)
              if (option.label != null)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      option.label!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 12),

              // Option parts
              Expanded(
                child: option.parts.isNotEmpty
                    ? IgnorePointer(
                        child: PartsListRenderer(
                          optionParts: option.parts,
                          spacing: 8,
                        ),
                      )
                    : const Text('(No content)'),
              ),

              // Selected/Status indicator
              if (widget.isReviewMode) ...[
                 if (statusIcon != null)
                   Icon(statusIcon, color: statusColor),
              ] else if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionHistorySheet extends StatefulWidget {
  final String questionId;
  const _QuestionHistorySheet({required this.questionId});

  @override
  State<_QuestionHistorySheet> createState() => _QuestionHistorySheetState();
}

class _QuestionHistorySheetState extends State<_QuestionHistorySheet> {
  final _questionService = QuestionService();
  List<dynamic>? _attempts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    try {
      final attempts = await _questionService.getQuestionAttempts(widget.questionId);
      if (mounted) {
        setState(() {
          _attempts = attempts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attempt History', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_attempts == null || _attempts!.isEmpty)
            const Center(child: Text('No past attempts found.'))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _attempts!.length,
                itemBuilder: (context, index) {
                  final attempt = _attempts![index];
                  final date = DateTime.parse(attempt['started_at']).toLocal();
                  final score = attempt['score'];
                  final maxScore = attempt['max_score'];
                  
                  final scoreVal = double.tryParse(score?.toString() ?? '0') ?? 0.0;
                  final maxScoreVal = double.tryParse(maxScore?.toString() ?? '0') ?? 0.0;
                  
                  return ListTile(
                    leading: Icon(
                      (maxScoreVal > 0 && (scoreVal - maxScoreVal).abs() < 0.01) ? Icons.check_circle : Icons.cancel,
                      color: (maxScoreVal > 0 && (scoreVal - maxScoreVal).abs() < 0.01) ? Colors.green : Colors.red,
                    ),
                    title: Text(DateFormat.yMMMd().add_jm().format(date)),
                    subtitle: Text('Score: ${scoreVal.toStringAsFixed(1)} / ${maxScoreVal.toStringAsFixed(1)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (attempt['quiz_attempt_id'] != null) {
                        Navigator.pop(context); // Close sheet
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttemptResultPage(attemptId: attempt['quiz_attempt_id']),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
