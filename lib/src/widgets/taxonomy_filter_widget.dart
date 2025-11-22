import 'package:flutter/material.dart';
import '../models/taxonomy_node.dart';
import '../services/taxonomy_service.dart';

class TaxonomyFilterWidget extends StatefulWidget {
  final String? selectedTaxonomyId;
  final ValueChanged<String?> onChanged;

  const TaxonomyFilterWidget({
    super.key,
    this.selectedTaxonomyId,
    required this.onChanged,
  });

  @override
  State<TaxonomyFilterWidget> createState() => _TaxonomyFilterWidgetState();
}

class _TaxonomyFilterWidgetState extends State<TaxonomyFilterWidget> {
  final _service = TaxonomyService();
  late Future<List<TaxonomyNode>> _treeFuture;

  @override
  void initState() {
    super.initState();
    _treeFuture = _service.getTaxonomyTree();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter by Topic',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (widget.selectedTaxonomyId != null)
                TextButton(
                  onPressed: () => widget.onChanged(null),
                  child: const Text('Clear'),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: FutureBuilder<List<TaxonomyNode>>(
            future: _treeFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('Error loading taxonomy: ${snapshot.error}'),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _treeFuture = _service.getTaxonomyTree();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final nodes = snapshot.data ?? [];
              if (nodes.isEmpty) {
                return const Center(child: Text('No taxonomy found'));
              }

              return ListView(
                children: nodes.map(_buildNodeTile).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNodeTile(TaxonomyNode node) {
    final isSelected = widget.selectedTaxonomyId == node.id;
    final hasChildren = node.children.isNotEmpty;

    // If it has children, we want to be able to expand it AND select it.
    // ExpansionTile doesn't easily support "selecting the header".
    // So we'll use a custom approach or just put a select button.
    // For simplicity, tapping the tile selects it. The trailing icon expands it.

    if (!hasChildren) {
      return ListTile(
        title: Text(node.name),
        subtitle: node.nodeType != null ? Text(node.nodeType!) : null,
        selected: isSelected,
        selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
        onTap: () => widget.onChanged(node.id),
      );
    }

    return ExpansionTile(
      title: Text(
        node.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      subtitle: node.nodeType != null ? Text(node.nodeType!) : null,
      backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : null,
      // We want to allow selecting this parent node too
      leading: IconButton(
        icon: Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
        onPressed: () => widget.onChanged(node.id),
      ),
      childrenPadding: const EdgeInsets.only(left: 16.0),
      children: node.children.map(_buildNodeTile).toList(),
    );
  }
}
