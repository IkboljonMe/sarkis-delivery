import 'package:cloud_firestore/cloud_firestore.dart';

/// Customer-facing approvals: profile changes (name / phone) require admin
/// review before they are applied to the user document.
class ApprovalService {
  ApprovalService._();
  static final ApprovalService instance = ApprovalService._();

  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('approvals');

  /// Files a profile-change request for the admin to approve.
  Future<void> requestProfileChange({
    required String userId,
    required String userName,
    required Map<String, dynamic> changes,
  }) async {
    final ref = _col.doc();
    await ref.set({
      'id': ref.id,
      'type': 'profile',
      'userId': userId,
      'userName': userName,
      'changes': changes,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
