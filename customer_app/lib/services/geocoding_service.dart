import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

/// Result of a Google Geocoding lookup.
class GeocodeResult {
  final String formattedAddress;
  final String postalCode;
  final String city;
  final double? lat;
  final double? lng;

  GeocodeResult({
    required this.formattedAddress,
    required this.postalCode,
    required this.city,
    this.lat,
    this.lng,
  });
}

/// Validates / formats an address through the Google Geocoding API.
class GeocodingService {
  GeocodingService._();
  static final GeocodingService instance = GeocodingService._();

  Future<GeocodeResult?> lookup(String rawAddress) async {
    final query = Uri.encodeComponent('$rawAddress, Germany');
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?address=$query&key=${AppConstants.googleGeocodingApiKey}',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return null;

      final results = data['results'] as List<dynamic>;
      if (results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      final formatted = first['formatted_address'] as String? ?? rawAddress;

      String postalCode = '';
      String city = '';
      final components = first['address_components'] as List<dynamic>? ?? [];
      for (final c in components) {
        final comp = c as Map<String, dynamic>;
        final types = (comp['types'] as List<dynamic>).cast<String>();
        if (types.contains('postal_code')) {
          postalCode = comp['long_name'] as String? ?? '';
        }
        if (types.contains('locality') ||
            types.contains('administrative_area_level_1')) {
          if (city.isEmpty) city = comp['long_name'] as String? ?? '';
        }
      }

      double? lat;
      double? lng;
      final geometry = first['geometry'] as Map<String, dynamic>?;
      if (geometry != null && geometry['location'] is Map) {
        final loc = geometry['location'] as Map<String, dynamic>;
        lat = (loc['lat'] as num?)?.toDouble();
        lng = (loc['lng'] as num?)?.toDouble();
      }

      return GeocodeResult(
        formattedAddress: formatted,
        postalCode: postalCode,
        city: city,
        lat: lat,
        lng: lng,
      );
    } catch (e) {
      return null;
    }
  }
}
