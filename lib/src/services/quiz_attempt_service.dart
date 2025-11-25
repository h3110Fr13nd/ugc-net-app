import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_manager.dart';

/// Models for quiz attempt API
class CreateQuizAttemptRequest {
  final String? quizId;  // Optional - can be null for standalone attempts
  final String userId;
  final String? quizVersionId;

  CreateQuizAttemptRequest({
    this.quizId,
    required this.userId,
    this.quizVersionId,
  });

  Map<String, dynamic> toJson() => {
    if (quizId != null) 'quiz_id': quizId,
    'user_id': userId,
    if (quizVersionId != null) 'quiz_version_id': quizVersionId,
  };
}

class CreateQuizAttemptResponse {
  final String id;
  final String? quizId;  // Optional - null for standalone attempts
  final String userId;
  final String status;

  CreateQuizAttemptResponse({
    required this.id,
    this.quizId,
    required this.userId,
    required this.status,
  });

  factory CreateQuizAttemptResponse.fromJson(Map<String, dynamic> json) {
    return CreateQuizAttemptResponse(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String?,
      userId: json['user_id'] as String,
      status: json['status'] as String,
    );
  }
}

/// Service for managing quiz attempts (REST API)
class QuizAttemptService {
  static final QuizAttemptService _instance = QuizAttemptService._internal();

  factory QuizAttemptService() => _instance;

  QuizAttemptService._internal();

  /// Create a new quiz attempt
  /// 
  /// Must be called before connecting to WebSocket for answering questions.
  /// Returns the attempt ID to use in WebSocket URL.
  /// 
  /// [quizId] can be null for standalone attempts (e.g., random questions)
  Future<CreateQuizAttemptResponse> createAttempt({
    String? quizId,  // Optional - null for standalone/random question attempts
    required String userId,
    String? quizVersionId,
  }) async {
    final request = CreateQuizAttemptRequest(
      quizId: quizId,
      userId: userId,
      quizVersionId: quizVersionId,
    );

    final url = Uri.parse('${AppConfig.apiBaseUrl}/quiz-attempts');
    
    try {
      // Get auth token via tokenProvider
      String? token;
      if (TokenManager.tokenProvider != null) {
        token = await TokenManager.tokenProvider!();
      }
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final mode = quizId != null ? 'quiz' : 'standalone';
      print('Creating $mode attempt for user=$userId');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(request.toJson()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('Create attempt response status: ${response.statusCode}');
      print('Create attempt response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final result = CreateQuizAttemptResponse.fromJson(json);
        print('✓ Quiz attempt created: ${result.id}');
        return result;
      } else if (response.statusCode == 422) {
        // Validation error
        throw Exception('Invalid request: ${response.body}');
      } else {
        throw Exception(
          'Failed to create quiz attempt: ${response.statusCode} ${response.body}'
        );
      }
    } catch (e) {
      print('✗ Error creating quiz attempt: $e');
      rethrow;
    }
  }
}
