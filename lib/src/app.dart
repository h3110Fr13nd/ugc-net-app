import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_state.dart';
import 'widgets/app_theme.dart';

// Pages
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
import 'pages/attempt_review_page.dart';
import 'pages/user_profile_page.dart';
import 'pages/search_page.dart';
import 'pages/analytics_page.dart';
import 'pages/settings_page.dart';
import 'pages/random_questions_page.dart';
import 'pages/attempt_history_page.dart';

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
            '/home': (context) => const DashboardPage(),
            '/settings': (context) => const SettingsPage(),
            // Pages
            '/pages/authentication': (context) => const AuthenticationPage(),
            '/pages/dashboard': (context) => const DashboardPage(),
            '/pages/quizzes': (context) => const QuizzesListPage(),
            '/pages/quiz_detail': (context) => const QuizDetailPage(),
            '/pages/quiz_editor': (context) => const QuizEditorPage(),
            '/pages/question_editor': (context) => const QuestionEditorPage(),
            '/pages/history': (context) => const AttemptHistoryPage(),
            '/pages/question_part_editor': (context) => const QuestionPartEditorPage(),
            '/pages/options_editor': (context) => const OptionsEditorPage(),
            '/pages/media_manager': (context) => const MediaManagerPage(),
            '/pages/topics': (context) => const TopicsPage(),
            '/pages/random-questions': (context) => const RandomQuestionsPage(),
            '/pages/question_banks': (context) => const QuestionBanksPage(),
            '/pages/attempt_review': (context) => const AttemptReviewPage(),
            '/pages/user_profile': (context) => const UserProfilePage(),
            '/pages/search': (context) => const SearchPage(),
            '/pages/analytics': (context) => const AnalyticsPage(),
          },
        );
      }),
    );
  }
}



