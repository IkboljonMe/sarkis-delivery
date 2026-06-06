import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/delivery_date_model.dart';

class DateCardWidget extends StatelessWidget {
  final DeliveryDateModel deliveryDate;
  final VoidCallback onOrder;

  const DateCardWidget({
    super.key,
    required this.deliveryDate,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final formatted =
        DateFormat('EEEE, d MMMM yyyy', locale).format(deliveryDate.date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, color: Color(0xFFC8860D)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formatted,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: Colors.black54),
                const SizedBox(width: 4),
                Text(deliveryDate.group,
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onOrder,
                child: Text(t.placeOrder.toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
