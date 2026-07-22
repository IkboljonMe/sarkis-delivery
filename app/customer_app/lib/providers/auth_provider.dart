import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../local_db/app_database.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/message_service.dart';
import '../services/push_service.dart';
import '../services/region_group_service.dart';
import '../services/user_service.dart';
import '../sync/sync_engine.dart';
import '../utils/welcome_message.dart';

enum AuthStatus { unknown, codeSent, authenticated, error }

/// Profile details collected during the 3-step registration BEFORE the phone
/// is verified. Saved once phone verification yields a session.
class RegistrationDraft {
  String name = '';
  String lastName = '';
  String referredBy = '';
  String address = '';
  String city = '';
  String postalCode = '';
  String group = '';
  double? lat;
  double? lng;
  String language = 'en';
}

class AuthProvider extends ChangeNotifier with WidgetsBindingObserver {
  final AuthService _auth = AuthService.instance;
  final UserService _users = UserService.instance;

  UserModel? _user;
  String? _pendingPhone; // phone currently going through OTP
  AuthStatus _status = AuthStatus.unknown;
  String? _error;
  bool _busy = false;
  bool _isNewUser = false;

  // 'login' or 'register' — set before opening the phone screen so the OTP
  // screen knows what to do on success.
  String authMode = 'login';
  // Pending profile during a registration (phone verified last).
  RegistrationDraft? draft;

