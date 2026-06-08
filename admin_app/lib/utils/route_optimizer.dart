import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Free, offline route helpers — no paid Routes API.
///
/// Uses straight-line (haversine) distance and a greedy nearest-neighbor
/// heuristic to order stops. Good enough for a single-city delivery run; swap
/// for the Google Routes API (optimizeWaypointOrder) once Blaze is enabled.
class RouteOptimizer {
  RouteOptimizer._();

  /// Great-circle distance between two points, in kilometres.
  static double distanceKm(LatLng a, LatLng b) {
    const earthR = 6371.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final lat1 = _rad(a.latitude);
    final lat2 = _rad(b.latitude);
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    return earthR * 2 * atan2(sqrt(h), sqrt(1 - h));
  }

  /// Returns the indices of [points] in nearest-neighbor visiting order,
  /// starting from [start]. Does not mutate [points].
  static List<int> nearestNeighborOrder(LatLng start, List<LatLng> points) {
    final remaining = List<int>.generate(points.length, (i) => i);
    final order = <int>[];
    var current = start;
    while (remaining.isNotEmpty) {
      var bestIdx = 0;
      var bestDist = double.infinity;
      for (var k = 0; k < remaining.length; k++) {
        final d = distanceKm(current, points[remaining[k]]);
        if (d < bestDist) {
          bestDist = d;
          bestIdx = k;
        }
      }
      final chosen = remaining.removeAt(bestIdx);
      order.add(chosen);
      current = points[chosen];
    }
    return order;
  }

  /// Total straight-line length of a path that starts at [start] and visits
  /// [points] in their current order, in kilometres.
  static double totalDistanceKm(LatLng start, List<LatLng> points) {
    var total = 0.0;
    var current = start;
    for (final p in points) {
      total += distanceKm(current, p);
      current = p;
    }
    return total;
  }

  static double _rad(double deg) => deg * pi / 180.0;
}
