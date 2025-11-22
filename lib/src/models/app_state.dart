import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/composite_question.dart';
import '../services/question_service.dart';
import '../services/auth_service.dart';

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  // Theme: default dark
  bool _darkMode = true;

  // Auth state
  String? _accessToken;
  Map<String, dynamic>? _user;

  bool get darkMode => _darkMode;

  String? get accessToken => _accessToken;

  Map<String, dynamic>? get user => _user;

  bool get isSignedIn => _accessToken != null;

  void toggleTheme() {
    _darkMode = !_darkMode;
    _savePrefs();
    notifyListeners();
  }

  MyAppState() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? true;
    _accessToken = prefs.getString('app_token');
    final u = prefs.getString('app_user');
    if (u != null) {
      try {
        _user = json.decode(u) as Map<String, dynamic>;
      } catch (e) {
        _user = null;
      }
    }
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
  }

  Future<void> setAuth(String token, Map<String, dynamic> user) async {
    _accessToken = token;
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_token', token);
    await prefs.setString('app_user', json.encode(user));
    notifyListeners();
  }

  /// Set only the access token (used after refresh) and persist it.
  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_token', token);
    notifyListeners();
  }

  /// Try to refresh access token using AuthService and stored refresh token.
  /// Returns true if refresh succeeded and token updated.
  Future<bool> tryRefresh() async {
    try {
      final auth = AuthService();
      final res = await auth.refresh();
      if (res.containsKey('access_token')) {
        final token = res['access_token'] as String;
        await setAccessToken(token);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearAuth() async {
    _accessToken = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_token');
    await prefs.remove('app_user');
    notifyListeners();
  }

  // final MockApi _api = MockApi(); // Removed
  final QuestionService _service = QuestionService();

  // Practice mode state
  List<CompositeQuestion> _questions = [];
  int _currentIndex = 0;
  bool _loading = false;

  // Public getters
  List<CompositeQuestion> get questions => List.unmodifiable(_questions);
  int get currentIndex => _currentIndex;
  CompositeQuestion? get currentQuestion => _questions.isNotEmpty ? _questions[_currentIndex] : null;
  bool get isLoading => _loading;

  Future<void> loadQuestions({int limit = 10}) async {
    _loading = true;
    notifyListeners();
    try {
      // Use searchQuestions to get a list of questions. 
      // Ideally we'd have a random fetch, but for now just fetch first page or search.
      _questions = await _service.searchQuestions(pageSize: limit);
    } catch (e) {
      print('Error loading questions: $e');
      _questions = [];
    }
    _currentIndex = 0;
    _loading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> submitCurrentAttempt(String selected) async {
    final q = currentQuestion;
    if (q == null) return {'error': 'no question'};
    
    // Stub submission for now as API doesn't have a direct submit endpoint yet
    // We can check correctness locally if the question has correct answer info
    bool correct = false;
    String explanation = 'Answer recorded locally.';
    
    try {
      final selectedOption = q.options.firstWhere((o) => o.id == selected);
      correct = selectedOption.isCorrect;
      if (correct) {
        explanation = 'Correct!';
      } else {
        explanation = 'Incorrect.';
      }
    } catch (_) {
      // Option not found or other error
    }

    // advance to next question automatically if available
    if (_currentIndex < _questions.length - 1) {
      _currentIndex += 1;
    }
    notifyListeners();
    return {'correct': correct, 'explanation': explanation};
  }

  Future<Map<String, dynamic>> fetchStats() async {
    // Stub stats
    return {'total': 0, 'correct': 0, 'topicCorrect': {}};
  }

  void next() {
    current = WordPair.random();
    notifyListeners();
  }
}
