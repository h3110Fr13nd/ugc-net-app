import 'package:flutter/material.dart';
import 'page_template.dart';
import '../ui/ui.dart';
import '../services/taxonomy_service.dart';
import '../models/taxonomy_node.dart';
import 'taxonomy_node_page.dart';

class TopicsPage extends StatelessWidget {
  const TopicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TaxonomyService();

    return PageTemplate(
      title: 'Topics / Subjects / Chapters',
      subtitle: 'Taxonomy and topic management',
      children: [
        FutureBuilder<List<TaxonomyNode>>(
          future: service.getTaxonomyTree(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final nodes = snapshot.data ?? [];
            if (nodes.isEmpty) {
              return const Text('No taxonomy nodes found');
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: nodes.length,
              itemBuilder: (context, index) {
                final node = nodes[index];
                return _buildNodeTile(context, node);
              },
            );
          },
        ),
        const SizedBox(height: 12),
        PrimaryButton(onPressed: () {}, child: const Text('Add topic')),
      ],
    );
  }

  Widget _buildNodeTile(BuildContext context, TaxonomyNode node) {
    if (node.children.isEmpty) {
      return ListTile(
        title: Text(node.name),
        subtitle: node.nodeType != null ? Text(node.nodeType!) : null,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => TaxonomyNodePage(node: node))),
      );
    }

    return ExpansionTile(
      title: Text(node.name),
      subtitle: node.nodeType != null ? Text(node.nodeType!) : null,
      children: node.children.map((c) => _buildNodeTile(context, c)).toList(),
    );
  }
}
