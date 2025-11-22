typedef TokenProvider = Future<String?> Function();

class TokenManager {
  /// Optional global TokenProvider. Set this once during app startup to allow
  /// ApiClient to pick up access tokens without needing DI everywhere.
  static TokenProvider? tokenProvider;
}
