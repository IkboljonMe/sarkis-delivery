import 'dart:typed_data';

import '../models/user_model.dart';
import 'api_client.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final ApiClient _api = ApiClient.instance;

  /// The API only exposes the caller's own profile ([uid] kept for
  /// signature compatibility).
  Future<UserModel?> getUser(String uid) async {
    final res = await _api.get('/v1/users/me');
    _api.currentUser = Map<String, dynamic>.from(res as Map);
    return UserModel.fromJson(_api.currentUser!);
  }

  /// Saves the profile fields of [user] (registration / profile edit).
  Future<void> saveUser(UserModel user) async {
    await _api.patch('/v1/users/me', {
      'name': user.name,
      'lastName': user.lastName,
      'address': user.address,
      'city': user.city,
      'postalCode': user.postalCode,
      'group': user.group,
      if (user.lat != null) 'lat': user.lat,
      if (user.lng != null) 'lng': user.lng,
      'language': user.language,
      'referredBy': user.referredBy,
    });
  }

  Future<void> updateFields(String uid, Map<String, dynamic> data) async {
    await _api.patch('/v1/users/me', data);
  }

  Future<void> updateFcmToken(String uid, String token) async {
    await _api.post('/v1/users/me/fcm-token', {'token': token});
  }

  Future<void> deleteUser(String uid) async {
    await _api.delete('/v1/users/me');
  }

  Future<String> uploadAvatar(String uid, Uint8List bytes) async {
    return _api.uploadBytes('/v1/users/me/avatar', bytes,
        filename: 'avatar.jpg', field: 'file');
  }

  Future<bool> isAdmin(String uid) async =>
      (_api.currentUser?['isAdmin'] as bool?) ?? false;
}
