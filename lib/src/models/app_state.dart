import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../services/mock_api.dart';

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

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
