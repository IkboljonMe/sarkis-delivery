import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/order_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/route_optimizer.dart';
import 'route_stop_list.dart';

/// A single reorderable stop row (number, ETA clocks, name/address, actions).
class RouteStopTile extends StatelessWidget {
  const RouteStopTile({
    super.key,
    required this.index,
    required this.stop,
    required this.eta,
    required this.onChat,
    required this.onDelivered,
    required this.onNavigate,
  });

  final int index;
  final RouteStop stop;
  final Eta? eta;
  final void Function(RouteStop stop) onChat;
  final void Function(OrderModel order) onDelivered;
  final void Function(RouteStop stop) onNavigate;

  @override
  Widget build(BuildContext context) {
    final i = index;
    final o = stop.order;
    final eta = this.eta;
    return Container(
      key: ValueKey(stop.id),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: Text('${i + 1}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          // Arrival / departure clocks (after the number).
          if (eta != null) ...[
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _clock(Icons.login, DateFormat('HH:mm').format(eta.arrival),
                    AppColors.primary),
                const SizedBox(height: 2),
                _clock(Icons.logout, DateFormat('HH:mm').format(eta.departure),
                    AppColors.textMuted),
              ],
            ),
          ],
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyBold),
                Text(o.userAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          _miniBtn(Icons.chat_bubble_outline, AppColors.textSecondary,
              'Сообщение (время прибытия)', () => onChat(stop)),
          _miniBtn(Icons.check_circle_outline, AppColors.success, 'Доставлен',
              () => onDelivered(o)),
          _miniBtn(Icons.navigation, AppColors.primary, 'Навигация',
              () => onNavigate(stop)),
          ReorderableDragStartListener(
            index: i,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Icon(Icons.drag_handle, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clock(IconData icon, String time, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 2),
        Text(time,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _miniBtn(
      IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
      onPressed: onTap,
    );
  }
}
