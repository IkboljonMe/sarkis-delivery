import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class OrderSuccessDialog extends StatelessWidget {
  const OrderSuccessDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const OrderSuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFFE8F5E9),
            child: Icon(Icons.check_circle,
                color: Colors.green, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            t.orderPlaced,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            t.orderSuccess,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            t.cashOnDelivery,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.yes),
          ),
        ),
      ],
    );
  }
}
