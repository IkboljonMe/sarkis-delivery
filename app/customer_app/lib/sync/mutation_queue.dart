import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';

import '../local_db/app_database.dart';
import '../services/api_client.dart';

/// Offline-sensitive write path: place order, send message, update profile,
/// etc. all go through [run] instead of calling [ApiClient] directly.
///
/// On success the caller's own upsert (via SyncEngine) reconciles the local
/// optimistic row. On a connectivity failure the mutation is queued and
/// retried FIFO as soon as connectivity returns — the caller is expected to
/// have already written an optimistic local row (e.g. an `Orders` row with
/// `pendingSync=true`) so the UI reflects the action immediately either way.
class MutationQueue {
  MutationQueue._(this._db, this._api);
  static final MutationQueue instance = MutationQueue._(AppDatabase.instance, ApiClient.instance);

  final AppDatabase _db;
  final ApiClient _api;
  StreamSubscription? _connectivitySub;
  bool _draining = false;

  void start() {
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) drain();
    });
  }

  Future<void> stop() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  /// Attempts the request now; queues it for later on a connectivity-shaped
  /// failure (ApiException code 0 — see ApiClient._send). Returns the decoded
  /// response on immediate success, or null if it was queued.
  Future<dynamic> run({
    required String entityType,
    required String method,
    required String path,
    Object? body,
    String localRefId = '',
  }) async {
    try {
      return await _send(method, path, body);
    } on ApiException catch (e) {
      if (e.statusCode != 0) rethrow; // a real server rejection, not offline — surface it
      await _db.into(_db.pendingMutations).insert(PendingMutationsCompanion.insert(
            entityType: entityType,
            method: method,
            path: path,
            bodyJson: Value(body == null ? '{}' : jsonEncode(body)),
            localRefId: Value(localRefId),
          ));
      return null;
    }
  }

  Future<dynamic> _send(String method, String path, Object? body) {
    switch (method) {
      case 'POST':
        return _api.post(path, body);
      case 'PATCH':
        return _api.patch(path, body);
      case 'PUT':
        return _api.put(path, body);
      case 'DELETE':
        return _api.delete(path);
      default:
        throw ArgumentError('Unsupported mutation method: $method');
    }
  }

  /// Replays queued mutations oldest-first. Stops at the first mutation that
  /// still fails for connectivity reasons (keeps ordering — a later mutation
  /// on the same entity shouldn't jump ahead of an earlier one that's still
  /// stuck offline).
  Future<void> drain() async {
    if (_draining) return;
    _draining = true;
    try {
      final rows = await (_db.select(_db.pendingMutations)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
      for (final row in rows) {
        try {
          final body = jsonDecode(row.bodyJson);
          await _send(row.method, row.path, body);
          await (_db.delete(_db.pendingMutations)..where((t) => t.id.equals(row.id))).go();
          
          // Reconcile optimistic local rows
          if (row.localRefId.isNotEmpty) {
            if (row.entityType == 'order') {
              await (_db.delete(_db.orders)..where((t) => t.id.equals(row.localRefId))).go();
              await (_db.delete(_db.orderItemRows)..where((t) => t.orderId.equals(row.localRefId))).go();
            } else if (row.entityType == 'message') {
              await (_db.delete(_db.messages)..where((t) => t.id.equals(row.localRefId))).go();
            }
          }
        } on ApiException catch (e) {
          if (e.statusCode == 0) return; // still offline — try again on the next connectivity event
          // A real rejection (validation, 4xx/5xx) — drop it rather than retry forever,
          // but keep the error visible for later diagnosis.
          await (_db.update(_db.pendingMutations)..where((t) => t.id.equals(row.id))).write(
            PendingMutationsCompanion(retryCount: Value(row.retryCount + 1), lastError: Value(e.message)),
          );
        }
      }
    } finally {
      _draining = false;
    }
  }
}
