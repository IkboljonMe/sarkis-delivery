import '../models/approval_model.dart';
import 'api_client.dart';

/// Admin review of customer profile-change requests.
class ApprovalService {
  ApprovalService._();
  static final ApprovalService instance = ApprovalService._();

  final ApiClient _api = ApiClient.instance;

  Stream<List<ApprovalModel>> pendingStream() => ApiClient.poll(
      const Duration(seconds: 15), () async {
        final res = await _api.get('/v1/admin/approvals?status=pending');
        return (res as List)
            .map((e) =>
                ApprovalModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      });

  /// Applies the change to the user and marks the request approved
  /// (both done atomically on the backend).
  Future<void> approve(ApprovalModel a) async {
    await _api.post('/v1/admin/approvals/${a.id}/approve');
  }

  Future<void> reject(String id) async {
    await _api.post('/v1/admin/approvals/$id/reject');
  }
}
