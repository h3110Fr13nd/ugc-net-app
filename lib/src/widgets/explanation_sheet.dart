import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Reusable widget for displaying streaming LLM explanations
/// Can be used in random questions, quiz attempts, practice mode, etc.
class ExplanationSheet extends StatefulWidget {
  final WebSocketService wsService;
  final VoidCallback? onClose;

  const ExplanationSheet({
    super.key,
    required this.wsService,
    this.onClose,
  });

  @override
  State<ExplanationSheet> createState() => _ExplanationSheetState();
}

class _ExplanationSheetState extends State<ExplanationSheet> {
  final List<Map<String, dynamic>> _explanationBlocks = [];
  bool _isComplete = false;
  double? _score;
  int _totalBlocks = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.wsService.messages.listen((msg) {
      if (mounted) {
        setState(() {
          final type = msg['type'];
          
          if (type == 'structured_chunk') {
            // Incremental update with score and block count
            _score = (msg['score'] as num?)?.toDouble();
            _totalBlocks = (msg['explanation_count'] as num?)?.toInt() ?? 0;
          } else if (type == 'explanation_block') {
            // New explanation block arrived
            final block = msg['block'];
            if (block is Map<String, dynamic>) {
              _explanationBlocks.add(block);
            }
          } else if (type == 'explanation_end') {
            _isComplete = true;
          } else if (type == 'result') {
            // Final result with score and total blocks
            _score = (msg['score'] as num?)?.toDouble();
            _totalBlocks = (msg['total_blocks'] as num?)?.toInt() ?? 0;
          } else if (type == 'error') {
            // Handle error
            _error = msg['error'] as String?;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    widget.wsService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explanation',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Row(
                    children: [
                      if (!_isComplete)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onClose?.call();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Error display
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Score display
              if (_score != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _score! >= 0.7
                        ? Colors.green.withOpacity(0.1)
                        : _score! >= 0.4
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _score! >= 0.7
                            ? Icons.check_circle
                            : _score! >= 0.4
                                ? Icons.warning
                                : Icons.error,
                        color: _score! >= 0.7
                            ? Colors.green
                            : _score! >= 0.4
                                ? Colors.orange
                                : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Score: ${(_score! * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (_totalBlocks > 0 && _explanationBlocks.length < _totalBlocks)
                        Text(
                          ' (${_explanationBlocks.length}/$_totalBlocks blocks)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              const Divider(),
              
              // Explanation blocks
              Expanded(
                child: _explanationBlocks.isEmpty && !_isComplete && _error == null
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _explanationBlocks.length,
                        itemBuilder: (context, index) {
                          final block = _explanationBlocks[index];
                          final blockType = block['type'] as String?;
                          final content = block['content'] as String?;

                          if (content == null) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: blockType == 'code'
                                ? Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      content,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : MarkdownBody(
                                    data: content,
                                    styleSheet: MarkdownStyleSheet(
                                      p: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
