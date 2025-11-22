import 'api_factory.dart';
import 'auth_service.dart';
import 'secure_storage_service.dart';

class AuthRepository {
  final AuthService _service;
  final SecureStorageService _secure;

  AuthRepository()
      : _service = AuthService(ApiFactory.getClient()),
        _secure = SecureStorageService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _service.login(email, password);
    return res;
  }

  Future<Map<String, dynamic>> register(String email, String password, {String? name}) async {
    final res = await _service.register(email: email, password: password, name: name);
    return res;
  }

  Future<Map<String, dynamic>> refresh() async {
    final res = await _service.refresh();
    return res;
  }

  Future<void> logout() async {
    // Call backend logout to revoke refresh token
    try {
      await ApiFactory.getClient().post('/auth/logout');
    } catch (_) {
      // Best-effort: ignore errors
    } finally {
      // clear local refresh token
      await _secure.deleteRefreshToken();
    }
  }
}
