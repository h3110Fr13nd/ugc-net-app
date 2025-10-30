import 'package:flutter/material.dart';
import 'page_template.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Search & Browse',
      subtitle: 'Global search across resources with filters',
      children: [
        TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search...')),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (context, idx) => Card(
            child: ListTile(title: Text('Result ${idx + 1}'), subtitle: const Text('Resource snippet')),
          ),
        )
      ],
    );
  }
}
