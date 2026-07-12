import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Estimated arrival/departure window for a stop.
class Eta {
  final DateTime arrival;
  final DateTime departure;
  const Eta(this.arrival, this.departure);
}

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

  /// Estimated arrival/departure windows for [stops] visited in order,
  /// starting from [start] at [routeStart]. Pure: [routeStart] is the caller's
  /// resolved start time (e.g. `DateTime.now()` when "now"). [detour] scales
  /// straight-line distance to approximate road distance.
  static List<Eta> computeEtas(
    LatLng start,
    List<LatLng> stops, {
    required DateTime routeStart,
    required int serviceMin,
    required double avgSpeedKmh,
    required double detour,
  }) {
    final eta = <Eta>[];
    var t = routeStart;
    var prev = start;
    for (final s in stops) {
      final km = distanceKm(prev, s) * detour;
      final travelMin = avgSpeedKmh > 0 ? (km / avgSpeedKmh * 60) : 0.0;
      final arrival = t.add(Duration(minutes: travelMin.round()));
      final departure = arrival.add(Duration(minutes: serviceMin));
      eta.add(Eta(arrival, departure));
      t = departure;
      prev = s;
    }
    return eta;
  }

  /// Latest departure time across [etas], or null when empty.
  static DateTime? latestDeparture(Iterable<Eta> etas) {
    DateTime? last;
    for (final e in etas) {
      if (last == null || e.departure.isAfter(last)) last = e.departure;
    }
    return last;
  }

  static double _rad(double deg) => deg * pi / 180.0;
}
