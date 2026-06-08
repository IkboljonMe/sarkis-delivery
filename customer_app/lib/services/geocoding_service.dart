import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

/// Resolved geocoding result for an address the customer typed.
class GeoResult {
  final double lat;
  final double lng;
  final String formattedAddress;
  final String postalCode;
  final String city;

  const GeoResult({
    required this.lat,
    required this.lng,
    required this.formattedAddress,
    required this.postalCode,
    required this.city,
  });

  /// Delivery group derived from the postal code, or null if out of coverage.
  String? get group => AppConstants.groupForPostalCode(postalCode);
}

/// Thin wrapper over the Google Geocoding API.
class GeocodingService {
  GeocodingService._();
  static final GeocodingService instance = GeocodingService._();

  /// Geocodes a free-form address (biased to Germany). Returns null when the
  /// address can't be resolved or the API key is missing.
  Future<GeoResult?> geocode(String address) async {
    final key = AppConstants.googleApiKey;
    if (key.isEmpty || address.trim().isEmpty) return null;

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'address': address.trim(),
      'region': 'de',
      'language': 'de',
      'key': key,
    });

    try {
      final res = await http
          .get(uri)
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['status'] != 'OK') return null;
      final results = body['results'] as List?;
      if (results == null || results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      final loc = (first['geometry']?['location']) as Map<String, dynamic>?;
      if (loc == null) return null;

      final components =
          (first['address_components'] as List?)?.cast<Map<String, dynamic>>() ??
              const [];
      return GeoResult(
        lat: (loc['lat'] as num).toDouble(),
        lng: (loc['lng'] as num).toDouble(),
        formattedAddress: first['formatted_address'] as String? ?? address,
        postalCode: _component(components, 'postal_code'),
        city: _component(components, 'locality').isNotEmpty
            ? _component(components, 'locality')
            : _component(components, 'administrative_area_level_1'),
      );
    } catch (_) {
      return null;
    }
  }

  String _component(List<Map<String, dynamic>> components, String type) {
    for (final c in components) {
      final types = (c['types'] as List?)?.cast<String>() ?? const [];
      if (types.contains(type)) return c['long_name'] as String? ?? '';
    }
    return '';
  }
}
