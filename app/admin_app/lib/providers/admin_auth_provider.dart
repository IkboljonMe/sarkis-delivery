import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../local_db/app_database.dart';
import '../services/auth_service.dart';
import '../services/push_service.dart';
import '../sync/sync_engine.dart';

class AdminAuthProvider extends ChangeNotifier with WidgetsBindingObserver {
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
  String? get uid => _auth.uid;

  Future<void> loadPreferences() async {
    WidgetsBinding.instance.addObserver(this);
    try {
      final prefs = await SharedPreferences.getInstance();
      _rememberMe = prefs.getBool(_rememberKey) ?? true;
      _savedEmail = prefs.getString(_emailKey) ?? '';
      notifyListeners();
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _auth.isLoggedIn) {
      SyncEngine.instance.fullSync().catchError((_) {});
      SyncEngine.instance.start();
    } else if (state == AppLifecycleState.paused) {
      SyncEngine.instance.stop().catchError((_) {});
    }
  }

  void setRememberMe(bool v) {
    _rememberMe = v;
    notifyListeners();
  }

  /// Returns true on successful admin login (also verifies isAdmin flag).
  Future<bool> login(String email, String password) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final session = await _auth.signInWithEmail(email: email, password: password);
      final role =
          ((session['user'] as Map?)?['role'] as String?) ?? 'CUSTOMER';
      // Staff app: drivers, admins and the superadmin may log in.
      final admin = role != 'CUSTOMER';
      if (!admin) {
        await _auth.signOut();
        _error = 'Доступ запрещён / Not an admin account';
        _busy = false;
        notifyListeners();
        return false;
      }
      await _persist(email);
      _busy = false;
      notifyListeners();
      
      SyncEngine.instance.fullSync().catchError((_) {});
      SyncEngine.instance.start();
      PushService.instance.register(); // background/closed-app push

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _busy = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _persist(String email) async {
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
    await SyncEngine.instance.stop();
    await AppDatabase.instance.wipeAll();
    await _auth.signOut();
    notifyListeners();
  }
}
