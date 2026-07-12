import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// An admin-created delivery group whose coverage is one or more free-drawn
/// polygons on the map. Stored in the `regionGroups` Firestore collection,
/// additive to the legacy hardcoded city groups in [AppConstants].
class RegionGroupModel {
  final String id;
  final String name;
  final int colorValue; // ARGB int used to tint the polygon fill/stroke
  final List<List<LatLng>> polygons; // each entry is one closed shape
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RegionGroupModel({
    required this.id,
    required this.name,
    required this.colorValue,
    this.polygons = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Approximate center of the first polygon, used to drop the name label.
  LatLng? get center {
    for (final ring in polygons) {
      if (ring.isEmpty) continue;
      double lat = 0, lng = 0;
      for (final p in ring) {
        lat += p.latitude;
        lng += p.longitude;
      }
      return LatLng(lat / ring.length, lng / ring.length);
    }
    return null;
  }

  bool get hasShapes => polygons.any((p) => p.length >= 3);

  factory RegionGroupModel.fromJson(Map<String, dynamic> json) {
    final rawPolys = (json['polygons'] as List?) ?? const [];
    final polygons = rawPolys.map<List<LatLng>>((ring) {
      // Each ring is stored as {points: [...]} because Firestore forbids
      // directly nesting an array inside another array. Fall back to a raw
      // list for any legacy documents.
      final pts = ring is Map ? (ring['points'] as List? ?? const []) : (ring as List? ?? const []);
      return pts.map<LatLng>((p) {
        final m = p as Map;
        return LatLng(
          (m['lat'] as num).toDouble(),
          (m['lng'] as num).toDouble(),
        );
      }).toList();
    }).toList();
    return RegionGroupModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFFC8972A,
      polygons: polygons,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        // Wrap each ring in a map; Firestore rejects arrays-of-arrays.
        'polygons': polygons
            .map((ring) => {
                  'points': ring
                      .map((p) => {'lat': p.latitude, 'lng': p.longitude})
                      .toList(),
                })
            .toList(),
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  RegionGroupModel copyWith({
    String? id,
    String? name,
    int? colorValue,
    List<List<LatLng>>? polygons,
    DateTime? createdAt,
  }) {
    return RegionGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      polygons: polygons ?? this.polygons,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
