import 'api_client.dart';

/// Customer-facing approvals: profile changes (name / phone) require admin
/// review before they are applied to the account.
class ApprovalService {
  ApprovalService._();
  static final ApprovalService instance = ApprovalService._();

  final ApiClient _api = ApiClient.instance;

  /// Files a profile-change request for the admin to approve.
  Future<void> requestProfileChange({
    required String userId,
    required String userName,
    required Map<String, dynamic> changes,
  }) async {
    await _api.post('/v1/approvals', {'changes': changes});
  }
}
