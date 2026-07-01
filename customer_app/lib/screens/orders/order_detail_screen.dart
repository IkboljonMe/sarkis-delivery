import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/order_model.dart';
import '../../models/shift_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/dark_card.dart';
import '../../widgets/glass_card.dart';
import '../products/categories_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  static const _steps = ['pending', 'confirmed', 'on_the_way', 'delivered'];

  Future<void> _cancel(BuildContext context, OrderModel order) async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('cancelOrder')),
        content: Text(t.t('cancelOrderConfirm')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.noGoBack)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.t('cancelOrder'),
                  style: const TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok != true) return;
    await OrderService.instance.updateStatus(order.id, 'cancelled');
    Fluttertoast.showToast(msg: t.t('orderCancelledMsg'));
  }

  void _edit(BuildContext context, OrderModel order) {
    final shift = ShiftModel(
      id: order.shiftId,
      group: order.userGroup,
      date: order.shiftDate,
      label: order.shiftLabel,
      cancelDaysBefore: order.cancelDaysBefore,
      editDaysBefore: order.editDaysBefore,
    );
    context.read<CartProvider>().loadFromOrder(order, shift);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoriesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.myOrders)),
      body: StreamBuilder<OrderModel?>(
        stream: OrderService.instance.orderStream(orderId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = snap.data;
          if (order == null) {
            return Center(child: Text(t.error));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (order.status == 'on_the_way') _etaBanner(t),
              _timeline(context, order.status)
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 16),
              DarkCard(
                child: Column(
                  children: [
                    ...order.items.map((i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Text(i.name,
                                      style: AppTextStyles.body)),
                              Expanded(
                                  child: Text('x${i.qty}',
                                      style: AppTextStyles.caption)),
                              Expanded(
                                child: Text(
                                    '€${i.subtotal.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: AppTextStyles.bodyBold),
                              ),
                            ],
                          ),
                        )),
                    const Divider(color: AppColors.border),
                    Row(
                      children: [
                        Text(t.orderTotal, style: AppTextStyles.bodyBold),
                        const Spacer(),
                        Text('€${order.totalPrice.toStringAsFixed(2)}',
                            style: AppTextStyles.price),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _info(Icons.event,
                        DateFormat('EEEE, d MMM yyyy').format(order.shiftDate)),
                    const SizedBox(height: 8),
                    _info(Icons.location_on_outlined,
                        '${order.userAddress}, ${order.userGroup}'),
                  ],
                ),
              ),
              if (order.adminNote.isNotEmpty) ...[
                const SizedBox(height: 16),
                DarkCard(
                  borderColor: AppColors.primary,
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(order.adminNote,
                              style: AppTextStyles.body)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _actions(context, order, t),
            ],
          );
        },
      ),
    );
  }

  Widget _actions(BuildContext context, OrderModel order, AppLocalizations t) {
    if (!order.canEdit && !order.canCancel) {
      // Active orders past the cut-off explain why actions are unavailable.
      if (order.status == 'pending' || order.status == 'confirmed') {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_clock,
                size: 16, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t.t('editCancelClosed'),
                style: AppTextStyles.caption,
              ),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        if (order.canEdit)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _edit(context, order),
              icon: const Icon(Icons.edit_outlined),
              label: Text(t.t('editOrder')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        if (order.canEdit && order.canCancel) const SizedBox(width: 12),
        if (order.canCancel)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _cancel(context, order),
              icon: const Icon(Icons.cancel_outlined),
              label: Text(t.t('cancelOrder')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _etaBanner(AppLocalizations t) {
    final now = DateTime.now();
    final from = DateFormat('HH:mm').format(now.add(const Duration(minutes: 25)));
    final to = DateFormat('HH:mm').format(now.add(const Duration(minutes: 45)));
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
                color: Colors.white24, shape: BoxShape.circle),
            child: const Icon(Icons.local_shipping, color: Colors.white),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveX(begin: -3, end: 3, duration: 900.ms),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.driverComing,
                    style:
                        AppTextStyles.bodyBold.copyWith(color: Colors.white)),
                const SizedBox(height: 2),
                Text('${t.t('estimatedArrival')} • ~$from–$to',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.2, curve: Curves.easeOut);
  }

  Widget _timeline(BuildContext context, String status) {
    final t = AppLocalizations.of(context);
    final currentIndex = _steps.indexOf(status);
    if (status == 'cancelled') {
      return DarkCard(
        borderColor: AppColors.error,
        child: Row(
          children: [
            const Icon(Icons.cancel, color: AppColors.error),
            const SizedBox(width: 8),
            Text(t.statusLabel('cancelled'),
                style: const TextStyle(color: AppColors.error)),
          ],
        ),
      );
    }
    return Row(
      children: List.generate(_steps.length, (i) {
        final done = i <= currentIndex;
        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        done ? AppColors.primary : AppColors.surfaceElevated,
                    child: Icon(
                      done ? Icons.check : Icons.circle,
                      size: 12,
                      color: done ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (i < _steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i < currentIndex
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.body)),
      ],
    );
  }
}
