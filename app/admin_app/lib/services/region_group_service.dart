import '../models/region_group_model.dart';
import 'api_client.dart';

/// Admin CRUD for delivery zones (map polygons).
class RegionGroupService {
  RegionGroupService._();
  static final RegionGroupService instance = RegionGroupService._();

  final ApiClient _api = ApiClient.instance;

  Stream<List<RegionGroupModel>> groupsStream() => ApiClient.poll(
      const Duration(seconds: 30), () async {
        final res = await _api.get('/v1/zones');
        return (res as List)
            .map((e) =>
                RegionGroupModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      });

  /// Creates or updates a zone; returns its id.
  Future<String> save(RegionGroupModel g) async {
    final body = Map<String, dynamic>.from(g.toJson())
      ..remove('id')
      ..remove('createdAt')
      ..remove('updatedAt');
    final res = g.id.isEmpty
        ? await _api.post('/v1/admin/zones', body)
        : await _api.patch('/v1/admin/zones/${g.id}', body);
    return ((res as Map)['id'] as String?) ?? g.id;
  }

  Future<void> delete(String id) async {
    await _api.delete('/v1/admin/zones/$id');
  }
}
