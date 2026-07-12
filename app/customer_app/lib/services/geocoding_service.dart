import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

/// Resolved geocoding result for an address the customer typed. The delivery
/// group is no longer derived here — it is resolved by point-in-polygon
/// against the admin-drawn map groups (see [RegionGroupService]).
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
}

/// A single address suggestion from Google Places Autocomplete.
class AddressSuggestion {
  final String description; // full, human-readable address
  final String mainText; // first line (street)
  final String secondaryText; // city / region line

  const AddressSuggestion({
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });
}

/// Thin wrapper over the Google Geocoding API.
class GeocodingService {
  GeocodingService._();
  static final GeocodingService instance = GeocodingService._();

  /// Returns up to [limit] address suggestions for what the user has typed so
  /// far, biased to Germany (Google Places Autocomplete). Empty on any error
  /// (e.g. the Places API isn't enabled for the key).
  Future<List<AddressSuggestion>> autocomplete(String input,
      {int limit = 3}) async {
    final key = AppConstants.googleApiKey;
    if (key.isEmpty || input.trim().length < 3) return const [];
    final uri = Uri.https(
        'maps.googleapis.com', '/maps/api/place/autocomplete/json', {
      'input': input.trim(),
      'components': 'country:de',
      'language': 'de',
      'types': 'address',
      'key': key,
    });
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return const [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final status = body['status'];
      if (status != 'OK') return const [];
      final preds = (body['predictions'] as List?) ?? const [];
      return preds.take(limit).map((p) {
        final m = p as Map<String, dynamic>;
        final fmt = (m['structured_formatting'] as Map<String, dynamic>?);
        return AddressSuggestion(
          description: m['description'] as String? ?? '',
          mainText: fmt?['main_text'] as String? ?? '',
          secondaryText: fmt?['secondary_text'] as String? ?? '',
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

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
