import 'dart:async';

import '../models/question.dart';

/// Simple mock API service that returns sample questions and records attempts locally.
/// Replace with real network client when backend is available.
class MockApi {
  // Sample in-memory question bank
  static final List<Question> _sampleQuestions = [
    Question(id: 1, text: 'What is the capital of France?', options: ['Paris', 'Rome', 'Berlin'], answer: 'Paris', topic: 'Geography'),
    Question(id: 2, text: '2 + 2 equals?', options: ['3', '4', '5'], answer: '4', topic: 'Mathematics'),
    Question(id: 3, text: 'Which gas do plants primarily use in photosynthesis?', options: ['Oxygen', 'Carbon dioxide', 'Nitrogen'], answer: 'Carbon dioxide', topic: 'Biology'),
  ];

  // simple in-memory attempts store
  static final List<Map<String, dynamic>> _attempts = [];

  Future<List<Question>> fetchQuestions({int limit = 10}) async {
    // Simulate latency
    await Future.delayed(Duration(milliseconds: 300));
    return _sampleQuestions.take(limit).toList();
  }

  Future<Map<String, dynamic>> submitAttempt(int questionId, String selected) async {
    await Future.delayed(Duration(milliseconds: 150));
    final q = _sampleQuestions.firstWhere((q) => q.id == questionId);
    final correct = q.answer == selected;
    final attempt = {'question_id': questionId, 'selected': selected, 'correct': correct, 'timestamp': DateTime.now().toIso8601String()};
    _attempts.add(attempt);

    // Simple mock explanation
    final explanation = correct ? 'Correct: ${q.answer} is the right answer.' : 'Incorrect. The correct answer is ${q.answer}.';
    return {'correct': correct, 'explanation': explanation};
  }

  Future<Map<String, dynamic>> stats() async {
    await Future.delayed(Duration(milliseconds: 100));
    final total = _attempts.length;
    final correct = _attempts.where((a) => a['correct'] == true).length;
    // topic wise
    final topicMap = <String, int>{};
    for (var a in _attempts) {
      final q = _sampleQuestions.firstWhere((q) => q.id == a['question_id']);
      topicMap[q.topic] = (topicMap[q.topic] ?? 0) + (a['correct'] ? 1 : 0);
    }
    return {'total': total, 'correct': correct, 'topicCorrect': topicMap};
  }
}
