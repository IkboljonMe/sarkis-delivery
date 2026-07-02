import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../models/coupon_model.dart';
import '../../services/coupon_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gold_badge.dart';
import '../../widgets/golden_button.dart';
import '../../widgets/skeletons.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, null),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<CouponModel>>(
        stream: CouponService.instance.couponsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const SimpleCardListSkeleton();
          }
          final coupons = snap.data ?? [];
          if (coupons.isEmpty) {
            return const EmptyState(
                icon: Icons.local_offer_outlined,
                title: 'Нет купонов. Нажмите +');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coupons.length,
            itemBuilder: (context, i) => _card(context, coupons[i]),
          );
        },
      ),
    );
  }

  Widget _card(BuildContext context, CouponModel c) {
    final value =
        c.type == 'percent' ? '${_n(c.value)}%' : '€${_n(c.value)}';
    final parts = <String>[
      if (c.minOrder > 0) 'от €${_n(c.minOrder)}',
      if (c.usageLimit > 0) '${c.usedCount}/${c.usageLimit}',
      if (c.expiresAt != null)
        'до ${DateFormat('d MMM yyyy').format(c.expiresAt!)}',
    ];
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
              Text(c.code, style: AppTextStyles.headingM),
              const SizedBox(width: 10),
              GoldBadge(text: '-$value'),
              const Spacer(),
              Switch(
                value: c.isActive,
                activeColor: AppColors.primary,
                onChanged: (v) =>
                    CouponService.instance.setActive(c.id, v),
              ),
            ],
          ),
          if (parts.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(parts.join(' • '), style: AppTextStyles.caption),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              if (!c.isActive)
                Text('Отключён',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted)),
              const Spacer(),
              TextButton(
                onPressed: () => _edit(context, c),
                child: const Text('Изменить'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _confirmDelete(context, c.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _n(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить купон?'),
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
    if (ok == true) await CouponService.instance.deleteCoupon(id);
  }

  Future<void> _edit(BuildContext context, CouponModel? coupon) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CouponSheet(coupon: coupon),
    );
  }
}

class _CouponSheet extends StatefulWidget {
  final CouponModel? coupon;
  const _CouponSheet({this.coupon});

  @override
  State<_CouponSheet> createState() => _CouponSheetState();
}

class _CouponSheetState extends State<_CouponSheet> {
  late final TextEditingController _code;
  late final TextEditingController _value;
  late final TextEditingController _minOrder;
  late final TextEditingController _usageLimit;
  String _type = 'percent';
  bool _active = true;
  DateTime? _expiresAt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.coupon;
    _code = TextEditingController(text: c?.code ?? '');
    _value = TextEditingController(
        text: (c?.value ?? 0) > 0 ? '${c!.value}' : '');
    _minOrder = TextEditingController(
        text: (c?.minOrder ?? 0) > 0 ? '${c!.minOrder}' : '');
    _usageLimit = TextEditingController(
        text: (c?.usageLimit ?? 0) > 0 ? '${c!.usageLimit}' : '');
    _type = c?.type ?? 'percent';
    _active = c?.isActive ?? true;
    _expiresAt = c?.expiresAt;
  }

  @override
  void dispose() {
    _code.dispose();
    _value.dispose();
    _minOrder.dispose();
    _usageLimit.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  Future<void> _save() async {
    final code = CouponModel.normalize(_code.text);
    if (code.isEmpty) {
      Fluttertoast.showToast(msg: 'Введите код купона');
      return;
    }
    if (_parse(_value) <= 0) {
      Fluttertoast.showToast(msg: 'Введите размер скидки');
      return;
    }
    setState(() => _saving = true);
    try {
      await CouponService.instance.saveCoupon(
        CouponModel(
          id: code,
          code: code,
          type: _type,
          value: _parse(_value),
          minOrder: _parse(_minOrder),
          isActive: _active,
          expiresAt: _expiresAt,
          usageLimit: int.tryParse(_usageLimit.text) ?? 0,
          usedCount: widget.coupon?.usedCount ?? 0,
          createdAt: widget.coupon?.createdAt,
        ),
        previousId: widget.coupon?.id,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        Fluttertoast.showToast(msg: 'Ошибка: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.coupon == null ? 'Новый купон' : 'Изменить купон',
                style: AppTextStyles.headingM),
            const SizedBox(height: 16),
            TextField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              style: AppTextStyles.body,
              decoration: const InputDecoration(labelText: 'Код (напр. SARKIS10)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    dropdownColor: AppColors.surfaceElevated,
                    decoration: const InputDecoration(labelText: 'Тип'),
                    items: const [
                      DropdownMenuItem(
                          value: 'percent', child: Text('Процент %')),
                      DropdownMenuItem(value: 'fixed', child: Text('Сумма €')),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? 'percent'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _value,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                        labelText: _type == 'percent' ? 'Скидка %' : 'Скидка €'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minOrder,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.body,
                    decoration:
                        const InputDecoration(labelText: 'Мин. сумма €'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _usageLimit,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                        labelText: 'Лимит (0 = ∞)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event, color: AppColors.primary),
              title: Text(
                  _expiresAt == null
                      ? 'Без срока действия'
                      : 'До ${DateFormat('d MMM yyyy').format(_expiresAt!)}',
                  style: AppTextStyles.body),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_expiresAt != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _expiresAt = null),
                    ),
                  TextButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _expiresAt ??
                            now.add(const Duration(days: 30)),
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 730)),
                      );
                      if (picked != null) setState(() => _expiresAt = picked);
                    },
                    child: const Text('Выбрать'),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: Text('Активен', style: AppTextStyles.body),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 8),
            GoldenButton(
                label: 'Сохранить', loading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
