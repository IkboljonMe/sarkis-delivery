import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/region_group_model.dart';

/// CRUD for admin-created map region groups (collection `regionGroups`).
class RegionGroupService {
  RegionGroupService._();
  static final RegionGroupService instance = RegionGroupService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection('regionGroups');

  Stream<List<RegionGroupModel>> groupsStream() {
    return _groups.snapshots().map((s) {
      final list = s.docs
          .map((d) => RegionGroupModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  /// Creates a new group (auto id) or updates an existing one when [g.id] is
  /// set. Returns the saved document id.
  Future<String> save(RegionGroupModel g) async {
    try {
      if (g.id.isEmpty) {
        final ref = await _groups.add(g.toJson());
        return ref.id;
      }
      await _groups.doc(g.id).set(g.toJson(), SetOptions(merge: true));
      return g.id;
    } catch (e) {
      throw Exception('Failed to save group: $e');
    }
  }

  Future<void> delete(String id) => _groups.doc(id).delete();
}
