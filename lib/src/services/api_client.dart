import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'token_manager.dart';

/// Optional token provider signature. Return current access token or null.
typedef TokenProvider = Future<String?> Function();

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final TokenProvider? tokenProvider;

  /// [tokenProvider] if provided will be called for each request to obtain
  /// the current access token to put into the `Authorization: Bearer ...` header.
  ApiClient({String? baseUrl, this.defaultHeaders = const {}, this.tokenProvider})
      : baseUrl = baseUrl ?? (() {
          final env = _getEnvBase();
          return env.isNotEmpty ? env : _defaultBase();
        })();

  static String _defaultBase() {
    try {
      // Use the developer LAN IP by default for Android devices (physical). This makes
      // it easier to run the app on a phone that reaches the local dev backend.
      if (Platform.isAndroid) return 'http://192.168.1.26:8000/api/v1';
    } catch (_) {}
    return 'http://localhost:8000/api/v1';
  }

  // Allow overriding the API base URL at compile time with --dart-define=API_BASE_URL=...
  // Also attempt to read a runtime environment variable when available.
  static const String _envBase = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String _getEnvBase() {
    if (_envBase.isNotEmpty) return _envBase;
    try {
      final runtime = Platform.environment['API_BASE_URL'];
      if (runtime != null && runtime.isNotEmpty) return runtime;
    } catch (_) {}
    return '';
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, String>> _buildHeaders([Map<String, String>? headers]) async {
    final Map<String, String> h = {...defaultHeaders, if (headers != null) ...headers};
    if (tokenProvider != null) {
      try {
        final token = await tokenProvider!();
        if (token != null && token.isNotEmpty) {
          h['Authorization'] = 'Bearer $token';
        }
      } catch (_) {
        // ignore token provider errors and proceed without Authorization header
      }
    } else {
      // Try global TokenManager if available to avoid changing all call sites.
      try {
        // Import here to avoid circular import at top-level.
        final tm = await _tryGetGlobalToken();
        if (tm != null && tm.isNotEmpty) {
          h['Authorization'] = 'Bearer $tm';
        }
      } catch (_) {}
    }
    return h;
  }

  // Helper to access TokenManager.tokenProvider without a static import at top
  Future<String?> _tryGetGlobalToken() async {
    try {
      // Lazy import pattern: import the token_manager file dynamically isn't supported,
      // but TokenManager is in the same package; import it normally.
      // Since the file is small and dependency-safe, we can import it.
      // However, Dart doesn't support dynamic imports here; instead rely on a compile-time import.
      // To keep this simple, attempt to reference TokenManager (it will be available).
      return await TokenManager.tokenProvider?.call();
    } catch (_) {
      return null;
    }
  }

  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    final h = await _buildHeaders(headers);
    try {
      return await http.get(_uri(path), headers: h).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw Exception('Connection to API timed out when calling ${_uri(path)}.\n' 
          'Ensure the backend is running and reachable from this device.\n'
          'If you are using a physical Android device, either run the app with --dart-define=API_BASE_URL="http://<host-ip>:8000/api/v1" or run `adb reverse tcp:8000 tcp:8000`.');
    }
  }

  Future<http.Response> post(String path, {Map<String, String>? headers, Object? body}) async {
    final h = await _buildHeaders(headers);
    try {
      return await http.post(_uri(path), headers: h, body: body).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      print('❌ ApiClient: Timeout calling ${_uri(path)}');
      throw Exception('Connection to API timed out when calling ${_uri(path)}.\n' 
          'Ensure the backend is running and reachable from this device.\n'
          'If you are using a physical Android device, either run the app with --dart-define=API_BASE_URL="http://<host-ip>:8000/api/v1" or run `adb reverse tcp:8000 tcp:8000`.');
    } catch (e) {
      print('❌ ApiClient: Error calling ${_uri(path)}: $e');
      rethrow;
    }
  }

  Future<http.Response> patch(String path, {Map<String, String>? headers, Object? body}) async {
    final h = await _buildHeaders(headers);
    try {
      return await http.patch(_uri(path), headers: h, body: body).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw Exception('Connection to API timed out when calling ${_uri(path)}.\n' 
          'Ensure the backend is running and reachable from this device.\n'
          'If you are using a physical Android device, either run the app with --dart-define=API_BASE_URL="http://<host-ip>:8000/api/v1" or run `adb reverse tcp:8000 tcp:8000`.');
    }
  }

  Map<String, dynamic> decode(String body) => json.decode(body) as Map<String, dynamic>;
}
