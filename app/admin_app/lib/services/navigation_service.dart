import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

/// External app handoffs: Maps navigation, phone dialer, WhatsApp, clipboard.
class NavigationService {
  NavigationService._();
  static final NavigationService instance = NavigationService._();

  Future<void> openGoogleMapsNavigation(String address) async {
    final encoded = Uri.encodeComponent('$address, Germany');
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$encoded&travelmode=driving',
    );
    await _launch(uri);
  }

  /// Turn-by-turn to a single coordinate (the next stop).
  Future<void> navigateToPoint(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$lat,$lng&travelmode=driving',
    );
    await _launch(uri);
  }

  /// Opens a free multi-stop route in Google Maps. The consumer Maps URL
  /// supports up to ~9 intermediate waypoints, so longer runs are truncated
  /// (the caller is told). [stops] are "lat,lng" strings in visiting order.
  Future<void> openMultiStopRoute({
    String? origin,
    required List<String> stops,
  }) async {
    if (stops.isEmpty) return;
    const maxWaypoints = 9;
    final truncated = stops.length > maxWaypoints + 1;
    final used = truncated ? stops.sublist(0, maxWaypoints + 1) : stops;

    final destination = used.last;
    final waypoints = used.sublist(0, used.length - 1);
    final params = <String, String>{
      'api': '1',
      'destination': destination,
      'travelmode': 'driving',
      if (origin != null && origin.isNotEmpty) 'origin': origin,
      if (waypoints.isNotEmpty) 'waypoints': waypoints.join('|'),
    };
    final uri =
        Uri.https('www.google.com', '/maps/dir/', params);
    await _launch(uri);
    if (truncated) {
      Fluttertoast.showToast(
          msg: 'Google Maps поддерживает до 9 точек — маршрут обрезан');
    }
  }

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: 'Не удалось открыть карты');
    }
  }

  Future<void> callPhone(String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: 'Не удалось позвонить');
    }
  }

  Future<void> openWhatsApp(String phone, String message) async {
    final number = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse(
        'https://wa.me/$number?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(msg: 'Скопировано!');
  }
}
