import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small wrapper around flutter_secure_storage for storing sensitive tokens.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  static const _refreshKey = 'refresh_token';

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshKey, value: token);
  }

  Future<String?> readRefreshToken() async {
    return await _storage.read(key: _refreshKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshKey);
  }
}