  AuthProvider() {
    _loadDraft();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _auth.isLoggedIn && _auth.uid != null) {
      SyncEngine.instance.fullSync(_auth.uid!).catchError((_) {});
      SyncEngine.instance.start(_auth.uid!);
    } else if (state == AppLifecycleState.paused) {
      SyncEngine.instance.stop().catchError((_) {});
    }
  }

  Future<void> _loadDraft() async {
    final row = await (AppDatabase.instance.select(AppDatabase.instance.registrationDrafts)..where((t) => t.id.equals('draft'))).getSingleOrNull();
    if (row != null) {
      draft = RegistrationDraft()
        ..name = row.name
        ..lastName = row.lastName
        ..referredBy = row.referredBy
        ..address = row.address
        ..city = row.city
        ..postalCode = row.postalCode
        ..group = row.groupName
        ..lat = row.lat
        ..lng = row.lng
        ..language = row.language;
    }
  }

  Future<void> saveDraft(RegistrationDraft d) async {
    draft = d;
    await AppDatabase.instance.into(AppDatabase.instance.registrationDrafts).insertOnConflictUpdate(
      RegistrationDraftsCompanion.insert(
        id: const Value('draft'),
        name: Value(d.name),
        lastName: Value(d.lastName),
        referredBy: Value(d.referredBy),
        address: Value(d.address),
        city: Value(d.city),
        postalCode: Value(d.postalCode),
        groupName: Value(d.group),
        lat: Value(d.lat),
        lng: Value(d.lng),
        language: Value(d.language),
      ),
    );
  }

  Future<void> clearDraft() async {
    draft = null;
    await (AppDatabase.instance.delete(AppDatabase.instance.registrationDrafts)..where((t) => t.id.equals('draft'))).go();
  }

  UserModel? get user => _user;

  /// The phone number the current OTP was sent to (kept under the old name
  /// for compatibility with the OTP screen).
  String? get verificationId => _pendingPhone;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get busy => _busy;
  bool get isLoggedIn => _auth.isLoggedIn;
  String? get uid => _auth.uid;
  String? get phone => _auth.phone ?? _pendingPhone;
  bool get isNewUser => _isNewUser;

  void _setBusy(bool v) {
    _busy = v;
    notifyListeners();
  }

  Future<UserModel?> loadCurrentUser() async {
    if (!_auth.isLoggedIn) return null;
    try {
      await SyncEngine.instance.syncProfile();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        // Session is genuinely dead — no local fallback.
        _user = null;
        notifyListeners();
        return null;
      }
      // Offline / server hiccup: fall through and serve the cached profile.
    } catch (_) {
      // Same: prefer the local cache over failing the whole session.
    }
    try {
      final row = await (AppDatabase.instance.select(AppDatabase.instance.localUser)..where((t) => t.id.equals(_auth.uid ?? ''))).getSingleOrNull();
      if (row != null) {
        _user = UserModel(
          id: row.id,
          name: row.name,
          lastName: row.lastName,
          phone: row.phone,
          address: row.address,
          city: row.city,
          postalCode: row.postalCode,
          group: row.group,
          lat: row.lat,
          lng: row.lng,
          language: row.language,
          isAdmin: false,
          referredBy: '',
        );
      } else {
        _user = null;
      }
      // A profile without a name has not completed registration yet — callers
      // treat a null user as "needs registration".
      if (_user != null && _user!.name.trim().isEmpty) {
        _user = null;
      }
      notifyListeners();
      return _user;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Requests the OTP SMS for [phoneNumber]. Completes when the code has been
  /// sent (status → codeSent) or on failure (status → error).
  Future<bool> startPhoneVerification(String phoneNumber) async {
    _setBusy(true);
    _error = null;
    _status = AuthStatus.unknown;
    try {
      final devCode = await _auth.requestOtp(phoneNumber);
      _pendingPhone = phoneNumber;
      _status = AuthStatus.codeSent;
      if (devCode != null) {
        debugPrint('[DEV] OTP for $phoneNumber: $devCode');
      }
      _setBusy(false);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _status = AuthStatus.error;
      _setBusy(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
      _setBusy(false);
      return false;
    }
  }

  Future<bool> verifyOtp(String smsCode) async {
    final phoneNumber = _pendingPhone;
    if (phoneNumber == null) return false;
    _setBusy(true);
    _error = null;
    try {
      final res = await _auth.verifyOtp(phoneNumber, smsCode);
      _isNewUser = res['isNewUser'] == true;
      _status = AuthStatus.authenticated;
      
      final uid = _auth.uid;
      if (uid != null) {
        // Seed the local cache in the background — a slow or partially
        // failing sync must not make a successful login look failed.
        SyncEngine.instance.fullSync(uid).catchError((_) {});
        SyncEngine.instance.start(uid);
        PushService.instance.register(); // background/closed-app push
      }

      await loadCurrentUser();
      _setBusy(false);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _status = AuthStatus.error;
      _setBusy(false);
      return false;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.error;
      _setBusy(false);
      return false;
    }
  }

  Future<bool> saveProfile({
    required String name,
    String lastName = '',
    required String address,
    required String city,
    required String postalCode,
    required String group,
    double? lat,
    double? lng,
    required String language,
    String referredBy = '',
  }) async {
    final id = _auth.uid;
    if (id == null) return false;
    _setBusy(true);
    try {
      final user = UserModel(
        id: id,
        name: name,
        lastName: lastName,
        phone: _auth.phone ?? '',
        address: address,
        city: city,
        postalCode: postalCode,
        group: group,
        lat: lat,
        lng: lng,
        language: language,
        isAdmin: false,
        referredBy: referredBy,
      );
      await _users.saveUser(user);
      _user = user;
      // Greet the new customer with an automated admin message in their language.
      await MessageService.instance.sendWelcomeIfNew(
        topicId: id,
        userName: user.fullName.isEmpty ? user.name : user.fullName,
        userGroup: group,
        text: WelcomeMessage.forLang(language),
        senderName: WelcomeMessage.senderName,
      );
      _setBusy(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setBusy(false);
      return false;
    }
  }

  /// Saves the collected [draft] once the phone is verified. The delivery
  /// group is resolved from the geocoded point; empty means out of coverage.
  Future<bool> completeRegistration() async {
    final d = draft;
    if (d == null) return false;
    var group = d.group;
    if (group.isEmpty && d.lat != null && d.lng != null) {
      try {
        group = await RegionGroupService.instance
                .resolveGroupName(d.lat!, d.lng!) ??
            '';
      } catch (_) {
        group = '';
      }
    }
    final ok = await saveProfile(
      name: d.name,
      lastName: d.lastName,
      address: d.address,
      city: d.city,
      postalCode: d.postalCode,
      group: group,
      lat: d.lat,
      lng: d.lng,
      language: d.language,
      referredBy: d.referredBy,
    );
    if (ok) await clearDraft();
    return ok;
  }

  Future<void> updateFields(Map<String, dynamic> data) async {
    final id = _auth.uid;
    if (id == null) return;
    try {
      await _users.updateFields(id, data);
      await loadCurrentUser();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await SyncEngine.instance.stop();
    await AppDatabase.instance.wipeAll();
    
    _user = null;
    _pendingPhone = null;
    _status = AuthStatus.unknown;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    try {
      await _auth.deleteCurrentUser();
    } catch (e) {
      debugPrint('deleteAccount: $e');
      await _auth.signOut();
    }
    await SyncEngine.instance.stop();
    await AppDatabase.instance.wipeAll();

    _user = null;
    _pendingPhone = null;
    _status = AuthStatus.unknown;
    notifyListeners();
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }

  // Helper to build E.164 number, leaving all-zero test numbers intact.
  static String buildE164(String countryCode, String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final hasNonZero = digits.replaceAll('0', '').isNotEmpty;
    final trimmed =
        (digits.startsWith('0') && hasNonZero) ? digits.substring(1) : digits;
    return '$countryCode$trimmed';
  }
}
