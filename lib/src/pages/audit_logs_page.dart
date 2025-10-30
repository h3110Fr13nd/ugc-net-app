import 'package:flutter/material.dart';
import 'page_template.dart';

class AuditLogsPage extends StatelessWidget {
  const AuditLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Audit Logs',
      subtitle: 'Timeline and export of audit events',
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 8,
          itemBuilder: (context, idx) => ListTile(
            leading: const Icon(Icons.history),
            title: Text('Event ${idx + 1}'),
            subtitle: const Text('Details about the event'),
          ),
        )
      ],
    );
  }
}
