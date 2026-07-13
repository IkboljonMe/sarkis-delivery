import 'api_client.dart';

/// Resolves which admin-drawn delivery zone a location falls inside.
/// The point-in-polygon test runs on the backend (`POST /v1/zones/resolve`).
class RegionGroupService {
  RegionGroupService._();
  static final RegionGroupService instance = RegionGroupService._();

  final ApiClient _api = ApiClient.instance;

  /// Returns the group name containing [lat]/[lng], or null when the point is
  /// outside every zone (out of coverage).
  Future<String?> resolveGroupName(double lat, double lng) async {
    final res = await _api.post('/v1/zones/resolve', {'lat': lat, 'lng': lng});
    return (res as Map)['group'] as String?;
  }
}
