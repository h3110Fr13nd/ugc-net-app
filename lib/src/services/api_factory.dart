import 'api_client.dart';
import 'token_manager.dart';
import 'package:http/http.dart' as http;
import 'package:net_api/api.dart' as api;

class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      final provider = TokenManager.tokenProvider;
      // print('[AuthenticatedHttpClient] TokenProvider exists: ${provider != null}');
      if (provider != null) {
        final token = await provider();
        // print('[AuthenticatedHttpClient] Token retrieved: ${token != null ? "YES (${token.substring(0, 20)}...)" : "NO"}');
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
          // print('[AuthenticatedHttpClient] Authorization header set');
        }
      }
    } catch (e) {
      print('[AuthenticatedHttpClient] Error getting token: $e');
    }
    return _inner.send(request);
  }
}

/// Simple ApiFactory that creates and returns shared API clients.
class ApiFactory {
  static ApiClient? _client;
  static api.ApiClient? _apiClient;

  static ApiClient getClient({String? baseUrl}) {
    if (_client != null) return _client!;
    _client = ApiClient(baseUrl: baseUrl, tokenProvider: TokenManager.tokenProvider);
    return _client!;
  }

  /// Replace the shared lightweight client (useful for tests)
  static void setClient(ApiClient client) {
    _client = client;
  }

  static api.ApiClient getApiClient({String? baseUrl}) {
    if (_apiClient != null) return _apiClient!;

    // Resolve base URL
    final client = getClient();
    var resolvedBase = baseUrl ?? client.baseUrl;
    if (resolvedBase.endsWith('/api/v1')) {
      resolvedBase = resolvedBase.substring(0, resolvedBase.length - '/api/v1'.length);
    }
    // Generated client expects base path without /api/v1? 
    // Wait, generated client usually appends path. 
    // If generated client basePath defaults to http://localhost, it might NOT include /api/v1.
    // But my endpoints in openapi.json start with /api/v1.
    // So basePath should be just the host.
    
    // However, the previous code stripped /api/v1.
    // Let's assume basePath should be just host:port.
    
    _apiClient = api.ApiClient(basePath: resolvedBase);
    _apiClient!.client = AuthenticatedHttpClient();
    return _apiClient!;
  }

  static api.QuestionsApi getQuestionsApi() {
    return api.QuestionsApi(getApiClient());
  }

  static api.StatsApi getStatsApi() {
    return api.StatsApi(getApiClient());
  }
  
  static api.AttemptsApi getAttemptsApi() {
    return api.AttemptsApi(getApiClient());
  }
  
  static api.TaxonomyApi getTaxonomyApi() {
    return api.TaxonomyApi(getApiClient());
  }
}
