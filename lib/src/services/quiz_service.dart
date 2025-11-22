import 'dart:convert';
import 'api_client.dart';

import 'api_factory.dart';

class QuizService {
  final ApiClient _client;

  QuizService([ApiClient? client]) : _client = client ?? ApiFactory.getClient();

  Future<List<Map<String, dynamic>>> listQuizzes() async {
    final res = await _client.get('/quizzes');
    if (res.statusCode == 200) {
      final decoded = json.decode(res.body) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
