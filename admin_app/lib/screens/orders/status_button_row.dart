import 'package:flutter/material.dart';

import '../../providers/admin_order_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

/// Renders the valid next-status action buttons for an order, with a
/// confirmation dialog before each change.
class StatusButtonRow extends StatelessWidget {
  final String currentStatus;
  final Future<void> Function(String newStatus) onChange;

  const StatusButtonRow({
    super.key,
    required this.currentStatus,
    required this.onChange,
  });

  static const _labels = {
    AppConstants.statusConfirmed: 'Подтвердить',
    AppConstants.statusOnTheWay: 'В пути',
    AppConstants.statusDelivered: 'Доставлено',
    AppConstants.statusCancelled: 'Отменить',
  };

  Future<void> _confirm(BuildContext context, String status) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Изменить статус?'),
        content: Text('Новый статус: ${_labels[status] ?? status}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Да')),
        ],
      ),
    );
    if (ok == true) await onChange(status);
  }

  @override
  Widget build(BuildContext context) {
    final next = AdminOrderProvider.nextStatuses(currentStatus);
    if (next.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Нет доступных действий',
            style: TextStyle(color: Colors.black54)),
      );
    }
    return Wrap(
      spacing: 8,
      children: next.map((status) {
        final isCancel = status == AppConstants.statusCancelled;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isCancel ? Colors.red.shade400 : AppTheme.statusColor(status),
          ),
          onPressed: () => _confirm(context, status),
          child: Text(_labels[status] ?? status),
        );
      }).toList(),
    );
  }
}
