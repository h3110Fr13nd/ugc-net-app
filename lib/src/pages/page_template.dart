import 'package:flutter/material.dart';

import '../ui/ui.dart';

class PageTemplate extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const PageTemplate({super.key, required this.title, this.subtitle = '', this.children = const []});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: title,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(title: title, subtitle: subtitle.isNotEmpty ? subtitle : null),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
