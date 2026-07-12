import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/approval_model.dart';

/// Admin-side approvals: review and apply customer profile-change requests.
class ApprovalService {
  ApprovalService._();
  static final ApprovalService instance = ApprovalService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('approvals');

  /// Pending requests, newest first (sorted client-side to avoid an index).
  Stream<List<ApprovalModel>> pendingStream() {
    return _col.where('status', isEqualTo: 'pending').snapshots().map((s) {
      final list = s.docs
          .map((d) => ApprovalModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      list.sort((a, b) => (b.createdAt ?? DateTime(1970))
          .compareTo(a.createdAt ?? DateTime(1970)));
      return list;
    });
  }

  /// Applies the requested changes to the user, then marks it approved.
  Future<void> approve(ApprovalModel a) async {
    if (a.type == 'profile' && a.changes.isNotEmpty) {
      await _db
          .collection('users')
          .doc(a.userId)
          .set(a.changes, SetOptions(merge: true));
    }
    await _col.doc(a.id).update({'status': 'approved'});
  }

  Future<void> reject(String id) async {
    await _col.doc(id).update({'status': 'rejected'});
  }
}
