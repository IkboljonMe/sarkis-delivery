import 'package:cloud_firestore/cloud_firestore.dart';

/// Resolves which admin-drawn map group (collection `regionGroups`) a delivery
/// location falls inside. A group's identifier is its name. Replaces the old
/// postal-code-range matching.
class RegionGroupService {
  RegionGroupService._();
  static final RegionGroupService instance = RegionGroupService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns the name of the first group whose polygon contains [lat]/[lng],
  /// or null when the point is outside every group (out of coverage).
  Future<String?> resolveGroupName(double lat, double lng) async {
    final snap = await _db.collection('regionGroups').get();
    for (final doc in snap.docs) {
      final data = doc.data();
      final name = data['name'] as String? ?? '';
      if (name.isEmpty) continue;
      final polys = (data['polygons'] as List?) ?? const [];
      for (final ring in polys) {
        // Each ring is stored as {points: [...]}; tolerate a raw list too.
        final pts = ring is Map
            ? (ring['points'] as List? ?? const [])
            : (ring as List? ?? const []);
        final coords = pts.map<List<double>>((p) {
          final m = p as Map;
          return [(m['lat'] as num).toDouble(), (m['lng'] as num).toDouble()];
        }).toList();
        if (coords.length >= 3 && _contains(lat, lng, coords)) return name;
      }
    }
    return null;
  }

  /// Ray-casting point-in-polygon. Each vertex is [lat, lng]; lat is the y
  /// axis, lng the x axis.
  bool _contains(double lat, double lng, List<List<double>> ring) {
    bool inside = false;
    final n = ring.length;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      final yi = ring[i][0], xi = ring[i][1];
      final yj = ring[j][0], xj = ring[j][1];
      final intersects = ((yi > lat) != (yj > lat)) &&
          (lng < (xj - xi) * (lat - yi) / (yj - yi) + xi);
      if (intersects) inside = !inside;
    }
    return inside;
  }
}
