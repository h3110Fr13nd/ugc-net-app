import 'package:flutter/material.dart';
import '../services/taxonomy_service.dart';
import '../models/taxonomy_node.dart';
import 'taxonomy_node_page.dart';

class TopicsPage extends StatefulWidget {
  const TopicsPage({super.key});

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  final _service = TaxonomyService();
  TaxonomyNode? _rootNode;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final nodes = await _service.getTaxonomyTree();
      
      // Calculate global stats
      int totalAttempted = 0;
      int totalCorrect = 0;
      int totalTime = 0;
      DateTime? lastAttempt;

      for (var node in nodes) {
        totalAttempted += node.questionsAttempted;
        totalCorrect += node.questionsCorrect;
        totalTime += node.totalTimeSeconds;
        
        if (node.lastAttemptAt != null) {
          if (lastAttempt == null || node.lastAttemptAt!.isAfter(lastAttempt)) {
            lastAttempt = node.lastAttemptAt;
          }
        }
      }

      double avgScore = totalAttempted > 0 ? totalCorrect / totalAttempted : 0.0;

      // Create virtual root node
      final root = TaxonomyNode(
        id: 'root',
        name: 'All Topics',
        children: nodes,
        questionsAttempted: totalAttempted,
        questionsCorrect: totalCorrect,
        questionsViewed: 0, // Not easily aggregatable without recursion
        totalTimeSeconds: totalTime,
        averageScorePercent: avgScore,
        lastAttemptAt: lastAttempt,
        description: 'Welcome to your practice dashboard. Here you can see your overall progress and start practicing across all topics.',
        relatedNodes: [],
      );

      if (mounted) {
        setState(() {
          _rootNode = root;
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    if (_rootNode == null) {
      return const Scaffold(body: Center(child: Text('No data available')));
    }

    // Delegate to TaxonomyNodePage
    return TaxonomyNodePage(
      node: _rootNode!,
      onRefresh: _loadData,
    );
  }
}
