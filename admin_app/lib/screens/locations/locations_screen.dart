import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../models/shift_model.dart';
import '../../providers/group_provider.dart';
import '../../services/navigation_service.dart';
import '../../services/order_service.dart';
import '../../services/shift_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/dark_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/golden_button.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  ShiftModel? _shift;
  String? _myLocation;
  static const _finished = ['delivered', 'cancelled'];

  Future<void> _getLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: 'Нет доступа к геолокации');
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _myLocation =
          '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Геолокация недоступна');
    }
  }

  void _copyAll(List<OrderModel> orders) {
    final text = orders
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value.userName} - ${e.value.userAddress}')
        .join('\n');
    NavigationService.instance.copyToClipboard(text);
  }

  @override
  Widget build(BuildContext context) {
    final group = context.watch<GroupProvider>().group;

    return StreamBuilder<List<ShiftModel>>(
      stream: ShiftService.instance.allShiftsStream(group),
      builder: (context, snap) {
        final shifts = snap.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Выберите смену', style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    value: _shift?.id,
                    hint: Text('Смена...', style: AppTextStyles.body),
                    items: shifts
                        .map((s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(
                                  '${DateFormat('d MMM').format(s.date)} • ${s.label}',
                                  style: AppTextStyles.body),
                            ))
                        .toList(),
                    onChanged: (id) => setState(() =>
                        _shift = shifts.firstWhere((s) => s.id == id)),
                  ),
                  const SizedBox(height: 8),
                  GoldenButton(
                    label: _myLocation == null
                        ? 'Моя локация'
                        : 'Я: $_myLocation',
                    icon: Icons.my_location,
                    onPressed: _getLocation,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_shift == null)
              const EmptyState(
                  icon: Icons.location_on, title: 'Выберите смену выше')
            else
              StreamBuilder<List<OrderModel>>(
                stream: OrderService.instance.ordersByShiftStream(_shift!.id),
                builder: (context, oSnap) {
                  final orders = (oSnap.data ?? [])
                      .where((o) => !_finished.contains(o.status))
                      .toList();
                  if (orders.isEmpty) {
                    return const EmptyState(
                        icon: Icons.check_circle,
                        title: 'Нет адресов для доставки');
                  }
                  return Column(
                    children: [
                      Row(
                        children: [
                          Text('${orders.length} адресов',
                              style: AppTextStyles.headingM),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _copyAll(orders),
                            icon: const Icon(Icons.copy_all, size: 18),
                            label: const Text('Копировать всё'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...orders.asMap().entries.map((e) =>
                          _addressCard(e.key + 1, e.value)),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _addressCard(int n, OrderModel o) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: Text('$n',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  NavigationService.instance.copyToClipboard(o.userAddress),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.userName, style: AppTextStyles.bodyBold),
                  const SizedBox(height: 2),
                  Text(o.userAddress, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.navigation, color: AppColors.primary),
            onPressed: () => NavigationService.instance
                .openGoogleMapsNavigation(o.userAddress),
          ),
        ],
      ),
    );
  }
}
