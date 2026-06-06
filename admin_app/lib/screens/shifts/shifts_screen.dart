import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../models/shift_model.dart';
import '../../providers/group_provider.dart';
import '../../services/order_service.dart';
import '../../services/shift_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gold_badge.dart';
import '../../widgets/golden_button.dart';
import 'shift_detail_screen.dart';

class ShiftsScreen extends StatelessWidget {
  const ShiftsScreen({super.key});

  Future<void> _createShift(BuildContext context, String group) async {
    DateTime date = DateTime.now().add(const Duration(days: 1));
    String selectedGroup = group;
    bool isOpen = true;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Создать смену', style: AppTextStyles.headingM),
              const SizedBox(height: 16),
              Row(
                children: AppConstants.groups.map((g) {
                  final sel = selectedGroup == g;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(AppConstants.groupLabel(g)),
                        selected: sel,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        onSelected: (_) =>
                            setSheet(() => selectedGroup = g),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event, color: AppColors.primary),
                title: Text(DateFormat('EEEE, d MMM yyyy').format(date),
                    style: AppTextStyles.body),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: date,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 1)),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setSheet(() => date = picked);
                  },
                  child: const Text('Выбрать'),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text('Открыта для заказов', style: AppTextStyles.body),
                value: isOpen,
                onChanged: (v) => setSheet(() => isOpen = v),
              ),
              const SizedBox(height: 12),
              GoldenButton(
                label: 'Создать смену',
                onPressed: () async {
                  await ShiftService.instance.addShift(ShiftModel(
                    id: '',
                    group: selectedGroup,
                    date: date,
                    label: ShiftModel.labelFor(date),
                    isOpen: isOpen,
                  ));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить смену?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Удалить',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) await ShiftService.instance.deleteShift(id);
  }

  @override
  Widget build(BuildContext context) {
    final group = context.watch<GroupProvider>().group;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createShift(context, group),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<ShiftModel>>(
        stream: ShiftService.instance.allShiftsStream(group),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final shifts = snap.data ?? [];
          if (shifts.isEmpty) {
            return const EmptyState(
                icon: Icons.event_note, title: 'Нет смен. Нажмите +');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shifts.length,
            itemBuilder: (context, i) => _shiftCard(context, shifts[i]),
          );
        },
      ),
    );
  }

  Widget _shiftCard(BuildContext context, ShiftModel shift) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(DateFormat('d MMM').format(shift.date),
                  style: AppTextStyles.headingL.copyWith(fontSize: 20)),
              const SizedBox(width: 10),
              GoldBadge(text: AppConstants.groupLabel(shift.group)),
              const Spacer(),
              Switch(
                value: shift.isOpen,
                activeColor: AppColors.primary,
                onChanged: (v) =>
                    ShiftService.instance.setOpen(shift.id, v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<OrderModel>>(
            stream: OrderService.instance.ordersByShiftStream(shift.id),
            builder: (context, snap) {
              final count = snap.data?.length ?? 0;
              return Row(
                children: [
                  GoldBadge(text: '$count заказов'),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ShiftDetailScreen(shift: shift)),
                    ),
                    child: const Text('Открыть'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                    onPressed: () => _confirmDelete(context, shift.id),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
