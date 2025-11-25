import '../services/websocket_service.dart';
import '../services/quiz_attempt_service.dart';
import 'package:flutter/foundation.dart';

/// Reusable service for submitting answers and getting LLM explanations
class AnswerSubmissionService {
  /// Create a quiz attempt before answering questions
  /// 
  /// Must be called once at the start of a quiz session.
  /// Returns the attempt ID to use for all subsequent answers.
  /// 
  /// [quizId] can be null for standalone attempts (e.g., random questions)
  static Future<String> createAttempt({
    String? quizId,  // Optional - null for standalone/random attempts
    required String userId,
    String? quizVersionId,
  }) async {
    final service = QuizAttemptService();
    try {
      final response = await service.createAttempt(
        quizId: quizId,
        userId: userId,
        quizVersionId: quizVersionId,
      );
      debugPrint('✓ Quiz attempt created: ${response.id}');
      return response.id;
    } catch (e) {
      debugPrint('✗ Failed to create quiz attempt: $e');
      rethrow;
    }
  }

  /// Submit an answer and get a WebSocketService for streaming explanations
  /// 
  /// [attemptId] - The quiz attempt ID (from createAttempt())
  /// [questionId] - The question ID
  /// [userId] - The user ID (for statistics tracking)
  /// [answer] - The user's answer (text or selected options)
  /// [attemptIndex] - Which attempt this is (default 1 for first try)
  static Future<WebSocketService> submitAnswer({
    required String attemptId,
    required String questionId,
    required String userId,
    required dynamic answer,
    int attemptIndex = 1,
  }) async {
    final wsService = WebSocketService();
    
    // Connect to WebSocket
    await wsService.connect(attemptId, questionId);
    
    // Send answer with user_id for statistics tracking
    final payload = {
      "parts": [
        {
          "text_response": answer is List
              ? answer.join(", ")
              : answer.toString(),
          "selected_option_ids": null,
          "numeric_response": null,
          "file_media_id": null,
          "raw_response": null,
        }
      ],
      "attempt_index": attemptIndex,
      "user_id": userId,  // ← NEW: Include user_id for stats
    };
    
    wsService.sendAnswer(payload);
    
    return wsService;
  }
}
