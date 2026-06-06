import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/constants.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  const OrderStatusBadge({super.key, required this.status});

  static Color colorFor(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return Colors.orange;
      case AppConstants.statusConfirmed:
        return Colors.blue;
      case AppConstants.statusOnTheWay:
        return Colors.purple;
      case AppConstants.statusDelivered:
        return Colors.green;
      case AppConstants.statusCancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String labelFor(BuildContext context, String status) {
    final t = AppLocalizations.of(context);
    switch (status) {
      case AppConstants.statusPending:
        return t.pending;
      case AppConstants.statusConfirmed:
        return t.confirmed;
      case AppConstants.statusOnTheWay:
        return t.onTheWay;
      case AppConstants.statusDelivered:
        return t.delivered;
      case AppConstants.statusCancelled:
        return t.cancelled;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        labelFor(context, status),
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
