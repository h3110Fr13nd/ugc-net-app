import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/import_screen.dart';

import 'ui/ui.dart';

// Pages (modular index)
import 'pages/pages_index.dart';
import 'pages/authentication_page.dart';
import 'pages/splash_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/quizzes_list_page.dart';
import 'pages/quiz_detail_page.dart';
import 'pages/quiz_editor_page.dart';
import 'pages/question_editor_page.dart';
import 'pages/question_part_editor_page.dart';
import 'pages/options_editor_page.dart';
import 'pages/media_manager_page.dart';
import 'pages/topics_page.dart';
import 'pages/question_banks_page.dart';
import 'pages/quiz_attempt_page.dart';
import 'pages/attempt_review_page.dart';
import 'pages/user_profile_page.dart';
import 'pages/admin_users_page.dart';
import 'pages/admin_roles_page.dart';
import 'pages/audit_logs_page.dart';
import 'pages/entity_relationships_page.dart';
import 'pages/search_page.dart';
import 'pages/analytics_page.dart';
import 'pages/import_export_page.dart';
import 'pages/settings_tenant_page.dart';
import 'pages/versioning_history_page.dart';
import 'pages/sitemap_page.dart';
import 'pages/ux_qa_page.dart';
import 'pages/composite_questions_demo.dart';
import 'pages/random_questions_page.dart';

class MyApp extends StatelessWidget {
  final MyAppState? initialState;

  const MyApp({super.key, this.initialState});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => initialState ?? MyAppState(),
      child: Consumer<MyAppState>(builder: (context, appState, _) {
        return MaterialApp(
          title: 'UGC Net App',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: appState.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashPage(),
          routes: {
            '/home': (context) => const HomeScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/practice': (context) => const PracticeScreen(),
            '/stats': (context) => const StatsScreen(),
            '/import': (context) => const ImportScreen(),
            // Pages from docs/pages
            '/pages': (context) => const PagesIndexScreen(),
            '/pages/authentication': (context) => const AuthenticationPage(),
            '/pages/dashboard': (context) => const DashboardPage(),
            '/pages/quizzes': (context) => const QuizzesListPage(),
            '/pages/quiz_detail': (context) => const QuizDetailPage(),
            '/pages/quiz_editor': (context) => const QuizEditorPage(),
            '/pages/question_editor': (context) => const QuestionEditorPage(),
            '/pages/question_part_editor': (context) => const QuestionPartEditorPage(),
            '/pages/options_editor': (context) => const OptionsEditorPage(),
            '/pages/media_manager': (context) => const MediaManagerPage(),
            '/pages/topics': (context) => const TopicsPage(),
            '/pages/random-questions': (context) => const RandomQuestionsPage(),
            '/pages/question_banks': (context) => const QuestionBanksPage(),
            '/pages/quiz_attempt': (context) => const QuizAttemptPage(),
            '/pages/attempt_review': (context) => const AttemptReviewPage(),
            '/pages/user_profile': (context) => const UserProfilePage(),
            '/pages/admin_users': (context) => const AdminUsersPage(),
            '/pages/admin_roles': (context) => const AdminRolesPage(),
            '/pages/audit_logs': (context) => const AuditLogsPage(),
            '/pages/entity_relationships': (context) => const EntityRelationshipsPage(),
            '/pages/search': (context) => const SearchPage(),
            '/pages/analytics': (context) => const AnalyticsPage(),
            '/pages/import_export': (context) => const ImportExportPage(),
            '/pages/settings_tenant': (context) => const SettingsTenantPage(),
            '/pages/versioning_history': (context) => const VersioningHistoryPage(),
            '/pages/sitemap': (context) => const SitemapPage(),
            '/pages/ux_qa': (context) => const UxQaChecklistPage(),
            '/pages/composite_questions': (context) => const CompositeQuestionsDemo(),
          },
        );
      }),
    );
  }
}


