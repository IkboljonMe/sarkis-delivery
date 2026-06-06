import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helpers that hand off to external apps (Maps, phone, WhatsApp).
class NavigationService {
  NavigationService._();
  static final NavigationService instance = NavigationService._();

  /// Opens Google Maps driving navigation to the given address.
  Future<void> openGoogleMapsNavigation(String address) async {
    final destination = Uri.encodeComponent('$address, Germany');
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$destination'
      '&travelmode=driving',
    );
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
    } else {
      Fluttertoast.showToast(msg: 'Не удалось открыть WhatsApp');
    }
  }
}
