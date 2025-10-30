import 'package:flutter/material.dart';
import 'page_template.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Admin - Users',
      subtitle: 'User management: search, deactivate, impersonate',
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 8,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, idx) => Card(
            child: ListTile(
              title: Text('User ${idx + 1}'),
              subtitle: const Text('email@example.com'),
              trailing: PopupMenuButton<String>(
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'impersonate', child: Text('Impersonate')),
                  const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
                ],
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      ],
    );
  }
}
