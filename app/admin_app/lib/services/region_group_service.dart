import 'dart:convert';
import 'package:drift/drift.dart' as drift;

import '../local_db/app_database.dart';
import '../models/region_group_model.dart';
import '../sync/mutation_queue.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Admin CRUD for delivery zones (map polygons).
class RegionGroupService {
  RegionGroupService._();
  static final RegionGroupService instance = RegionGroupService._();

  Stream<List<RegionGroupModel>> groupsStream() {
    final db = AppDatabase.instance;
    return (db.select(db.regionZones)
          ..orderBy([(t) => drift.OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map((r) => RegionGroupModel(
              id: r.id,
              name: r.name,
              colorValue: r.colorValue,
              polygons: r.polygonsJson.isNotEmpty
                  ? (jsonDecode(r.polygonsJson) as List).map((ring) => (ring['points'] as List? ?? []).map((p) => LatLng(
                          (p['lat'] as num).toDouble(),
                          (p['lng'] as num).toDouble())).toList()).toList()
                  : const [],
            )).toList());
  }

  /// Creates or updates a zone; returns its id.
  Future<String> save(RegionGroupModel g) async {
    final body = Map<String, dynamic>.from(g.toJson())
      ..remove('id')
      ..remove('createdAt')
      ..remove('updatedAt');
      
    final isNew = g.id.isEmpty;
    final id = isNew ? 'local_${DateTime.now().millisecondsSinceEpoch}' : g.id;
    final method = isNew ? 'POST' : 'PATCH';
    final path = isNew ? '/v1/admin/zones' : '/v1/admin/zones/${g.id}';

    final db = AppDatabase.instance;
    await db.into(db.regionZones).insertOnConflictUpdate(RegionZonesCompanion.insert(
      id: id,
      name: g.name,
      colorValue: drift.Value(g.colorValue),
      polygonsJson: drift.Value(jsonEncode(g.polygons.map((ring) => {'points': ring.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList()}).toList())),
      createdAt: drift.Value(DateTime.now()),
      updatedAt: DateTime.now(),
    ));

    await MutationQueue.instance.run(
      entityType: 'zone',
      method: method,
      path: path,
      body: body,
      localRefId: isNew ? id : '',
    );
    
    return id;
  }

  Future<void> delete(String id) async {
    final db = AppDatabase.instance;
    await (db.delete(db.regionZones)..where((t) => t.id.equals(id))).go();

    await MutationQueue.instance.run(
      entityType: 'zone',
      method: 'DELETE',
      path: '/v1/admin/zones/$id',
    );
  }
}
