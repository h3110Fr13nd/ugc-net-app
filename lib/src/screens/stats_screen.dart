import 'package:flutter/material.dart';
import 'package:net_api/api.dart' as api;
import '../services/api_factory.dart';
import '../ui/ui.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoading = true;
  String? _error;
  List<api.TaxonomyTreeResponse> _statsTree = [];
  String _sortBy = 'attempted'; // 'attempted', 'accuracy', 'name'

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiInstance = ApiFactory.getStatsApi();
      final tree = await apiInstance.getMyTaxonomyTreeApiV1StatsMeTaxonomyTreeGet();
      
      if (mounted) {
        setState(() {
          _statsTree = tree ?? [];
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

  void _sortStats(List<api.TaxonomyTreeResponse> nodes) {
    // Sort current level
    nodes.sort((a, b) {
      switch (_sortBy) {
        case 'attempted':
          return b.questionsAttempted.compareTo(a.questionsAttempted); // Descending
        case 'accuracy':
          return b.averageScorePercent.compareTo(a.averageScorePercent);
        case 'name':
        default:
          return (a.name).compareTo(b.name);
      }
    });

    // Recursively sort children
    for (var node in nodes) {
      if (node.children.isNotEmpty) {
        _sortStats(node.children);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Apply sort before building
    _sortStats(_statsTree);

    return AppShell(
      title: 'Statistics',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _statsTree.isEmpty
                  ? const Center(child: Text('No statistics available yet.'))
                  : Column(
                      children: [
                        // Add sort button as a header since AppShell doesn't support actions
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('Sort by: '),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.sort),
                                onSelected: (value) {
                                  setState(() {
                                    _sortBy = value;
                                  });
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'attempted', child: Text('Sort by Attempts')),
                                  const PopupMenuItem(value: 'accuracy', child: Text('Sort by Accuracy')),
                                  const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: _loadStats,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _statsTree.length,
                            itemBuilder: (context, index) {
                              return _buildStatNode(_statsTree[index]);
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildStatNode(api.TaxonomyTreeResponse node, {int depth = 0}) {
    final attempted = node.questionsAttempted;
    final accuracy = node.averageScorePercent;
    
    final hasActivity = attempted > 0;

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: 16 + (depth * 16), right: 16),
          title: Text(
            node.name,
            style: TextStyle(
              fontWeight: depth == 0 ? FontWeight.bold : FontWeight.normal,
              color: hasActivity ? null : Colors.grey,
            ),
          ),
          subtitle: hasActivity
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: accuracy / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        accuracy >= 80 ? Colors.green : (accuracy >= 50 ? Colors.orange : Colors.red),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$attempted attempted • ${accuracy.toStringAsFixed(1)}% accuracy',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                )
              : const Text('No attempts yet', style: TextStyle(fontSize: 12, color: Colors.grey)),
          onTap: () {
            // Maybe navigate to practice this topic?
          },
        ),
        if (node.children.isNotEmpty)
          ...node.children.map((child) => _buildStatNode(child, depth: depth + 1)),
      ],
    );
  }
}
