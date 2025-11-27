// Lightweight client-side model that mirrors the server `TaxonomyTreeResponse`.
import 'package:net_api/api.dart' as api;

class TaxonomyNode {
  final String id;
  final String name;
  final String? description;
  final String? nodeType;
  final String? parentId;
  final List<TaxonomyNode> children;
  final List<TaxonomyNode> relatedNodes;
  final int questionsAttempted;
  final int questionsCorrect;
  final int questionsViewed;
  final int totalTimeSeconds;
  final double averageScorePercent;
  final DateTime? lastAttemptAt;

  TaxonomyNode({
    required this.id,
    required this.name,
    this.description,
    this.nodeType,
    this.parentId,
    this.children = const [],
    this.relatedNodes = const [],
    this.questionsAttempted = 0,
    this.questionsCorrect = 0,
    this.questionsViewed = 0,
    this.totalTimeSeconds = 0,
    this.averageScorePercent = 0.0,
    this.lastAttemptAt,
  });

  factory TaxonomyNode.fromApi(api.TaxonomyTreeResponse src) {
    return TaxonomyNode(
      id: src.id,
      name: src.name,
      description: src.description,
      nodeType: src.nodeType,
      parentId: src.parentId,
      children: src.children == null
          ? const []
          : src.children!.map((c) => TaxonomyNode.fromApi(c)).toList(),
      relatedNodes: src.relatedNodes == null
          ? const []
          : src.relatedNodes!.map((c) => TaxonomyNode.fromResponse(c)).toList(),
      questionsAttempted: src.questionsAttempted,
      questionsCorrect: src.questionsCorrect,
      questionsViewed: src.questionsViewed,
      totalTimeSeconds: src.totalTimeSeconds,
      averageScorePercent: src.averageScorePercent.toDouble(),
      lastAttemptAt: src.lastAttemptAt,
    );
  }

  factory TaxonomyNode.fromResponse(api.TaxonomyResponse src) {
    return TaxonomyNode(
      id: src.id,
      name: src.name,
      description: src.description,
      nodeType: src.nodeType,
      parentId: src.parentId,
      relatedNodes: src.relatedNodes == null
          ? const []
          : src.relatedNodes!.map((c) => TaxonomyNode.fromResponse(c)).toList(),
    );
  }
}
