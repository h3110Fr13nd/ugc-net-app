import 'package:flutter/material.dart';
import '../models/composite_question.dart';
import 'part_renderer.dart';

/// Widget to display a composite question with all its parts and options
class CompositeQuestionCard extends StatefulWidget {
  final CompositeQuestion question;
  final Function(List<String> selectedOptionIds)? onAnswerSubmit;
  final bool isInteractive;

  const CompositeQuestionCard({
    super.key,
    required this.question,
    this.onAnswerSubmit,
    this.isInteractive = true,
  });

  @override
  State<CompositeQuestionCard> createState() => _CompositeQuestionCardState();
}

class _CompositeQuestionCardState extends State<CompositeQuestionCard> {
  final Set<String> _selectedOptions = {};
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and metadata
            if (widget.question.title != null) ...[
              Text(
                widget.question.title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            ],

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
            if (widget.question.answerType == AnswerType.text && widget.isInteractive) ...[
              const Divider(),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Your answer',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled: !_submitted,
              ),
            ],

            // Numeric input (if answer type is numeric or integer)
            if ((widget.question.answerType == AnswerType.numeric ||
                    widget.question.answerType == AnswerType.integer) &&
                widget.isInteractive) ...[
              const Divider(),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Your answer',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                enabled: !_submitted,
              ),
            ],

            // Submit button
            if (widget.isInteractive && widget.onAnswerSubmit != null) ...[
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
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, QuestionOption option) {
    final isSelected = _selectedOptions.contains(option.id);
    final theme = Theme.of(context);

    return Card(
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: widget.isInteractive && !_submitted
            ? () {
                setState(() {
                  if (isSelected) {
                    _selectedOptions.remove(option.id);
                  } else {
                    // For single-select, clear previous selections
                    // For multi-select, keep multiple selections
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

              // Selected indicator
              if (isSelected)
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
