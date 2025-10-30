import 'package:flutter/material.dart';
import 'page_template.dart';

class SitemapPage extends StatelessWidget {
  const SitemapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Sitemap',
      subtitle: 'High-level navigation flows (Mermaid)',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Sitemap placeholder'),
                SizedBox(height: 12),
                Placeholder(fallbackHeight: 200),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
