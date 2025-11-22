// Lightweight client-side model that mirrors the server `TaxonomyTreeResponse`.
import 'package:net_api/net_api.dart' as api;

class TaxonomyNode {
  final String id;
  final String name;
  final String? nodeType;
  final String? parentId;
  final List<TaxonomyNode> children;

  TaxonomyNode({
    required this.id,
    required this.name,
    this.nodeType,
    this.parentId,
    this.children = const [],
  });

  factory TaxonomyNode.fromApi(api.TaxonomyTreeResponse src) {
    return TaxonomyNode(
      id: src.id,
      name: src.name,
      nodeType: src.nodeType,
      parentId: src.parentId,
      children: src.children == null
          ? const []
          : src.children!.map((c) => TaxonomyNode.fromApi(c)).toList(),
    );
  }
}
