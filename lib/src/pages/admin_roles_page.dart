import 'package:flutter/material.dart';
import 'page_template.dart';
import '../ui/ui.dart';

class AdminRolesPage extends StatelessWidget {
  const AdminRolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Admin - Roles & Permissions',
      subtitle: 'Manage RBAC and role assignments',
      children: [
        Wrap(
          spacing: 8,
          children: List.generate(4, (i) => Chip(label: Text('Role ${i + 1}'))),
        ),
        const SizedBox(height: 12),
        PrimaryButton(onPressed: () {}, child: const Text('Create role')),
      ],
    );
  }
}
