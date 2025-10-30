import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/question.dart';
import '../services/mock_api.dart';

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

  Future<void> clearAuth() async {
    _accessToken = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_token');
    await prefs.remove('app_user');
    notifyListeners();
  }

  final MockApi _api = MockApi();

  // Practice mode state
  List<Question> _questions = [];
  int _currentIndex = 0;
  bool _loading = false;

  // Public getters
  List<Question> get questions => List.unmodifiable(_questions);
  int get currentIndex => _currentIndex;
  Question? get currentQuestion => _questions.isNotEmpty ? _questions[_currentIndex] : null;
  bool get isLoading => _loading;

  Future<void> loadQuestions({int limit = 10}) async {
    _loading = true;
    notifyListeners();
    _questions = await _api.fetchQuestions(limit: limit);
    _currentIndex = 0;
    _loading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> submitCurrentAttempt(String selected) async {
    final q = currentQuestion;
    if (q == null) return {'error': 'no question'};
    final res = await _api.submitAttempt(q.id ?? 0, selected);
    // advance to next question automatically if available
    if (_currentIndex < _questions.length - 1) {
      _currentIndex += 1;
    }
    notifyListeners();
    return res;
  }

  Future<Map<String, dynamic>> fetchStats() async {
    return await _api.stats();
  }

  void next() {
    current = WordPair.random();
    notifyListeners();
  }
}
