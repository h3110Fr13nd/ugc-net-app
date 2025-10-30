import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client;
  final GoogleSignIn _googleSignIn;
  final String? serverClientId;

  /// AuthService optionally accepts a [serverClientId]. On Android this
  /// should be the Web OAuth client ID (the one that ends with
  /// `.apps.googleusercontent.com`). Passing it into [GoogleSignIn]
  /// causes the plugin to request an ID token which your backend can
  /// verify. If you don't pass it, `googleAuth.idToken` may be null.
  AuthService([ApiClient? client, GoogleSignIn? googleSignIn, String? serverClientIdParam])
      : _client = client ?? ApiClient(),
        serverClientId = serverClientIdParam,
        _googleSignIn = googleSignIn ?? GoogleSignIn(
          scopes: ['email', 'profile'],
          // Note: On Android, you need to provide serverClientId to obtain an ID token.
          serverClientId: serverClientIdParam,
        );

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final res = await _client.post(
      '/auth/register',
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        if (name != null) 'name': name,
      }),
    );
    if (res.statusCode == 200) {
      return _client.decode(res.body);
    }
    final errorBody = json.decode(res.body) as Map<String, dynamic>?;
    return {
      'error': 'registration_failed',
      'status': res.statusCode,
      'detail': errorBody?['detail'] ?? res.body,
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _client.post(
      '/auth/login',
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      return _client.decode(res.body);
    }
    final errorBody = json.decode(res.body) as Map<String, dynamic>?;
    return {
      'error': 'login_failed',
      'status': res.statusCode,
      'detail': errorBody?['detail'] ?? res.body,
    };
  }

  /// Get the Google consent URL from backend. Frontend should open this URL (in-app WebView) and capture the redirect.
  Future<String?> getGoogleConsentUrl(String redirectUri) async {
    final encoded = Uri.encodeComponent(redirectUri);
    final urlRes = await _client.get('/auth/google/url?redirect_uri=$encoded');
    if (urlRes.statusCode != 200) return null;
    final body = json.decode(urlRes.body) as Map<String, dynamic>;
    return body['url'] as String?;
  }

  /// Exchange the authorization code for an application token (backend will perform Google exchange).
  Future<Map<String, dynamic>> exchangeGoogleCode(String code, String redirectUri) async {
    final tokenRes = await _client.post(
      '/auth/google/token',
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': code, 'redirect_uri': redirectUri}),
    );
    if (tokenRes.statusCode != 200) {
      return {
        'error': 'token_exchange_failed',
        'status': tokenRes.statusCode,
        'body': tokenRes.body
      };
    }
    final tokenBody = json.decode(tokenRes.body) as Map<String, dynamic>;
    return tokenBody;
  }

  /// Sign in with Google and exchange the ID token with the backend
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Check if Google Play Services is available (Android only)
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'error': 'sign_in_cancelled'};
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        // Provide diagnostic details to help the developer debug OAuth config.
        final accessToken = googleAuth.accessToken;
        return {
          'error': 'no_id_token',
          'message': 'ID token was not returned by Google Sign-In. On Android you must provide the Web OAuth client ID (serverClientId) when constructing GoogleSignIn so an ID token is requested.',
          'serverClientId_used': serverClientId,
          'access_token_available': accessToken != null,
          'access_token': accessToken,
          'google_user_email': googleUser.email,
          'google_user_id': googleUser.id,
        };
      }

      // Send ID token to backend for verification and session creation
      final res = await _client.post(
        '/auth/google/verify',
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id_token': idToken}),
      );

      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }

      return {
        'error': 'backend_verification_failed',
        'status': res.statusCode,
        'body': res.body
      };
    } on Exception catch (e) {
      // Handle platform-specific errors (e.g., Google Play Services not available)
      final errorMsg = e.toString();
      if (errorMsg.contains('DEVELOPER_ERROR') || errorMsg.contains('sign_in_failed')) {
        return {
          'error': 'configuration_error',
          'message': 'Google Sign-In is not properly configured. Check SHA-1 fingerprint and OAuth client setup.',
          'detail': errorMsg
        };
      }
      return {'error': 'exception', 'message': errorMsg};
    }
  }

  /// Sign out from Google
  /// Sign out from Google and optionally revoke access.
  ///
  /// On Android, calling `disconnect()` after `signOut()` revokes the
  /// previously granted consent and forces the account chooser to appear
  /// the next time `signIn()` is called. Pass `revoke=true` to force this
  /// behavior (defaults to true).
  Future<void> signOut({bool revoke = true}) async {
    try {
      await _googleSignIn.signOut();
      if (revoke) {
        // disconnect() revokes the granted permissions and should force
        // Google Play services to show the account chooser next time.
        await _googleSignIn.disconnect();
      }
    } catch (e) {
      // Don't crash the app on sign-out issues; log for debugging.
      // Callers may also clear local app state (tokens) after this.
      // Example: debugPrint('AuthService.signOut failed: $e');
      // Keep method return type void for existing callers.
      // Ignore errors here; they are usually non-fatal platform channel issues.
      // Use print so the message appears in logcat / console.
      print('AuthService.signOut error: $e');
    }
  }
}