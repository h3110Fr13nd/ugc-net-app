import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiClient({String? baseUrl, this.defaultHeaders = const {}})
      : baseUrl = baseUrl ?? (() {
          final env = _getEnvBase();
          return env.isNotEmpty ? env : _defaultBase();
        })();

  static String _defaultBase() {
    try {
      // Use the developer LAN IP by default for Android devices (physical). This makes
      // it easier to run the app on a phone that reaches the local dev backend.
      if (Platform.isAndroid) return 'http://192.168.1.33:8000/api/v1';
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

  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    final h = {...defaultHeaders, if (headers != null) ...headers};
    try {
      return await http.get(_uri(path), headers: h).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw Exception('Connection to API timed out when calling ${_uri(path)}.\n' 
          'Ensure the backend is running and reachable from this device.\n'
          'If you are using a physical Android device, either run the app with --dart-define=API_BASE_URL="http://<host-ip>:8000/api/v1" or run `adb reverse tcp:8000 tcp:8000`.');
    }
  }

  Future<http.Response> post(String path, {Map<String, String>? headers, Object? body}) async {
    final h = {...defaultHeaders, if (headers != null) ...headers};
    try {
      return await http.post(_uri(path), headers: h, body: body).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw Exception('Connection to API timed out when calling ${_uri(path)}.\n' 
          'Ensure the backend is running and reachable from this device.\n'
          'If you are using a physical Android device, either run the app with --dart-define=API_BASE_URL="http://<host-ip>:8000/api/v1" or run `adb reverse tcp:8000 tcp:8000`.');
    }
  }

  Future<http.Response> patch(String path, {Map<String, String>? headers, Object? body}) async {
    final h = {...defaultHeaders, if (headers != null) ...headers};
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
