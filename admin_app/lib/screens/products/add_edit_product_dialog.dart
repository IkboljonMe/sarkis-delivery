import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../utils/constants.dart';

/// Add or edit a product. Returns the resulting [ProductModel] or null.
class AddEditProductDialog extends StatefulWidget {
  final ProductModel? product;
  const AddEditProductDialog({super.key, this.product});

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _nameControllers;
  late final TextEditingController _priceController;
  late final TextEditingController _unitController;
  late final TextEditingController _maxQtyController;
  late final TextEditingController _imageController;
  bool _isActive = true;

  static const _langLabels = {
    'en': 'English',
    'hy': 'Հայերեն',
    'ru': 'Русский',
    'tr': 'Türkçe',
    'de': 'Deutsch',
  };

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameControllers = {
      for (final code in AppConstants.languageCodes)
        code: TextEditingController(text: p?.name[code] ?? ''),
    };
    _priceController =
        TextEditingController(text: p != null ? p.price.toString() : '');
    _unitController = TextEditingController(text: p?.unit ?? 'piece');
    _maxQtyController =
        TextEditingController(text: p != null ? p.maxQty.toString() : '10');
    _imageController = TextEditingController(text: p?.imageUrl ?? '');
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    for (final c in _nameControllers.values) {
      c.dispose();
    }
    _priceController.dispose();
    _unitController.dispose();
    _maxQtyController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final names = <String, String>{
      for (final entry in _nameControllers.entries)
        entry.key: entry.value.text.trim(),
    };
    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: names,
      price: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0,
      unit: _unitController.text.trim(),
      maxQty: int.tryParse(_maxQtyController.text) ?? 10,
      isActive: _isActive,
      imageUrl: _imageController.text.trim(),
    );
    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null
          ? 'Новый товар'
          : 'Редактировать товар'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...AppConstants.languageCodes.map((code) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextFormField(
                        controller: _nameControllers[code],
                        decoration: InputDecoration(
                            labelText: 'Название (${_langLabels[code]})'),
                        validator: code == 'ru'
                            ? (v) => (v == null || v.trim().isEmpty)
                                ? 'Обязательно'
                                : null
                            : null,
                      ),
                    )),
                TextFormField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Цена (EUR)'),
                  validator: (v) =>
                      (v == null || double.tryParse(v.replaceAll(',', '.')) ==
                              null)
                          ? 'Цена?'
                          : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _unitController,
                  decoration:
                      const InputDecoration(labelText: 'Единица (piece/pack)'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _maxQtyController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Макс. количество'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(
                      labelText: 'URL картинки (необязательно)'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Активен'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Сохранить')),
      ],
    );
  }
}
