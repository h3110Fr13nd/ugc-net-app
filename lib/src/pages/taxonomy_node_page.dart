import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/taxonomy_node.dart';
import 'practice_session_page.dart';

class TaxonomyNodePage extends StatefulWidget {
  final TaxonomyNode node;
  final VoidCallback? onRefresh;

  const TaxonomyNodePage({super.key, required this.node, this.onRefresh});

  @override
  State<TaxonomyNodePage> createState() => _TaxonomyNodePageState();
}

class _TaxonomyNodePageState extends State<TaxonomyNodePage> {
  String _sortBy = 'name'; // name, attempted, time, score, last_practiced
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.node.name),
        actions: [
          if (widget.onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: widget.onRefresh,
              tooltip: 'Refresh Stats',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortBy = value;
                  _sortAscending = true; 
                  if (value != 'name') _sortAscending = false;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Name')),
              const PopupMenuItem(value: 'attempted', child: Text('Questions Attempted')),
              const PopupMenuItem(value: 'time', child: Text('Time Spent')),
              const PopupMenuItem(value: 'score', child: Text('Average Score')),
              const PopupMenuItem(value: 'last_practiced', child: Text('Recently Practiced')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            if (widget.node.description != null && widget.node.description!.isNotEmpty) ...[
              Text('About', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              MarkdownBody(data: widget.node.description!),
              const SizedBox(height: 24),
            ],

            // Stats Card
            Text('Your Progress', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _buildStatsCard(context),
            const SizedBox(height: 24),

            // Practice Actions
            Text('Practice', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startPractice(context, null),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Practice All'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _startPractice(context, 'unattempted'),
                    icon: const Icon(Icons.check_box_outline_blank),
                    label: const Text('Unattempted'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Children / Sub-topics
            if (widget.node.children.isNotEmpty) ...[
              Text('Sub-topics', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildNodeTree(widget.node.children),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNodeTree(List<TaxonomyNode> nodes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final sortedNodes = _sortNodes(nodes);
        return _buildNodeTile(sortedNodes[index]);
      },
    );
  }

  Widget _buildNodeTile(TaxonomyNode node) {
    final accuracy = node.averageScorePercent;
    final hasChildren = node.children.isNotEmpty;

    // Custom tile to handle both navigation and expansion
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaxonomyNodePage(
                    node: node,
                    onRefresh: widget.onRefresh,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      if (node.questionsAttempted > 0) ...[
                        LinearProgressIndicator(
                          value: accuracy,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            accuracy >= 0.8 ? Colors.green : (accuracy >= 0.5 ? Colors.orange : Colors.red),
                          ),
                          minHeight: 4,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        '${node.questionsAttempted} attempts • ${(accuracy * 100).toStringAsFixed(0)}% avg',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          trailing: hasChildren ? null : const SizedBox.shrink(), // Default chevron if children exist
          children: hasChildren
              ? [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: _buildNodeTree(node.children),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  List<TaxonomyNode> _sortNodes(List<TaxonomyNode> nodes) {
    final sorted = List<TaxonomyNode>.from(nodes);
    sorted.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case 'attempted':
          cmp = a.questionsAttempted.compareTo(b.questionsAttempted);
          break;
        case 'time':
          cmp = a.totalTimeSeconds.compareTo(b.totalTimeSeconds);
          break;
        case 'score':
          cmp = a.averageScorePercent.compareTo(b.averageScorePercent);
          break;
        case 'last_practiced':
          final dateA = a.lastAttemptAt;
          final dateB = b.lastAttemptAt;
          if (dateA == null && dateB == null) {
            cmp = 0;
          } else if (dateA == null) {
            cmp = -1; 
          } else if (dateB == null) {
            cmp = 1; 
          } else {
            cmp = dateA.compareTo(dateB);
          }
          break;
        case 'name':
        default:
          cmp = a.name.compareTo(b.name);
      }
      return _sortAscending ? cmp : -cmp;
    });
    return sorted;
  }

  void _startPractice(BuildContext context, String? filterStatus) {
    // If node ID is 'root', pass null to practice session for global practice
    final taxonomyId = widget.node.id == 'root' ? null : widget.node.id;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeSessionPage(
          taxonomyId: taxonomyId,
          title: widget.node.name,
          filterStatus: filterStatus,
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Attempts', '${widget.node.questionsAttempted}'),
                _buildStatItem(context, 'Correct', '${widget.node.questionsCorrect}'),
                _buildStatItem(context, 'Avg Score', '${(widget.node.averageScorePercent * 100).toStringAsFixed(0)}%'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Time Spent', _formatDuration(widget.node.totalTimeSeconds)),
                _buildStatItem(context, 'Last Practiced', widget.node.lastAttemptAt != null ? _formatDate(widget.node.lastAttemptAt!) : 'Never'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    return '${hours}h ${minutes % 60}m';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
