import 'api_client.dart';
import 'token_manager.dart';
import 'package:dio/dio.dart';
import 'package:net_api/net_api.dart' as api;


/// Simple ApiFactory that creates and returns shared API clients.
///
/// - `getClient()` returns the existing lightweight `ApiClient` (http package)
///   for code that still uses it.
/// - `getNetApi()` returns the generated `NetApi` (dart-dio + generated APIs)
///   wired with a request interceptor that injects the access token from
///   `TokenManager.tokenProvider` when available.
class ApiFactory {
  static ApiClient? _client;
  static api.NetApi? _netApi;

  static ApiClient getClient({String? baseUrl}) {
    if (_client != null) return _client!;
    _client = ApiClient(baseUrl: baseUrl, tokenProvider: TokenManager.tokenProvider);
    return _client!;
  }

  /// Replace the shared lightweight client (useful for tests)
  static void setClient(ApiClient client) {
    _client = client;
  }

  /// Return a generated `NetApi` instance (dart-dio). This is wired with
  /// an interceptor that injects `Authorization: Bearer <token>` using the
  /// global `TokenManager.tokenProvider` when available. Optionally pass
  /// `baseUrl` to override the default (e.g. http://localhost:8000).
  static api.NetApi getNetApi({String? baseUrl}) {
    if (_netApi != null) return _netApi!;

    // Interceptor to attach Authorization header from TokenManager
    final authInterceptor = InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final provider = TokenManager.tokenProvider;
          if (provider != null) {
            final token = await provider();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
        } catch (_) {}
        handler.next(options);
      },
    );

    // Resolve base URL using the same logic as ApiClient so that both the
    // lightweight http client and the generated Dio client point to the
    // same backend. This lets --dart-define=API_BASE_URL and the
    // repository `.env` (via the run script) control both clients.
    final client = getClient();
    var resolvedBase = baseUrl ?? client.baseUrl;
    if (resolvedBase.endsWith('/api/v1')) {
      resolvedBase = resolvedBase.substring(0, resolvedBase.length - '/api/v1'.length);
    }

    final dio = Dio(BaseOptions(
      baseUrl: resolvedBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    _netApi = api.NetApi(
      dio: dio,
      interceptors: [authInterceptor],
    );
    return _netApi!;
  }

  /// Replace the shared generated client (useful for tests)
  static void setNetApi(api.NetApi api) {
    _netApi = api;
  }
}
