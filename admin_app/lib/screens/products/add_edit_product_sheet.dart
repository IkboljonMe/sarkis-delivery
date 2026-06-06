import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/golden_button.dart';

Future<void> showAddEditProductSheet(
    BuildContext context, ProductModel? product) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ProductSheet(product: product),
  );
}

class _ProductSheet extends StatefulWidget {
  final ProductModel? product;
  const _ProductSheet({this.product});

  @override
  State<_ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends State<_ProductSheet> {
  late final Map<String, TextEditingController> _names;
  late final Map<String, TextEditingController> _descs;
  late final TextEditingController _price;
  late final TextEditingController _unit;
  late final TextEditingController _maxQty;
  late final TextEditingController _image;
  String? _categoryId;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _names = {
      for (final c in AppConstants.languageCodes)
        c: TextEditingController(text: p?.name[c] ?? ''),
    };
    _descs = {
      for (final c in AppConstants.languageCodes)
        c: TextEditingController(text: p?.description[c] ?? ''),
    };
    _price = TextEditingController(text: p != null ? '${p.price}' : '');
    _unit = TextEditingController(text: p?.unit ?? 'piece');
    _maxQty = TextEditingController(text: '${p?.maxQty ?? 10}');
    _image = TextEditingController(text: p?.imageUrl ?? '');
    _categoryId = p?.categoryId;
    _active = p?.isActive ?? true;
  }

  @override
  void dispose() {
    for (final c in [..._names.values, ..._descs.values]) {
      c.dispose();
    }
    _price.dispose();
    _unit.dispose();
    _maxQty.dispose();
    _image.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ProductService.instance.saveProduct(ProductModel(
      id: widget.product?.id ?? '',
      categoryId: _categoryId ?? '',
      name: {for (final e in _names.entries) e.key: e.value.text.trim()},
      description: {
        for (final e in _descs.entries) e.key: e.value.text.trim()
      },
      price: double.tryParse(_price.text.replaceAll(',', '.')) ?? 0,
      unit: _unit.text.trim(),
      maxQty: int.tryParse(_maxQty.text) ?? 10,
      imageUrl: _image.text.trim(),
      isActive: _active,
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: AppConstants.languageCodes.length,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.product == null ? 'Новый товар' : 'Редактировать товар',
                  style: AppTextStyles.headingM),
              const SizedBox(height: 12),
              StreamBuilder<List<CategoryModel>>(
                stream: ProductService.instance.allCategoriesStream(),
                builder: (context, snap) {
                  final cats = snap.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _categoryId,
                    dropdownColor: AppColors.surfaceElevated,
                    decoration: const InputDecoration(labelText: 'Категория'),
                    items: cats
                        .map((c) => DropdownMenuItem(
                            value: c.id, child: Text(c.nameFor('ru'))))
                        .toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                  );
                },
              ),
              const SizedBox(height: 12),
              TabBar(
                isScrollable: true,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: AppConstants.languageCodes
                    .map((c) => Tab(text: c.toUpperCase()))
                    .toList(),
              ),
              SizedBox(
                height: 160,
                child: TabBarView(
                  children: AppConstants.languageCodes
                      .map((code) => Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              children: [
                                AppInputField(
                                    controller: _names[code],
                                    label: 'Название (${code.toUpperCase()})'),
                                const SizedBox(height: 8),
                                AppInputField(
                                    controller: _descs[code],
                                    label: 'Описание (${code.toUpperCase()})',
                                    maxLines: 2),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: AppInputField(
                        controller: _price,
                        label: 'Цена €',
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true))),
                const SizedBox(width: 8),
                Expanded(
                    child: AppInputField(controller: _unit, label: 'Единица')),
              ]),
              const SizedBox(height: 12),
              AppInputField(
                  controller: _maxQty,
                  label: 'Макс. количество',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              AppInputField(controller: _image, label: 'URL картинки'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text('Активен', style: AppTextStyles.body),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
              const SizedBox(height: 8),
              GoldenButton(label: 'Сохранить', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
