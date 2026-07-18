import 'dart:convert';
import 'package:drift/drift.dart' as drift;

import '../local_db/app_database.dart';
import '../models/approval_model.dart';
import '../sync/mutation_queue.dart';

/// Admin review of customer profile-change requests.
class ApprovalService {
  ApprovalService._();
  static final ApprovalService instance = ApprovalService._();

  Stream<List<ApprovalModel>> pendingStream() {
    final db = AppDatabase.instance;
    return (db.select(db.approvals)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map((r) {
              final changes = r.changesJson.isNotEmpty ? jsonDecode(r.changesJson) as Map<String, dynamic> : <String, dynamic>{};
              return ApprovalModel(
                id: r.id,
                userId: r.userId,
                userName: r.userName,
                type: r.type,
                changes: changes.map((k, v) => MapEntry(k, v.toString())),
                status: r.status,
                createdAt: r.createdAt,
              );
            }).toList());
  }

  /// Applies the change to the user and marks the request approved.
  Future<void> approve(ApprovalModel a) async {
    final db = AppDatabase.instance;
    await (db.update(db.approvals)..where((t) => t.id.equals(a.id))).write(const ApprovalsCompanion(
      status: drift.Value('approved'),
    ));

    await MutationQueue.instance.run(
      entityType: 'approval',
      method: 'POST',
      path: '/v1/admin/approvals/${a.id}/approve',
    );
  }

  Future<void> reject(String id) async {
    final db = AppDatabase.instance;
    await (db.update(db.approvals)..where((t) => t.id.equals(id))).write(const ApprovalsCompanion(
      status: drift.Value('rejected'),
    ));

    await MutationQueue.instance.run(
      entityType: 'approval',
      method: 'POST',
      path: '/v1/admin/approvals/$id/reject',
    );
  }
}
