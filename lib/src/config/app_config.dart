/// Runtime configuration for API endpoints
class AppConfig {
  /// Get the API base URL from compile-time environment variable
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.29:8000/api/v1',
  );

  /// Get WebSocket base URL derived from API base URL
  static String get wsBaseUrl {
    return apiBaseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://')
        .replaceFirst('/api/v1', ''); // Remove /api/v1 suffix
  }

  /// Get full WebSocket URL for quiz attempts
  static String getWsUrl(String attemptId, String questionId) {
    return '$wsBaseUrl/api/v1/ws/quiz-attempts/$attemptId/question/$questionId/stream-answer';
  }
}
