import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/order_service.dart';
import '../../services/user_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../orders/order_detail_screen.dart';

/// Admin-facing customer profile: contact, location and order history.
class CustomerProfileScreen extends StatefulWidget {
  final String userId;
  final String fallbackName;
  const CustomerProfileScreen(
      {super.key, required this.userId, this.fallbackName = ''});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  UserModel? _user;
  bool _showAllActive = false;
  bool _showAllPast = false;

  @override
  void initState() {
    super.initState();
    UserService.instance.getUser(widget.userId).then((u) {
      if (mounted) setState(() => _user = u);
    });
  }

  bool _isActive(OrderModel o) =>
      o.status != 'delivered' && o.status != 'cancelled';

  Future<void> _call(String phone) async {
    if (phone.isEmpty) {
      Fluttertoast.showToast(msg: 'Нет номера');
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openMap(UserModel u) async {
    final q = (u.lat != null && u.lng != null)
        ? '${u.lat},${u.lng}'
        : Uri.encodeComponent('${u.address} ${u.city} ${u.postalCode}');
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = _user;
    final name = u?.fullName.isNotEmpty == true ? u!.fullName : widget.fallbackName;
    return Scaffold(
      appBar: AppBar(title: Text(name.isEmpty ? 'Профиль' : name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(name, u),
          const SizedBox(height: 16),
          if (u != null) _contactCard(u),
          const SizedBox(height: 16),
          StreamBuilder<List<OrderModel>>(
            stream: OrderService.instance.userOrdersStream(widget.userId),
            builder: (context, snap) {
              final orders = snap.data ?? [];
              final active = orders.where(_isActive).toList();
              final past = orders.where((o) => !_isActive(o)).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _spentSummary(orders),
                  const SizedBox(height: 16),
                  _orderSection('Текущие заказы', active, _showAllActive,
                      () => setState(() => _showAllActive = !_showAllActive)),
                  const SizedBox(height: 16),
                  _orderSection('Прошлые заказы', past, _showAllPast,
                      () => setState(() => _showAllPast = !_showAllPast)),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _header(String name, UserModel? u) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final photo = u?.photoUrl ?? '';
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: photo.isEmpty ? AppColors.goldGradient : null),
          child: photo.isEmpty
              ? Center(
                  child: Text(initial,
                      style:
                          AppTextStyles.headingL.copyWith(color: Colors.white)))
              : CachedNetworkImage(imageUrl: photo, fit: BoxFit.cover),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name.isEmpty ? '—' : name, style: AppTextStyles.headingM),
              if (u != null)
                Text(AppConstants.groupLabel(u.group),
                    style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contactCard(UserModel u) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.call, color: AppColors.primary),
            title: Text(u.phone.isEmpty ? '—' : u.phone),
            subtitle: const Text('Позвонить'),
            onTap: () => _call(u.phone),
          ),
          const Divider(height: 1, color: AppColors.border),
          ListTile(
            leading: const Icon(Icons.location_on_outlined,
                color: AppColors.primary),
            title: Text('${u.address}, ${u.city} ${u.postalCode}'.trim()),
            subtitle: const Text('Открыть на карте'),
            onTap: () => _openMap(u),
          ),
          const Divider(height: 1, color: AppColors.border),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primary),
            title: Text('Язык: ${u.language.toUpperCase()}'),
          ),
        ],
      ),
    );
  }

  Widget _spentSummary(List<OrderModel> orders) {
    final delivered = orders.where((o) => o.status == 'delivered');
    final spent =
        delivered.fold<double>(0, (s, o) => s + o.totalPrice);
    return Row(
      children: [
        _stat('${orders.length}', 'Заказов'),
        const SizedBox(width: 12),
        _stat('€${spent.toStringAsFixed(0)}', 'Потрачено'),
      ],
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.headingM
                    .copyWith(color: AppColors.primary)),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _orderSection(
      String title, List<OrderModel> orders, bool showAll, VoidCallback toggle) {
    final shown = showAll ? orders : orders.take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: AppTextStyles.label),
        const SizedBox(height: 8),
        if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Нет заказов', style: AppTextStyles.caption),
          )
        else ...[
          ...shown.map(_orderTile),
          if (orders.length > 2)
            TextButton(
              onPressed: toggle,
              child: Text(showAll
                  ? 'Скрыть'
                  : 'Показать ещё (${orders.length - 2})'),
            ),
        ],
      ],
    );
  }

  Widget _orderTile(OrderModel o) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        title: Text(o.itemsSummary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyBold),
        subtitle: Text(
            '${o.shiftLabel} • €${o.totalPrice.toStringAsFixed(2)} • '
            '${AppConstants.statusLabel(o.status)}',
            style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => OrderDetailScreen(orderId: o.id)),
        ),
      ),
    );
  }
}
