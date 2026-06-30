import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/golden_button.dart';

/// Real product-photo manager: upload a main photo + up to 3 extras, view each,
/// edit its per-language title, set the main one, or remove it.
class ProductPhotoManager extends StatefulWidget {
  final List<ProductPhoto> photos;
  final ValueChanged<List<ProductPhoto>> onChanged;
  final int maxPhotos;

  const ProductPhotoManager({
    super.key,
    required this.photos,
    required this.onChanged,
    this.maxPhotos = 4,
  });

  @override
  State<ProductPhotoManager> createState() => _ProductPhotoManagerState();
}

class _ProductPhotoManagerState extends State<ProductPhotoManager> {
  bool _uploading = false;

  List<ProductPhoto> get _photos => widget.photos;

  Future<void> _addPhoto() async {
    if (_photos.length >= widget.maxPhotos) {
      Fluttertoast.showToast(msg: 'Максимум ${widget.maxPhotos} фото');
      return;
    }
    final source = await _pickSource();
    if (source == null) return;
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
          source: source, maxWidth: 1600, imageQuality: 82);
      if (file == null) return;
      setState(() => _uploading = true);
      final bytes = await file.readAsBytes();
      final ext = file.name.contains('.')
          ? file.name.split('.').last.toLowerCase()
          : 'jpg';
      final url = await ProductService.instance.uploadProductImage(
        bytes,
        ext: ext == 'png' ? 'png' : 'jpg',
        contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
      );
      final next = [..._photos, ProductPhoto(url: url)];
      widget.onChanged(next);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Ошибка загрузки: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<ImageSource?> _pickSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: Text('Из галереи', style: AppTextStyles.body),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: Text('Камера', style: AppTextStyles.body),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  void _setMain(int index) {
    if (index <= 0) return;
    final next = [..._photos];
    final p = next.removeAt(index);
    next.insert(0, p);
    widget.onChanged(next);
  }

  void _remove(int index) {
    final removed = _photos[index];
    final next = [..._photos]..removeAt(index);
    widget.onChanged(next);
    // Best-effort cleanup of the stored file.
    ProductService.instance.deleteImageByUrl(removed.url);
  }

  void _updateTitle(int index, Map<String, String> title) {
    final next = [..._photos];
    next[index] = next[index].copyWith(title: title);
    widget.onChanged(next);
  }

  Future<void> _openPhoto(int index) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PhotoEditorSheet(
        photo: _photos[index],
        isMain: index == 0,
        onSetMain: () {
          Navigator.pop(ctx);
          _setMain(index);
        },
        onRemove: () {
          Navigator.pop(ctx);
          _remove(index);
        },
        onTitleChanged: (title) => _updateTitle(index, title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Фотографии', style: AppTextStyles.body),
            const SizedBox(width: 6),
            Text('(1 главное + до ${widget.maxPhotos - 1} доп.)',
                style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < _photos.length; i++) _thumb(i),
            if (_photos.length < widget.maxPhotos) _addTile(),
          ],
        ),
      ],
    );
  }

  Widget _thumb(int index) {
    final photo = _photos[index];
    final isMain = index == 0;
    return GestureDetector(
      onTap: () => _openPhoto(index),
      child: Stack(
        children: [
          Container(
            width: 84,
            height: 84,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isMain ? AppColors.primary : AppColors.border,
                  width: isMain ? 2 : 1),
            ),
            child: CachedNetworkImage(
              imageUrl: photo.url,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.surface),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.broken_image, color: AppColors.textMuted),
            ),
          ),
          if (isMain)
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(8)),
                ),
                child: const Text('Главное',
                    style: TextStyle(
                        fontSize: 9,
                        color: Colors.black,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          const Positioned(
            right: 2,
            top: 2,
            child: Icon(Icons.edit, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _addTile() {
    return GestureDetector(
      onTap: _uploading ? null : _addPhoto,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: _uploading
            ? const Center(
                child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary)))
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      color: AppColors.primary),
                  SizedBox(height: 4),
                  Text('Добавить',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
      ),
    );
  }
}

/// Per-photo editor: preview, per-language title, set-main and remove actions.
class _PhotoEditorSheet extends StatefulWidget {
  final ProductPhoto photo;
  final bool isMain;
  final VoidCallback onSetMain;
  final VoidCallback onRemove;
  final ValueChanged<Map<String, String>> onTitleChanged;

  const _PhotoEditorSheet({
    required this.photo,
    required this.isMain,
    required this.onSetMain,
    required this.onRemove,
    required this.onTitleChanged,
  });

  @override
  State<_PhotoEditorSheet> createState() => _PhotoEditorSheetState();
}

class _PhotoEditorSheetState extends State<_PhotoEditorSheet> {
  late final Map<String, TextEditingController> _titles;

  @override
  void initState() {
    super.initState();
    _titles = {
      for (final c in AppConstants.languageCodes)
        c: TextEditingController(text: widget.photo.title[c] ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _titles.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _commit() {
    final title = {
      for (final e in _titles.entries)
        if (e.value.text.trim().isNotEmpty) e.key: e.value.text.trim(),
    };
    widget.onTitleChanged(title);
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
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: widget.photo.url,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(height: 200, color: AppColors.surface),
                  errorWidget: (_, __, ___) => Container(
                      height: 200,
                      color: AppColors.surface,
                      child: const Icon(Icons.broken_image,
                          color: AppColors.textMuted)),
                ),
              ),
              const SizedBox(height: 12),
              Text('Название фото (по языку)', style: AppTextStyles.body),
              const SizedBox(height: 8),
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
                height: 90,
                child: TabBarView(
                  children: AppConstants.languageCodes
                      .map((code) => Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: AppInputField(
                              controller: _titles[code]!,
                              label: 'Название (${code.toUpperCase()})',
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (!widget.isMain)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _commit();
                          widget.onSetMain();
                        },
                        icon: const Icon(Icons.star_outline,
                            color: AppColors.primary, size: 18),
                        label: Text('Сделать главным',
                            style: AppTextStyles.caption),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  if (!widget.isMain) const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onRemove,
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error, size: 18),
                      label: Text('Удалить',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GoldenButton(
                label: 'Готово',
                onPressed: () {
                  _commit();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
