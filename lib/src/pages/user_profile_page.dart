import 'package:flutter/material.dart';
import 'page_template.dart';
import '../ui/ui.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'User Profile',
      subtitle: 'Edit profile, linked accounts, sessions',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Display name'),
                const SizedBox(height: 8),
                TextField(decoration: const InputDecoration(labelText: 'Display name')),
                const SizedBox(height: 12),
                PrimaryButton(onPressed: () {}, child: const Text('Save profile')),
              ],
            ),
          ),
        )
      ],
    );
  }
}
