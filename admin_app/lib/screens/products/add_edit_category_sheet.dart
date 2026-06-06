import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../services/product_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/golden_button.dart';

Future<void> showAddEditCategorySheet(
    BuildContext context, CategoryModel? category) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CategorySheet(category: category),
  );
}

class _CategorySheet extends StatefulWidget {
  final CategoryModel? category;
  const _CategorySheet({this.category});

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  late final Map<String, TextEditingController> _names;
  late final TextEditingController _image;
  late final TextEditingController _sort;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _names = {
      for (final code in AppConstants.languageCodes)
        code: TextEditingController(text: c?.name[code] ?? ''),
    };
    _image = TextEditingController(text: c?.imageUrl ?? '');
    _sort = TextEditingController(text: '${c?.sortOrder ?? 0}');
    _active = c?.isActive ?? true;
  }

  @override
  void dispose() {
    for (final c in _names.values) {
      c.dispose();
    }
    _image.dispose();
    _sort.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final names = {
      for (final e in _names.entries) e.key: e.value.text.trim(),
    };
    await ProductService.instance.saveCategory(CategoryModel(
      id: widget.category?.id ?? '',
      name: names,
      imageUrl: _image.text.trim(),
      sortOrder: int.tryParse(_sort.text) ?? 0,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.category == null
                ? 'Новая категория'
                : 'Редактировать категорию',
                style: AppTextStyles.headingM),
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
              height: 80,
              child: TabBarView(
                children: AppConstants.languageCodes
                    .map((code) => Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: AppInputField(
                            controller: _names[code],
                            label: 'Название (${code.toUpperCase()})',
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            AppInputField(controller: _image, label: 'URL картинки'),
            const SizedBox(height: 12),
            AppInputField(
                controller: _sort,
                label: 'Порядок',
                keyboardType: TextInputType.number),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: Text('Активна', style: AppTextStyles.body),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 8),
            GoldenButton(label: 'Сохранить', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
