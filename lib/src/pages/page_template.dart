import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class PageTemplate extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final List<Widget>? actions;

  const PageTemplate({super.key, required this.title, this.subtitle = '', this.children = const [], this.actions});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: title,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: PageHeader(title: title, subtitle: subtitle.isNotEmpty ? subtitle : null)),
                if (actions != null) ...actions!,
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
