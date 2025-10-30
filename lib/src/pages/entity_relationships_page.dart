import 'package:flutter/material.dart';
import 'page_template.dart';

class EntityRelationshipsPage extends StatelessWidget {
  const EntityRelationshipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Entity Relationships',
      subtitle: 'Graph view and polymorphic relationships',
      children: [
        Card(
          child: SizedBox(
            height: 240,
            child: Center(child: Text('Graph canvas placeholder', style: Theme.of(context).textTheme.bodyLarge)),
          ),
        ),
      ],
    );
  }
}
