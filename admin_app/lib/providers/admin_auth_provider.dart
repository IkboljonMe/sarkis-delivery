import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

/// Manages admin email/password login and "remember me" auto-login.
class AdminAuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService.instance;

  static const _rememberKey = 'admin_remember';
  static const _emailKey = 'admin_email';

  bool _busy = false;
  String? _error;
  bool _rememberMe = true;
  String _savedEmail = '';

  bool get busy => _busy;
  String? get error => _error;
  bool get rememberMe => _rememberMe;
  String get savedEmail => _savedEmail;
  bool get isLoggedIn => _auth.isLoggedIn;

  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _rememberMe = prefs.getBool(_rememberKey) ?? true;
      _savedEmail = prefs.getString(_emailKey) ?? '';
      notifyListeners();
    } catch (_) {}
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.signIn(email: email, password: password);
      await _persistPreferences(email);
      _busy = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _busy = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _persistPreferences(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberKey, _rememberMe);
      if (_rememberMe) {
        await prefs.setString(_emailKey, email);
      } else {
        await prefs.remove(_emailKey);
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
