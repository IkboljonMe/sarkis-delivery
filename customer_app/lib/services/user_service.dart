import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_model.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('users');

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _col.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  Future<void> saveUser(UserModel user) async {
    try {
      await _col.doc(user.id).set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  Future<void> updateFields(String uid, Map<String, dynamic> data) async {
    try {
      await _col.doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _col.doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Uploads a profile photo to Storage and returns its download URL.
  Future<String> uploadAvatar(String uid, Uint8List bytes) async {
    final ref = FirebaseStorage.instance.ref().child('avatars/$uid/avatar.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<bool> isAdmin(String uid) async {
    final user = await getUser(uid);
    return user?.isAdmin ?? false;
  }

  /// All users (admin only).
  Stream<List<UserModel>> usersStream() {
    return _col.snapshots().map((s) => s.docs
        .map((d) => UserModel.fromJson({...d.data(), 'id': d.id}))
        .toList());
  }
}
