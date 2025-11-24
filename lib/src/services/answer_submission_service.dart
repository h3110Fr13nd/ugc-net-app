import '../services/websocket_service.dart';

/// Reusable service for submitting answers and getting LLM explanations
class AnswerSubmissionService {
  /// Submit an answer and get a WebSocketService for streaming explanations
  /// 
  /// [attemptId] - The quiz attempt ID (use placeholder for practice mode)
  /// [questionId] - The question ID
  /// [answer] - The user's answer (text or selected options)
  static Future<WebSocketService> submitAnswer({
    required String attemptId,
    required String questionId,
    required dynamic answer,
  }) async {
    final wsService = WebSocketService();
    
    // Connect to WebSocket
    await wsService.connect(attemptId, questionId);
    
    // Send answer
    // Format answer based on type
    final payload = {
      "parts": [
        {
          "text_response": answer is List
              ? answer.join(", ")
              : answer.toString()
        }
      ],
      "attempt_index": 1
    };
    
    wsService.sendAnswer(payload);
    
    return wsService;
  }
}
