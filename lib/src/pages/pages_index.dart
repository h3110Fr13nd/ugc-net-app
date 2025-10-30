import 'package:flutter/material.dart';
import 'page_template.dart';

class PagesIndexScreen extends StatelessWidget {
  const PagesIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, String>>[
      {'title': 'Authentication', 'route': '/pages/authentication'},
      {'title': 'Dashboard', 'route': '/pages/dashboard'},
      {'title': 'Quizzes', 'route': '/pages/quizzes'},
      {'title': 'Quiz Detail', 'route': '/pages/quiz_detail'},
      {'title': 'Quiz Editor', 'route': '/pages/quiz_editor'},
      {'title': 'Question Editor', 'route': '/pages/question_editor'},
      {'title': 'Question Part Editor', 'route': '/pages/question_part_editor'},
      {'title': 'Options Editor', 'route': '/pages/options_editor'},
      {'title': 'Media Manager', 'route': '/pages/media_manager'},
      {'title': 'Topics / Subjects / Chapters', 'route': '/pages/topics'},
      {'title': 'Question Banks', 'route': '/pages/question_banks'},
      {'title': 'Quiz Attempt', 'route': '/pages/quiz_attempt'},
      {'title': 'Attempt Review', 'route': '/pages/attempt_review'},
      {'title': 'User Profile', 'route': '/pages/user_profile'},
      {'title': 'Admin - Users', 'route': '/pages/admin_users'},
      {'title': 'Admin - Roles & Permissions', 'route': '/pages/admin_roles'},
      {'title': 'Audit Logs', 'route': '/pages/audit_logs'},
      {'title': 'Entity Relationships', 'route': '/pages/entity_relationships'},
      {'title': 'Search & Browse', 'route': '/pages/search'},
      {'title': 'Analytics & Reports', 'route': '/pages/analytics'},
      {'title': 'Import & Export', 'route': '/pages/import_export'},
      {'title': 'Settings & Tenant', 'route': '/pages/settings_tenant'},
      {'title': 'Versioning & History', 'route': '/pages/versioning_history'},
      {'title': 'Sitemap', 'route': '/pages/sitemap'},
      {'title': 'UX & QA Checklist', 'route': '/pages/ux_qa'},
    ];

    return PageTemplate(
      title: 'Pages index',
      subtitle: 'Lightweight navigation for the app pages',
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: items
              .map((it) => Card(
                    elevation: 2,
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, it['route']!),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(it['title']!, style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            Text(it['route']!, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// Provide a const alias used by routes
// Alias removed: use PagesIndexScreen directly in routes.
