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
