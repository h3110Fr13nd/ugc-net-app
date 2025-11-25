import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/auth_service.dart';

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  // Theme: default dark
  bool _darkMode = true;

  // Auth state
  String? _accessToken;
  Map<String, dynamic>? _user;

  bool get darkMode => _darkMode;

  String? get accessToken => _accessToken;

  Map<String, dynamic>? get user => _user;

  bool get isSignedIn => _accessToken != null;

  void toggleTheme() {
    _darkMode = !_darkMode;
    _savePrefs();
    notifyListeners();
  }

  MyAppState() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? true;
    _accessToken = prefs.getString('app_token');
    final u = prefs.getString('app_user');
    if (u != null) {
      try {
        _user = json.decode(u) as Map<String, dynamic>;
      } catch (e) {
        _user = null;
      }
    }
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
  }

  Future<void> setAuth(String token, Map<String, dynamic> user) async {
    _accessToken = token;
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_token', token);
    await prefs.setString('app_user', json.encode(user));
    notifyListeners();
  }

  /// Set only the access token (used after refresh) and persist it.
  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_token', token);
    notifyListeners();
  }

  /// Try to refresh access token using AuthService and stored refresh token.
  /// Returns true if refresh succeeded and token updated.
  Future<bool> tryRefresh() async {
    try {
      const webClientId = '305527226287-a1p11gqcbdjdgcred1nt4m3mvljnf3h4.apps.googleusercontent.com';
      final auth = AuthService(null, null, webClientId);
      final res = await auth.refresh();
      if (res.containsKey('access_token')) {
        final token = res['access_token'] as String;
        await setAccessToken(token);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearAuth() async {
    _accessToken = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_token');
    await prefs.remove('app_user');
    notifyListeners();
  }

  void next() {
    current = WordPair.random();
    notifyListeners();
  }
}
