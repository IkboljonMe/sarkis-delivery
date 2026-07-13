import '../models/user_model.dart';
import 'api_client.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final ApiClient _api = ApiClient.instance;

  /// Own profile for the logged-in staff member, customer profiles otherwise.
  Future<UserModel?> getUser(String uid) async {
    final self = uid.isEmpty || uid == _api.uid;
    final res = await _api.get(self ? '/v1/users/me' : '/v1/admin/users/$uid');
    if (self) _api.currentUser = Map<String, dynamic>.from(res as Map);
    return UserModel.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// Admin-side edit of a customer profile.
  Future<void> saveUser(UserModel user) async {
    await _api.patch('/v1/admin/users/${user.id}', {
      'name': user.name,
      'lastName': user.lastName,
      'address': user.address,
      'city': user.city,
      'postalCode': user.postalCode,
      'group': user.group,
      if (user.lat != null) 'lat': user.lat,
      if (user.lng != null) 'lng': user.lng,
      'language': user.language,
      'isVerified': user.isVerified,
    });
  }

  Future<void> updateFields(String uid, Map<String, dynamic> data) async {
    if (uid == _api.uid) {
      await _api.patch('/v1/users/me', data);
    } else {
      await _api.patch('/v1/admin/users/$uid', data);
    }
  }

  Future<void> updateFcmToken(String uid, String token) async {
    await _api.post('/v1/users/me/fcm-token', {'token': token});
  }

  Future<bool> isAdmin(String uid) async {
    final res = await _api.get('/v1/auth/me');
    _api.currentUser = Map<String, dynamic>.from(res as Map);
    final role = _api.currentUser?['role'] as String? ?? 'CUSTOMER';
    // The staff app is for drivers, admins and the superadmin.
    return role != 'CUSTOMER';
  }

  /// All customers (admin lists). Polls the API.
  Stream<List<UserModel>> usersStream() =>
      ApiClient.poll(const Duration(seconds: 20), () async {
        final res = await _api.get('/v1/admin/users');
        return (res as List)
            .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      });
}
