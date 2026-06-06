import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Sticky bottom bar showing item count, total and the place-order button.
class CartSummaryWidget extends StatelessWidget {
  final int itemCount;
  final double total;
  final bool placing;
  final VoidCallback onPlaceOrder;

  const CartSummaryWidget({
    super.key,
    required this.itemCount,
    required this.total,
    required this.placing,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final enabled = itemCount > 0 && !placing;

    return Material(
      elevation: 12,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$itemCount × ${t.quantity}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  Text(
                    '€${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: enabled ? onPlaceOrder : null,
                  child: placing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(t.placeOrder.toUpperCase()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
